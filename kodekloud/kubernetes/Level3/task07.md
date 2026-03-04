# Task 07: 

The Nautilus DevOps team want to deploy a static website on Kubernetes cluster. They are going to use Nginx, phpfpm and MySQL for the database. The team had already gathered the requirements and now they want to make this website live. Below you can find more details:



Create some secrets for MySQL.

Create a secret named `mysql-root-pass` wih key/value pairs as below:

```bash
name: password
value: R00t
```



Create a secret named `mysql-user-pass` with key/value pairs as below:

```bash
name: username
value: kodekloud_top

name: password
value: TmPcZjtRQx
```



Create a secret named `mysql-db-url` with key/value pairs as below:

```bash
name: database
value: kodekloud_db7
```


Create a secret named `mysql-host` with key/value pairs as below:

```bash
name: host
value: mysql-service
```


Create a config map `php-config` for `php.ini` with `variables_order = "EGPCS"` data.


Create a deployment named `lemp-wp`.


Create two containers under it. First container must be `nginx-php-container` using image `webdevops/php-nginx:alpine-3-php7` and second container must be `mysql-container` from image `mysql:5.6`. Mount `php-config` configmap in nginx container at `/opt/docker/etc/php/php.ini` location.


5) Add some environment variables for both containers:


`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` and `MYSQL_HOST`. Take their values from the secrets you created. Please make sure to use env field (do not use envFrom) to define the name-value pair of environment variables.

6) Create a node port type service `lemp-service` to expose the web application, nodePort must be `30008`.


7) Create a service for mysql named `mysql-service` and its port must be `3306`.


We already have a `/tmp/index.php` file on `jump_host` server.


Copy this file into the `nginx` container under document root i.e `/app` and replace the dummy values for mysql related variables with the environment variables you have set for mysql related parameters. Please make sure you do not hard code the mysql related details in this file, you must use the environment variables to fetch those values.


Once done, you must be able to access this website using `Website` button on the top bar, please note that you should see Connected successfully message while accessing this page.


Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.

## Solution:

1. Create Secrets:

```bash
k create secret generic mysql-root-pass --from-literal=password=R00t

k create secret generic mysql-user-pass --from-literal=username=kodekloud_top --from-literal=password=TmPcZjtRQx

k create secret generic mysql-db-url --from-literal=database=kodekloud_db7

k create secret generic mysql-host --from-literal=host=mysql-service
```

2. Create php.ini config map:

```bash
echo 'variables_order = "EGPCS"' > php.ini
k create cm php-config --from-file=php.ini
```

3. Create deployment:

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: lemp-wp
  name: lemp-wp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lemp-wp
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: lemp-wp
    spec:
      volumes:
      - name: php-config-volume
        configMap:
          name: php-config
      containers:
      - image: webdevops/php-nginx:alpine-3-php7
        name: nginx-php-container
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-root-pass
              key: password
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-db-url
              key: database
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              name: mysql-host
              key: host
        volumeMounts:
        - name: php-config-volume
          mountPath: "/opt/docker/etc/php/php.ini"
          subPath: php.ini
          readOnly: true
        resources: {}
      - image: mysql:5.6
        name: mysql-container
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-root-pass
              key: password
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-db-url
              key: database
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              name: mysql-host
              key: host
status: {}
```

4. Create lemp-service:

```bash
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: lemp-wp
  name: lemp-service
spec:
  ports:
  - port: 80
    protocol: TCP
    nodePort: 30008
  selector:
    app: lemp-wp
  type: NodePort
status:
  loadBalancer: {}

```

5. Create mysql-service:

```bash
thor@jumphost ~$ k expose deploy lemp-wp --name=mysql-service --port=3306 --type=ClusterIP
service/mysql-service exposed
thor@jumphost ~$ k get svc
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP        56m
lemp-service    NodePort    10.96.43.138   <none>        80:30008/TCP   85s
mysql-service   ClusterIP   10.96.11.150   <none>        3306/TCP       7s
```

6. Copy /tmp/index.php to nginx-php container and edit index.php to use env var:

```bash
thor@jumphost ~$ k cp /tmp/index.php lemp-wp-79975c8f98-kwnkf:/app/index.php -c nginx-php-container
thor@jumphost ~$ k exec -it lemp-wp-79975c8f98-kwnkf -c nginx-php-container -- sh

/app # cat index.php 
<?php
$dbname = $apiKey = $_ENV['MYSQL_DATABASE'];
$dbuser = $apiKey = $_ENV['MYSQL_USER'];
$dbpass = $apiKey = $_ENV['MYSQL_PASSWORD'];
$dbhost = $apiKey = $_ENV['MYSQL_HOST'];

$connect = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");

$test_query = "SHOW TABLES FROM $dbname";
$result = mysqli_query($test_query);

if ($result->connect_error) {
   die("Connection failed: " . $conn->connect_error);
}
  echo "Connected successfully";/app # 
```