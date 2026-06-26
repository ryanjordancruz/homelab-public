# Wazuh Agent Installation — Windows Endpoint

## Overview

Installed the Wazuh agent on the Windows PC to enable security monitoring, log collection, and SCA policy checking via the Wazuh Manager.

## Environment

| Device | Role | IP |
|--------|------|----|
| Wazuh Manager VM | SIEM | `<WAZUH_MANAGER_IP>` |
| Windows PC | Monitored endpoint | `<WINDOWS_PC_IP>` |

## Installation Steps

### 1. Download the Wazuh Windows agent

- In the Wazuh dashboard, navigate to **Agents → Deploy New Agent**
- Select **Windows** as the OS
- Copy the generated PowerShell installation command, which includes the manager IP pre-configured

### 2. Run the installer on the Windows PC

Open PowerShell as Administrator and run the command from the dashboard. It follows this pattern:

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x.x-1.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="<WAZUH_MANAGER_IP>" WAZUH_AGENT_NAME="Windows-PC"
```

### 3. Start the Wazuh agent service

```powershell
NET START WazuhSvc
```

### 4. Verify in the Wazuh dashboard

- Navigate to **Agents** in the Wazuh dashboard
- Confirm the Windows PC appears with status **Active**

## What the Agent Monitors

| Capability | Description |
|------------|-------------|
| Log collection | Windows Event Logs (Security, System, Application) |
| SCA | CIS benchmark policy checks against the Windows configuration |
| File integrity monitoring | Detects changes to monitored files and directories |
| Vulnerability detection | Identifies known CVEs in installed software |

## Key Takeaways

- The Wazuh dashboard generates a pre-configured install command that automatically points the agent at the correct manager IP — no manual config file editing needed
- The agent must be able to reach the Wazuh Manager on port 1514 (UDP/TCP) — ensure firewall rules allow this
- Agent status updates in the dashboard within a minute of the service starting
