# Proxmox VE Installation on MacBook Pro (2015)

## Hardware

| Component | Details |
|-----------|---------|
| Model | MacBook Pro (2015) |
| RAM | 8GB |
| Storage | Internal SSD |
| Network | USB Ethernet adapter (Realtek RTL8153) |

## Overview

Proxmox VE was installed on a repurposed 2015 MacBook Pro to serve as a bare-metal hypervisor for running cybersecurity lab VMs. Using existing hardware kept costs at zero while providing enough resources to run multiple VMs simultaneously.

## Installation Steps

1. Downloaded Proxmox VE ISO from [proxmox.com](https://www.proxmox.com/en/downloads)
2. Flashed ISO to a USB drive using Balena Etcher
3. Booted the MacBook Pro from USB by holding the **Option key** at startup to access the boot menu
4. Completed the Proxmox VE installation wizard:
   - Selected internal SSD as the target disk
   - Set hostname, root password, and initial network settings
5. Rebooted into Proxmox VE

## Post-Installation Configuration

- Accessed Proxmox web UI at `https://<host-ip>:8006`
- Resolved USB Ethernet adapter connectivity issue — see [Proxmox Web UI Troubleshooting](proxmox-webui-troubleshooting.md)
- Added 1TB external USB drive for additional storage — see [External Drive Setup](external-drive-storage.md)
- Configured Mac to stay awake with the lid closed so VMs remain running unattended

## Notes

- The MacBook Pro's built-in Wi-Fi is not used — all traffic goes through the USB Ethernet adapter
- Proxmox does not officially support Mac hardware but installs and runs reliably on the 2015 model
