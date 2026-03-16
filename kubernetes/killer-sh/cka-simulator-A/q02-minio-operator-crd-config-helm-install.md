# Question 2 | MinIO Operator, CRD Config, Helm Install

**Solve this question on:** `ssh cka7968`

## Task

Install the MinIO Operator using Helm in Namespace `minio`. Then configure and create the Tenant CRD:

1. Create Namespace `minio`
2. Install Helm chart `minio/operator` into the new Namespace  
   - the Helm Release should be called `minio-operator`
3. Update the Tenant resource in `/opt/course/2/minio-tenant.yaml` to include `enableSFTP: true` under `features`
4. Create the Tenant resource from `/opt/course/2/minio-tenant.yaml`

> It is not required for MinIO to run properly. Installing the Helm Chart and the Tenant resource as requested is enough.

---

## Concepts

- **Helm Chart**: Kubernetes YAML template files combined into a single package
- **Helm Release**: Installed instance of a Chart
- **Helm Values**: Allow customization of the YAML template files in a Chart when creating a Release
- **Operator**: Pod that communicates with the Kubernetes API and may work with CRDs
- **CRD**: Custom Resources are extensions of the Kubernetes API

---

## Solution

### Step 1: Create the Namespace

```bash
ssh cka7968
kubectl create namespace minio
```

Expected output:

```text
namespace/minio created
```

---

### Step 2: Install the MinIO Operator Helm chart

Check available Helm repos and charts:

```bash
helm repo list
helm search repo
```

Expected relevant output:

```text
NAME    URL
minio   http://localhost:6000
```

```text
NAME             CHART VERSION   APP VERSION   DESCRIPTION
minio/operator   6.0.4           v6.0.4        A Helm chart for MinIO Operator
```

Install the chart into Namespace `minio` with release name `minio-operator`:

```bash
helm -n minio install minio-operator minio/operator
```

Verify the release:

```bash
helm -n minio ls
```

Verify pods:

```bash
kubectl -n minio get pods
```

Example output:

```text
NAME                              READY   STATUS    RESTARTS   AGE
minio-operator-7b595f559d-5hrj5   1/1     Running   0          24s
minio-operator-7b595f559d-sl22g   1/1     Running   0          25s
```

Because the Helm chart is installed, the MinIO CRDs are now available:

```bash
kubectl get crd
```

Example relevant output:

```text
NAME                     CREATED AT
miniojobs.job.min.io     ...
policybindings.sts.min.io ...
tenants.minio.min.io     ...
```

You can inspect the Tenant CRD:

```bash
kubectl describe crd tenant
```

---

### Step 3: Update the Tenant resource YAML

Edit the file:

```bash
vim /opt/course/2/minio-tenant.yaml
```

Update it so that `enableSFTP: true` is included under `spec.features`.

Example relevant YAML section:

```yaml
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: tenant
  namespace: minio
  labels:
    app: minio
spec:
  features:
    bucketDNS: false
    enableSFTP: true
  image: quay.io/minio/minio:latest
  pools:
    - servers: 1
      name: pool-0
      volumesPerServer: 0
      volumeClaimTemplate:
        apiVersion: v1
        kind: persistentvolumeclaims
        metadata: {}
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Mi
          storageClassName: standard
        status: {}
  requestAutoCert: true
```

If you want to confirm the available fields under `features`, you can inspect the CRD:

```bash
kubectl describe crd tenant | grep -i feature -A 20
```

This shows that `Enable SFTP` is a valid boolean field.

---

### Step 4: Create the Tenant resource

Apply the updated file:

```bash
kubectl apply -f /opt/course/2/minio-tenant.yaml
```

Verify the Tenant:

```bash
kubectl -n minio get tenant
```

Example output:

```text
NAME     STATE                     HEALTH   AGE
tenant   empty tenant credentials           21s
```

---

## Final Commands Summary

```bash
ssh cka7968

kubectl create namespace minio

helm -n minio install minio-operator minio/operator

vim /opt/course/2/minio-tenant.yaml

kubectl apply -f /opt/course/2/minio-tenant.yaml

kubectl -n minio get tenant
```