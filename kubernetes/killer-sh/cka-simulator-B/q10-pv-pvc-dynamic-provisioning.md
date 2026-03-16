# Question 10 | PV PVC Dynamic Provisioning

**Solve this question on:** `ssh cka6016`

## Task

There is a backup Job which needs to be adjusted to use a PVC to store backups.

Create a StorageClass named `local-backup` which uses:

- `provisioner: rancher.io/local-path`
- `volumeBindingMode: WaitForFirstConsumer`

To prevent possible data loss, the StorageClass should keep a PV retained even if a bound PVC is deleted.

Adjust the Job at:

```bash
/opt/course/10/backup.yaml
```

to use a PVC which requests `50Mi` storage and uses the new StorageClass.

Deploy your changes, verify the Job completed once and the PVC was bound to a newly created PV.

> To re-run a Job, delete it and create it again.

> PV = PersistentVolume, PVC = PersistentVolumeClaim.

---

## Solution

### Step 1: Connect to the node

```bash
ssh cka6016
```

---

## Step 2: Create the StorageClass

Check the existing StorageClasses:

```bash
kubectl get sc
```

Example output:

```text
NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE         ...
local-path   rancher.io/local-path   Delete          WaitForFirstConsumer      ...
```

Create a new YAML:

```bash
vim sc.yaml
```

Use:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-backup
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

Apply it:

```bash
kubectl apply -f sc.yaml
```

Verify:

```bash
kubectl get sc
```

Expected relevant output:

```text
NAME           PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE         ...
local-backup   rancher.io/local-path   Retain          WaitForFirstConsumer      ...
local-path     rancher.io/local-path   Delete          WaitForFirstConsumer      ...
```

---

## Step 3: Inspect the existing Job YAML

Open the current file:

```bash
cat /opt/course/10/backup.yaml
```

Current content is similar to:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup
  namespace: project-bern
spec:
  backoffLimit: 0
  template:
    spec:
      volumes:
        - name: backup
          emptyDir: {}
      containers:
        - name: bash
          image: bash:5
          command:
            - bash
            - -c
            - |
              set -x
              touch /backup/backup-$(date +%Y-%m-%d-%H-%M-%S).tar.gz
              sleep 15
          volumeMounts:
            - name: backup
              mountPath: /backup
      restartPolicy: Never
```

Right now it uses `emptyDir`, which is temporary storage and disappears with the Pod.

---

## Step 4: Modify the Job YAML to use a PVC

Go into the directory and back up the file first:

```bash
cd /opt/course/10
cp backup.yaml backup.yaml_ori
vim backup.yaml
```

Replace it with:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-pvc
  namespace: project-bern
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  storageClassName: local-backup
---
apiVersion: batch/v1
kind: Job
metadata:
  name: backup
  namespace: project-bern
spec:
  backoffLimit: 0
  template:
    spec:
      volumes:
        - name: backup
          persistentVolumeClaim:
            claimName: backup-pvc
      containers:
        - name: bash
          image: bash:5
          command:
            - bash
            - -c
            - |
              set -x
              touch /backup/backup-$(date +%Y-%m-%d-%H-%M-%S).tar.gz
              sleep 15
          volumeMounts:
            - name: backup
              mountPath: /backup
      restartPolicy: Never
```

Key changes:

- added a PVC named `backup-pvc`
- PVC requests `50Mi`
- PVC uses StorageClass `local-backup`
- changed Job volume from `emptyDir` to `persistentVolumeClaim`

---

## Step 5: Deploy the changes

If the Job was already created before, delete it first:

```bash
kubectl delete -f backup.yaml
```

Then apply:

```bash
kubectl apply -f backup.yaml
```

Expected output:

```text
persistentvolumeclaim/backup-pvc created
job.batch/backup created
```

---

## Step 6: Verify Job, PVC, and PV

Check the resources:

```bash
kubectl -n project-bern get job,pod,pvc,pv
```

Example output while running:

```text
NAME               STATUS    COMPLETIONS   DURATION   AGE
job.batch/backup   Running   0/1           13s        13s

NAME               READY   STATUS    RESTARTS   AGE
pod/backup-q7dgx   1/1     Running   0          13s

NAME         STATUS   VOLUME                                     CAPACITY   ...
backup-pvc   Bound    pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a   50Mi       ...

NAME                                         CAPACITY   ...   RECLAIM POLICY   STATUS   CLAIM
pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a     50Mi       ...   Retain           Bound    project-bern/backup-pvc
```

After completion, the Job should show:

```text
job.batch/backup   Complete   1/1
```

This confirms:

- the Job completed once
- the PVC is bound
- a new PV was dynamically created
- the PV has reclaim policy `Retain`

---

## Optional verification on filesystem

Because this uses Rancher Local Path Provisioner, the actual data is stored on the node filesystem.

You can inspect it with:

```bash
find /opt/local-path-provisioner
```

Example output:

```text
/opt/local-path-provisioner/
/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc
/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc/backup-2024-12-30-17-27-51.tar.gz
```

---

## Final Commands Summary

```bash
ssh cka6016

kubectl get sc

vim sc.yaml
kubectl apply -f sc.yaml

cd /opt/course/10
cp backup.yaml backup.yaml_ori
vim backup.yaml

kubectl delete -f backup.yaml
kubectl apply -f backup.yaml

kubectl -n project-bern get job,pod,pvc,pv
```