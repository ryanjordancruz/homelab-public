# Detection Gap: Nmap Scan Not Visible in Wazuh (Find, Fix, Verify)

## Summary

| Field | Details |
|-------|---------|
| Dates | Found 2026-08-10, closed 2026-08-30 |
| Source | Kali Linux (vm-100) |
| Target | Windows PC with the Wazuh agent (`<WINDOWS_AGENT_NAME>` / `<WINDOWS_PC_IP>`) |
| Technique | T1046 Network Service Discovery (T1595.001 from the scanner's side) |
| Before | 0 Wazuh alerts across a full 24 hour search |
| After | 40 to 50 alerts per scan |

An authorized Nmap scan from my Kali VM against my monitored Windows endpoint produced zero Wazuh alerts. I documented the gap, then came back and traced it through several layers until the full pipeline worked: Windows audit policy, then Wazuh agent forwarding, then manager rule matching, then the indexer, then the dashboard.

---

## Part 1: Finding the Gap (2026-08-10)

### Test

```bash
nmap <WINDOWS_PC_IP>
```

The scan finished in about 22 seconds. Windows Firewall silently dropped every probe, so all 1000 default TCP ports showed as **filtered**. The firewall was doing its job.

### Detection Check

Nothing appeared in Wazuh during the scan window. To rule out a timing or indexing delay, I widened the search to the previous 24 hours and searched for:

- Windows Filtering Platform event IDs **5156** (connection allowed) and **5157** (connection blocked)
- Free text "firewall" and "nmap"

There were zero results across the whole index. That event category was not reaching Wazuh at all.

### First Root Cause

Windows only logs firewall connection events if the **Audit Filtering Platform Connection** advanced audit subcategory is enabled. It is off by default, and my earlier [SCA hardening work](../hardening/sca-remediation.md) never touched it.

Leaving it off is often deliberate in real environments. At the Success level it logs every permitted connection, which can mean thousands of events per hour on a busy host. I recorded it as a known coverage gap and came back to fix it.

---

## Part 2: Fixing It (2026-08-30)

The fix turned out to need several layers of troubleshooting, not one setting.

### Step 1: Enable the audit policy

From an admin PowerShell on the Windows endpoint:

```powershell
auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:enable
auditpol /get /subcategory:"Filtering Platform Connection"
```

I re-ran the scan. The firewall behaved the same (correct, since only logging changed), but before I could check for alerts, the Wazuh dashboard broke.

### Step 2: Dashboard down because the VM was out of memory

The dashboard showed a "pattern handler" error. The Proxmox host (8 GB total) was running both Kali and the Wazuh manager, and the Wazuh VM was down to about 112 MiB of free memory with heavy swap use.

- Shut down Kali to free host memory.
- Raised the Wazuh VM's allocation from 4 GiB to 6 GiB. This needed a full VM stop and start in Proxmox, not just a reboot inside the guest, because memory hotplug isn't configured.
- Result: about 3.8 GiB available inside the VM.

**Lesson:** Proxmox VMs get a fixed memory allocation. Stopping a sibling VM frees room on the host, but it doesn't raise a running VM's own ceiling.

### Step 3: Indexer failing on a systemd timeout

`wazuh-indexer` then failed with "start operation timed out." OpenSearch's startup and index recovery on this hardware (the VM disk is on a USB external drive) took longer than systemd's default 3 minute limit.

I added a drop-in override instead of editing the vendor unit file:

```ini
# /etc/systemd/system/wazuh-indexer.service.d/override.conf
[Service]
TimeoutStartSec=900
```

```bash
sudo systemctl daemon-reload
sudo systemctl start wazuh-indexer
```

The indexer started cleanly. The dashboard showed one more transient error (the Wazuh API on port 55000 timing out while it caught up after the restart), which cleared on its own after a short wait.

### Step 4: Still zero alerts, so isolate the layer

Everything was healthy and the agent showed Active, but a new scan still produced no alerts. I checked the endpoint directly:

- **Event Viewer, Security log, Event ID 5157:** many entries. Windows **was** logging the blocked connections.

That ruled out Windows, the manager, and the indexer. The problem had to be in the **agent**.

### Step 5: The real root cause, an agent filter

The agent's config file (`C:\Program Files (x86)\ossec-agent\ossec.conf`) collects the Security event channel through an XPath query that excludes a list of noisy event IDs. **5157 was on that exclusion list**, grouped together with 5156.

- **5156 (allowed connection)** should stay excluded. It fires on every normal connection and is pure noise.
- **5157 (blocked connection)** is the signal you want for scan detection.

I removed only `EventID != 5157` from the query and kept 5156 excluded. Because the file is under Program Files, I edited it in an elevated editor.

### Step 6: Restart the agent

`Restart-Service -Name Wazuh` failed with "cannot open service." "Wazuh" is only the display name. I found the real service name first:

```powershell
Get-Service | Where-Object { $_.Name -like "*wazuh*" }
Restart-Service -Name WazuhSvc
```

---

## Part 3: Verifying (2026-08-30)

I re-ran the same scan from Kali:

```bash
nmap <WINDOWS_PC_IP>
```

**Result: 40 to 50 alerts in Wazuh**, confirming the whole pipeline now works for this technique.

---

## Side Issue: Dashboard Login After the Restarts

After the indexer restarts, the dashboard login started failing. I reset the admin password with `wazuh-passwords-tool.sh` (see [Wazuh Manager Password Reset](../wazuh/wazuh-manager-password-reset.md)), but login only worked after I also restarted `wazuh-dashboard`, `filebeat`, and `wazuh-manager`. Services that were already connected kept the old credential until they reconnected. The tool's own output warns about this.

---

## MITRE ATT&CK

| Technique | ID | Coverage |
|-----------|----|----------|
| Network Service Discovery | T1046 | None before, detected after |
| Active Scanning: Scanning IP Blocks | T1595.001 | Scanner's view of the same activity |

---

## Lessons Learned

1. **Confirm the log at the source before blaming the pipeline.** Event Viewer showed Windows was logging 5157, which narrowed the problem to the agent in one step.
2. **Default configs can silently drop the event you need.** The agent's template grouped a noisy event (5156) with a useful one (5157). It's worth checking the agent's collection filter any time one specific event type never shows up.
3. **Fix noise with precision.** I kept 5156 excluded and only let 5157 through, so I got scan visibility without flooding the index with every allowed connection.
4. **Infrastructure problems surface during security work.** Memory limits and a service timeout had to be fixed before the detection itself could be tested.

## Possible Next Steps

- Add a Wazuh rule that correlates a burst of 5157 events from one source IP into a single higher-severity "possible port scan" alert.
- Add a network sensor (for example Suricata), which is the more standard way to detect scans in production regardless of endpoint audit settings.
