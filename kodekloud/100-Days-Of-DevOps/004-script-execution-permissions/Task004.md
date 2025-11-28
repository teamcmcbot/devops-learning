# Task 004: Script Execution Permissions

In a bid to automate backup processes, the xFusionCorp Industries sysadmin team has developed a new bash script named xfusioncorp.sh. While the script has been distributed to all necessary servers, it lacks executable permissions on App Server 2 within the Stratos Datacenter.

Your task is to grant executable permissions to the /tmp/xfusioncorp.sh script on App Server 2. Additionally, ensure that all users have the capability to execute it.

## Instructions

1. SSH into App Server 2

```bash
thor@jumphost ~$ ssh steve@stapp02
The authenticity of host 'stapp02 (172.16.238.11)' can't be established.
ED25519 key fingerprint is SHA256:h/nErXHG/2KeoWB/l6Q2+kK/0Xl/IqBKX6Ei+tC/3Uw.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'stapp02' (ED25519) to the list of known hosts.
steve@stapp02's password:
[steve@stapp02 ~]$
```

2. Check the current permissions of the /tmp/xfusioncorp.sh script

```bash
[steve@stapp02 ~]$ ls -la /tmp/xfusioncorp.sh
---------- 1 root root 40 Nov 27 03:38 /tmp/xfusioncorp.sh
[steve@stapp02 ~]$ sudo cat /tmp/xfusioncorp.sh

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for steve:
#!/bin/bash

echo "Welcome To KodeKloud"[steve@stapp02 ~]$
```

3. Grant read and executable permissions to all users for the /tmp/xfusioncorp.sh script

#NOTE: Simply adding execute permission is insufficient for script execution; read permission is also required.

```bash
[steve@stapp02 ~]$ sudo chmod a+rx /tmp/xfusioncorp.sh

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for banner:
[banner@stapp03 ~]
```

4. Verify the permissions have been updated

```bash
[steve@stapp02 ~]$ ls -la /tmp/xfusioncorp.sh
-r-xr-xr-x 1 root root 40 Nov 27 03:38 /tmp/xfusioncorp.sh
```

5. Test script execution

```bash
[steve@stapp02 ~]$ /tmp/xfusioncorp.sh
Welcome To KodeKloud
[steve@stapp02 ~]$
```

## Understanding chmod Commands

**Different ways to grant execute permissions:**

- `chmod +x file` - Adds execute permission to **all users** (owner, group, others)
- `chmod a+x file` - Explicitly adds execute to **all users** (same as +x, but more clear)
- `chmod u+x file` - Adds execute permission to **owner only**
- `chmod g+x file` - Adds execute permission to **group only**
- `chmod o+x file` - Adds execute permission to **others only**
- `chmod 755 file` - Sets rwxr-xr-x (owner: rwx, group: r-x, others: r-x)

**Permission breakdown:**

- `---x--x--x` = Execute only for all users (no read/write) - **PROBLEMATIC FOR SCRIPTS**
- `-r-xr-xr-x` = Read and execute for all users - **CORRECT FOR SCRIPTS**
- `rwxrwxrwx` = Full permissions for all users (read/write/execute)

## Troubleshooting Script Execution

**Problem**: "Permission denied" even with execute permission (`---x--x--x`)

**Root Cause**: Scripts need **both read AND execute** permissions to run

- Execute permission (`x`) allows the file to be executed
- Read permission (`r`) allows the shell to read the script content

**Solution**: Use `chmod a+rx` to add both read and execute permissions

**Key Learning**:

- Binary executables only need execute permission (`x`)
- Shell scripts need both read and execute permissions (`rx`)
