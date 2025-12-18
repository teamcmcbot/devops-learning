# Task 011 - Install and Configure Tomcat Server

The Nautilus application development team recently finished the beta version of one of their Java-based applications, which they are planning to deploy on one of the app servers in Stratos DC. After an internal team meeting, they have decided to use the tomcat application server. Based on the requirements mentioned below complete the task:

a. Install tomcat server on App Server 1.

b. Configure it to run on port 6400.

c. There is a ROOT.war file on Jump host at location /tmp.

Deploy it on this tomcat server and make sure the webpage works directly on base URL i.e curl http://stapp01:6400

## Additional Information:

Jump Host:

```bash
thor@jumphost /tmp$ ls -la *.war
-rw-r--r-- 1 root root 4529 Dec 18 02:06 ROOT.war
```

## Solution

1. Install Tomcat server on App Server 1:

```bash
[tony@stapp01 tmp]$ sudo dnf install -y tomcat tomcat-webapps

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for tony:
CentOS Stream 9 - BaseOS                                                33 kB/s | 7.3 kB     00:00
CentOS Stream 9 - BaseOS                                                13 MB/s | 8.8 MB     00:00
CentOS Stream 9 - AppStream                                             50 kB/s | 7.8 kB     00:00
CentOS Stream 9 - AppStream                                             12 MB/s |  26 MB     00:02
CentOS Stream 9 - Extras packages                                       38 kB/s | 8.3 kB     00:00
CentOS Stream 9 - Extras packages                                       46 kB/s |  20 kB     00:00
Extra Packages for Enterprise Linux 9 - x86_64                          93 kB/s |  24 kB     00:00
Extra Packages for Enterprise Linux 9 - x86_64                          15 MB/s |  20 MB     00:01
Extra Packages for Enterprise Linux 9 openh264 (From Cisco) - x86_64   4.4 kB/s | 993  B     00:00
Extra Packages for Enterprise Linux 9 - Next - x86_64                   73 kB/s |  24 kB     00:00
Extra Packages for Enterprise Linux 9 - Next - x86_64                  287 kB/s | 289 kB     00:01
Dependencies resolved.
=======================================================================================================
 Package                            Architecture  Version                       Repository        Size
=======================================================================================================
Installing:
 tomcat                             noarch        1:9.0.87-6.el9                appstream         98 k
 tomcat-webapps                     noarch        1:9.0.87-6.el9                appstream         80 k
Installing dependencies:
 apr                                x86_64        1.7.0-12.el9                  appstream        123 k
 avahi-libs                         x86_64        0.8-23.el9                    baseos            67 k
 copy-jdk-configs                   noarch        4.0-3.el9                     appstream         28 k
 cups-libs                          x86_64        1:2.3.3op2-36.el9             baseos           260 k
 ecj                                noarch        1:4.20-17.el9                 appstream        1.9 M
 freetype                           x86_64        2.10.4-11.el9                 baseos           372 k
 graphite2                          x86_64        1.3.14-9.el9                  baseos            95 k
 harfbuzz                           x86_64        2.7.4-10.el9                  baseos           624 k
 java-1.8.0-openjdk-headless        x86_64        1:1.8.0.472.b08-2.el9         appstream         33 M
 javapackages-filesystem            noarch        6.4.0-1.el9                   appstream         13 k
 javapackages-tools                 noarch        6.4.0-1.el9                   appstream         34 k
 libbrotli                          x86_64        1.0.9-7.el9                   baseos           313 k
 libpng                             x86_64        2:1.6.37-12.el9               baseos           117 k
 lksctp-tools                       x86_64        1.0.19-2.el9                  baseos            94 k
 lua                                x86_64        5.4.4-4.el9                   appstream        188 k
 lua-posix                          x86_64        35.0-8.el9                    appstream        151 k
 nspr                               x86_64        4.36.0-4.el9                  appstream        133 k
 nss                                x86_64        3.112.0-4.el9                 appstream        722 k
 nss-softokn                        x86_64        3.112.0-4.el9                 appstream        399 k
 nss-softokn-freebl                 x86_64        3.112.0-4.el9                 appstream        413 k
 nss-sysinit                        x86_64        3.112.0-4.el9                 appstream         18 k
 nss-util                           x86_64        3.112.0-4.el9                 appstream         88 k
 tomcat-el-3.0-api                  noarch        1:9.0.87-6.el9                appstream        105 k
 tomcat-jsp-2.3-api                 noarch        1:9.0.87-6.el9                appstream         72 k
 tomcat-lib                         noarch        1:9.0.87-6.el9                appstream        6.0 M
 tomcat-servlet-4.0-api             noarch        1:9.0.87-6.el9                appstream        284 k
Installing weak dependencies:
 tomcat-native                      x86_64        1:1.3.0-1.el9                 epel              74 k

Transaction Summary
=======================================================================================================
Install  29 Packages

Total download size: 46 M
Installed size: 135 M
Downloading Packages:
(1/29): avahi-libs-0.8-23.el9.x86_64.rpm                               368 kB/s |  67 kB     00:00
(2/29): freetype-2.10.4-11.el9.x86_64.rpm                              1.4 MB/s | 372 kB     00:00
(3/29): cups-libs-2.3.3op2-36.el9.x86_64.rpm                           1.0 MB/s | 260 kB     00:00
(4/29): graphite2-1.3.14-9.el9.x86_64.rpm                              1.2 MB/s |  95 kB     00:00
(5/29): libpng-1.6.37-12.el9.x86_64.rpm                                2.8 MB/s | 117 kB     00:00
(6/29): harfbuzz-2.7.4-10.el9.x86_64.rpm                               7.4 MB/s | 624 kB     00:00
(7/29): libbrotli-1.0.9-7.el9.x86_64.rpm                               3.7 MB/s | 313 kB     00:00
(8/29): lksctp-tools-1.0.19-2.el9.x86_64.rpm                           2.2 MB/s |  94 kB     00:00
(9/29): copy-jdk-configs-4.0-3.el9.noarch.rpm                          232 kB/s |  28 kB     00:00
(10/29): apr-1.7.0-12.el9.x86_64.rpm                                   651 kB/s | 123 kB     00:00
(11/29): javapackages-filesystem-6.4.0-1.el9.noarch.rpm                376 kB/s |  13 kB     00:00
(12/29): javapackages-tools-6.4.0-1.el9.noarch.rpm                     888 kB/s |  34 kB     00:00
(13/29): ecj-4.20-17.el9.noarch.rpm                                    6.1 MB/s | 1.9 MB     00:00
(14/29): lua-5.4.4-4.el9.x86_64.rpm                                    2.6 MB/s | 188 kB     00:00
(15/29): lua-posix-35.0-8.el9.x86_64.rpm                               4.3 MB/s | 151 kB     00:00
(16/29): nspr-4.36.0-4.el9.x86_64.rpm                                  3.4 MB/s | 133 kB     00:00
(17/29): nss-3.112.0-4.el9.x86_64.rpm                                   17 MB/s | 722 kB     00:00
(18/29): nss-softokn-freebl-3.112.0-4.el9.x86_64.rpm                    11 MB/s | 413 kB     00:00
(19/29): nss-softokn-3.112.0-4.el9.x86_64.rpm                          5.4 MB/s | 399 kB     00:00
(20/29): nss-sysinit-3.112.0-4.el9.x86_64.rpm                          530 kB/s |  18 kB     00:00
(21/29): nss-util-3.112.0-4.el9.x86_64.rpm                             2.5 MB/s |  88 kB     00:00
(22/29): tomcat-9.0.87-6.el9.noarch.rpm                                2.7 MB/s |  98 kB     00:00
(23/29): tomcat-el-3.0-api-9.0.87-6.el9.noarch.rpm                     2.8 MB/s | 105 kB     00:00
(24/29): tomcat-jsp-2.3-api-9.0.87-6.el9.noarch.rpm                    2.0 MB/s |  72 kB     00:00
(25/29): tomcat-servlet-4.0-api-9.0.87-6.el9.noarch.rpm                7.3 MB/s | 284 kB     00:00
(26/29): tomcat-webapps-9.0.87-6.el9.noarch.rpm                        2.2 MB/s |  80 kB     00:00
(27/29): tomcat-lib-9.0.87-6.el9.noarch.rpm                             37 MB/s | 6.0 MB     00:00
(28/29): java-1.8.0-openjdk-headless-1.8.0.472.b08-2.el9.x86_64.rpm     47 MB/s |  33 MB     00:00
(29/29): tomcat-native-1.3.0-1.el9.x86_64.rpm                          258 kB/s |  74 kB     00:00
-------------------------------------------------------------------------------------------------------
Total                                                                   22 MB/s |  46 MB     00:02
Extra Packages for Enterprise Linux 9 - x86_64                         1.6 MB/s | 1.6 kB     00:00
Importing GPG key 0x3228467C:
 Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
 Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Running scriptlet: copy-jdk-configs-4.0-3.el9.noarch                                             1/1
  Running scriptlet: java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64                      1/1
  Preparing        :                                                                               1/1
  Installing       : javapackages-filesystem-6.4.0-1.el9.noarch                                   1/29
  Installing       : nspr-4.36.0-4.el9.x86_64                                                     2/29
  Installing       : nss-util-3.112.0-4.el9.x86_64                                                3/29
  Installing       : javapackages-tools-6.4.0-1.el9.noarch                                        4/29
  Installing       : tomcat-el-3.0-api-1:9.0.87-6.el9.noarch                                      5/29
  Running scriptlet: tomcat-el-3.0-api-1:9.0.87-6.el9.noarch                                      5/29
  Installing       : tomcat-servlet-4.0-api-1:9.0.87-6.el9.noarch                                 6/29
  Running scriptlet: tomcat-servlet-4.0-api-1:9.0.87-6.el9.noarch                                 6/29
  Installing       : tomcat-jsp-2.3-api-1:9.0.87-6.el9.noarch                                     7/29
  Running scriptlet: tomcat-jsp-2.3-api-1:9.0.87-6.el9.noarch                                     7/29
  Installing       : nss-softokn-freebl-3.112.0-4.el9.x86_64                                      8/29
  Installing       : nss-softokn-3.112.0-4.el9.x86_64                                             9/29
  Installing       : nss-3.112.0-4.el9.x86_64                                                    10/29
  Running scriptlet: nss-3.112.0-4.el9.x86_64                                                    10/29
  Installing       : nss-sysinit-3.112.0-4.el9.x86_64                                            11/29
  Installing       : lua-posix-35.0-8.el9.x86_64                                                 12/29
  Installing       : lua-5.4.4-4.el9.x86_64                                                      13/29
  Installing       : copy-jdk-configs-4.0-3.el9.noarch                                           14/29
  Installing       : apr-1.7.0-12.el9.x86_64                                                     15/29
  Installing       : tomcat-native-1:1.3.0-1.el9.x86_64                                          16/29
  Installing       : lksctp-tools-1.0.19-2.el9.x86_64                                            17/29
  Installing       : libpng-2:1.6.37-12.el9.x86_64                                               18/29
  Installing       : libbrotli-1.0.9-7.el9.x86_64                                                19/29
  Installing       : graphite2-1.3.14-9.el9.x86_64                                               20/29
  Installing       : harfbuzz-2.7.4-10.el9.x86_64                                                21/29
  Installing       : freetype-2.10.4-11.el9.x86_64                                               22/29
  Installing       : avahi-libs-0.8-23.el9.x86_64                                                23/29
  Installing       : cups-libs-1:2.3.3op2-36.el9.x86_64                                          24/29
  Installing       : java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64                    25/29
  Running scriptlet: java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64                    25/29
  Installing       : ecj-1:4.20-17.el9.noarch                                                    26/29
  Installing       : tomcat-lib-1:9.0.87-6.el9.noarch                                            27/29
  Running scriptlet: tomcat-1:9.0.87-6.el9.noarch                                                28/29
  Installing       : tomcat-1:9.0.87-6.el9.noarch                                                28/29
  Running scriptlet: tomcat-1:9.0.87-6.el9.noarch                                                28/29
  Installing       : tomcat-webapps-1:9.0.87-6.el9.noarch                                        29/29
  Running scriptlet: nss-3.112.0-4.el9.x86_64                                                    29/29
  Running scriptlet: copy-jdk-configs-4.0-3.el9.noarch                                           29/29
  Running scriptlet: java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64                    29/29
  Running scriptlet: tomcat-webapps-1:9.0.87-6.el9.noarch                                        29/29
  Verifying        : avahi-libs-0.8-23.el9.x86_64                                                 1/29
  Verifying        : cups-libs-1:2.3.3op2-36.el9.x86_64                                           2/29
  Verifying        : freetype-2.10.4-11.el9.x86_64                                                3/29
  Verifying        : graphite2-1.3.14-9.el9.x86_64                                                4/29
  Verifying        : harfbuzz-2.7.4-10.el9.x86_64                                                 5/29
  Verifying        : libbrotli-1.0.9-7.el9.x86_64                                                 6/29
  Verifying        : libpng-2:1.6.37-12.el9.x86_64                                                7/29
  Verifying        : lksctp-tools-1.0.19-2.el9.x86_64                                             8/29
  Verifying        : apr-1.7.0-12.el9.x86_64                                                      9/29
  Verifying        : copy-jdk-configs-4.0-3.el9.noarch                                           10/29
  Verifying        : ecj-1:4.20-17.el9.noarch                                                    11/29
  Verifying        : java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64                    12/29
  Verifying        : javapackages-filesystem-6.4.0-1.el9.noarch                                  13/29
  Verifying        : javapackages-tools-6.4.0-1.el9.noarch                                       14/29
  Verifying        : lua-5.4.4-4.el9.x86_64                                                      15/29
  Verifying        : lua-posix-35.0-8.el9.x86_64                                                 16/29
  Verifying        : nspr-4.36.0-4.el9.x86_64                                                    17/29
  Verifying        : nss-3.112.0-4.el9.x86_64                                                    18/29
  Verifying        : nss-softokn-3.112.0-4.el9.x86_64                                            19/29
  Verifying        : nss-softokn-freebl-3.112.0-4.el9.x86_64                                     20/29
  Verifying        : nss-sysinit-3.112.0-4.el9.x86_64                                            21/29
  Verifying        : nss-util-3.112.0-4.el9.x86_64                                               22/29
  Verifying        : tomcat-1:9.0.87-6.el9.noarch                                                23/29
  Verifying        : tomcat-el-3.0-api-1:9.0.87-6.el9.noarch                                     24/29
  Verifying        : tomcat-jsp-2.3-api-1:9.0.87-6.el9.noarch                                    25/29
  Verifying        : tomcat-lib-1:9.0.87-6.el9.noarch                                            26/29
  Verifying        : tomcat-servlet-4.0-api-1:9.0.87-6.el9.noarch                                27/29
  Verifying        : tomcat-webapps-1:9.0.87-6.el9.noarch                                        28/29
  Verifying        : tomcat-native-1:1.3.0-1.el9.x86_64                                          29/29

Installed:
  apr-1.7.0-12.el9.x86_64
  avahi-libs-0.8-23.el9.x86_64
  copy-jdk-configs-4.0-3.el9.noarch
  cups-libs-1:2.3.3op2-36.el9.x86_64
  ecj-1:4.20-17.el9.noarch
  freetype-2.10.4-11.el9.x86_64
  graphite2-1.3.14-9.el9.x86_64
  harfbuzz-2.7.4-10.el9.x86_64
  java-1.8.0-openjdk-headless-1:1.8.0.472.b08-2.el9.x86_64
  javapackages-filesystem-6.4.0-1.el9.noarch
  javapackages-tools-6.4.0-1.el9.noarch
  libbrotli-1.0.9-7.el9.x86_64
  libpng-2:1.6.37-12.el9.x86_64
  lksctp-tools-1.0.19-2.el9.x86_64
  lua-5.4.4-4.el9.x86_64
  lua-posix-35.0-8.el9.x86_64
  nspr-4.36.0-4.el9.x86_64
  nss-3.112.0-4.el9.x86_64
  nss-softokn-3.112.0-4.el9.x86_64
  nss-softokn-freebl-3.112.0-4.el9.x86_64
  nss-sysinit-3.112.0-4.el9.x86_64
  nss-util-3.112.0-4.el9.x86_64
  tomcat-1:9.0.87-6.el9.noarch
  tomcat-el-3.0-api-1:9.0.87-6.el9.noarch
  tomcat-jsp-2.3-api-1:9.0.87-6.el9.noarch
  tomcat-lib-1:9.0.87-6.el9.noarch
  tomcat-native-1:1.3.0-1.el9.x86_64
  tomcat-servlet-4.0-api-1:9.0.87-6.el9.noarch
  tomcat-webapps-1:9.0.87-6.el9.noarch

Complete!


[tony@stapp01 tmp]$ tomcat version
Server version: Apache Tomcat/9.0.87
Server built:   Dec 14 1969 11:59:35 UTC
Server number:  9.0.87.0
OS Name:        Linux
OS Version:     5.15.0-1083-gcp
Architecture:   amd64
JVM Version:    1.8.0_472-b08
JVM Vendor:     Red Hat, Inc.
[tony@stapp01 tmp]$ java -version
openjdk version "1.8.0_472"
OpenJDK Runtime Environment (build 1.8.0_472-b08)
OpenJDK 64-Bit Server VM (build 25.472-b08, mixed mode)
```

