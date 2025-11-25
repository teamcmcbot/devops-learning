# Task 1: Create a User with Non-Interactive Shell

To accommodate the backup agent tool's specifications, the system admin team at xFusionCorp Industries requires the creation of a user with a non-interactive shell. Here's your task:

Create a user named james with a non-interactive shell on App Server 1.

Note: You can find the infrastructure details by clicking on the Details of all Users and Servers button on the top-right section of the page.

## Solution

```bash
[tony@stapp01 ~]$ ls -l /sbin/nologin
-rwxr-xr-x 1 root root 15704 Jan 16  2025 /sbin/nologin
[tony@stapp01 ~]$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
tss:x:59:59:Account used for TPM access:/:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/usr/share/empty.sshd:/usr/sbin/nologin
ansible:x:1000:1000::/home/ansible:/bin/bash
tony:x:1001:1001::/home/tony:/bin/bash
[tony@stapp01 ~]$ sudo useradd -s /sbin/nologin james

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for tony:
Sorry, try again.
[sudo] password for tony:
[tony@stapp01 ~]$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
tss:x:59:59:Account used for TPM access:/:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/usr/share/empty.sshd:/usr/sbin/nologin
ansible:x:1000:1000::/home/ansible:/bin/bash
tony:x:1001:1001::/home/tony:/bin/bash
james:x:1002:1002::/home/james:/sbin/nologin
[tony@stapp01 ~]$
```

## 📚 Conclusion & DevOps Insights

### 🎯 What This Task Teaches Us

This foundational task introduces a critical security concept in Linux system administration: **non-interactive shells**. As a DevOps engineer, understanding user account management with different shell types is essential for maintaining secure and functional infrastructure.

### 🔍 Understanding Non-Interactive Shells

**What is `/sbin/nologin`?**

- A special shell that prevents user login while maintaining account functionality
- Returns an error message and exits immediately when login is attempted
- Different from `/bin/false` (silent exit) or disabling the account entirely

**Key Characteristics:**

```bash
# User exists but cannot login interactively
$ su - james
This account is currently not available.

# Account can still be used for system processes and file ownership
$ chown james:james /some/file  # ✅ Works
$ sudo -u james /some/script    # ✅ Works
$ ssh james@server              # ❌ Fails
```

### 🚀 DevOps Use Cases for Non-Interactive Users

1. **Application Service Accounts**

   ```bash
   # Web server user
   useradd -r -s /sbin/nologin -d /var/www nginx

   # Database service user
   useradd -r -s /sbin/nologin -d /var/lib/mysql mysql
   ```

2. **CI/CD Pipeline Agents**

   ```bash
   # Jenkins agent user
   useradd -s /sbin/nologin -d /opt/jenkins jenkins

   # GitLab runner user
   useradd -s /sbin/nologin gitlab-runner
   ```

3. **Backup and Monitoring Tools**

   ```bash
   # Backup agent (as mentioned in the task)
   useradd -s /sbin/nologin backup-agent

   # Monitoring service user
   useradd -s /sbin/nologin prometheus
   ```

4. **File Transfer and Processing**

   ```bash
   # SFTP-only user for file uploads
   useradd -s /sbin/nologin -d /uploads ftpuser

   # Log processing user
   useradd -s /sbin/nologin logstash
   ```

### 🔐 Security Benefits

**Principle of Least Privilege:**

- Users get only the minimum access needed for their function
- Prevents unauthorized interactive access
- Reduces attack surface in case of credential compromise

**Audit and Compliance:**

- Clear separation between human and service accounts
- Easier to track and monitor automated processes
- Meets security compliance requirements

### 🛠️ DevOps Best Practices

1. **System User Creation Pattern:**

   ```bash
   # Complete service user setup
   useradd -r -s /sbin/nologin -d /opt/myapp -c "MyApp Service User" myapp
   mkdir -p /opt/myapp
   chown myapp:myapp /opt/myapp
   chmod 755 /opt/myapp
   ```

2. **Infrastructure as Code Integration:**

   ```yaml
   # Ansible playbook example
   - name: Create service user
     user:
       name: "{{ service_user }}"
       shell: /sbin/nologin
       system: yes
       home: "{{ service_home }}"
       create_home: yes
   ```

3. **Container and Orchestration:**
   ```dockerfile
   # Dockerfile best practice
   RUN useradd -r -s /sbin/nologin -d /app appuser
   USER appuser
   ```

### 🎯 Why This Matters in DevOps

**Automation and Security:**

- Service accounts need to exist for process ownership but shouldn't allow human login
- Automated tools and scripts can run as these users safely
- Clear distinction between human operators and system processes

**Scalability:**

- Consistent user management across multiple servers
- Easier deployment and configuration management
- Standardized security posture

**Operational Excellence:**

- Reduces human error in production environments
- Enables better monitoring and alerting
- Supports zero-trust security models

### 🔄 Next Steps in Your DevOps Journey

This task builds the foundation for:

- **Day 2**: User account lifecycle management
- **Day 3**: SSH security configurations
- **Day 7**: Advanced authentication methods
- **Later tasks**: Service account automation with Ansible/Terraform

Understanding user management is crucial before diving into containerization, orchestration, and infrastructure automation where service accounts play vital roles in security and operations.
