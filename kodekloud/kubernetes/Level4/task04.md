# Task 04:

We need to deploy a Drupal application on Kubernetes cluster. The Nautilus application development team want to setup a fresh Drupal as they will do the installation on their own. Below you can find the requirements, they have shared with us.



1) Configure a persistent volume `drupal-mysql-pv` with `hostPath = /drupal-mysql-data` (`/drupal-mysql-data` directory already exists on the worker Node i.e jump host), `5Gi` of storage and `ReadWriteOnce` access mode.


2) Configure one PersistentVolumeClaim named `drupal-mysql-pvc` with storage request of `3Gi` and `ReadWriteOnce` access mode.


3) Create a deployment `drupal-mysql` with `1` replica, use `mysql:5.7` image. Mount the claimed PVC at `/var/lib/mysql`.


4) Create a deployment `drupal` with `1` replica and use `drupal:8.6` image.


4) Create a `NodePort` type service which should be named as `drupal-service` and nodePort should be `30095`.


5) Create a service `drupal-mysql-service` to expose `mysql` deployment on port `3306`.


6) Set rest of the configration for deployments, services, secrets etc as per your preferences. At the end you should be able to access the Drupal installation page by clicking on `App` button.


Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.


## Solution:

1. Create PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: drupal-mysql-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/drupal-mysql-data"
```

2. Create PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: drupal-mysql-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

3. Create deployment for mysql:

NOTE: mysql requirement some environment variables which we should create secrets for at least the password.

```bash
thor@jumphost ~$ k create secret generic mysql-pass --from-literal=password=kode-db-pass123
secret/mysql-pass created
thor@jumphost ~$ k describe secret/mysql-pass
Name:         mysql-pass
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  15 bytes
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: drupal-mysql
  name: drupal-mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drupal-mysql
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: drupal-mysql
    spec:
      volumes:
      - name: mysql-pv-volume
        persistentVolumeClaim:
          claimName: drupal-mysql-pvc
      containers:
      - image: mysql:5.7
        name: mysql
        resources: {}
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        - name: MYSQL_DATABASE
          value: kode-db
        - name: MYSQL_USER
          value: kode-db-admin
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        volumeMounts:
        - mountPath: "/var/lib/mysql"
          name: mysql-pv-volume
```

4. Create deployment for drupal app:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: drupal
  name: drupal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drupal
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: drupal
    spec:
      containers:
      - image: drupal:8.6
        name: drupal
        resources: {}
status: {}
```

5. Create NodePort service:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: drupal
  name: drupal-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30095
  selector:
    app: drupal
  type: NodePort
status:
```

6. Create mysql service:

```bash
k expose deploy drupal-mysql --port=3306 --target-port=3306 --name=drupal-mysql-service --type=ClusterIP
```

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: drupal-mysql
  name: drupal-mysql-service
spec:
  ports:
  - port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    app: drupal-mysql
  type: ClusterIP
status:
  loadBalancer: {}
```


