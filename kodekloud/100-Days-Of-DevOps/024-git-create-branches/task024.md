# Task 024 - Create Branches in Git Repository

Nautilus developers are actively working on one of the project repositories, `/usr/src/kodekloudrepos/blog`. Recently, they decided to implement some new features in the application, and they want to maintain those new changes in a separate branch. Below are the requirements that have been shared with the DevOps team:

On `Storage server` in Stratos DC create a new branch `xfusioncorp_blog` from master branch in `/usr/src/kodekloudrepos/blog` git repo.

Please do not try to make any changes in the code.

## Solution

1. **Access the Storage Server**

   First, log in to the `Storage server` where the Git repository is located.

   ```bash
   ssh <your-username>@<storage-server-ip>
   ```

2. **Navigate to the Git Repository**
   Change directory to the Git repository located at `/usr/src/kodekloudrepos/blog`.

   ```bash
   cd /usr/src/kodekloudrepos/blog
   ```

3. Switch to root user (if necessary):

   ```bash
   sudo su -
   ```

4. Check current branches and ensure you are on the master branch:

   ```bash
   [root@ststor01 blog]# git status
   On branch kodekloud_blog
   nothing to commit, working tree clean
   ```

5. Switch to the master branch:

   ```bash
   [root@ststor01 blog]# git checkout master
   Switched to branch 'master'
   Your branch is up to date with 'origin/master'.
   ```

6. Create a new branch named `xfusioncorp_blog` from the master branch:

   ```bash
    root@ststor01 blog]# git checkout -b xfusioncorp_blog
   Switched to a new branch 'xfusioncorp_blog'
   ```

7. Verify that the new branch has been created:

   ```bash
   [root@ststor01 blog]# git branch
   kodekloud_blog
   master
   * xfusioncorp_blog
   ```
