# Amazon Linux 2023 Compatibility Issues

## Overview

This document summarizes the compatibility issues encountered when running Terraform user_data scripts designed for Amazon Linux 2 on Amazon Linux 2023 instances, and the solutions implemented.

## Root Cause

**Course Content Age**: The instructor created these scripts when Amazon Linux 2 was the default and most commonly used AMI. At that time (likely 2020-2022), Amazon Linux 2023 didn't exist or wasn't widely adopted.

**AWS AMI Evolution**: AWS has since made Amazon Linux 2023 the default AMI in many regions, but the course materials weren't updated to reflect this change.

## Key Differences Between Amazon Linux 2 and 2023

### Package Manager

- **Amazon Linux 2**: Uses `yum` package manager
- **Amazon Linux 2023**: Uses `dnf` package manager (though yum is aliased to dnf for basic operations)

### Repository System

- **Amazon Linux 2**: Uses `amazon-linux-extras` for additional packages
- **Amazon Linux 2023**: No `amazon-linux-extras` - packages are directly available via dnf

### Package Names

- **Java**:
  - AL2: `java-11-openjdk` via `amazon-linux-extras`
  - AL2023: `java-11-amazon-corretto` via direct dnf installation
- **MySQL Client**:
  - AL2: `mariadb` via `amazon-linux-extras enable mariadb10.5`
  - AL2023: `mariadb105` via direct dnf installation

## Issues Encountered

### 1. Bastion Host (jumpbox-install.sh)

**Problem**: MySQL client installation failed

```bash
# Original (AL2)
sudo amazon-linux-extras enable mariadb10.5
sudo yum install -y mariadb

# Error: amazon-linux-extras: command not found
# Error: No match for argument: mariadb
```

**Solution**: Use AL2023 compatible commands

```bash
sudo dnf install -y mariadb105
```

### 2. App1 & App2 (Apache Installation)

**Problem**: While `yum` commands worked (aliased to dnf), best practice is to use native dnf

**Solution**: Replace `yum` with `dnf`

```bash
# Before
sudo yum update -y
sudo yum install -y httpd

# After
sudo dnf update -y
sudo dnf install -y httpd
```

### 3. App3 (Java Application)

**Problem**: Multiple issues with Java installation and file permissions

```bash
# Original (AL2)
sudo amazon-linux-extras enable java-openjdk11
sudo yum install -y java-11-openjdk

# Errors:
# - amazon-linux-extras: command not found
# - No match for argument: java-11-openjdk
# - Permission denied on log files (directory created by root)
```

**Solution**: Use Amazon Corretto and fix permissions

```bash
sudo dnf install -y java-11-amazon-corretto java-11-amazon-corretto-devel
sudo mkdir -p /home/ec2-user/app3-usermgmt
sudo chown -R ec2-user:ec2-user /home/ec2-user/app3-usermgmt
```

## Files Updated

1. **`jumpbox-install.sh`**: Fixed MySQL client installation
2. **`app1-install.sh`**: Updated package manager from yum to dnf
3. **`app2-install.sh`**: Updated package manager from yum to dnf
4. **`app3-ums-install.tmpl`**: Fixed Java installation and file permissions

## Target Group Health Check Issue

The TG3 (Target Group 3) health check failures were caused by:

1. Java application not starting (due to Java installation failure)
2. Health check path `/login` might not be immediately available during app startup

**Solution**:

- Fixed Java installation enables the app to start
- Added process cleanup to prevent conflicts
- Consider changing health check path to `/` or increasing timeout values

## Prevention for Future Courses

1. **Always specify AMI explicitly** in data sources rather than using "most recent"
2. **Test scripts on current default AMIs** before course release
3. **Use conditional logic** for different OS versions:
   ```bash
   # Example of OS-aware scripting
   if command -v dnf >/dev/null 2>&1; then
       PACKAGE_MANAGER="dnf"
   else
       PACKAGE_MANAGER="yum"
   fi
   ```

## Lessons Learned

1. **Infrastructure as Code needs maintenance** - Even "simple" scripts can break as underlying platforms evolve
2. **Default AMIs change over time** - What works today may not work in 6-12 months
3. **User_data debugging** requires understanding cloud-init logs and OS differences
4. **File permissions matter** - Scripts running as root during cloud-init can create permission issues for application users

## Best Practices Going Forward

1. Use explicit AMI data sources with specific OS versions
2. Add error handling and conditional logic in user_data scripts
3. Test user_data scripts on target AMI before deployment
4. Use configuration management tools (Ansible, etc.) for complex setups
5. Document OS-specific requirements and dependencies

---

_Updated: November 28, 2025_  
_Course: Terraform on AWS with SRE & OaC DevOps_  
_Section: 13-DNS-to-DB_
