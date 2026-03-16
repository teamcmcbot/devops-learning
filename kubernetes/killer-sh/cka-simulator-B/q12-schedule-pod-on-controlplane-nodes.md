# Question 12 | Schedule Pod on Controlplane Nodes

**Solve this question on:** `ssh cka5248`

## Task

Create a Pod in Namespace `default` with:

- Image: `httpd:2-alpine`
- Pod name: `pod1`
- Container name: `pod1-container`

The Pod **must only run on controlplane nodes**.

⚠️ Do **not** add any labels to nodes.

---

# Solution

## Step 1 — Connect and inspect nodes

```bash
ssh cka5248
kubectl get node
```

Example output:

```text
NAME            STATUS   ROLES           AGE   VERSION
cka5248         Ready    control-plane   90m   v1.33.1
cka5248-node1   Ready    <none>          85m   v1.33.1
```

Check control plane taints:

```bash
kubectl describe node cka5248 | grep -i taint -A1
```

Output:

```text
Taints: node-role.kubernetes.io/control-plane:NoSchedule
```

Controlplane nodes are tainted, so we must **add a toleration**.

---

# Step 2 — Create Pod YAML

Generate template:

```bash
kubectl run pod1 --image=httpd:2-alpine --dry-run=client -o yaml > pod1.yaml
```

Edit it:

```bash
vim pod1.yaml
```

Final YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  namespace: default
spec:
  containers:
  - name: pod1-container
    image: httpd:2-alpine

  nodeSelector:
    node-role.kubernetes.io/control-plane: ""

  tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
```

Explanation:

| Field | Purpose |
|-----|-----|
| nodeSelector | Ensures Pod runs **only on controlplane nodes** |
| tolerations | Allows scheduling despite controlplane **NoSchedule taint** |

---

# Step 3 — Create the Pod

```bash
kubectl apply -f pod1.yaml
```

Output:

```text
pod/pod1 created
```

---

# Step 4 — Verify scheduling

```bash
kubectl get pod -o wide
```

Example:

```text
NAME   READY   STATUS    NODE
pod1   1/1     Running   cka5248
```

The Pod runs **only on the controlplane node**.

---

# Quick Command Summary (CKA speed)

```bash
ssh cka5248

kubectl run pod1 --image=httpd:2-alpine --dry-run=client -o yaml > pod1.yaml

vim pod1.yaml
```

Add:

```yaml
nodeSelector:
  node-role.kubernetes.io/control-plane: ""

tolerations:
- key: node-role.kubernetes.io/control-plane
  operator: Exists
  effect: NoSchedule
```

Then:

```bash
kubectl apply -f pod1.yaml
kubectl get pod -o wide
```

---

If you want, I can also show you the **3-line fastest CKA solution** that avoids writing YAML and solves this in ~15 seconds (the trick many candidates use in the real exam).