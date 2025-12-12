# Task 008: Install Ansible on your Linux machine

During the weekly meeting, the Nautilus DevOps team discussed about the automation and configuration management solutions that they want to implement. While considering several options, the team has decided to go with Ansible for now due to its simple setup and minimal pre-requisites. The team wanted to start testing using Ansible, so they have decided to use jump host as an Ansible controller to test different kind of tasks on rest of the servers.

Install ansible version 4.8.0 on Jump host using pip3 only. Make sure Ansible binary is available globally on this system, i.e all users on this system are able to run Ansible commands.

## Instructions:

1. Install Ansible version 4.8.0 using pip3 on Jump host.
2. Ensure that Ansible binary is available globally on this system.
3. Verify the installation by checking the Ansible version.

NOTE: Take note of OS details and package manager used on Jump host before you proceed with the installation.

```bash
thor@jumphost ~$ cat /etc/os-release
NAME="CentOS Stream"
VERSION="9"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="9"
PLATFORM_ID="platform:el9"
PRETTY_NAME="CentOS Stream 9"
ANSI_COLOR="0;31"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:centos:centos:9"
HOME_URL="https://centos.org/"
BUG_REPORT_URL="https://issues.redhat.com/"
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux 9"
REDHAT_SUPPORT_PRODUCT_VERSION="CentOS Stream"
```

## Solution:

1. First, connect to the Jump host via SSH.
2. Update the package manager and install necessary dependencies (Optional):
   ```bash
   sudo dnf update -y
   sudo dnf install -y python3 python3-pip
   ```
3. Install Ansible version 4.8.0 using pip3:
   ```bash
   sudo python3 -m pip install ansible==4.8.0
   ```
4. Verify that Ansible is installed and check the versions (note: `ansible --version` shows the bundled `ansible-core` version):

   ```bash
   python3 -m pip show ansible | egrep 'Name|Version|Location'
   ansible --version
   ```

   You should see `Version: 4.8.0` from `pip show`, and a compatible `ansible [core 2.11.x]` from `ansible --version`.

5. Ensure that Ansible binary is available globally on this system:

   ```bash
   which ansible
   ls -l "$(command -v ansible)"
   sudo -iu root command -v ansible
   ```

   The output of `which ansible` should point to a system-wide directory that is in `PATH` for all users (commonly `/usr/local/bin/ansible`). The permissions should allow execution by all users (e.g., `-rwxr-xr-x`).
