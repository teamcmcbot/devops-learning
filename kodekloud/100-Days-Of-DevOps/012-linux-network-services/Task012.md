# Task 012: Linux Network Services

Our monitoring tool has reported an issue in Stratos Datacenter. One of our app servers has an issue, as its Apache service is not reachable on port 5003 (which is the Apache port). The service itself could be down, the firewall could be at fault, or something else could be causing the issue.

Use tools like telnet, netstat, etc. to find and fix the issue. Also make sure Apache is reachable from the jump host without compromising any security settings.

Once fixed, you can test the same using command curl http://stapp01:5003 command from jump host.

Note: Please do not try to alter the existing index.html code, as it will lead to task failure.

## Troubleshooting Steps

1. Run Curl Command from Jump Host:

```bash
thor@jumphost ~$ curl http://stapp01:5003
curl: (7) Failed to connect to stapp01 port 5003: No route to host
```

**What I learned:** The service is not reachable, indicating a potential network or service issue.

2. Run Telnet Command from Jump Host:

```bash
thor@jumphost ~$ telnet stapp01 5003
Trying 172.16.238.10...
telnet: connect to address 172.16.238.10: No route to host
```

3. Run this on netstat on stapp01 to check if Apache is listening on port 5003:

```bash
[tony@stapp01 ~]$ sudo netstat -tulpen | grep 5003
tcp        0      0 127.0.0.1:5003          0.0.0.0:*               LISTEN      0          241522806  502/sendmail: accep
```

**What I learned:** Port 5003 is used by sendmail service instead of Apache.

4. Check systemctl status of httpd and sendmail services:

```bash
[tony@stapp01 ~]$ sudo systemctl status sendmail
● sendmail.service - Sendmail Mail Transport Agent
   Loaded: loaded (/usr/lib/systemd/system/sendmail.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2025-12-21 16:12:15 UTC; 6min ago
  Process: 495 ExecStart=/usr/sbin/sendmail -bd $SENDMAIL_OPTS $SENDMAIL_OPTARG (code=exited, status=0/
SUCCESS)
  Process: 491 ExecStartPre=/etc/mail/make aliases (code=exited, status=0/SUCCESS)
  Process: 490 ExecStartPre=/etc/mail/make (code=exited, status=0/SUCCESS)
 Main PID: 502 (sendmail)
    Tasks: 1 (limit: 411434)
   Memory: 3.1M
   CGroup: /docker/96fdc6f6c611be9f6f9960438214fb94eb5d93c357d1fd85a38ab60b10007404/system.slice/sendma
il.service
           └─502 sendmail: accepting connections

Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: T
rying to read PID file /run/sendmail.pid in case it changed
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
an't open PID file /run/sendmail.pid (yet?) after start: No such file or directory
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: i
notify event
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: N
ew main PID 502 belongs to service, we are happy.
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: M
ain PID loaded: 502
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: S
topping watch for PID file /run/sendmail.pid
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
hanged start -> running
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: J
ob sendmail.service/start finished, result=done
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: Started Sendmail Mail Transport Agent.
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: F
ailed to send unit change signal for sendmail.service: Connection reset by peer


[tony@stapp01 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sun 2025-12-21 16:12:15 UTC; 8min ago
     Docs: man:httpd.service(8)
  Process: 559 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)

 Main PID: 559 (code=exited, status=1/FAILURE)
   Status: "Reading configuration..."

Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com httpd[559]: (98)Address already in use: AH00072: make_s
ock: could not bind to address 0.0.0.0:5003
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com httpd[559]: no listening sockets available, shutting do
wn
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com httpd[559]: AH00015: Unable to open logs
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Chil
d 559 belongs to httpd.service.
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Main
 process exited, code=exited, status=1/FAILURE
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Fail
ed with result 'exit-code'.
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Chan
ged start -> failed
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Job
httpd.service/start finished, result=failed
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: Failed to start The
 Apache HTTP Server.
Dec 21 16:12:15 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Unit
 entered failed state.
```

**What I learned:** The sendmail service is occupying port 5003, preventing Apache from starting.

5. Stop and Disable sendmail service:

