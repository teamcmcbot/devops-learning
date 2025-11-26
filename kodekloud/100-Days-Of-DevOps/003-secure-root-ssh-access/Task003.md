# Task 003: Secure Root SSH Access

Following security audits, the xFusionCorp Industries security team has rolled out new protocols, including the restriction of direct root SSH login.

Your task is to disable direct SSH root login on all app servers within the Stratos Datacenter.

## Instructions

1. ssh into each app server. Update the SSH configuration (/etc/ssh/sshd_config) to disable root login (PermitRootLogin no).
2. Restart the SSH service to apply the changes `sudo systemctl restart sshd`.
3. Verify config `sudo sshd -T | grep permitrootlogin` should return `permitrootlogin no`.
4. Verify that root login is disabled by attempting to SSH as root (ssh root@<server-ip>), which should be denied.
