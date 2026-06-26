# Proxmox Web UI Troubleshooting

## Problem

After installing Proxmox VE on the MacBook Pro, the web UI at `https://<PROXMOX_HOST_IP>:8006` was unreachable from the Windows PC on the same network.

## Environment

| Device | IP |
|--------|----|
| Proxmox Host | `<PROXMOX_HOST_IP>` |
| Windows PC | `<WINDOWS_PC_IP>` |
| Gateway | `<GATEWAY_IP>` |

Both devices are connected via Ethernet to a network switch, which connects to the wall jack.

## Root Cause

The USB Ethernet adapter (Realtek RTL8153, driver: `r8152`) was not loading its kernel module automatically at boot. Without the driver, the `vmbr0` bridge had no active NIC to bridge to, leaving the Proxmox host unreachable from the network.

## Fix

### 1. Persist the r8152 driver across reboots

```bash
echo "r8152" >> /etc/modules-load.d/r8152.conf
```

### 2. Configure a static IP via vmbr0

Edit `/etc/network/interfaces`:

```
auto lo
iface lo inet loopback

auto nic0
iface nic0 inet manual

auto vmbr0
iface vmbr0 inet static
    address <PROXMOX_HOST_IP>/24
    gateway <GATEWAY_IP>
    bridge-ports nic0
    bridge-stp off
    bridge-fd 0
```

### 3. Restart networking

```bash
systemctl restart networking
```

## Verification

- Proxmox web UI accessible at `https://<PROXMOX_HOST_IP>:8006` from the Windows PC
- Static IP and driver persist across reboots

## Key Takeaways

- Proxmox bridges all VM network traffic through a virtual bridge (`vmbr0`) — if the underlying NIC driver isn't loaded at boot, the bridge has nothing to work with and the host becomes unreachable
- USB Ethernet adapters may require manual driver persistence on Proxmox
- Always assign a static IP to the Proxmox host to ensure consistent access after reboots