```bash
[tony@stapp01 ~]$ sudo systemctl stop sendmail
[tony@stapp01 ~]$ sudo systemctl status sendmail
● sendmail.service - Sendmail Mail Transport Agent
   Loaded: loaded (/usr/lib/systemd/system/sendmail.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
an't open PID file /run/sendmail.pid (yet?) after stop-sigterm: No such file or directory
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: M
ain process exited, code=exited, status=0/SUCCESS
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: Succeeded.
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
hanged stop-sigterm -> dead
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: J
ob sendmail.service/stop finished, result=done
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: Stopped Sendmail Mail Transport Agent.
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
ollecting.
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
ollecting.
Dec 21 16:21:57 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
ollecting.
Dec 21 16:25:27 stapp01.stratos.xfusioncorp.com systemd[1]: sendmail.service: C
ollecting.
```

6. Start and Enable httpd service:

```bash
[tony@stapp01 ~]$ sudo systemctl start httpd
[tony@stapp01 ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[tony@stapp01 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2025-12-21 16:26:24 UTC; 1min 3s ago
     Docs: man:httpd.service(8)
 Main PID: 1350 (httpd)
   Status: "Running, listening on: port 5003"
    Tasks: 212 (limit: 411434)
   Memory: 21.4M
   CGroup: /docker/96fdc6f6c611be9f6f9960438214fb94eb5d93c357d1fd85a38ab60b10007404/system.slice/httpd.
service
           ├─1350 /usr/sbin/httpd -DFOREGROUND
           ├─1375 /usr/sbin/httpd -DFOREGROUND
           ├─1376 /usr/sbin/httpd -DFOREGROUND
           ├─1377 /usr/sbin/httpd -DFOREGROUND
           └─1378 /usr/sbin/httpd -DFOREGROUND

Dec 21 16:26:24 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Started, listening on: port 5003, MAINPID=1350)
Dec 21 16:26:34 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
Dec 21 16:26:43 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
Dec 21 16:26:53 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
Dec 21 16:27:04 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
Dec 21 16:27:14 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
Dec 21 16:27:20 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Chan
ged dead -> running
Dec 21 16:27:20 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Fail
ed to reset devices.list: Operation not permitted
Dec 21 16:27:20 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Fail
ed to set invocation ID on control group /docker/96fdc6f6c611be9f6f9960438214fb94eb5d93c357d1fd85a38ab6
0b10007404/system.slice/httpd.service, ignoring: Operation not permitted
Dec 21 16:27:24 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: Got
notification message from PID 1350 (READY=1, STATUS=Running, listening on: port 5003)
```

7. Verfiy httpd is listening on port 5003:

```bash
[tony@stapp01 ~]$ sudo netstat -tulpen | grep 5003
tcp        0      0 0.0.0.0:5003            0.0.0.0:*               LISTEN      0          242358592  1350/httpd
```

**What I learned:** Apache is now successfully running and listening on port 5003.

8. Test Curl Command from Jump Host Again:

```bash
thor@jumphost ~$ curl http://stapp01:5003
curl: (7) Failed to connect to stapp01 port 5003: No route to host
```

**What I learned:** The service is still not reachable, indicating a potential firewall issue.

9. Check iptables Rules on stapp01:

```bash
[tony@stapp01 ~]$ sudo iptables -L -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination
1    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
# Warning: iptables-legacy tables present, use iptables-legacy to see them
```

**What I learned:** There is a REJECT rule in the INPUT chain that may be blocking access to port 5003.

10. Add iptables Rule to Allow Traffic on Port 5003:

```bash
[tony@stapp01 ~]$ sudo iptables -I INPUT 4 -p tcp --dport 5003 -j ACCEPT
[tony@stapp01 ~]$ sudo iptables -L -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:5003
5    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
6    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination
1    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
# Warning: iptables-legacy tables present, use iptables-legacy to see them

```

11. Test Curl Command from Jump Host Again:

```bash
thor@jumphost ~$ curl http://stapp01:5003 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html lang="en">
<head>
  <meta name="generator" content="HTML Tidy for HTML5 for Linux version 5.7.28">
  <title>HTTP Server Test Page powered by CentOS</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link rel="shortcut icon" href="http://www.centos.org/favicon.ico">
  <style type="text/css">
      /*<![CDATA[*/
 44  195k   44 89520    0     0  85.3M      0 --:--:-- --:--:-- --:--:-- 85.3M
curl: (23) Failure writing output to destination
thor@jumphost ~$
```

**What I learned:** The Apache service is now reachable on port 5003 from the jump host.

## Summary of Fixes Applied

- Stopped and disabled the sendmail service that was occupying port 5003.
- Started and enabled the Apache (httpd) service to listen on port 5003.
- Added an iptables rule to allow incoming traffic on port 5003.
  The issue has been successfully resolved.
