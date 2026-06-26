# Wazuh Manager Installation

## Overview

Deployed a Wazuh Manager VM (vm-101) on Proxmox to serve as the SIEM for the homelab. Wazuh provides log collection, security event correlation, SCA policy checking, and a web-based dashboard.

## VM Details

| Property | Value |
|----------|-------|
| VM ID | 101 |
| IP Address | `<WAZUH_MANAGER_IP>` |
| Dashboard URL | `https://<WAZUH_MANAGER_IP>` |
| Storage | external-storage (migrated from local-lvm) |

## Installation Method

Used the Wazuh all-in-one installer, which deploys the Wazuh Manager, Wazuh Indexer, and Wazuh Dashboard on a single VM.

### 1. Create VM in Proxmox

- Downloaded the Wazuh OVA or a compatible Linux ISO (Ubuntu/CentOS)
- Created a new VM in Proxmox with sufficient resources (2+ vCPUs, 4GB+ RAM recommended)
- Attached the disk to `external-storage` to avoid filling `local-lvm`

### 2. Run the Wazuh all-in-one installer

```bash
curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

### 3. Access the dashboard

- Navigate to `https://<WAZUH_MANAGER_IP>` in a browser
- Log in with the admin credentials generated during installation

## Components Installed

| Component | Purpose |
|-----------|---------|
| Wazuh Manager | Receives and processes agent data |
| Wazuh Indexer | Stores and indexes security events (OpenSearch-based) |
| Wazuh Dashboard | Web UI for viewing alerts, SCA results, and agent status |

## Post-Installation

- Reset the admin password — see [Wazuh Manager Password Reset](../wazuh/wazuh-manager-password-reset.md)
- Deployed Windows agent — see [Wazuh Agent Installation](../wazuh/wazuh-agent-installation.md)
- Confirmed agent appearing as active in the dashboard

## Key Takeaways

- The Wazuh all-in-one installer is the fastest way to get a full SIEM stack running in a homelab
- Running Wazuh on a dedicated VM keeps it isolated from the monitored endpoints
- Migrating the VM disk to external storage early prevents storage capacity issues as log data grows
