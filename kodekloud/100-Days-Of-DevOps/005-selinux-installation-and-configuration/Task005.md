# Task 005: SELinux Installation and Configuration

Following a security audit, the xFusionCorp Industries security team has opted to enhance application and server security with SELinux. To initiate testing, the following requirements have been established for App server 1 in the Stratos Datacenter:

Install the required SELinux packages.

Permanently disable SELinux for the time being; it will be re-enabled after necessary configuration changes.

No need to reboot the server, as a scheduled maintenance reboot is already planned for tonight.

Disregard the current status of SELinux via the command line; the final status after the reboot should be disabled.

## Resources

- https://www.zenarmor.com/docs/linux-tutorials/how-to-enable-and-disable-selinux

## Instructions

1. SSH into App Server 1

```bash
thor@jumphost ~$ ssh tony@stapp01
tony@stapp01's password:
[tony@stapp01 ~]$
```

2. Install the necessary SELinux packages

```bash
#CentOS9
# Update System (Optional)
sudo dnf update

# Install SELinux packages
sudo dnf install selinux-policy selinux-policy-targeted policycoreutils

# Check the status of SELinux
[tony@stapp01 ~]$ sestatus
SELinux status:                 disabled

```

3. Permanently disable SELinux by editing the configuration file

```bash
sudo vi /etc/selinux/config
# Change the line to:
SELINUX=disabled
```

4. Verify the configuration file to ensure SELinux is set to disabled

```bash
cat /etc/selinux/config | grep "^SELINUX="
SELINUX=disabled
```
