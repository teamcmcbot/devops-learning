# Question 11 | DaemonSet on all Nodes

**Solve this question on:** `ssh cka2556`

## Task

Use Namespace `project-tiger` for the following.

Create a DaemonSet named `ds-important` with image `httpd:2-alpine` and labels:

- `id=ds-important`
- `uuid=18426a0b-5f59-4e10-923f-c0e078e82462`

The Pods it creates should request:

- `10m` CPU
- `10Mi` memory

The Pods of that DaemonSet should run on **all nodes**, including control planes.

---

## Key Idea

A DaemonSet normally runs one Pod per eligible node.

Because the task says it must also run on control plane nodes, the Pod template needs a toleration for the control-plane taint.

---

## Solution

SSH into the target node first:

```bash
ssh cka2556
```

### Step 1: Generate a starter manifest

`kubectl create daemonset` is not available, so generate a Deployment manifest and convert it.

```bash
kubectl -n project-tiger create deployment ds-important --image=httpd:2-alpine --dry-run=client -o yaml > 11.yaml
```

Edit the file:

```bash
vim 11.yaml
```

Replace it with:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
      containers:
        - name: ds-important
          image: httpd:2-alpine
          resources:
            requests:
              cpu: 10m
              memory: 10Mi
```

---

### Step 2: Create the DaemonSet

```bash
kubectl apply -f 11.yaml
```

Expected output:

```text
daemonset.apps/ds-important created
```

---

### Step 3: Verify it runs on all nodes

Check the DaemonSet:

```bash
kubectl -n project-tiger get daemonset ds-important
```

Example output:

```text
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ds-important   3         3         3       3            3           <none>          8s
```

Check the Pods and nodes:

```bash
kubectl -n project-tiger get pods -l id=ds-important -o wide
```

Example output:

```text
NAME                 READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
ds-important-26456   1/1     Running   0          ...   ...           cka2556-node2   <none>           <none>
ds-important-wnt5p   1/1     Running   0          ...   ...           cka2556         <none>           <none>
ds-important-wrbjd   1/1     Running   0          ...   ...           cka2556-node1   <none>           <none>
```

This confirms one Pod is running on each node, including the control plane.

---

## Final Commands Summary

```bash
ssh cka2556

kubectl -n project-tiger create deployment ds-important --image=httpd:2-alpine --dry-run=client -o yaml > 11.yaml
vim 11.yaml

kubectl apply -f 11.yaml

kubectl -n project-tiger get daemonset ds-important
kubectl -n project-tiger get pods -l id=ds-important -o wide
```