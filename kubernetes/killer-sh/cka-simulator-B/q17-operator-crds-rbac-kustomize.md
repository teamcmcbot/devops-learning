# Question 17 | Operator, CRDs, RBAC, Kustomize

**Solve this question on:** `ssh cka6016`

## Task

There is Kustomize config available at:

```bash
/opt/course/17/operator
```

It installs an operator which works with different CRDs. It has been deployed like this:

```bash
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -
```

Perform the following changes in the Kustomize **base** config:

1. The operator needs to list certain CRDs. Check the logs to find out which ones and adjust the permissions for Role `operator-role`
2. Add a new `Student` resource called `student4` with any name and description
3. Deploy your Kustomize config changes to `prod`

---

## Solution

### Step 1: Connect and inspect the Kustomize structure

```bash
ssh cka6016
cd /opt/course/17/operator
ls
```

Expected output:

```text
base  prod
```

Inspect the base:

```bash
kubectl kustomize base
```

Inspect the prod overlay:

```bash
kubectl kustomize prod
```

This shows that:

- `base` contains the common resources
- `prod` applies the namespace `operator-prod`
- `prod` also adds a label to the Deployment
- the rest comes from `base`

---

### Step 2: Check the operator logs to find the missing permissions

Check the running operator Pod:

```bash
kubectl -n operator-prod get pod
```

Example output:

```text
NAME                        READY   STATUS    RESTARTS   AGE
operator-7f4f58d4d9-v6ftw   1/1     Running   0          6m9s
```

Check the logs:

```bash
kubectl -n operator-prod logs operator-7f4f58d4d9-v6ftw
```

Relevant output:

```text
+ true
+ kubectl get students
Error from server (Forbidden): students.education.killer.sh is forbidden: User "system:serviceaccount:operator-prod:operator" cannot list resource "students" in API group "education.killer.sh" in the namespace "operator-prod"

+ kubectl get classes
Error from server (Forbidden): classes.education.killer.sh is forbidden: User "system:serviceaccount:operator-prod:operator" cannot list resource "classes" in API group "education.killer.sh" in the namespace "operator-prod"
```

So the operator needs permission to **list** these CRDs:

- `students`
- `classes`

You can also confirm from the Deployment that it is trying to run these commands in a loop:

```bash
kubectl -n operator-prod edit deploy operator
```

Relevant section:

```yaml
command: ["/bin/sh","-c"]
args:
  - |
    set -x
    while true; do
      kubectl get students
      kubectl get classes
      sleep 60
    done
```

---

### Step 3: Adjust the Role in the Kustomize base config

You need to update:

```bash
base/rbac.yaml
```

You can first generate the correct Role YAML as a reference:

```bash
kubectl -n operator-prod create role operator-role --verb=list --resource=student --resource=class -o yaml --dry-run=client
```

Expected generated structure:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: operator-role
  namespace: operator-prod
rules:
- apiGroups:
  - education.killer.sh
  resources:
  - students
  - classes
  verbs:
  - list
```

Now edit the base RBAC file:

```bash
vim base/rbac.yaml
```

Update it to:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: operator-role
  namespace: default
rules:
- apiGroups:
  - education.killer.sh
  resources:
  - students
  - classes
  verbs:
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: operator-rolebinding
  namespace: default
subjects:
- kind: ServiceAccount
  name: operator
  namespace: default
roleRef:
  kind: Role
  name: operator-role
  apiGroup: rbac.authorization.k8s.io
```

> The namespace is `default` in the base because the overlay will transform it to `operator-prod`.

---

### Step 4: Deploy the RBAC change to prod

Apply the updated Kustomize config:

```bash
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -
```

Expected output:

```text
customresourcedefinition.apiextensions.k8s.io/classes.education.killer.sh unchanged
customresourcedefinition.apiextensions.k8s.io/students.education.killer.sh unchanged
serviceaccount/operator unchanged
role.rbac.authorization.k8s.io/operator-role configured
rolebinding.rbac.authorization.k8s.io/operator-rolebinding unchanged
deployment.apps/operator unchanged
class.education.killer.sh/advanced unchanged
student.education.killer.sh/student1 unchanged
student.education.killer.sh/student2 unchanged
student.education.killer.sh/student3 unchanged
```

Check the logs again:

```bash
kubectl -n operator-prod logs operator-7f4f58d4d9-v6ftw
```

Expected output now:

```text
+ kubectl get students
NAME       AGE
student1   22m
student2   22m
student3   22m

+ kubectl get classes
NAME       AGE
advanced   20m
```

This confirms the RBAC issue is fixed.

---

### Step 5: Add a new Student resource called student4

Edit the students file in the base config:

```bash
vim base/students.yaml
```

Append a new Student resource after the existing ones:

```yaml
apiVersion: education.killer.sh/v1
kind: Student
metadata:
  name: student4
spec:
  name: Some Name
  description: Some Description
```

For example, the end of the file should look like:

```yaml
apiVersion: education.killer.sh/v1
kind: Student
metadata:
  name: student3
spec:
  name: Carol Williams
  description: A student excelling in container orchestration and management
---
apiVersion: education.killer.sh/v1
kind: Student
metadata:
  name: student4
spec:
  name: Some Name
  description: Some Description
```

---

### Step 6: Deploy the updated Kustomize config again

Apply the changes:

```bash
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -
```

Expected output:

```text
customresourcedefinition.apiextensions.k8s.io/classes.education.killer.sh unchanged
customresourcedefinition.apiextensions.k8s.io/students.education.killer.sh unchanged
serviceaccount/operator unchanged
role.rbac.authorization.k8s.io/operator-role unchanged
rolebinding.rbac.authorization.k8s.io/operator-rolebinding unchanged
deployment.apps/operator unchanged
class.education.killer.sh/advanced unchanged
student.education.killer.sh/student1 unchanged
student.education.killer.sh/student2 unchanged
student.education.killer.sh/student3 unchanged
student.education.killer.sh/student4 created
```

Verify:

```bash
kubectl -n operator-prod get student
```

Expected output:

```text
NAME       AGE
student1   28m
student2   28m
student3   27m
student4   43s
```

This confirms `student4` was created successfully.

---

## Final Commands Summary

```bash
ssh cka6016

cd /opt/course/17/operator
ls

kubectl -n operator-prod get pod
kubectl -n operator-prod logs operator-7f4f58d4d9-v6ftw

vim base/rbac.yaml
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

kubectl -n operator-prod logs operator-7f4f58d4d9-v6ftw

vim base/students.yaml
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

kubectl -n operator-prod get student
```