# Homelab

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Ryan%20Cruz-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ryanjordancruz/)

A cybersecurity homelab built on a 2015 MacBook Pro running Proxmox VE. Designed to gain hands-on experience with SIEM deployment, endpoint hardening, and network analysis — core skills for a SOC analyst role.

## Hardware

| Component | Details |
|-----------|---------|
| Host | 2015 MacBook Pro, 8GB RAM |
| Hypervisor | Proxmox VE |
| Network | USB Ethernet adapter (Realtek RTL8153) via network switch |
| Storage | Internal SSD + 1TB USB external drive |

## Network Layout

| Device | IP |
|--------|----|
| Proxmox Host | `<PROXMOX_HOST_IP>` |
| Wazuh Manager VM | `<WAZUH_MANAGER_IP>` |
| Windows PC (monitored endpoint) | `<WINDOWS_PC_IP>` |

## Virtual Machines

| VM | ID | Purpose |
|----|----|---------|
| Kali Linux | 100 | Penetration testing and network analysis |
| Wazuh Manager | 101 | SIEM and security monitoring |

## Projects

| # | Project | Category |
|---|---------|----------|
| 1 | [Proxmox Installation on MacBook Pro](infrastructure/proxmox-installation.md) | Infrastructure |
| 2 | [Proxmox Web UI Troubleshooting](infrastructure/proxmox-webui-troubleshooting.md) | Infrastructure |
| 3 | [1TB External Drive as Proxmox Directory Storage](infrastructure/external-drive-storage.md) | Infrastructure |
| 4 | [Kali Linux VM Setup](vms/kali-linux-setup.md) | VM |
| 5 | [Wazuh Manager Installation](vms/wazuh-manager-installation.md) | SIEM |
| 6 | [Wazuh Agent Installation](wazuh/wazuh-agent-installation.md) | SIEM |
| 7 | [Wazuh Manager Password Reset](wazuh/wazuh-manager-password-reset.md) | SIEM |
| 8 | [Nmap Network Scanning](network-analysis/nmap-tutorial.md) | Network Analysis |
| 9 | [Wireshark Network Analysis](network-analysis/wireshark-packet-analysis.md) | Network Analysis |
| 10 | [SCA Remediation — Windows Agent](hardening/sca-remediation.md) | Hardening |
| 11 | [Detection Gap: Nmap Scan Not Visible in Wazuh (Find, Fix, Verify)](detection/detection-gap-nmap-scan.md) | Detection Engineering |
| 12 | [Alert Triage: Wazuh Rule 60227, External Device Recognized](detection/alert-triage-rule-60227.md) | Alert Triage |
| 13 | [Access Mapping: Find and Fix an Over-Shared Folder (NTFS)](access-control/ntfs-access-mapping-lab.md) | Access Control |

## Skills Demonstrated

- Hypervisor deployment and VM management (Proxmox VE)
- SIEM deployment and configuration (Wazuh)
- Endpoint agent deployment and monitoring
- Network scanning and analysis (nmap, Wireshark)
- CIS benchmark remediation and Windows endpoint hardening
- Linux system administration and troubleshooting
- Documenting security decisions and exceptions with rationale
- Detection gap analysis: Windows audit policy, agent log collection filters, end-to-end pipeline verification
- Alert triage, root cause analysis, and MITRE ATT&CK mapping
- Access mapping and least-privilege remediation: NTFS ACL analysis (icacls, Get-Acl), scripted permission scans

## Certifications

- CompTIA Security+ (March 2026)
- Google Cybersecurity Certificate (November 2025)
