# Task 02: 

A new MySQL server needs to be deployed on Kubernetes cluster. The Nautilus DevOps team was working on to gather the requirements. Recently they were able to finalize the requirements and shared them with the team members to start working on it. Below you can find the details:



1.) Create a PersistentVolume `mysql-pv`, its capacity should be `250Mi`, set other parameters as per your preference.


2.) Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as `mysql-pv-claim` and request a `250Mi` of storage. Set other parameters as per your preference.


3.) Create a deployment named `mysql-deployment`, use any mysql image as per your preference. Mount the PersistentVolume at mount path `/var/lib/mysql`.


4.) Create a `NodePort` type service named `mysql` and set nodePort to `30007`.


5.) Create a secret named `mysql-root-pass` having a key pair value, where key is `password` and its value is `YUIidhb667`, create another secret named `mysql-user-pass` having some key pair values, where frist key is `username` and its value is `kodekloud_top`, second key is `password` and value is `YchZHRcLkL`, create one more secret named `mysql-db-url`, key name is `database` and value is `kodekloud_db6`


6.) Define some Environment variables within the container:


a) name: `MYSQL_ROOT_PASSWORD`, should pick value from secretKeyRef name: `mysql-root-pass` and key: `password`


b) name: `MYSQL_DATABASE`, should pick value from secretKeyRef name: `mysql-db-url` and key: `database`


c) name: `MYSQL_USER`, should pick value from secretKeyRef name: `mysql-user-pass` key key: `username`


d) name: `MYSQL_PASSWORD`, should pick value from secretKeyRef name: `mysql-user-pass` and key: `password`


Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

## Solution:

1. Create PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

2. Create PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
```

3. Create Secrets:

```bash
thor@jumphost ~$ k create secret generic mysql-root-pass --from-literal=password=YUIidhb667
secret/mysql-root-pass created
thor@jumphost ~$ k create secret generic mysql-user-pass --from-literal=username=kodekloud_top --from-literal=password=YchZHRcLkL
secret/mysql-user-pass created
thor@jumphost ~$ k create secret generic mysql-db-url --from-literal=database=kodekloud_db6
secret/mysql-db-url created
thor@jumphost ~$ k get secrets
NAME              TYPE     DATA   AGE
mysql-db-url      Opaque   1      5s
mysql-root-pass   Opaque   1      100s
mysql-user-pass   Opaque   2      34s
```

