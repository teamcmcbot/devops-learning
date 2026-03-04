# Task 04:

The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster. There are some requirements to create/use persistent volumes to store the application code, and the template needs to be designed accordingly. Please find more details below:


Create a `PersistentVolume` named as `pv-datacenter`. Configure the `spec` as storage class should be `manual`, set capacity to `3Gi`, set access mode to `ReadWriteOnce`, volume type should be `hostPath` and set path to `/mnt/data` (this directory is already created, you might not be able to access it directly, so you need not to worry about it).

Create a `PersistentVolumeClaim` named as `pvc-datacenter`. Configure the `spec` as storage class should be `manual`, request `3Gi` of the storage, set access mode to `ReadWriteOnce`.

Create a `pod` named as `pod-datacenter`, mount the persistent volume you created with claim name `pvc-datacenter` at document root of the web server, the container within the pod should be named as `container-datacenter` using image `nginx` with `latest` tag only (remember to mention the tag i.e `nginx:latest`).

Create a node port type service named `web-datacenter` using node port `30008` to expose the web server running within the pod.

Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

## Solution

1. Create PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-datacenter
spec:
  capacity:
    storage: 3Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath: 
    path: /mnt/data
```

2. Create PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-datacenter
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 3Gi
  storageClassName: manual
```

3. Create POD:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod-datacenter
  name: pod-datacenter
spec:
  volumes:
  - name: mypd
    persistentVolumeClaim:
      claimName: pvc-datacenter
  containers:
  - image: nginx:latest
    name: container-datacenter
    volumeMounts:
      - mountPath: "/root"
        name: mypd
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

4. Create NodePort:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: pod-datacenter
  name: web-datacenter
spec:
  ports:
  - port: 80
    protocol: TCP
    nodePort: 30008
  selector:
    run: pod-datacenter
  type: NodePort
status:
  loadBalancer: {}
```


## Verification

```bash
thor@jumphost ~$ k get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
pv-datacenter   3Gi        RWO            Retain           Bound    default/pvc-datacenter   manual                  6m24s
thor@jumphost ~$ k get pvc
NAME             STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-datacenter   Bound    pv-datacenter   3Gi        RWO            manual         6m22s

thor@jumphost ~$ k get all
NAME                 READY   STATUS    RESTARTS   AGE
pod/pod-datacenter   1/1     Running   0          6m24s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP        27m
service/web-datacenter   NodePort    10.96.65.149   <none>        80:30008/TCP   3m20s

thor@jumphost ~$ k get nodes
NAME                      STATUS   ROLES           AGE   VERSION
kodekloud-control-plane   Ready    control-plane   28m   v1.27.16-1+f5da3b717fc217
thor@jumphost ~$ curl http://kodekloud-control-plane:30008
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```