# Task 09:

There is an iron gallery app that the Nautilus DevOps team was developing. They have recently customized the app and are going to deploy the same on the Kubernetes cluster. Below you can find more details:



Create a namespace `iron-namespace-xfusion`

Create a deployment `iron-gallery-deployment-xfusion` for iron gallery under the same namespace you created.

:- Labels `run` should be `iron-gallery`.

:- Replicas count should be `1`.

:- Selector's matchLabels `run` should be `iron-gallery`.

:- Template labels `run` should be `iron-gallery` under metadata.

:- The container should be named as `iron-gallery-container-xfusion`, use `kodekloud/irongallery:2.0 image` ( use exact image name / tag ).

:- Resources limits for memory should be `100Mi` and for CPU should be `50m`.

:- First volumeMount name should be `config`, its mountPath should be `/usr/share/nginx/html/data`.

:- Second volumeMount name should be `images`, its mountPath should be `/usr/share/nginx/html/uploads`.

:- First volume name should be `config` and give it `emptyDir` and second volume name should be `images`, also give it `emptyDir`.

Create a deployment `iron-db-deployment-xfusion` for iron db under the same namespace.

:- Labels `db` should be `mariadb`.

:- Replicas count should be `1`.

:- Selector's matchLabels `db` should be `mariadb`.

:- Template labels `db` should be `mariadb` under metadata.

:- The container name should be `iron-db-container-xfusion`, use `kodekloud/irondb:2.0` image ( use exact image name / tag ).

:- Define environment, set `MYSQL_DATABASE` its value should be `database_host`, set `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` value should be with some complex passwords for DB connections, and `MYSQL_USER` value should be any custom user ( except root ).

:- Volume mount name should be `db` and its mountPath should be `/var/lib/mysql`. Volume name should be `db` and give it an `emptyDir`.

Create a service for iron db which should be named `iron-db-service-xfusion` under the same namespace. Configure spec as selector's `db` should be `mariadb`. Protocol should be `TCP`, port and targetPort should be `3306` and its type should be `ClusterIP`.

Create a service for iron gallery which should be named `iron-gallery-service-xfusion` under the same namespace. Configure spec as selector's `run` should be `iron-gallery`. Protocol should be `TCP`, port and targetPort should be `80`, nodePort should be `32678` and its type should be `NodePort`.


Note:


We don't need to make connection b/w database and front-end now, if the installation page is coming up it should be enough for now.

The kubectl on jump_host has been configured to work with the kubernetes cluster.


## Solution

1. Create namespace:

```bash
k create ns iron-namespace-xfusion
```

2. Create a deployment `iron-gallery-deployment-xfusion`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    run: iron-gallery
  name: iron-gallery-deployment-xfusion
  namespace: iron-namespace-xfusion
spec:
  replicas: 1
  selector:
    matchLabels:
      run: iron-gallery 
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: iron-gallery
    spec:
      volumes:
        - name: config
          emptyDir: {}
        - name: images
          emptyDir: {}
      containers:
      - image: kodekloud/irongallery:2.0
        name: iron-gallery-container-xfusion
        resources:
          limits:
            memory: "100Mi"
            cpu: "50m"
        volumeMounts:
          - mountPath: /usr/share/nginx/html/data
            name: config
          - mountPath: /usr/share/nginx/html/uploads
            name: images
status: {}
```

3. Create a deployment `iron-db-deployment-xfusion`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    db: mariadb
  name: iron-db-deployment-xfusion
  namespace: iron-namespace-xfusion
spec:
  replicas: 1
  selector:
    matchLabels:
      db: mariadb
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        db: mariadb
    spec:
     volumes:
      - name: db
        emptyDir: {} 
     containers:
      - image: kodekloud/irondb:2.0
        name: iron-db-container-xfusion
        volumeMounts:
          - name: db
            mountPath: /var/lib/mysql
        env:
          - name: MYSQL_DATABASE
            value: "database_host"
          - name: MYSQL_ROOT_PASSWORD
            value: "kode-root-pw123"
          - name: MYSQL_PASSWORD
            value: "kode-user-pw123"
          - name: MYSQL_USER
            value: "kode-admin-user"
        resources: {}
status: {}
```

3. Create service `iron-db-service-xfusion`:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    db: mariadb
  name: iron-db-service-xfusion
  namespace: iron-namespace-xfusion
spec:
  ports:
  - port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    db: mariadb
  type: ClusterIP
status:
  loadBalancer: {}
```

4. Create service `iron-gallery-service-xfusion`:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: iron-gallery
  name: iron-gallery-service-xfusion
  namespace: iron-namespace-xfusion
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 32678
  selector:
    run: iron-gallery
  type: NodePort
status:
  loadBalancer: {}
```

## Verification

```bash
thor@jumphost ~$ k get all -n iron-namespace-xfusion
NAME                                                   READY   STATUS    RESTARTS   AGE
pod/iron-db-deployment-xfusion-5f7946b498-bfngf        1/1     Running   0          9m9s
pod/iron-gallery-deployment-xfusion-859fcc9b85-r2wcx   1/1     Running   0          11m

NAME                                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/iron-db-service-xfusion        ClusterIP   10.96.97.26     <none>        3306/TCP       6m28s
service/iron-gallery-service-xfusion   NodePort    10.96.149.242   <none>        80:32678/TCP   3m58s

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/iron-db-deployment-xfusion        1/1     1            1           9m9s
deployment.apps/iron-gallery-deployment-xfusion   1/1     1            1           11m

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/iron-db-deployment-xfusion-5f7946b498        1         1         1       9m9s
replicaset.apps/iron-gallery-deployment-xfusion-859fcc9b85   1         1         1       11m
```

```bash
thor@jumphost ~$ k get nodes 
NAME                      STATUS   ROLES           AGE   VERSION
kodekloud-control-plane   Ready    control-plane   63m   v1.27.16-1+f5da3b717fc217
thor@jumphost ~$ curl -I http://kodekloud-control-plane:32678
HTTP/1.1 200 OK
Server: nginx/1.17.0
Date: Tue, 03 Mar 2026 06:04:40 GMT
Content-Type: text/html
Content-Length: 68734
Last-Modified: Sat, 22 Jun 2019 14:48:06 GMT
Connection: keep-alive
ETag: "5d0e3fa6-10c7e"
Accept-Ranges: bytes
```


## Errors:

template's spec resources limits 'memory' for 'iron-gallery' deployment is not '100Mi' under namespace 'iron-namespace-xfusion'

template's spec resources limits 'cpu' for 'iron-gallery' deployment is not '50m' under namespace 'iron-namespace-xfusion'