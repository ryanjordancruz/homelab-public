# SCA Exceptions — Documented Intentional Failures

## Overview

40 SCA checks remain failed after remediation. Each is a documented, intentional exception with a specific rationale. These are not oversights — they reflect deliberate decisions based on the endpoint's role as a personal gaming, streaming, and printing workstation.

---

## Not Applicable — Standalone Machine

These checks are designed for domain-joined machines and do not apply to a standalone home PC.

| Check | Description | Reason |
|-------|-------------|--------|
| 26004 | Password complexity via AD policy | Uses `Get-ADDefaultDomainPasswordPolicy` — AD cmdlet, N/A on standalone |
| 26011 | Guest account disabled | Account was renamed to `LocalGuest`; Wazuh checks for the name "guest" specifically |
| 26023 | Domain machine account password age | Domain-only setting, N/A on standalone |
| 26176–26181 | LAPS (Local Admin Password Solution) | Enterprise feature requiring AD infrastructure |

---

## Gaming and Xbox

This PC is used for gaming with an Xbox controller, wireless headset (USB dongle), and Xbox Game Pass. Applying these checks would break gaming functionality.

| Check | Description | Reason |
|-------|-------------|--------|
| 26091 | Disable Print Spooler | Kept enabled — printer is in active use |
| 26115 | Disable XboxGipSvc | Kept enabled — required for Xbox controller support |
| 26116 | Disable XblAuthManager | Kept enabled — required for Xbox Live authentication |
| 26117 | Disable XblGameSave | Kept enabled — required for Xbox cloud save sync |
| 26118 | Disable XboxNetApiSvc | Kept enabled — required for Xbox Live networking |
| 26213 | Disable IPv6 | Kept enabled — disabling breaks Xbox NAT Type and Teredo tunneling for online multiplayer |
| 26226–26231 | Virtualization Based Security / Device Guard | Skipped — VBS can reduce gaming FPS and conflict with anti-cheat software |
| 26238 | Turn off access to the Store | Skipped — Microsoft Store is required for Xbox Game Pass |
| 26317 | Block Microsoft Account authentication | Skipped — Microsoft Account is required for Xbox Game Pass game entitlement |
| 26320–26321 | Configure ASR rules | Skipped — ASR rules conflict with anti-cheat software used in online games |
| 26360 | Only display private store in Microsoft Store | Skipped — restricts Store to corporate catalog; breaks Xbox Game Pass |
| 26363 | Turn off the Store application | Skipped — disables Microsoft Store entirely; breaks Xbox Game Pass |
| 26368 | Disable Game DVR / Xbox Game Bar | Skipped — potential unknown side effects on Xbox services |

---

## Streaming and Peripherals

| Check | Description | Reason |
|-------|-------------|--------|
| 26286 | Disable camera | Kept enabled — camera is required for Streamlabs streaming |

---

## Home User Convenience

These checks address risks relevant to corporate environments but have meaningful usability trade-offs on a personal home machine.

| Check | Description | Reason |
|-------|-------------|--------|
| 26029 | Configure logon message text | Not applicable on a personal machine |
| 26030 | Configure logon message title | Not applicable on a personal machine |
| 26033 | Smart card removal — lock workstation | No smart card in use |
| 26251 | Turn off Windows Error Reporting | Kept enabled — useful for diagnosing crashes |
| 26315 | Turn off location services | Kept enabled — GPS functionality in use |
| 26323 | Enable file hash computation | Minimal security benefit; skipped |
| 26333 | Disable news and interests on taskbar | News widget is in active use |
| 26334 | Disable OneDrive | May be used for file sync |
| 26336 | Disable RDP password saving | Kept — convenience on a home machine with no external RDP exposure |
| 26359 | Disable all apps from Microsoft Store set to Disabled | Remediation attempted; Wazuh rule condition could not be satisfied |
| 26364 | Disable widgets | Widgets used occasionally |
| 26391 | Remove access to pause Windows Updates | Kept — home user needs ability to pause updates if a problematic update ships |
