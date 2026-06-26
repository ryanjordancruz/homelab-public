# Kali Linux VM Setup

## Overview

Deployed a Kali Linux VM (vm-100) on Proxmox to serve as the attack/analysis platform for the homelab. Kali provides a full suite of penetration testing and network analysis tools out of the box.

## VM Details

| Property | Value |
|----------|-------|
| VM ID | 100 |
| OS | Kali Linux |
| Storage | local-lvm |
| Snapshot | `vm-100-state-Fresh_Install` (~9GB) |

## Installation Steps

### 1. Download the Kali Linux ISO

- Downloaded the Kali Linux installer ISO from [kali.org](https://www.kali.org/get-kali/)

### 2. Upload ISO to Proxmox

- In the Proxmox web UI: **local → ISO Images → Upload**
- Uploaded the Kali Linux ISO

### 3. Create the VM

- **Proxmox web UI → Create VM**
- Assigned VM ID 100
- Selected the Kali ISO as the boot media
- Configured disk, CPU, and RAM resources
- Started the VM and completed the Kali Linux installation wizard

### 4. Take a fresh install snapshot

After completing the base installation and confirming the system was stable, a snapshot was taken to preserve the clean state:

- **Proxmox web UI → vm-100 → Snapshots → Take Snapshot**
- Name: `Fresh_Install`

This allows rolling back to a known-good state at any time.

## Tools Used From This VM

- **nmap** — network scanning and host discovery
- **Wireshark** — packet capture and traffic analysis

## Key Takeaways

- Taking a snapshot immediately after a clean install is a best practice — it provides a reliable rollback point before making changes
- Kali Linux in a Proxmox VM gives a safe, isolated environment for running network tools without affecting the host or other VMs
