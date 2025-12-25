# Task 005 - Create files on app servers using Ansible

The Nautilus DevOps team is testing various Ansible modules on servers in Stratos DC. They're currently focusing on file creation on remote hosts using Ansible. Here are the details:

a. Create an inventory file `~/playbook/inventory` on jump host and include all app servers.

b. Create a playbook `~/playbook/playbook.yml` to create a blank file `/opt/nfsshare.txt` on all app servers.

c. Set the permissions of the `/opt/nfsshare.txt` file to `0744`.
d. Ensure the user/group owner of the `/opt/nfsshare.txt` file is `tony` on app server 1, `steve` on app server 2 and `banner` on app server 3.

Note: Validation will execute the playbook using the command ansible-playbook -i inventory playbook.yml, so ensure the playbook functions correctly without any additional arguments.

## Soultion

1. Create inventory file:

```ini
[app]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_password=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_password=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_password=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

```bash
hor@jumphost ~/playbook$ ansible -i inventory app -m ping
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
stapp01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
stapp03 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

2. Create playbook file:

```yaml
---
- name: Create blank file on app servers
  hosts: app
  become: yes
  tasks:
    - name: Create blank file /opt/nfsshare.txt
      file:
        path: /opt/nfsshare.txt
        state: touch
        mode: "0744"
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
```

> **Note:** Since `ansible_user` is defined per host in the inventory (`tony`, `steve`, `banner`), we can use it directly instead of nested ternary conditions.

3. Run the playbook:

```bash
thor@jumphost ~/playbook$ ansible-playbook -i inventory playbook.yml

PLAY [Create blank file on app servers] ****************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************
ok: [stapp03]
ok: [stapp02]
ok: [stapp01]

TASK [Create blank file /opt/nfsshare.txt] *************************************************************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

PLAY RECAP *********************************************************************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

4. Verify on app servers:

```bash
thor@jumphost ~/playbook$ ansible -i inventory app -m command -a "ls -l /opt/nfsshare.txt"
stapp02 | CHANGED | rc=0 >>
-rwxr--r-- 1 steve steve 0 Dec 25 14:10 /opt/nfsshare.txt
stapp03 | CHANGED | rc=0 >>
-rwxr--r-- 1 banner banner 0 Dec 25 14:10 /opt/nfsshare.txt
stapp01 | CHANGED | rc=0 >>
-rwxr--r-- 1 tony tony 0 Dec 25 14:10 /opt/nfsshare.txt
```
