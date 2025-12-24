# Task 014 - Linux Process Troubleshooting

The production support team of xFusionCorp Industries has deployed some of the latest monitoring tools to keep an eye on every service, application, etc. running on the systems. One of the monitoring systems reported about Apache service unavailability on one of the app servers in Stratos DC.

Identify the faulty app host and fix the issue. Make sure Apache service is up and running on all app hosts. They might not have hosted any code yet on these servers, so you don’t need to worry if Apache isn’t serving any pages. Just make sure the service is up and running. Also, make sure Apache is running on port `8085` on all app servers.

## App Servers

- stapp01: tony@stapp01
- stapp02: steve@stapp02
- stapp03: bruce@stapp03

## Troubleshooting Steps

1. Identify the faulty app server.

```bash
[tony@stapp01 ~]$ sudo systemctl status httpd -l
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2025-12-24 03:17:18 UTC; 6min ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 808 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=1/FAILURE)
  Process: 807 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)
 Main PID: 807 (code=exited, status=1/FAILURE)

Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com httpd[807]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using stapp01.stratos.xfusioncorp.com. Set the 'ServerName' directive globally to suppress this message
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com httpd[807]: (98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:8085
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com httpd[807]: no listening sockets available, shutting down
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com httpd[807]: AH00015: Unable to open logs
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: main process exited, code=exited, status=1/FAILURE
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com kill[808]: kill: cannot find process ""
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service: control process exited, code=exited status=1
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Failed to start The Apache HTTP Server.
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Unit httpd.service entered failed state.
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: httpd.service failed.
```

**NOTE:** The error message indicates that Apache is unable to bind to port `8085` because it is already in use.
**NOTE2:** You can also use the `ss -tulnp` or `netstat -tulpen` command to check which process is using port `8085`.

2. Find the process using port `8085` and stop it.

```bash
[tony@stapp01 ~]$ sudo netstat -tulpen | grep 8085
tcp        0      0 127.0.0.1:8085          0.0.0.0:*               LISTEN      0          1288405856 782/sendmail: accep
```

**NOTE:** The output shows that the `sendmail` service is using port `8085`.

```bash
[tony@stapp01 ~]$ sudo systemctl status sendmail
● sendmail.service - Sendmail Mail Transport Agent
   Loaded: loaded (/usr/lib/systemd/system/sendmail.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2025-12-24 03:17:18 UTC; 13min ago
  Process: 781 ExecStart=/usr/sbin/sendmail -bd $SENDMAIL_OPTS $SENDMAIL_OPTARG (code=exited, status=0/SUCCESS)
  Process: 777 ExecStartPre=/etc/mail/make aliases (code=exited, status=0/SUCCESS)
  Process: 776 ExecStartPre=/etc/mail/make (code=exited, status=0/SUCCESS)
 Main PID: 782 (sendmail)
   CGroup: /docker/e96a41431b20c033146c1ef9d5fc3ae9203c7767e9cac1a3450a2bb9f29db4ae/system.slice/sendmail.service
           └─782 sendmail: accepting connections

Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Starting Sendmail Mail Transport Agent...
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com sendmail[782]: starting daemon (8.14.7): SMTP+queueing@01:00:00
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Started Sendmail Mail Transport Agent.
[tony@stapp01 ~]$ sudo systemctl stop sendmail
[tony@stapp01 ~]$ sudo systemctl status sendmail
● sendmail.service - Sendmail Mail Transport Agent
   Loaded: loaded (/usr/lib/systemd/system/sendmail.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Wed 2025-12-24 03:31:09 UTC; 7s ago
  Process: 781 ExecStart=/usr/sbin/sendmail -bd $SENDMAIL_OPTS $SENDMAIL_OPTARG (code=exited, status=0/SUCCESS)
  Process: 777 ExecStartPre=/etc/mail/make aliases (code=exited, status=0/SUCCESS)
  Process: 776 ExecStartPre=/etc/mail/make (code=exited, status=0/SUCCESS)
 Main PID: 782 (code=exited, status=0/SUCCESS)

Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Starting Sendmail Mail Transport Agent...
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com sendmail[782]: starting daemon (8.14.7): SMTP+queueing@01:00:00
Dec 24 03:17:18 stapp01.stratos.xfusioncorp.com systemd[1]: Started Sendmail Mail Transport Agent.
Dec 24 03:31:09 stapp01.stratos.xfusioncorp.com systemd[1]: Stopping Sendmail Mail Transport Agent...
Dec 24 03:31:09 stapp01.stratos.xfusioncorp.com systemd[1]: Stopped Sendmail Mail Transport Agent.
```