2. Configure Tomcat to run on port 6400:
   Change port 8080 to 6400 in /etc/tomcat/server.xml file.

```bash
[tony@stapp01 tmp]$ sudo grep -n 'Connector port=' /etc/tomcat/server.xml
69:    <Connector port="8080" protocol="HTTP/1.1"
91:    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
108:    <Connector port="8443" protocol="org.apache.coyote.http11.Http11AprProtocol"


[tony@stapp01 tmp]$ sudo vi /etc/tomcat/server.xml
[tony@stapp01 tmp]$ sudo grep -n 'Connector port=' /etc/tomcat/server.xml
69:    <Connector port="6400" protocol="HTTP/1.1"
91:    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
108:    <Connector port="8443" protocol="org.apache.coyote.http11.Http11AprProtocol"
```

3. Start and enable Tomcat service:

```bash
[tony@stapp01 tmp]$ sudo systemctl restart tomcat
[tony@stapp01 tmp]$ sudo systemctl status tomcat
● tomcat.service - Apache Tomcat Web Application Container
     Loaded: loaded (/usr/lib/systemd/system/tomcat.service; disabled; preset: disabled)
     Active: active (running) since Thu 2025-12-18 03:04:55 UTC; 9s ago
   Main PID: 3218 (java)
      Tasks: 50 (limit: 411434)
     Memory: 155.7M
     CGroup: /docker/6e1cb42810f2b1ff0a402984118f357f7292aedc7baaae54d397e2b51d2f6176/system.slice/tomcat.service
             └─3218 /usr/lib/jvm/jre/bin/java -Djavax.sql.DataSource.Factory=org.apache.commons.dbcp.BasicDataSourceFactory -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar: -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat -Djava.endorsed.dirs= -Djava.io.tmpdir=/var/cache/tomcat/temp -Djava.util.logging.config.file=/usr/share/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dsun.io.useCanonCaches=false org.apache.catalina.startup.Bootstrap start

Dec 18 03:04:56 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:56.305 INFO [main] org.apache.catalina.core.AprLifecycleListener.initializeSSL OpenSSL successfully initialized [OpenSSL 3.5.1 1 Jul 2025]
Dec 18 03:04:57 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:57.308 INFO [main] org.apache.coyote.AbstractProtocol.init Initializing ProtocolHandler ["http-nio-6400"]
Dec 18 03:04:57 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:57.323 INFO [main] org.apache.catalina.startup.Catalina.load Server initialization in [1479] milliseconds
Dec 18 03:04:57 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:57.417 INFO [main] org.apache.catalina.core.StandardService.startInternal Starting service [Catalina]
Dec 18 03:04:57 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:57.417 INFO [main] org.apache.catalina.core.StandardEngine.startInternal Starting Servlet engine: [Apache Tomcat/9.0.87]
Dec 18 03:04:57 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:57.424 INFO [main] org.apache.catalina.startup.HostConfig.deployDirectory Deploying web application directory [/var/lib/tomcat/webapps/ROOT]
Dec 18 03:04:58 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:58.658 INFO [main] org.apache.jasper.servlet.TldScanner.scanJars At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.
Dec 18 03:04:58 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:58.745 INFO [main] org.apache.catalina.startup.HostConfig.deployDirectory Deployment of web application directory [/var/lib/tomcat/webapps/ROOT] has finished in [1,320] ms
Dec 18 03:04:58 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:58.748 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-6400"]
Dec 18 03:04:58 stapp01.stratos.xfusioncorp.com server[3218]: 18-Dec-2025 03:04:58.810 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [1486] milliseconds


[tony@stapp01 tmp]$ sudo ss -ltnp | grep 6400
LISTEN 0      100          0.0.0.0:6400       0.0.0.0:*    users:(("java",pid=3218,fd=59))
```

