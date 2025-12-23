# Task 003 - Configure default SSH user for Ansible

The Nautilus DevOps team aims to manage all servers within the stack using Ansible, utilizing a common sudo user across all servers. They plan to use this user for various tasks on each server. While this isn't finalized, they're starting with testing. Ansible is already installed on the jump host via yum. Here's the requirement:

On the jump host, modify the default configuration of Ansible to enable the use of javed as the default SSH user for all hosts. Ensure to make changes within Ansible's default configuration without creating a new one.

## Instructions

1. Add `remote_user = javed` to the default Ansible configuration file located at `/etc/ansible/ansible.cfg`.

```bash
thor@jumphost ~$ sudo vi /etc/ansible/ansible.cfg
thor@jumphost ~$ cat /etc/ansible/ansible.cfg
# Since Ansible 2.12 (core):
# To generate an example config file (a "disabled" one with all default settings, commented out):
#               $ ansible-config init --disabled > ansible.cfg
#
# Also you can now have a more complete file by including existing plugins:
# ansible-config init --disabled -t all > ansible.cfg

# For previous versions of Ansible you can check for examples in the 'stable' branches of each version
# Note that this file was always incomplete  and lagging changes to configuration settings

# for example, for 2.9: https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg
[defaults]
host_key_checking = False
remote_user = javed
```

2. Verify the configuration by checking the contents of `/etc/ansible/ansible.cfg` to ensure that `remote_user = javed` has been added correctly.

```bash
thor@jumphost ~$ ansible-config dump --only-changed | grep -E 'DEFAULT_REMOTE_USER|remote_user'
DEFAULT_REMOTE_USER(/etc/ansible/ansible.cfg) = javed
```
