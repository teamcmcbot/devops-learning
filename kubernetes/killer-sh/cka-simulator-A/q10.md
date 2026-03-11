# Question 10 | RBAC ServiceAccount Role RoleBinding

**Solve this question on:** `ssh cka3962`

## Task

Create a new ServiceAccount `processor` in Namespace `project-hamster`.

Create a Role and RoleBinding, both named `processor` as well.

These should allow the new ServiceAccount to **only create Secrets and ConfigMaps** in that Namespace.

---

## Key Idea

This is a namespace-scoped RBAC task, so the correct combination is:

- **ServiceAccount** in `project-hamster`
- **Role** in `project-hamster`
- **RoleBinding** in `project-hamster`

Permissions required:

- resource types:
  - `secrets`
  - `configmaps`
- verb:
  - `create`

Nothing else should be allowed.

---

## Solution

SSH into the target node first:

```bash
ssh cka3962
```

### Step 1: Create the ServiceAccount

```bash
kubectl -n project-hamster create serviceaccount processor
```

Expected output:

```text
serviceaccount/processor created
```

---

### Step 2: Create the Role

Create a Role that allows only `create` on `secrets` and `configmaps`:

```bash
kubectl -n project-hamster create role processor --verb=create --resource=secrets --resource=configmaps
```

Expected output:

```text
role.rbac.authorization.k8s.io/processor created
```

This creates a Role similar to:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: processor
  namespace: project-hamster
rules:
  - apiGroups:
      - ""
    resources:
      - secrets
      - configmaps
    verbs:
      - create
```

---

### Step 3: Create the RoleBinding

Bind the Role to the ServiceAccount:

```bash
kubectl -n project-hamster create rolebinding processor --role=processor --serviceaccount=project-hamster:processor
```

Expected output:

```text
rolebinding.rbac.authorization.k8s.io/processor created
```

This creates a RoleBinding similar to:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: processor
  namespace: project-hamster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: processor
subjects:
  - kind: ServiceAccount
    name: processor
    namespace: project-hamster
```

---

### Step 4: Verify permissions

Check that the ServiceAccount can create Secrets:

```bash
kubectl -n project-hamster auth can-i create secret --as=system:serviceaccount:project-hamster:processor
```

Expected output:

```text
yes
```

Check that it can create ConfigMaps:

```bash
kubectl -n project-hamster auth can-i create configmap --as=system:serviceaccount:project-hamster:processor
```

Expected output:

```text
yes
```

Check that it cannot do other actions:

```bash
kubectl -n project-hamster auth can-i create pod --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i delete secret --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i get configmap --as=system:serviceaccount:project-hamster:processor
```

Expected output:

```text
no
no
no
```

---

## Final Commands Summary

```bash
ssh cka3962

kubectl -n project-hamster create serviceaccount processor

kubectl -n project-hamster create role processor --verb=create --resource=secrets --resource=configmaps

kubectl -n project-hamster create rolebinding processor --role=processor --serviceaccount=project-hamster:processor

kubectl -n project-hamster auth can-i create secret --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i create configmap --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i create pod --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i delete secret --as=system:serviceaccount:project-hamster:processor
kubectl -n project-hamster auth can-i get configmap --as=system:serviceaccount:project-hamster:processor
```