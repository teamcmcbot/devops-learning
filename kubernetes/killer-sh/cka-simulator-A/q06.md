# Question 6 | Storage, PV, PVC, Pod volume

**Solve this question on:** `ssh cka7968`

## Task

Create a new PersistentVolume named `safari-pv` with:

- capacity: `2Gi`
- access mode: `ReadWriteOnce`
- hostPath: `/Volumes/Data`
- no `storageClassName` defined

Then create a new PersistentVolumeClaim in Namespace `project-t230` named `safari-pvc` with:

- request: `2Gi`
- access mode: `ReadWriteOnce`
- no `storageClassName` defined

The PVC should bind to the PV correctly.

Finally create a new Deployment named `safari` in Namespace `project-t230` which mounts that volume at:

`/tmp/safari-data`

The Pods of that Deployment should use image:

`httpd:2-alpine`

---

## Solution

SSH into the target node first:

```bash
ssh cka7968
```

### Step 1: Create the PersistentVolume

Create a YAML file:

```bash
vim 6_pv.yaml
```

Use:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /Volumes/Data
```

Create it:

```bash
kubectl create -f 6_pv.yaml
```

Expected output:

```text
persistentvolume/safari-pv created
```

---

### Step 2: Create the PersistentVolumeClaim

Create another YAML file:

```bash
vim 6_pvc.yaml
```

Use:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-t230
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

Create it:

```bash
kubectl create -f 6_pvc.yaml
```

Expected output:

```text
persistentvolumeclaim/safari-pvc created
```

Check binding:

```bash
kubectl -n project-t230 get pv,pvc
```

Expected output:

```text
NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                     STORAGECLASS   REASON   AGE
persistentvolume/safari-pv   2Gi        RWO            Retain           Bound    project-t230/safari-pvc                           ...

NAME                                STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/safari-pvc    Bound    safari-pv   2Gi        RWO                           ...
```

---

### Step 3: Create the Deployment

Generate a deployment template:

```bash
kubectl -n project-t230 create deployment safari --image=httpd:2-alpine --dry-run=client -o yaml > 6_dep.yaml
```

Edit the file:

```bash
vim 6_dep.yaml
```

Update it to mount the PVC:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: safari
  name: safari
  namespace: project-t230
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  template:
    metadata:
      labels:
        app: safari
    spec:
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: safari-pvc
      containers:
        - image: httpd:2-alpine
          name: safari
          volumeMounts:
            - name: data
              mountPath: /tmp/safari-data
```

Create it:

```bash
kubectl create -f 6_dep.yaml
```

Expected output:

```text
deployment.apps/safari created
```

---

### Step 4: Verify the mount

Check the Pod:

```bash
kubectl -n project-t230 get pods
```

Describe the Pod and confirm the volume mount:

```bash
kubectl -n project-t230 describe pod | grep -A2 Mounts:
```

Expected relevant output:

```text
Mounts:
  /tmp/safari-data from data (rw)
  /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-... (ro)
```

---

## Final Commands Summary

```bash
ssh cka7968

vim 6_pv.yaml
kubectl create -f 6_pv.yaml

vim 6_pvc.yaml
kubectl create -f 6_pvc.yaml

kubectl -n project-t230 get pv,pvc

kubectl -n project-t230 create deployment safari --image=httpd:2-alpine --dry-run=client -o yaml > 6_dep.yaml
vim 6_dep.yaml
kubectl create -f 6_dep.yaml

kubectl -n project-t230 describe pod | grep -A2 Mounts:
```