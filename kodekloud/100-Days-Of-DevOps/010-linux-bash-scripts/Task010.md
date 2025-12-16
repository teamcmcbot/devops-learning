# Task 010: Create a Bash Script to Display System Information

The production support team of xFusionCorp Industries is working on developing some bash scripts to automate different day to day tasks. One is to create a bash script for taking websites backup. They have a static website running on App Server 2 in Stratos Datacenter, and they need to create a bash script named `media_backup.sh` which should accomplish the following tasks. (Also remember to place the script under /scripts directory on App Server 2).

a. Create a zip archive named xfusioncorp_media.zip of /var/www/html/media directory.

b. Save the archive in /backup/ on App Server 2. This is a temporary storage, as backups from this location will be clean on weekly basis. Therefore, we also need to save this backup archive on Nautilus Backup Server.

c. Copy the created archive to Nautilus Backup Server server in /backup/ location.

d. Please make sure script won't ask for password while copying the archive file. Additionally, the respective server user (for example, tony in case of App Server 1) must be able to run it.

e. Do not use sudo inside the script.

Note:
The zip package must be installed on given App Server before executing the script. This package is essential for creating the zip archive of the website files. Install it manually outside the script.

## Solution Steps

1. Log in to App Server 2.
2. Ensure the `zip` package is installed:
   ```bash
   sudo dnf install zip -y
   ```
3. Create media_backup.sh and set permissions:
   ```bash
    mkdir -p /scripts
   vi /scripts/media_backup.sh
   chmod +x /scripts/media_backup.sh
   ```
4. Add the following content to `media_backup.sh` as per the requirements:

   ```bash
   #!/bin/bash

   # Variables
   SOURCE_DIR="/var/www/html/media"
   BACKUP_DIR="/backup"
   ARCHIVE_NAME="xfusioncorp_media.zip"
   LOCAL_ARCHIVE="$BACKUP_DIR/$ARCHIVE_NAME"
   REMOTE_USER="tony"
   REMOTE_HOST="nautilus_backup_server"  # Replace with actual hostname or IP
   REMOTE_DIR="/backup"
   REMOTE_TARGET="$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

   # Create backup directory if it doesn't exist
   mkdir -p "$BACKUP_DIR"

   # Create zip archive of the media directory
   zip -r "$LOCAL_ARCHIVE" "$SOURCE_DIR"

   # Copy to Nautilus Backup Server (no password prompts)
   scp -q -o BatchMode=yes "$LOCAL_ARCHIVE" "$REMOTE_TARGET"

   echo "Backup completed successfully: $LOCAL_ARCHIVE to $REMOTE_TARGET"
   ```

5. Create SSH key-based authentication from App Server 2 to Nautilus Backup Server to avoid password prompts during `scp`:

```bash
[steve@stapp02 scripts]$ ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
Generating public/private ed25519 key pair.
Created directory '/home/steve/.ssh'.
Your identification has been saved in /home/steve/.ssh/id_ed25519
Your public key has been saved in /home/steve/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:JzxjT/XA3ek2eLJ6YpoYnJXFDQcwp148T6GYJvCtYbk steve@stapp02.stratos.xfusioncorp.com
The key's randomart image is:
+--[ED25519 256]--+
|     .   o.+.o   |
|      o o O.=....|
|       * * B+o...|
|      ..B +.+oo  |
|       ES+o  +.= |
|      ..oB    = .|
|       +  .  .   |
|        o .o..   |
|       . oo.o    |
+----[SHA256]-----+
[steve@stapp02 scripts]$ ssh-copy-id clint@stbkp01
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/steve/.ssh/id_ed25519.pub"
The authenticity of host 'stbkp01 (172.16.238.16)' can't be established.
ED25519 key fingerprint is SHA256:GArHyheW3lxa8cwmU9Hulk/TYk1tpKSsGJMol4nn+hI.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
clint@stbkp01's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'clint@stbkp01'"
and check to make sure that only the key(s) you wanted were added.
```

6. Run the script to verify it works as expected:

   ```bash
   [steve@stapp02 scripts]$ ./media_backup.sh
   updating: media/ (stored 0%)
   updating: media/index.html (stored 0%)
   updating: media/.gitkeep (stored 0%)
   Backup completed successfully: /backup/xfusioncorp_media.zip to clint@stbkp01:/backup/
   ```

7. Verify the backup file exists on Nautilus Backup Server:
   ```bash
   [steve@stapp02 scripts]$ ssh clint@stbkp01
   Last login: Mon Dec 15 14:50:29 2025 from 172.16.238.11
   [clint@stbkp01 ~]$ cd /backup/
   [clint@stbkp01 backup]$ ls
   xfusioncorp_media.zip
   [clint@stbkp01 backup]$ ls -la
   total 12
   drwxrwxrwx 2 root  root  4096 Dec 15 14:56 .
   drwxr-xr-x 1 root  root  4096 Dec 15 14:56 ..
   -rw-r--r-- 1 clint clint  517 Dec 15 14:56 xfusioncorp_media.zip
   [clint@stbkp01 backup]$ unzip xfusioncorp_media.zip
   Archive:  xfusioncorp_media.zip
   creating: media/
   extracting: media/index.html
   extracting: media/.gitkeep
   [clint@stbkp01 backup]$ ls -la
   total 16
   drwxrwxrwx 3 root  root  4096 Dec 15 14:58 .
   drwxr-xr-x 1 root  root  4096 Dec 15 14:56 ..
   drwxr-xr-x 2 clint clint 4096 Dec 15 14:17 media
   -rw-r--r-- 1 clint clint  517 Dec 15 14:56 xfusioncorp_media.zip
   [clint@stbkp01 backup]$
   ```