4. Copy the ROOT.war file from Jump host to App Server 1 and deploy it:

```bash
thor@jumphost /tmp$ scp ROOT.war tony@stapp01:/tmp/
tony@stapp01's password:
ROOT.war                                                             100% 4529    11.5MB/s   00:00
```

```bash
# remove the default ROOT webapp if present (very likely from tomcat-webapps)
sudo rm -rf /var/lib/tomcat/webapps/ROOT /var/lib/tomcat/webapps/ROOT.war

# deploy the provided ROOT.war
sudo mv /tmp/ROOT.war /var/lib/tomcat/webapps/ROOT.war
sudo chown tomcat:tomcat /var/lib/tomcat/webapps/ROOT.war
sudo chmod 0644 /var/lib/tomcat/webapps/ROOT.war


[tony@stapp01 webapps]$ ls -la
total 20
drwxrwxr-x 3 root   tomcat 4096 Dec 18 03:08 .
drwxr-xr-x 3 root   tomcat 4096 Dec 18 02:58 ..
drwxr-xr-x 4 tomcat tomcat 4096 Dec 18 03:08 ROOT
-rw-r--r-- 1 tomcat tomcat 4529 Dec 18 02:56 ROOT.war
```

NOTE: You are seeing ROOT folder along with ROOT.war because Tomcat auto-extracted the WAR file upon startup.

5. Verify the deployment by accessing the application URL:

```bash
[tony@stapp01 ROOT]$ curl -i http://localhost:6400/
HTTP/1.1 200
Accept-Ranges: bytes
ETag: W/"471-1580289830000"
Last-Modified: Wed, 29 Jan 2020 09:23:50 GMT
Content-Type: text/html
Content-Length: 471
Date: Thu, 18 Dec 2025 03:12:02 GMT

<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <title>SampleWebApp</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <h2>Welcome to xFusionCorp Industries!</h2>
        <br>

    </body>
</html>

```

6. Verify from Jump host as well:

```bash
thor@jumphost /tmp$ curl -i http://stapp01:6400/
HTTP/1.1 200
Accept-Ranges: bytes
ETag: W/"471-1580289830000"
Last-Modified: Wed, 29 Jan 2020 09:23:50 GMT
Content-Type: text/html
Content-Length: 471
Date: Thu, 18 Dec 2025 03:12:19 GMT

<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <title>SampleWebApp</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <h2>Welcome to xFusionCorp Industries!</h2>
        <br>

    </body>
</html>
```
