# SCA Remediation — Windows Agent

## Overview

Used the Wazuh Security Configuration Assessment (SCA) module to benchmark the Windows PC against the CIS Microsoft Windows 11 Enterprise benchmark, then systematically remediated failed checks over multiple sessions.

## Score Progression

| Stage | Failed Checks |
|-------|--------------|
| Baseline | 261 |
| After initial hardening | 169 |
| After full remediation | 40 |

The 40 remaining failures are all documented intentional exceptions — see [SCA Exceptions](sca-exceptions.md).

## What is SCA?

SCA runs a set of policy checks against the endpoint configuration and reports each check as passed, failed, or not applicable. The CIS benchmark provides industry-standard hardening guidance across hundreds of configuration points covering account policy, network hardening, privacy, telemetry, services, and more.

## Remediation Approach

Checks were organized into logical batches and applied via PowerShell (registry edits, service changes, audit policy) and `net accounts` commands. Each batch was followed by a Wazuh agent restart to trigger a rescan and confirm results.

### Batch A — Credential and Logon Security
Applied security options for credential caching, interactive logon behavior, and account security via registry edits under `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system` and related keys.

### Batch B — Network and TCP/IP Hardening
Checks: 26185, 26187, 26190–26196, 26199–26203, 26205, 26208–26212, 26214–26218

Disabled NetBIOS over TCP/IP, LLMNR, mDNS, and applied TCP/IP stack hardening via registry edits under `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters` and related keys.

### Batch C — System, Privacy, and UI
Applied system behavior, privacy, and UI hardening settings covering screen saver timeout, lock behavior, and related policies.

### Batch D — Privacy and Telemetry
Checks applied: 26282, 26287, 26288, 26294–26301, 26316, 26352–26355, 26357

Disabled telemetry collection, diagnostic data upload, advertising ID, and activity history via registry edits under `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` and related keys.

### Batch E — Windows Defender and ASR
Applied core Windows Defender hardening settings. ASR rule configuration (26321) was skipped due to anti-cheat software compatibility — see [SCA Exceptions](sca-exceptions.md).

### Batch F — RDP and Terminal Services
Applied Remote Desktop hardening including NLA enforcement and encryption level requirements.

### Batch G — WinRM and Remote Shell
Applied all WinRM and Windows Remote Shell restrictions to disable remote management attack surface.

### Batch H — System, UI, and Miscellaneous
Applied remaining system configuration checks covering Windows Update behavior, user interface settings, and miscellaneous policy hardening.

### Batch I — Microsoft Store and Apps
- **26362** — Disabled the offer to upgrade to the latest version of Windows:
```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v DisableOSUpgrade /t REG_DWORD /d 1 /f
```

## Triggering a Rescan

After applying changes, restart the Wazuh agent service to force a new SCA scan:

```powershell
Restart-Service -Name WazuhSvc
```

Results appear in the Wazuh dashboard under **Security Configuration Assessment** within 1–2 minutes.

## Key Takeaways

- SCA remediation is an iterative process — changes should be applied in small batches and verified before moving on
- Not every failed check should be remediated blindly; each one requires judgment about the risk it addresses versus the impact on the system's intended use
- Documenting exceptions with rationale is as important as the fixes themselves — it demonstrates that the remaining failures are informed decisions, not oversights
