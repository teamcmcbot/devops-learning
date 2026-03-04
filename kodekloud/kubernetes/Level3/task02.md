# Task 02: 

The Nautilus DevOps team want to deploy a PHP website on Kubernetes cluster. They are going to use Apache as a web server and Mysql for database. The team had already gathered the requirements and now they want to make this website live. Below you can find more details:



1) Create a config map `php-config` for `php.ini` with `variables_order = "EGPCS"` data.


2) Create a deployment named `lamp-wp`.


3) Create two containers under it. First container must be `httpd-php-container` using image `webdevops/php-apache:alpine-3-php7` and second container must be `mysql-container` from image `mysql:5.6`. Mount `php-config` configmap in httpd container at `/opt/docker/etc/php/php.ini` location.


4) Create kubernetes generic secrets for mysql related values like myql root password, mysql user, mysql password, mysql host and mysql database. Set any values of your choice.


5) Add some environment variables for both containers:


a) `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` and `MYSQL_HOST`. Take their values from the secrets you created. Please make sure to use `env` field (do not use `envFrom`) to define the name-value pair of environment variables.


6) Create a node port type service `lamp-service` to expose the web application, nodePort must be `30008`.


7) Create a service for mysql named `mysql-service` and its port must be `3306`.


8) We already have `/tmp/index.php` file on jump_host server.


a) Copy this file into httpd container under Apache document root i.e /app and replace the dummy values for mysql related variables with the environment variables you have set for mysql related parameters. Please make sure you do not hard code the mysql related details in this file, you must use the environment variables to fetch those values.


b) You must be able to access this index.php on node port 30008 at the end, please note that you should see Connected successfully message while accessing this page.


Note:


The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

## Additional Details

```bash
thor@jumphost ~$ cat /tmp/index.php 
<?php
$dbname = 'dbname';
$dbuser = 'dbuser';
$dbpass = 'dbpass';
$dbhost = 'dbhost';

$connect = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");

$test_query = "SHOW TABLES FROM $dbname";
$result = mysqli_query($test_query);

if ($result->connect_error) {
   die("Connection failed: " . $conn->connect_error);
}
  echo "Connected successfully";
```

## Solution:

1. Create config map

```bash
thor@jumphost ~$ echo 'variables_order = "EGPCS"' > php.ini
thor@jumphost ~$ k create cm php-config --from-file=php.ini
configmap/php-config created
thor@jumphost ~$ k describe cm php-config
Name:         php-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
php.ini:
----
variables_order = "EGPCS"


BinaryData
====

Events:  <none>
```

2. Create Secrets

```bash
thor@jumphost ~$ k create secret generic mysql-secret --from-literal=mysql-root-password=kode-root-pw --from-literal=mysql-database=kode-db --from-literal=mysql-user=kode-user-name --from-literal=mysql-password=kode-user-pw --from-literal=mysql-host=mysql-service
secret/mysql-secret created
thor@jumphost ~$ k describe secret/mysql-secret
Name:         mysql-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
mysql-database:       7 bytes
mysql-host:           13 bytes
mysql-password:       12 bytes
mysql-root-password:  12 bytes
mysql-user:           14 bytes
```

3. Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: lamp-wp
  name: lamp-wp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lamp-wp
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: lamp-wp
    spec:
      volumes:
      - name: php-config-volume
        configMap:
          name: php-config
      containers:
      - image: webdevops/php-apache:alpine-3-php7
        name: httpd-php-container
        volumeMounts:
        - name: php-config-volume
          mountPath: /opt/docker/etc/php/php.ini
          subPath: php.ini
          readOnly: true
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-host
        resources: {}
      - image: mysql:5.6
        name: mysql-container
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-host
        resources: {}
status: {}
```

4. Create lamb-service:

```bash
thor@jumphost ~$ cat lamp-service.yaml 
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: lamp-wp
  name: lamp-service
spec:
  ports:
  - port: 80
    protocol: TCP
    nodePort: 30008
  selector:
    app: lamp-wp
  type: NodePort
status:
  loadBalancer: {}

thor@jumphost ~$ k describe svc lamp-service
Name:                     lamp-service
Namespace:                default
Labels:                   app=lamp-wp
Annotations:              <none>
Selector:                 app=lamp-wp
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.232.230
IPs:                      10.96.232.230
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30008/TCP
Endpoints:                10.244.0.5:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

5. Create mysql-service:

```bash
thor@jumphost ~$ k expose deploy lamp-wp --type=ClusterIP --name=mysql-service --port=3306
service/mysql-service exposed

thor@jumphost ~$ k describe svc mysql-service
Name:              mysql-service
Namespace:         default
Labels:            app=lamp-wp
Annotations:       <none>
Selector:          app=lamp-wp
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.213.31
IPs:               10.96.213.31
Port:              <unset>  3306/TCP
TargetPort:        3306/TCP
Endpoints:         10.244.0.5:3306
Session Affinity:  None
Events:            <none>
```

6. Copy /tmp/index.php to httpd-php-container and edit the env variables.

```bash
thor@jumphost ~$ k cp /tmp/index.php lamp-wp-6c898f66fd-lgnm5:/app/index.php -c httpd-php-container
thor@jumphost ~$ k exec -it lamp-wp-6c898f66fd-lgnm5 -c httpd-php-container -- sh
/ # cd app/
/app # vi index.php 
/app # cat index.php 
<?php
$dbname = getenv('MYSQL_DATABASE');
$dbuser = getenv('MYSQL_USER');
$dbpass = getenv('MYSQL_PASSWORD');
$dbhost = getenv('MYSQL_HOST');

$connect = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");

$test_query = "SHOW TABLES FROM $dbname";
$result = mysqli_query($test_query);

if ($result->connect_error) {
   die("Connection failed: " . $conn->connect_error);
}
  echo "Connected successfully";/app # 
```

## Verification 

Access the website at https://30008-port-pypictqiybpfisnd.labs.kodekloud.com

Expected: "Connected successfully" message
