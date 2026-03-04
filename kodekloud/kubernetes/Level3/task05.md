## Task 05: 

The Nautilus DevOps team is working to deploy some tools in Kubernetes cluster. Some of the tools are licence based so that licence information needs to be stored securely within Kubernetes cluster. Therefore, the team wants to utilize Kubernetes secrets to store those secrets. Below you can find more details about the requirements:



We already have a secret key file `ecommerce.txt` under `/opt` location on `jump host`. Create a generic secret named `ecommerce`, it should contain the password/license-number present in `ecommerce.txt` file.


Also create a `pod` named `secret-xfusion`.


Configure pod's `spec` as container name should be `secret-container-xfusion`, image should be `fedora` with `latest` tag (remember to mention the tag with image). Use `sleep` command for container so that it remains in running state. Consume the created secret and mount it under `/opt/apps` within the container.


To verify you can exec into the container `secret-container-xfusion`, to check the secret key under the mounted path `/opt/apps`. Before hitting the `Check` button please make sure pod/pods are in running state, also validation can take some time to complete so keep patience.


Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

## Additonal information:

```bash
thor@jumphost ~$ cat /opt/ecommerce.txt 
5ecur3
```

## Solution

1. Create secret from file

```bash
thor@jumphost /opt$ k create secret generic ecommerce --from-file=/opt/ecommerce.txt 
secret/ecommerce created
thor@jumphost /opt$ k describe secret/ecommerce
Name:         ecommerce
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
ecommerce.txt:  7 bytes
```

2. Create POD:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-xfusion
  name: secret-xfusion
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: ecommerce
  containers:
  - image: fedora:latest
    name: secret-container-xfusion
    command: ["sleep"]
    args: ["20000"]
    volumeMounts:
      - name: secret-volume
        mountPath: /opt/apps
        readOnly: true
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

## Verification

```bash
thor@jumphost ~$ k get all
NAME                 READY   STATUS    RESTARTS   AGE
pod/secret-xfusion   1/1     Running   0          40s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   35m

thor@jumphost ~$ k exec -it secret-xfusion -- sh
sh-5.3# cd /opt/apps/
sh-5.3# ls
ecommerce.txt
sh-5.3# cat ecommerce.txt 
5ecur3
```