# 1TB External Drive as Proxmox Directory Storage

## Overview

Added a 1TB USB external drive to Proxmox as a directory storage target to expand available storage for VM disks, ISOs, and backups. This resolved a critical issue where `local-lvm` reached 100% capacity, causing I/O errors on the Wazuh Manager VM.

## Drive Details

| Property | Value |
|----------|-------|
| Capacity | 1TB |
| Format | ext4 |
| Mount Point | `/mnt/external` |
| Proxmox Storage ID | `external-storage` |
| Content Types | ISO, backup, disk image, container template |
| Available Space | ~870GB |

## Setup Steps

### 1. Identify the drive

```bash
lsblk
```

### 2. Format as ext4

```bash
mkfs.ext4 /dev/sdX   # replace sdX with actual device name
```

### 3. Get the UUID

```bash
blkid /dev/sdX
```

### 4. Create the mount point and persist via fstab

```bash
mkdir -p /mnt/external
```

Add to `/etc/fstab`:

```
UUID=<your-uuid>  /mnt/external  ext4  defaults  0  2
```

Apply immediately:

```bash
mount -a
```

### 5. Add to Proxmox as directory storage

In the Proxmox web UI:
- **Datacenter → Storage → Add → Directory**
- ID: `external-storage`
- Directory: `/mnt/external`
- Content: Disk image, ISO image, VZDump backup file, Container template

## Outcome

- Wazuh Manager VM disk (vm-101) migrated from `local-lvm` to `external-storage`
- `local-lvm` usage dropped from 100% to ~38%
- I/O errors resolved and Wazuh Manager VM returned to stable operation

## Key Takeaways

- Proxmox `local-lvm` uses a thin-provisioned LVM pool — when it fills up, VMs experience I/O errors that can destabilize running workloads
- Directory storage on an external drive is a fast, low-cost way to expand a homelab's capacity
- Always use UUID in `/etc/fstab` rather than device names like `/dev/sdX`, which can change between reboots
