# Wazuh Manager Password Reset

## Overview

Documents the process for resetting the Wazuh admin password using the built-in password management tool. This is needed when the initial auto-generated password is lost or needs to be changed.

## Tool Location

```
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh
```

## Reset Command

SSH into the Wazuh Manager VM and run:

```bash
sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -u admin -p 'YourNewPassword'
```

## Password Requirements

The password tool has strict symbol restrictions. Only the following special characters are accepted:

| Allowed | Not Allowed |
|---------|-------------|
| `*` | `@` |
| `+` | `#` |
| `?` | `$` |
| | `!` |

Using a disallowed symbol will cause the tool to fail silently or return an error — use only the allowed symbols when composing the password.

## Verification

After running the reset command, navigate to `https://<WAZUH_MANAGER_IP>` and log in with the new credentials to confirm the reset was successful.

## Key Takeaways

- The Wazuh password tool's symbol restrictions are not documented prominently — trial and error revealed only `*`, `+`, and `?` are accepted
- Always verify the new password works in the dashboard immediately after resetting
- If the dashboard login fails after a reset, restart the Wazuh services and try again:

```bash
sudo systemctl restart wazuh-manager wazuh-indexer wazuh-dashboard
```
