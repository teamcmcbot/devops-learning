# Task 006: Create a Cron Job

The Nautilus system admins team has prepared scripts to automate several day-to-day tasks. They want them to be deployed on all app servers in Stratos DC on a set schedule. Before that they need to test similar functionality with a sample cron job. Therefore, perform the steps below:

a. Install cronie package on all Nautilus app servers and start crond service.

b. Add a cron _/5 _ \* \* \* echo hello > /tmp/cron_text for root user.

## Instructions

### Servers:

ssh tony@stapp01
ssh steve@stapp02
ssh banner@stapp03

## Steps:

1. Install cronie package on all app servers

# Task 006: Create a Cron Job

The Nautilus system admins team has prepared scripts to automate several day-to-day tasks. They want them to be deployed on all app servers in Stratos DC on a set schedule. Before that they need to test similar functionality with a sample cron job. Therefore, perform the steps below:

a. Install cronie package on all Nautilus app servers and start crond service.

b. Add a cron _/5 _ \* \* \* echo hello > /tmp/cron_text for root user.

## Instructions

### Servers:

ssh tony@stapp01
ssh steve@stapp02
ssh banner@stapp03

## Steps:

1. Install cronie package on all app servers

```bash
sudo dnf install -y cronie
```

2. Verify crond service is running and enabled

```bash
[banner@stapp03 ~]$ sudo systemctl status crond
● crond.service - Command Scheduler
     Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; preset: enabled)
     Active: active (running) since Sun 2025-11-30 02:33:32 UTC; 8min ago
   Main PID: 1022 (crond)
      Tasks: 1 (limit: 411434)
     Memory: 1.0M
     CGroup: /docker/adbb6bf486106786363fab64e99c71b5590ea44261316bbe8f4b7284eb04dd6d/system.slice/crond.service
             └─1022 /usr/sbin/crond -n

Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com systemd[1]: crond.service: Changed dead -> running
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com systemd[1]: crond.service: Job 66 crond.service/start finished, result=done
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com systemd[1]: Started Command Scheduler.
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com systemd[1022]: crond.service: Executing: /usr/sbin/crond -n
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com crond[1022]: (CRON) STARTUP (1.5.7)
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com crond[1022]: (CRON) INFO (Syslog will be used instead of sendmail.)
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com crond[1022]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 48% if used.)
Nov 30 02:33:32 stapp03.stratos.xfusioncorp.com crond[1022]: (CRON) INFO (running with inotify support)
[banner@stapp03 ~]$
```

3. Add cron job for root user

```bash
sudo crontab -e
```

Add the following line to the crontab file:

_/5 _ \* \* \* echo hello > /tmp/cron_text

Save and exit the editor.

4. Verify the cron job has been added

```bash
[tony@stapp01 ~]$ sudo crontab -l
*/5 * * * * echo hello > /tmp/cron_text
```

5. Repeat the above steps on all Nautilus app servers (stapp01, stapp02, stapp03).

```bash
[steve@stapp02 ~]$ sudo crontab -e
[sudo] password for steve:
no crontab for root - using an empty one
crontab: installing new crontab
[steve@stapp02 ~]$ sudo crontab -l
*/5 * * * * echo hello > /tmp/cron_text


[banner@stapp03 ~]$ sudo crontab -e
[sudo] password for banner:
no crontab for root - using an empty one
crontab: installing new crontab
[banner@stapp03 ~]$ sudo crontab -l
*/5 * * * * echo hello > /tmp/cron_text
```

6. Verify the cron job is working by checking the /tmp/cron_text file after a few minutes

```bash
[tony@stapp01 ~]$ cat /tmp/cron_text
hello

[steve@stapp02 ~]$ cat /tmp/cron_text
hello

[banner@stapp03 ~]$ cat /tmp/cron_text
hello

```
