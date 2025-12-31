# Task 005 - Configure Jenkins Job for Package Installation

Some new requirements have come up to install and configure some packages on the Nautilus infrastructure under Stratos Datacenter. The Nautilus DevOps team installed and configured a new Jenkins server so they wanted to create a Jenkins job to automate this task. Find below more details and complete the task accordingly:

1. Access the Jenkins UI by clicking on the Jenkins button in the top bar. Log in using the credentials: username `admin` and password `Adm!n321`.

2. Create a new Jenkins job named `install-packages` and configure it with the following specifications:

Add a string parameter named `PACKAGE`.
Configure the job to install a package specified in the `$PACKAGE` parameter on the storage server within the Stratos Datacenter.

Note:

1. Ensure to install any required plugins and restart the Jenkins service if necessary. Opt for Restart Jenkins when installation is complete and no jobs are running on the plugin installation/update page. Refresh the UI page if needed after restarting the service.

2. Verify that the Jenkins job runs successfully on repeated executions to ensure reliability.

3. Capture screenshots of your configuration for documentation and review purposes. Alternatively, use screen recording software like loom.com for comprehensive documentation and sharing.

## Solution Steps:

### Part 1: Configure Passwordless Sudo on Storage Server

Since Jenkins will run commands on the storage server via SSH, the user needs passwordless sudo access.

1. SSH to the storage server from the jump host:

   ```bash
   ssh natasha@ststor01
   # Password: Bl@kW
   ```

2. Switch to root and configure sudoers:

   ```bash
   sudo su -
   # Enter password: Bl@kW

   echo "natasha ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/natasha
   chmod 440 /etc/sudoers.d/natasha
   exit
   ```

3. Verify passwordless sudo works:
   ```bash
   sudo whoami
   # Should return "root" without asking for password
   ```

---

### Part 2: Install SSH Plugin in Jenkins

1. Access the Jenkins UI and log in with credentials: username `admin` and password `Adm!n321`.

2. Go to **Manage Jenkins → Plugins → Available plugins**.

3. Search for `SSH` and install the **SSH plugin** (by CloudBees).

4. Check **"Restart Jenkins when installation is complete and no jobs are running"**.

5. Refresh the page after Jenkins restarts.

---

### Part 3: Configure SSH Remote Host

1. Go to **Manage Jenkins → System**.

2. Scroll down to **SSH remote hosts** section.

3. Click **Add** to add a new SSH site:

   - **Hostname:** `ststor01`
   - **Port:** `22`
   - **Credentials:** Click **Add → Jenkins**
     - Kind: `Username with password`
     - Username: `natasha`
     - Password: `Bl@kW`
     - ID: `natasha-ststor01`
     - Description: `Storage Server SSH Credentials`
     - Click **Add**
   - Select the newly created credential from the dropdown

4. Click **Save** at the bottom of the page.

---

### Part 4: Create the Jenkins Job

1. From the Jenkins dashboard, click on **"New Item"**.

2. Enter the job name as `install-packages`, select **"Freestyle project"**, and click **"OK"**.

3. In the job configuration page:

   **a. Add Parameter:**

   - Check **"This project is parameterized"**
   - Click **"Add Parameter"** → **"String Parameter"**
   - Name: `PACKAGE`
   - Default Value: (leave empty or set a default like `tree`)

   **b. Add Build Step:**

   - Scroll down to **"Build"** section
   - Click **"Add build step"** → **"Execute shell script on remote host using ssh"**
   - SSH site: Select `natasha@ststor01:22`
   - Command:
     ```bash
     sudo yum install -y $PACKAGE
     ```

4. Click **Save**.

---

### Part 5: Test the Job

1. Click **"Build with Parameters"** from the left sidebar.
2. Enter a package name (e.g., `cowsay` or `tree`) in the PACKAGE field.
3. Click **"Build"**.
4. Check the **Console Output** to verify the build succeeded.

---

## Testing the Job

### Test 1: Install `tree`

1. Click "Build with Parameters"
2. Enter `tree` in the PACKAGE field
3. Click "Build"
4. Verify installation (SSH to storage server):
   ```bash
   ssh natasha@ststor01 'tree --version'
   ```

### Test 2: Install `cowsay`

1. Click "Build with Parameters"
2. Enter `cowsay` in the PACKAGE field
3. Click "Build"
4. Verify installation:
   ```bash
   ssh natasha@ststor01 'cowsay "Hello from Jenkins!"'
   ```
   Expected output:
   ```
    ______________________
   < Hello from Jenkins! >
    ----------------------
           \   ^__^
            \  (oo)\_______
               (__)\       )\/\
                   ||----w |
                   ||     ||
   ```

### Test 3: Install `wget`

1. Click "Build with Parameters"
2. Enter `wget` in the PACKAGE field
3. Click "Build"
4. Verify:
   ```bash
   ssh natasha@ststor01 'which wget'
   ```

### Verification Commands (on Storage Server)

```bash
# SSH to storage server
ssh natasha@ststor01

# Check if package is installed (CentOS/RHEL)
rpm -qa | grep cowsay
rpm -qa | grep tree

# Check package location
which cowsay
which tree
```

---

## Troubleshooting

### Issue: "SSH Site not specified"

- Re-save the SSH remote host configuration in **Manage Jenkins → System**
- Make sure credentials are selected before saving

### Issue: "sudo: a password is required"

- Configure passwordless sudo (see Part 1)
- Or use this command as a workaround:
  ```bash
  echo 'Bl@kW' | sudo -S yum install -y $PACKAGE
  ```

### Issue: "Package not found"

- Storage server uses CentOS/RHEL, so use `yum`, not `apt-get`
- Some packages have different names (e.g., `httpd` instead of `apache2`)

---

## Key Concepts Learned

| Concept             | Description                                         |
| ------------------- | --------------------------------------------------- |
| SSH Plugin          | Enables Jenkins to execute commands on remote hosts |
| Parameterized Build | Allows passing variables to build jobs              |
| SSH Remote Host     | Pre-configured SSH connection settings              |
| Passwordless Sudo   | Required for automated package installation         |

---
