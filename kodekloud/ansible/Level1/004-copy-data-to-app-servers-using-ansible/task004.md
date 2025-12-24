# Task 004 - Copy Data to App Servers using Ansible

The Nautilus DevOps team needs to copy data from the jump host to all application servers in Stratos DC using Ansible. Execute the task with the following details:

a. Create an inventory file `/home/thor/ansible/inventory` on jump_host and add all application servers as managed nodes.

b. Create a playbook `/home/thor/ansible/playbook.yml` on the jump host to copy the `/usr/src/sysops/index.html` file to all application servers, placing it at `/opt/sysops`.

Note: Validation will run the playbook using the command `ansible-playbook -i inventory playbook.yml`. Ensure the playbook functions properly without any extra arguments.

## Applicatin Servers Details:

- stapp01
- stapp02
- stapp03

## Inventory File:

```ini
[app]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_password=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_password=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_password=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

Verify Inventory File:

```bash
thor@jumphost ~/ansible$ ansible -i inventory app -m ping
stapp03 | SUCCESS => {
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
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## Playbook File: /home/thor/ansible/playbook.yml

```yaml
---
- name: Copy index.html to all app servers
  hosts: app
  become: true
  tasks:
    - name: Ensure /opt/sysops exists
      ansible.builtin.file:
        path: /opt/sysops
        state: directory
        owner: root
        group: root
        mode: "0755"

    - name: Copy index.html
      ansible.builtin.copy:
        src: /usr/src/sysops/index.html
        dest: /opt/sysops/index.html
        owner: root
        group: root
        mode: "0644"
```

## Run the Playbook

```bash
thor@jumphost ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Copy index.html to all app servers] *************************************************************

TASK [Gathering Facts] ********************************************************************************
ok: [stapp02]
ok: [stapp03]
ok: [stapp01]

TASK [Ensure /opt/sysops exists] **********************************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Copy index.html] ********************************************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

PLAY RECAP ********************************************************************************************
stapp01                    : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
stapp02                    : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
stapp03                    : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Verify the File Copy

```bash
thor@jumphost ~/ansible$ ansible -i inventory app -a "ls -l /opt/sysops/index.html"
stapp01 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 35 Dec 24 04:18 /opt/sysops/index.html
stapp03 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 35 Dec 24 04:18 /opt/sysops/index.html
stapp02 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 35 Dec 24 04:18 /opt/sysops/index.html


thor@jumphost ~/ansible$ ssh tony@stapp01 "sudo cat /opt/sysops/index.html"
tony@stapp01's password:
Welcome to xFusionCorp Industries !

thor@jumphost ~/ansible$ ssh steve@stapp02 "sudo cat /opt/sysops/index.html"
steve@stapp02's password:
Welcome to xFusionCorp Industries !

thor@jumphost ~/ansible$ ssh banner@stapp03 "sudo cat /opt/sysops/index.html"
banner@stapp03's password:
Welcome to xFusionCorp Industries !

```
