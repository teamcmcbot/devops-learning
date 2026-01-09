# Task 022 - Clone Git Repository on Storage Server

The DevOps team established a new Git repository last week, which remains unused at present. However, the Nautilus application development team now requires a copy of this repository on the `Storage Server` in the Stratos DC. Follow the provided details to clone the repository:

The repository to be cloned is located at `/opt/demo.git`

Clone this Git repository to the `/usr/src/kodekloudrepos` directory. Perform this task using the natasha user, and ensure that no modifications are made to the repository or existing directories, such as changing permissions or making unauthorized alterations.

## Solution

1. ssh to the Storage Server as natasha user
   ```bash
   ssh natasha@ststor01
   ```
2. Go to the desired directory and clone the repository
   ```bash
   cd /usr/src/kodekloudrepos
    [natasha@ststor01 kodekloudrepos]$ git clone /opt/demo.git/
   Cloning into 'demo'...
   warning: You appear to have cloned an empty repository.
   done.
   [natasha@ststor01 kodekloudrepos]$ ls -la
   total 12
   drwxr-xr-x 3 natasha natasha 4096 Jan  9 06:11 .
   drwxr-xr-x 1 root    root    4096 Jan  9 06:07 ..
   drwxr-xr-x 3 natasha natasha 4096 Jan  9 06:11 demo
   [natasha@ststor01 kodekloudrepos]$ cd demo/
   [natasha@ststor01 demo]$ ls -la
   total 12
   drwxr-xr-x 3 natasha natasha 4096 Jan  9 06:11 .
   drwxr-xr-x 3 natasha natasha 4096 Jan  9 06:11 ..
   drwxr-xr-x 7 natasha natasha 4096 Jan  9 06:11 .git
   [natasha@ststor01 demo]$ git status
   On branch master
   ```

No commits yet

nothing to commit (create/copy files and use "git add" to track)
[natasha@ststor01 demo]$

```

```
