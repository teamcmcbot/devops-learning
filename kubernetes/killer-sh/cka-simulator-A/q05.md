# Question 5 | Kustomize configure HPA Autoscaler

**Solve this question on:** `ssh cka5774`

## Task

Previously the application `api-gateway` used some external autoscaler which should now be replaced with a `HorizontalPodAutoscaler` (HPA).

The application has been deployed to Namespaces `api-gateway-staging` and `api-gateway-prod` like this:

```bash
kubectl kustomize /opt/course/5/api-gateway/staging | kubectl apply -f -
kubectl kustomize /opt/course/5/api-gateway/prod | kubectl apply -f -
```

Using the Kustomize config at `/opt/course/5/api-gateway` do the following:

1. Remove the ConfigMap `horizontal-scaling-config` completely
2. Add HPA named `api-gateway` for Deployment `api-gateway` with:
   - min replicas: `2`
   - max replicas: `4`
   - scale at `50%` average CPU utilization
3. In `prod`, the HPA should have max replicas `6`
4. Apply the changes for both `staging` and `prod`

---

## Key Idea

This setup uses **Kustomize base + overlays**.

- `base/` contains the common resources
- `staging/` and `prod/` patch or transform the base
- We must:
  - remove the old ConfigMap from base and overlays
  - add the HPA in base
  - override only `maxReplicas` in prod

---

## Solution

### Step 1: SSH and inspect the Kustomize structure

```bash
ssh cka5774
cd /opt/course/5/api-gateway
ls
```

Expected directories:

```text
base  prod  staging
```

Inspect the base:

```bash
kubectl kustomize base
```

Inspect staging:

```bash
kubectl kustomize staging
```

Inspect prod:

```bash
kubectl kustomize prod
```

You will see that `horizontal-scaling-config` is currently part of the generated YAML.

---

### Step 2: Remove the ConfigMap from base and overlays

You need to remove the `horizontal-scaling-config` resource from:

- `base/api-gateway.yaml`
- `staging/api-gateway.yaml`
- `prod/api-gateway.yaml`

If you only remove it from base, staging/prod patches may fail because they still try to patch that ConfigMap.

Edit the files:

```bash
vim base/api-gateway.yaml
vim staging/api-gateway.yaml
vim prod/api-gateway.yaml
```

After removal, `kubectl kustomize staging` and `kubectl kustomize prod` should no longer show the ConfigMap.

---

### Step 3: Add the HPA to the base config

Edit the base YAML and add a HorizontalPodAutoscaler resource.

Example `base/api-gateway.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 2
  maxReplicas: 4
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-gateway
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      id: api-gateway
  template:
    metadata:
      labels:
        id: api-gateway
    spec:
      serviceAccountName: api-gateway
      containers:
        - image: httpd:2-alpine
          name: httpd
```

Namespace is not specified here because the overlay `NamespaceTransformer` will set it.

---

### Step 4: Override maxReplicas in prod

Edit the prod patch file:

```bash
vim prod/api-gateway.yaml
```

Add a patch for the HPA so that only prod changes `maxReplicas` to `6`.

Example `prod/api-gateway.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  labels:
    env: prod
```

This keeps base at `4` and changes prod to `6`.

---

### Step 5: Verify generated output

Check staging:

```bash
kubectl kustomize staging | grep -B 5 maxReplicas
```

Expected relevant output:

```text
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
  namespace: api-gateway-staging
spec:
  maxReplicas: 4
```

Check prod:

```bash
kubectl kustomize prod | grep -B 5 maxReplicas
```

Expected relevant output:

```text
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
  namespace: api-gateway-prod
spec:
  maxReplicas: 6
```

---

### Step 6: Apply changes

Apply staging:

```bash
kubectl kustomize staging | kubectl apply -f -
```

Apply prod:

```bash
kubectl kustomize prod | kubectl apply -f -
```

Expected output includes HPA creation:

```text
horizontalpodautoscaler.autoscaling/api-gateway created
```

---

### Step 7: Delete the old ConfigMaps manually

Even though the ConfigMap was removed from the Kustomize files, Kustomize does not keep state and will not automatically delete resources that already exist in the cluster.

So remove them manually:

```bash
kubectl -n api-gateway-staging delete configmap horizontal-scaling-config
kubectl -n api-gateway-prod delete configmap horizontal-scaling-config
```

Verify:

```bash
kubectl -n api-gateway-staging get cm
kubectl -n api-gateway-prod get cm
```

---

## Notes

- Kustomize does **not** automatically delete remote resources removed from local YAML.
- Helm can do that because it keeps release state.
- If you later run `kubectl diff` and see the Deployment replicas changing from `2` back to `1`, that is because the HPA already scaled it up to its minimum replicas. This does not affect the correctness of this task.

---

## Final Commands Summary

```bash
ssh cka5774
cd /opt/course/5/api-gateway

vim base/api-gateway.yaml
vim staging/api-gateway.yaml
vim prod/api-gateway.yaml

kubectl kustomize staging | kubectl apply -f -
kubectl kustomize prod | kubectl apply -f -

kubectl -n api-gateway-staging delete configmap horizontal-scaling-config
kubectl -n api-gateway-prod delete configmap horizontal-scaling-config
```