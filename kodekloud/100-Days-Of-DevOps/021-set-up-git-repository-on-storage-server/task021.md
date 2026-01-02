# Task 021 - Set up Git repository on storage server

The Nautilus development team has provided requirements to the DevOps team for a new application development project, specifically requesting the establishment of a Git repository. Follow the instructions below to create the Git repository on the Storage server in the Stratos DC:

Utilize `yum` to install the `git` package on the Storage Server.

Create a bare repository named `/opt/cluster.git` (ensure exact name usage).

## Solution

1. **Install Git on the Storage Server:**

   ```bash
    sudo yum install -y git
   ```

2. **Create a Bare Git Repository:**

   ```bash
    sudo git init --bare /opt/cluster.git
   ```

   ```bash
    [natasha@ststor01 ~]$ sudo git init --bare /opt/cluster.git
   hint: Using 'master' as the name for the initial branch. This default branch name
   hint: is subject to change. To configure the initial branch name to use in all
   hint: of your new repositories, which will suppress this warning, call:
   hint:
   hint:   git config --global init.defaultBranch <name>
   hint:
   hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
   hint: 'development'. The just-created branch can be renamed via this command:
   hint:
   hint:   git branch -m <name>
   Initialized empty Git repository in /opt/cluster.git/
   ```

This will set up a bare Git repository at the specified location, ready for use by the development team.
