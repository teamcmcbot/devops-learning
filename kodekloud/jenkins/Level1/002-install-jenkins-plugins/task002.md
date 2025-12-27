# Task 002 - Install Jenkins Plugins

The Nautilus DevOps team has recently setup a Jenkins server, which they want to use for some CI/CD jobs. Before that they want to install some plugins which will be used in most of the jobs. Please find below more details about the task

1. Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username `admin` and `Adm!n321` password.

2. Once logged in, install the `Git` and `GitLab` plugins. Note that you may need to restart Jenkins service to complete the plugins installation, If required, opt to Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre.

Note:

1. After restarting the Jenkins service, wait for the Jenkins login page to reappear before proceeding.

2. For tasks involving web UI changes, capture screenshots to share for review or consider using screen recording software like loom.com for documentation and sharing.

## Solution

### Steps to Install Git and GitLab Plugins

1. **Login to Jenkins**

   - Click the Jenkins button on the top bar
   - Username: `admin`
   - Password: `Adm!n321`

2. **Navigate to Plugin Manager**

   - Go to **Manage Jenkins** → **Plugins**
   - Click on the **Available plugins** tab

3. **Search and Select Plugins**

   - In the search/filter box, type `Git`
   - Check the box for **Git client plugin** (dependency)
   - Check the box for **Git** plugin
   - Search for `GitLab`
   - Check the box for **GitLab** plugin

4. **Install Plugins**

   - Click **Install**
   - Check the option: **Restart Jenkins when installation is complete and no jobs are running**

5. **Wait for Restart**
   - Wait for Jenkins to restart
   - Log back in once the login page reappears

### Verification

After installation, verify the plugins are installed:

- Go to **Manage Jenkins** → **Plugins** → **Installed plugins** tab
- Search for "Git" and "GitLab" to confirm they appear in the list with enabled status

### Installed Plugins

| Plugin            | Version | Status     |
| ----------------- | ------- | ---------- |
| Git client plugin | 6.2.1   | ✅ Enabled |
| Git plugin        | 5.7.0   | ✅ Enabled |
| GitLab Plugin     | 1.9.8   | ✅ Enabled |
