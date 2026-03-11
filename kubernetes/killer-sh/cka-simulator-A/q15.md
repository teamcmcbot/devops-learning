# Question 15 | NetworkPolicy

**Solve this question on:** `ssh cka7968`

## Task

There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.

To prevent this, create a NetworkPolicy called `np-backend` in Namespace `project-snake`.

It should allow the `backend-*` Pods only to:

- connect to `db1-*` Pods on port `1111`
- connect to `db2-*` Pods on port `2222`

Use the app Pod labels in your policy.

> All Pods in the Namespace run plain Nginx images. This allows simple connectivity tests like:
>
> ```bash
> kubectl -n project-snake exec POD_NAME -- curl POD_IP:PORT
> ```

> For example, connections from `backend-*` Pods to `vault-*` Pods on port `3333` should no longer work.

---

## Key Idea

A NetworkPolicy with `policyTypes: [Egress]` and `podSelector` targeting the backend Pods will restrict outgoing traffic from those Pods.

Since the task says backend Pods should **only** connect to:

- `db1-*` on port `1111`
- `db2-*` on port `2222`

we create two allowed egress rules and nothing else.

---

## Solution

### Step 1: Connect to the node and inspect Pod labels

```bash
ssh cka7968
kubectl -n project-snake get pods --show-labels
```

Example output will show app labels similar to:

```text
backend-...   ...   app=backend
db1-...       ...   app=db1
db2-...       ...   app=db2
vault-...     ...   app=vault
```

The task says to use the **app Pod labels**, so the policy should match these labels.

---

### Step 2: Create the NetworkPolicy

Create the manifest:

```bash
vim 15.yaml
```

Use:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Egress
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db1
      ports:
        - protocol: TCP
          port: 1111
    - to:
        - podSelector:
            matchLabels:
              app: db2
      ports:
        - protocol: TCP
          port: 2222
```

Apply it:

```bash
kubectl apply -f 15.yaml
```

Expected output:

```text
networkpolicy.networking.k8s.io/np-backend created
```

---

### Step 3: Verify the policy

Check the policy:

```bash
kubectl -n project-snake get networkpolicy
kubectl -n project-snake describe networkpolicy np-backend
```

---

### Step 4: Test connectivity

Get Pod IPs:

```bash
kubectl -n project-snake get pods -o wide
```

Pick one backend Pod and test allowed traffic:

```bash
kubectl -n project-snake exec backend-xxx -- curl <db1-pod-ip>:1111
kubectl -n project-snake exec backend-xxx -- curl <db2-pod-ip>:2222
```

These should work.

Test blocked traffic, for example to vault on port 3333:

```bash
kubectl -n project-snake exec backend-xxx -- curl <vault-pod-ip>:3333
```

This should fail.

---

## Notes

- Because this policy targets only Pods with `app=backend`, only backend Pods are restricted.
- Once an egress policy selects a Pod, all other egress traffic is denied unless explicitly allowed.
- The policy uses Pod labels, not Pod names, as requested.

---

## Final Commands Summary

```bash
ssh cka7968

kubectl -n project-snake get pods --show-labels

vim 15.yaml
kubectl apply -f 15.yaml

kubectl -n project-snake get networkpolicy
kubectl -n project-snake get pods -o wide
```