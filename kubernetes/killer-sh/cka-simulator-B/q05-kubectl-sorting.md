# Question 5 | Kubectl sorting

**Solve this question on:** `ssh cka8448`

## Task

Create two bash script files which use kubectl sorting to:

- Write a command into `/opt/course/5/find_pods.sh` which lists all Pods in all Namespaces sorted by their AGE (`metadata.creationTimestamp`)
- Write a command into `/opt/course/5/find_pods_uid.sh` which lists all Pods in all Namespaces sorted by field `metadata.uid`

---

## Solution

SSH into the target node first:

```bash
ssh cka8448
```

### Step 1: Create the first script

Create the file:

```bash
vim /opt/course/5/find_pods.sh
```

Put this inside:

```bash
kubectl get pod -A --sort-by=.metadata.creationTimestamp
```

You can test it with:

```bash
sh /opt/course/5/find_pods.sh
```

Expected output will show Pods ordered by AGE.

---

### Step 2: Create the second script

Create the file:

```bash
vim /opt/course/5/find_pods_uid.sh
```

Put this inside:

```bash
kubectl get pod -A --sort-by=.metadata.uid
```

You can test it with:

```bash
sh /opt/course/5/find_pods_uid.sh
```

Expected output will show Pods ordered by UID.

---

## Final Commands Summary

```bash
ssh cka8448

vim /opt/course/5/find_pods.sh
vim /opt/course/5/find_pods_uid.sh

sh /opt/course/5/find_pods.sh
sh /opt/course/5/find_pods_uid.sh
```