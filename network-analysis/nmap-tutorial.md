# Nmap Network Scanning

## Overview

Used nmap from the Kali Linux VM to perform network scanning and host discovery across the homelab environment. nmap is a core tool for network reconnaissance and is widely used in both offensive and defensive security roles.

## Environment

| Device | IP |
|--------|----|
| Kali Linux (scanning from) | VM on Proxmox host |
| Proxmox Host | `<PROXMOX_HOST_IP>` |
| Wazuh Manager | `<WAZUH_MANAGER_IP>` |
| Windows PC | `<WINDOWS_PC_IP>` |
| Network Range | `<YOUR_SUBNET>/24` |

## Scans Performed

### Host Discovery — identify live hosts on the network

```bash
nmap -sn <YOUR_SUBNET>/24
```

### SYN Scan — fast, stealthy port scan of a target

```bash
nmap -sS <TARGET_IP>
```

### Service and Version Detection

```bash
nmap -sV <TARGET_IP>
```

### OS Detection

```bash
nmap -O <TARGET_IP>
```

### Full scan — OS detection, version detection, script scanning

```bash
nmap -A <TARGET_IP>
```

## Key Findings

<!-- Add your specific scan results and observations here -->

## Observations in Wazuh

Running nmap scans against monitored endpoints generates security alerts in the Wazuh dashboard. This demonstrates how network reconnaissance activity appears from a defender's perspective — correlating offensive actions with SIEM detections is a core SOC analyst skill.

## Key Takeaways

- nmap SYN scans (`-sS`) require root/sudo privileges on Linux
- Service version detection (`-sV`) provides significantly more useful information than a plain port scan
- Network scans generate detectable traffic — running them in a lab environment and observing the resulting Wazuh alerts provides hands-on experience with both sides of the detection equation
