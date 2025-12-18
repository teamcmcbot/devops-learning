# Task 001 : Troubleshoot and Create Ansible Playbook

An Ansible playbook needs completion on the jump host, where a team member left off. Below are the details:

The inventory file `/home/thor/ansible/inventory` requires adjustments. The playbook must run on `App Server 3` in Stratos DC. Update the inventory accordingly.

Create a playbook `/home/thor/ansible/playbook.yml`. Include a task to create an empty file `/tmp/file.txt` on `App Server 3`.

Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook works without any additional arguments.

## Current Inventory File (Wrong IP, no password)

```ini
stapp02 ansible_host=172.238.16.204 ansible_user=steve ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

## Updated Inventory File (Correct IP, with password)

```ini
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_password=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_password=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_password=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

## Verify Invetory File

```bash
thor@jumphost ~/ansible$ ansible -i inventory stapp03 -m ping
stapp03 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
thor@jumphost ~/ansible$
```

## Playbook File: /home/thor/ansible/playbook.yml

```yaml
---
- name: Create an empty file on App Server 3
  hosts: stapp03
  tasks:
    - name: Create an empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
```

## Run the Playbook

```bash
thor@jumphost ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Create an empty file on App Server 3] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************
ok: [stapp03]

TASK [Create an empty file /tmp/file.txt] **************************************************************************************
changed: [stapp03]

PLAY RECAP *********************************************************************************************************************
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Verify the File Creation

```bash
thor@jumphost ~/ansible$ ssh banner@stapp03 'ls -la /tmp/file.txt'
The authenticity of host 'stapp03 (172.16.238.12)' can't be established.
ED25519 key fingerprint is SHA256:FB5KOxzGglFDnxeuwQZrUh+0EJveBSAN+jObgAtD9AQ.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: 172.16.238.12
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'stapp03' (ED25519) to the list of known hosts.
banner@stapp03's password:
-rw-r--r-- 1 banner banner 0 Dec 18 16:09 /tmp/file.txt
thor@jumphost ~/ansible$
```
