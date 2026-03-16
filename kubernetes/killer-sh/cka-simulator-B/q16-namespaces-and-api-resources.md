# Question 16 | Namespaces and Api Resources

**Solve this question on:** `ssh cka3200`

## Task

Write the names of all namespaced Kubernetes resources (like Pod, Secret, ConfigMap...) into:

```text
/opt/course/16/resources.txt
```

Find the `project-*` Namespace with the highest number of Roles defined in it and write its name and amount of Roles into:

```text
/opt/course/16/crowded-namespace.txt
```

---

## Solution

### Step 1: Connect to the node

```bash
ssh cka3200
```

---

## Step 2: Write all namespaced API resources into the file

List all namespaced Kubernetes resources and write them directly into the requested file:

```bash
kubectl api-resources --namespaced -o name > /opt/course/16/resources.txt
```

This results in a file similar to:

```text
bindings
configmaps
endpoints
events
limitranges
persistentvolumeclaims
pods
podtemplates
replicationcontrollers
resourcequotas
secrets
serviceaccounts
services
controllerrevisions.apps
daemonsets.apps
deployments.apps
replicasets.apps
statefulsets.apps
localsubjectaccessreviews.authorization.k8s.io
horizontalpodautoscalers.autoscaling
cronjobs.batch
jobs.batch
leases.coordination.k8s.io
endpointslices.discovery.k8s.io
events.events.k8s.io
ingresses.networking.k8s.io
networkpolicies.networking.k8s.io
poddisruptionbudgets.policy
rolebindings.rbac.authorization.k8s.io
roles.rbac.authorization.k8s.io
csistoragecapacities.storage.k8s.io
```

---

## Step 3: Find the project-* Namespace with the most Roles

Check the number of Roles in each `project-*` Namespace:

```bash
kubectl -n project-jinan get role --no-headers | wc -l
kubectl -n project-miami get role --no-headers | wc -l
kubectl -n project-melbourne get role --no-headers | wc -l
kubectl -n project-seoul get role --no-headers | wc -l
kubectl -n project-toronto get role --no-headers | wc -l
```

Example output:

```text
0
300
2
10
0
```

From this, the Namespace with the highest number of Roles is:

```text
project-miami
```

with:

```text
300 roles
```

Write the result into the required file:

```bash
echo 'project-miami with 300 roles' > /opt/course/16/crowded-namespace.txt
```

---

## Final Commands Summary

```bash
ssh cka3200

kubectl api-resources --namespaced -o name > /opt/course/16/resources.txt

kubectl -n project-jinan get role --no-headers | wc -l
kubectl -n project-miami get role --no-headers | wc -l
kubectl -n project-melbourne get role --no-headers | wc -l
kubectl -n project-seoul get role --no-headers | wc -l
kubectl -n project-toronto get role --no-headers | wc -l

echo 'project-miami with 300 roles' > /opt/course/16/crowded-namespace.txt
```