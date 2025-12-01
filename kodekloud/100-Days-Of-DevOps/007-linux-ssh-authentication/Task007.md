# Task 007: Linux SSH Authentication

The system admins team of xFusionCorp Industries has set up some scripts on jump host that run on regular intervals and perform operations on all app servers in Stratos Datacenter. To make these scripts work properly we need to make sure the thor user on jump host has password-less SSH access to all app servers through their respective sudo users (i.e tony for app server 1). Based on the requirements, perform the following:

Set up a password-less authentication from user thor on jump host to all app servers through their respective sudo users.

## Instructions

1. Generate an SSH key pair for user thor on jump host.

```bash
thor@jumphost ~$ pwd
/home/thor
thor@jumphost ~$ ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (/home/thor/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/thor/.ssh/id_rsa
Your public key has been saved in /home/thor/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:hwsvPo+FXq10Ra2awFVjpBGDJ+EuVrD2l/Wh73V/Geo thor@jumphost.stratos.xfusioncorp.com
The key's randomart image is:
+---[RSA 4096]----+
|      . .o+o=    |
|       +o .* o   |
|      o ooo o o  |
|     . = o + + . |
|      + S + + .  |
|     . = * + . . |
|      o * =   o =|
|     o.* o   o o+|
|      +oo   .E. o|
+----[SHA256]-----+
```

2. Copy the public key to the respective sudo users on all app servers.

````bash
thor@jumphost ~$ ssh-copy-id -i ~/.ssh/id_rsa.pub tony@stapp01
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/thor/.ssh/id_rsa.pub"
The authenticity of host 'stapp01 (172.16.238.10)' can't be established.
ED25519 key fingerprint is SHA256:W1dm/EuiknNQk+cLofe6RdgAVb+8hTzLmfS1P8f5tOY.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
tony@stapp01's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'tony@stapp01'"
and check to make sure that only the key(s) you wanted were added.

```bash
thor@jumphost ~$ ssh-copy-id -i ~/.ssh/id_rsa.pub steve@stapp02
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/thor/.ssh/id_rsa.pub"
The authenticity of host 'stapp02 (172.16.238.11)' can't be established.
ED25519 key fingerprint is SHA256:9p1Yevd+cjXaJYyV4JudkqKHaeqJk6IEc1aQatUHusE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
steve@stapp02's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'steve@stapp02'"
and check to make sure that only the key(s) you wanted were added.

````

```bash
thor@jumphost ~$ ssh-copy-id -i ~/.ssh/id_rsa.pub banner@stapp03
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/thor/.ssh/id_rsa.pub"
The authenticity of host 'stapp03 (172.16.238.12)' can't be established.
ED25519 key fingerprint is SHA256:ntM718Kf9RVMQ5ns8qU5/GXYYWxJ58N8hwLLlhk+P+8.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
banner@stapp03's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'banner@stapp03'"
and check to make sure that only the key(s) you wanted were added.

```

3. Verify password-less SSH access from user thor on jump host to all app servers through their respective sudo users.

```bash
thor@jumphost ~$ ssh tony@stapp01
Last login: Mon Dec  1 16:00:06 2025 from 172.16.238.3
[tony@stapp01 ~]$ whoami
tony

```

```bash
thor@jumphost ~$ ssh steve@stapp02
[steve@stapp02 ~]$ whoami
steve
[steve@stapp02 ~]$ pwd
/home/steve

```

```bash
thor@jumphost ~$ ssh banner@stapp03
[banner@stapp03 ~]$ whoami
banner
[banner@stapp03 ~]$ pwd
/home/banner

```
