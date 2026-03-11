# Question 12 | Deployment on all worker Nodes

**Solve this question on:** `ssh cka2556`

## Task

Implement the following in Namespace `project-tiger`:

- Create a Deployment named `deploy-important` with `3` replicas
- The Deployment and its Pods should have label `id=very-important`
- First container named `container1` with image `nginx:1-alpine`
- Second container named `container2` with image `google/pause`
- There should only ever be one Pod of that Deployment running on one worker node, use topologyKey: `kubernetes.io/hostname` for this

> Because there are two worker nodes and the Deployment has three replicas, the result should be that the third Pod will remain Pending.

---

## Key Idea

This can be solved using either:

- `podAntiAffinity`
- `topologySpreadConstraints`

The most direct interpretation of “only ever be one Pod ... on one worker node” with `topologyKey: kubernetes.io/hostname` is to prevent multiple matching Pods from being scheduled onto the same node.

Since the control-plane node is tainted and no toleration was requested, the Pods will only run on the two worker nodes. With 3 replicas, 2 Pods will run and 1 will stay Pending.

---

## Solution

SSH into the target node first:

```bash
ssh cka2556
```

### Step 1: Generate a starter manifest

```bash
kubectl -n project-tiger create deployment deploy-important --image=nginx:1-alpine --dry-run=client -o yaml > 12.yaml
```

Edit the file:

```bash
vim 12.yaml
```

Replace it with:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-tiger
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      containers:
        - name: container1
          image: nginx:1-alpine
        - name: container2
          image: google/pause
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              id: very-important
```

---

### Step 2: Create the Deployment

```bash
kubectl apply -f 12.yaml
```

Expected output:

```text
deployment.apps/deploy-important created
```

---

### Step 3: Verify the result

Check the Deployment:

```bash
kubectl -n project-tiger get deployment -l id=very-important
```

Expected output:

```text
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
deploy-important   2/3     3            2           ...
```

Check the Pods:

```bash
kubectl -n project-tiger get pods -o wide -l id=very-important
```

Expected output will look similar to:

```text
NAME                                READY   STATUS    IP          NODE
deploy-important-78f98b75f9-657hx   2/2     Running   10.44.0.33  cka2556-node1
deploy-important-78f98b75f9-9bz8q   2/2     Running   10.36.0.20  cka2556-node2
deploy-important-78f98b75f9-5s6js   0/2     Pending   <none>      <none>
```

This shows:

- one Pod on `cka2556-node1`
- one Pod on `cka2556-node2`
- third Pod Pending because it cannot be scheduled onto a node that already has a matching Pod

To confirm the reason:

```bash
kubectl -n project-tiger describe pod <pending-pod-name>
```

You should see a scheduling message similar to:

```text
0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 2 node(s) didn't match pod topology spread constraints.
```

---

## Alternative valid solution using podAntiAffinity

This also works:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-tiger
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      containers:
        - name: container1
          image: nginx:1-alpine
        - name: container2
          image: google/pause
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: id
                    operator: In
                    values:
                      - very-important
              topologyKey: kubernetes.io/hostname
```

---

## Final Commands Summary

```bash
ssh cka2556

kubectl -n project-tiger create deployment deploy-important --image=nginx:1-alpine --dry-run=client -o yaml > 12.yaml
vim 12.yaml

kubectl apply -f 12.yaml

kubectl -n project-tiger get deployment -l id=very-important
kubectl -n project-tiger get pods -o wide -l id=very-important
```