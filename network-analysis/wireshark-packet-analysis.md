# Wireshark Network Analysis and Packet Sniffing

## Overview

Used Wireshark to capture and analyze network traffic within the homelab environment. Wireshark provides deep visibility into network protocols and is an essential tool for both network troubleshooting and security analysis.

## Environment

| Device | IP |
|--------|----|
| Kali Linux (capturing from) | VM on Proxmox host |
| Network Range | `<YOUR_SUBNET>/24` |

## Captures Performed

### Start a capture on the active interface

In Wireshark, select the active network interface and click **Start Capture**, or from the terminal:

```bash
wireshark &
```

Or use `tshark` for command-line captures:

```bash
sudo tshark -i eth0 -w capture.pcap
```

### Useful display filters

| Filter | Purpose |
|--------|---------|
| `ip.addr == <WINDOWS_PC_IP>` | Traffic to/from the Windows PC |
| `tcp.port == 443` | HTTPS traffic |
| `dns` | DNS queries and responses |
| `icmp` | Ping/ICMP traffic |
| `http` | Unencrypted HTTP traffic |
| `tcp.flags.syn == 1` | TCP SYN packets (connection attempts) |

## Analysis Performed

<!-- Add your specific capture findings and observations here -->

## Key Takeaways

- Packet captures provide ground truth about what is actually traversing the network — useful for validating firewall rules, diagnosing connectivity issues, and identifying unexpected traffic
- Running nmap scans (see [nmap tutorial](nmap-tutorial.md)) while capturing in Wireshark makes the scan traffic visible in real time, building an intuition for what reconnaissance looks like at the packet level
- Wireshark display filters are essential for isolating relevant traffic from high-volume captures