**NOTE:** The `sendmail` service has been stopped successfully.

3. Start the Apache service.

```bash
[tony@stapp01 ~]$ sudo systemctl status httpd -l
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2025-12-24 03:31:58 UTC; 8s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 808 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=1/FAILURE)
 Main PID: 939 (httpd)
   Status: "Processing requests..."
   CGroup: /docker/e96a41431b20c033146c1ef9d5fc3ae9203c7767e9cac1a3450a2bb9f29db4ae/system.slice/httpd.service
           ├─939 /usr/sbin/httpd -DFOREGROUND
           ├─940 /usr/sbin/httpd -DFOREGROUND
           ├─941 /usr/sbin/httpd -DFOREGROUND
           ├─942 /usr/sbin/httpd -DFOREGROUND
           ├─943 /usr/sbin/httpd -DFOREGROUND
           └─944 /usr/sbin/httpd -DFOREGROUND

Dec 24 03:31:58 stapp01.stratos.xfusioncorp.com systemd[1]: Starting The Apache HTTP Server...
Dec 24 03:31:58 stapp01.stratos.xfusioncorp.com httpd[939]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using stapp01.stratos.xfusioncorp.com. Set the 'ServerName' directive globally to suppress this message
Dec 24 03:31:58 stapp01.stratos.xfusioncorp.com systemd[1]: Started The Apache HTTP Server.
```

**NOTE:** The Apache service is now up and running on port `8085`.

4. Verify Apache is running on port `8085`.

```bash
[tony@stapp01 ~]$ sudo netstat -tulpen | grep 8085
tcp        0      0 0.0.0.0:8085            0.0.0.0:*               LISTEN      0          1288978281 939/httpd
```

5. Verify Apache service status on other app servers.

```bash
[steve@stapp02 ~]$ sudo netstat -tulpen | grep 8085
tcp        0      0 0.0.0.0:8085            0.0.0.0:*               LISTEN      0          1288409838 1661/httpd


[banner@stapp03 ~]$ sudo netstat -tulpen | grep 8085
tcp        0      0 0.0.0.0:8085            0.0.0.0:*               LISTEN      0          1288418506 1679/httpd

```

**NOTE:** stapp02 and stapp03 does not have netstat installed by default. I ran `sudo dnf install net-tools -y` to install it.

Alternative: You can also use `sudo ss -tulpn | grep :8085` to verify if Apache is running on port `8085`.

### About `ss` (socket statistics)

`ss` is a modern replacement for `netstat` that inspects socket information (listening ports, established connections, etc.).

In `sudo ss -tulpn`:

- `-t`: show TCP sockets
- `-u`: show UDP sockets
- `-l`: show only listening sockets (services bound to ports)
- `-p`: show process info (program name + PID) that owns the socket (usually requires `sudo`)
- `-n`: show numeric addresses/ports (skip DNS/service-name lookups)

So `ss -tuln` only tells you “something is listening on 8085”, while `ss -tulpn` shows _which process_ (e.g., `httpd`) is listening.

```bash
[steve@stapp02 ~]$ sudo ss -tulpn | grep :8085
tcp   LISTEN 0      511          0.0.0.0:8085       0.0.0.0:*    users:(("httpd",pid=1671,fd=3),("httpd",pid=1670,fd=3),("httpd",pid=1669,fd=3),("httpd",pid=1661,fd=3))

[banner@stapp03 ~]$ sudo ss -tulpn | grep :8085
tcp   LISTEN 0      511          0.0.0.0:8085       0.0.0.0:*    users:(("httpd",pid=1689,fd=3),("httpd",pid=1688,fd=3),("httpd",pid=1687,fd=3),("httpd",pid=1679,fd=3))
```
