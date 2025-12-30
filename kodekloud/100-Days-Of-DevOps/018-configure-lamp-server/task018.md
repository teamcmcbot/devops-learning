# Task 018 - Configure LAMP Server

xFusionCorp Industries is planning to host a `WordPress` website on their infra in Stratos Datacenter. They have already done infrastructure configuration—for example, on the storage server they already have a shared directory `/var/www/html` that is mounted on each app host under `/var/www/html` directory. Please perform the following steps to accomplish the task:

a. Install `httpd`, `php` and its dependencies on all app hosts.

b. Apache should serve on port `5000` within the apps.

c. Install/Configure `MariaDB` server on DB Server.

d. Create a database named `kodekloud_db1` and create a database user named `kodekloud_aim` identified as password `dCV3szSGNA`. Further make sure this newly created user is able to perform all operation on the database you created.

e. Finally you should be able to access the website on LBR link, by clicking on the App button on the top bar. You should see a message like App is able to connect to the database using user kodekloud_aim

## Pre-checks:

1. You have 3 CentOS 7 servers already deployed in Stratos Datacenter.
2. /var/www/html is already mounted from the storage server on all app hosts.

```bash
[tony@stapp01 ~]$ cat /var/www/html/index.php
<?php

$dbname = 'kodekloud_db1';
$dbuser = 'kodekloud_aim';
$dbpass = 'dCV3szSGNA';
$dbhost = 'stdb01';

$link = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");
echo "App is able to connect to the database using user $dbuser";
```

## Solution Steps:

1. Install `httpd`, `php` and its dependencies on all app hosts (`stapp01` and `stapp02`):

```bash
sudo dnf install httpd php php-mysqlnd -y
```

2. Configure Apache to serve on port 5000 on both app hosts:

```bash
cat /etc/httpd/conf/httpd.conf | grep Listen
sudo sed -i 's/Listen 80/Listen 5000/' /etc/httpd/conf/httpd.conf
cat /etc/httpd/conf/httpd.conf | grep Listen
sudo systemctl restart httpd
sudo systemctl enable httpd

# Verify Apache is listening on port 5000
sudo netstat -tulpen | grep 5000
sudo ss -tulpn | grep 5000
```

3. Install and configure `MariaDB` server on the DB server (`stdb01`):

```bash
sudo dnf install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

4. Create the database `kodekloud_db1` and user `kodekloud_aim` with the specified password on the DB server:

```bash
sudo mysql -u root <<EOF
CREATE DATABASE kodekloud_db1;
CREATE USER 'kodekloud_aim'@'%' IDENTIFIED BY 'dCV3szSGNA';
GRANT ALL PRIVILEGES ON kodekloud_db1.* TO 'kodekloud_aim'@'%';
FLUSH PRIVILEGES;
EOF
```

Verify the database and user creation:

```bash
[peter@stdb01 ~]$ mysql -u kodekloud_aim -p'dCV3szSGNA'
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 6
Server version: 10.5.29-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| kodekloud_db1      |
+--------------------+
2 rows in set (0.000 sec)

MariaDB [(none)]>
```

5. From Jump Host, access the website using the LBR link by clicking on the App button on the top bar. You should see the message confirming the app can connect to the database.

Alternatively, you can `curl` to LBR:

```bash
thor@jumphost ~$ curl http://stlb01.stratos.xfusioncorp.com/
App is able to connect to the database using user kodekloud_aim

thor@jumphost ~$ curl http://stlb01
App is able to connect to the database using user kodekloud_aim
```
