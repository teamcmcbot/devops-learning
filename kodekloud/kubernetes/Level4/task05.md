# Task 05:

The Nautilus Application development team has finished development of one of the applications and it is ready for deployment. It is a guestbook application that will be used to manage entries for guests/visitors. As per discussion with the DevOps team, they have finalized the infrastructure that will be deployed on Kubernetes cluster. Below you can find more details about it.


`BACK-END TIER`

Create a deployment named `redis-master` for Redis master.

a.) Replicas count should be `1`.

b.) Container name should be `master-redis-devops` and it should use image `redis`.

c.) Request resources as `CPU` should be `100m` and Memory should be `100Mi`.

d.) Container port should be redis default port i.e `6379`.

Create a service named `redis-master` for Redis master. Port and targetPort should be Redis default port i.e `6379`.

Create another deployment named `redis-slave` for Redis slave.

a.) Replicas count should be `2`.

b.) Container name should be `slave-redis-devops` and it should use `gcr.io/google_samples/gb-redisslave:v3` image.

c.) Requests resources as `CPU` should be `100m` and Memory should be `100Mi`.

d.) Define an environment variable named `GET_HOSTS_FROM` and its value should be `dns`.

e.) Container port should be Redis default port i.e `6379`.

Create another service named `redis-slave`. It should use Redis default port i.e `6379`.

`FRONT END TIER`

Create a deployment named `frontend`.

a.) Replicas count should be `3`.

b.) Container name should be `php-redis-devops` and it should use `gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff` image.

c.) Request resources as `CPU` should be `100m` and Memory should be `100Mi`.

d.) Define an environment variable named as `GET_HOSTS_FROM` and its value should be `dns`.

e.) Container port should be `80`.

Create a service named `frontend`. Its `type` should be `NodePort`, port should be `80` and its `nodePort` should be `30009`.

Finally, you can check the `guestbook app` by clicking on `App` button.


`You can use any labels as per your choice.`

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.


## Solution:

1. Create a deployment named `redis-master`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: redis-master
  name: redis-master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-master
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: redis-master
    spec:
      containers:
      - image: redis
        name: master-redis-devops
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m"
status: {}
```

2. Create service `redis-master`:

```bash
thor@jumphost ~/backend$ k expose deploy redis-master --name=redis-master --port=6379 --target-port=6379 --type=ClusterIP
service/redis-master exposed
thor@jumphost ~/backend$ k describe service/redis-master
Name:              redis-master
Namespace:         default
Labels:            app=redis-master
Annotations:       <none>
Selector:          app=redis-master
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.7.165
IPs:               10.96.7.165
Port:              <unset>  6379/TCP
TargetPort:        6379/TCP
Endpoints:         10.244.0.5:6379
Session Affinity:  None
Events:            <none>

```

3. Create another deployment named `redis-slave`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: redis-slave
  name: redis-slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis-slave
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: redis-slave
    spec:
      containers:
      - image: gcr.io/google_samples/gb-redisslave:v3
        name: slave-redis-devops
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m"
        env:
        - name: GET_HOSTS_FROM
          value: "dns"
status: {}
```

4. Create another service named `redis-slave`

```bash
thor@jumphost ~/backend$ k expose deploy redis-slave --name=redis-slave --port=6379 --target-port=6379 --type=ClusterIP

service/redis-slave exposed
thor@jumphost ~/backend$ k describe service/redis-slave
Name:              redis-slave
Namespace:         default
Labels:            app=redis-slave
Annotations:       <none>
Selector:          app=redis-slave
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.183.73
IPs:               10.96.183.73
Port:              <unset>  6379/TCP
TargetPort:        6379/TCP
Endpoints:         10.244.0.6:6379,10.244.0.7:6379
Session Affinity:  None
Events:            <none>
```

5. Create deployment `frontend`: 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: frontend
    spec:
      containers:
      - image: gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff
        name: php-redis-devops
        ports:
        - containerPort: 80
        resources:
          requests:
             memory: "100Mi"
             cpu: "100m"
        env:
        - name: GET_HOSTS_FROM
          value: "dns"
status: {}
```

5. Create a NodePort service named `frontend`:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30009
  selector:
    app: frontend
  type: NodePort
status:
  loadBalancer: {}
```

## Verification:

```bash
thor@jumphost ~/frontend$ k get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/frontend-cddd497bb-9kj79        1/1     Running   0          5m10s
pod/frontend-cddd497bb-ghgbc        1/1     Running   0          5m10s
pod/frontend-cddd497bb-jp7qt        1/1     Running   0          5m10s
pod/redis-master-5587f87489-f2qpv   1/1     Running   0          19m
pod/redis-slave-6594f4ddb6-m66zq    1/1     Running   0          11m
pod/redis-slave-6594f4ddb6-vrdrv    1/1     Running   0          11m

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/frontend       NodePort    10.96.26.0     <none>        80:30009/TCP   87s
service/kubernetes     ClusterIP   10.96.0.1      <none>        443/TCP        46m
service/redis-master   ClusterIP   10.96.7.165    <none>        6379/TCP       17m
service/redis-slave    ClusterIP   10.96.183.73   <none>        6379/TCP       9m26s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/frontend       3/3     3            3           5m10s
deployment.apps/redis-master   1/1     1            1           19m
deployment.apps/redis-slave    2/2     2            2           11m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/frontend-cddd497bb        3         3         3       5m10s
replicaset.apps/redis-master-5587f87489   1         1         1       19m
replicaset.apps/redis-slave-6594f4ddb6    2         2         2       11m


thor@jumphost ~/frontend$ k get nodes
NAME                      STATUS   ROLES           AGE   VERSION
kodekloud-control-plane   Ready    control-plane   47m   v1.27.16-1+f5da3b717fc217


thor@jumphost ~/frontend$ curl http://kodekloud-control-plane:30009
<html ng-app="redis">
  <head>
    <title>Guestbook</title>
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular.min.js"></script>
    <script src="controllers.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/2.5.6/ui-bootstrap-tpls.js"></script>
  </head>
  <body ng-controller="RedisCtrl">
    <div style="width: 50%; margin-left: 20px">
      <h2>Guestbook</h2>
    <form>
    <fieldset>
    <input ng-model="msg" placeholder="Messages" class="form-control" type="text" name="input"><br>
    <button type="button" class="btn btn-primary" ng-click="controller.onRedis()">Submit</button>
    </fieldset>
    </form>
    <div>
      <div ng-repeat="msg in messages track by $index">
        {{msg}}
      </div>
    </div>
    </div>
  </body>
</html>
```