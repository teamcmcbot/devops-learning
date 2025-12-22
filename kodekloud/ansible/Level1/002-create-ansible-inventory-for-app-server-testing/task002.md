# Task 002: Create Ansible Inventory for App Server Testing

The Nautilus DevOps team is testing Ansible playbooks on various servers within their stack. They've placed some playbooks under /home/thor/playbook/ directory on the jump host and now intend to test them on app server 1 in Stratos DC. However, an inventory file needs creation for Ansible to connect to the respective app. Here are the requirements:

a. Create an ini type Ansible inventory file `/home/thor/playbook/inventory` on `jump host`.

b. Include `App Server 1` in this inventory along with necessary variables for proper functionality.

c. Ensure the inventory hostname corresponds to the `server name` as per the wiki, for example `stapp01` for `app server 1` in Stratos DC.

Note: Validation will execute the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.

## Solution Steps

1. Create the inventory file at the specified location.

```bash
thor@jumphost ~$ cd playbook/
thor@jumphost ~/playbook$ ls -la
total 16
drwxr-xr-x 2 thor thor 4096 Dec 22 02:34 .
drwxr----- 1 thor thor 4096 Dec 22 02:34 ..
-rw-r--r-- 1 thor thor   36 Dec 22 02:34 ansible.cfg
-rw-r--r-- 1 thor thor  250 Dec 22 02:34 playbook.yml
thor@jumphost ~/playbook$ touch inventory
thor@jumphost ~/playbook$ ls -la
total 16
drwxr-xr-x 2 thor thor 4096 Dec 22 02:38 .
drwxr----- 1 thor thor 4096 Dec 22 02:34 ..
-rw-r--r-- 1 thor thor   36 Dec 22 02:34 ansible.cfg
-rw-r--r-- 1 thor thor    0 Dec 22 02:38 inventory
-rw-r--r-- 1 thor thor  250 Dec 22 02:34 playbook.yml
thor@jumphost ~/playbook$
```

2. Edit the inventory file to include `App Server 1` with the correct hostname and necessary variables.

```bash
thor@jumphost ~/playbook$ echo "stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_password=Ir0nM@n" >> inventory
thor@jumphost ~/playbook$ cat inventory
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_password=Ir0nM@n
```

3. Verify the inventory by pinging `App Server 1`.

```bash
thor@jumphost ~/playbook$ ansible -i inventory stapp01 -m ping
stapp01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
thor@jumphost ~/playbook$
```

4. Check what playbook.yml does.

```bash
thor@jumphost ~/playbook$ cat playbook.yml
---
- hosts: all
  become: yes
  become_user: root
  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: installed

    - name: Start service httpd
      service:
        name: httpd
        state: startedthor@jumphost ~/playbook$
```

**Note:** The playbook installs and starts the httpd service on the target server.

5. Run the playbook to ensure it works correctly with the created inventory.

```bash
thor@jumphost ~/playbook$ ansible-playbook -i inventory playbook.yml

PLAY [all] ********************************************************************************************

TASK [Gathering Facts] ********************************************************************************
ok: [stapp01]

TASK [Install httpd package] **************************************************************************
ok: [stapp01]

TASK [Start service httpd] ****************************************************************************
ok: [stapp01]

PLAY RECAP ********************************************************************************************
stapp01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

6. Verify that httpd is running on App Server 1.

```bash
thor@jumphost ~/playbook$ ssh tony@stapp01 "sudo systemctl status httpd"
The authenticity of host 'stapp01 (172.16.238.10)' can't be established.
ED25519 key fingerprint is SHA256:ZzJpMsz51qCJ+e++3BDD0ZNd2s+Ht2F2Q19faR+Li9E.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: 172.16.238.10
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'stapp01' (ED25519) to the list of known hosts.
tony@stapp01's password:
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: active (running) since Mon 2025-12-22 02:44:42 UTC; 1min 4s ago
       Docs: man:httpd.service(8)
   Main PID: 3489 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 177 (limit: 411140)
     Memory: 16.2M
     CGroup: /docker/4b06b7d790bbfd6cc85cc5c70fcd517049672ab721fa798f79437855024932c6/system.slice/httpd.service
             ├─3489 /usr/sbin/httpd -DFOREGROUND
             ├─3496 /usr/sbin/httpd -DFOREGROUND
             ├─3497 /usr/sbin/httpd -DFOREGROUND
             ├─3498 /usr/sbin/httpd -DFOREGROUND
             └─3499 /usr/sbin/httpd -DFOREGROUND

Dec 22 02:44:42 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Job 294 httpd.service/start finished, result=done
Dec 22 02:44:42 stapp01.stratos.xfusioncorp.com systemd[1]: Started The Apache HTTP Server.
Dec 22 02:44:42 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Failed to send unit change signal for httpd.service: Connection reset by peer
Dec 22 02:44:42 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Started, listening on: port 80, MAINPID=3489)
Dec 22 02:44:51 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
Dec 22 02:45:01 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
Dec 22 02:45:11 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
Dec 22 02:45:21 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
Dec 22 02:45:32 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
Dec 22 02:45:42 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got notification message from PID 3489 (READY=1, STATUS=Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec)
thor@jumphost ~/playbook$
```
