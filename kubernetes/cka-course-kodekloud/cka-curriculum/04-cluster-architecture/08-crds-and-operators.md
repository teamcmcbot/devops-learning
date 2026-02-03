# Custom Resource Definitions (CRDs) and Operators

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Understand what Custom Resource Definitions (CRDs) are
- Create and manage CRDs
- Create custom resources from CRDs
- Understand Operators and their purpose
- Deploy and manage Operators
- Troubleshoot CRD and custom resource issues

## Sample Questions

1. **Create a Custom Resource Definition**
2. **Create a custom resource from a CRD**
3. **List all CRDs in the cluster**
4. **Deploy an operator using Operator Lifecycle Manager**
5. **Troubleshoot custom resource not being created**

## Official Documentation

- [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Custom Resource Definitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
- [Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

## Key Concepts

### Custom Resource Definitions (CRDs)

CRDs extend the Kubernetes API by allowing you to define custom resource types.

```
Standard Kubernetes Resources        Custom Resources
┌──────────────────────┐             ┌──────────────────────┐
│ Pod                  │             │ Database             │
│ Deployment           │             │ Backup               │
│ Service              │   +CRD →    │ Certificate          │
│ ConfigMap            │             │ VirtualMachine       │
│ ...                  │             │ ...                  │
└──────────────────────┘             └──────────────────────┘
```

### Operators

Operators = CRDs + Controllers (automation logic)

```
┌─────────────────────────────────────────┐
│            Operator                     │
│  ┌──────────────┐  ┌────────────────┐  │
│  │     CRD      │  │   Controller   │  │
│  │  (What)      │  │   (How)        │  │
│  └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────┘
        │                      │
        ▼                      ▼
  Custom Resource    Manages Kubernetes
   (Desired State)    Resources to match
                      Desired State
```

## Create Custom Resource Definitions

### Basic CRD Example

```yaml
# crd-backup.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              schedule:
                type: string
              database:
                type: string
              retention:
                type: integer
            required:
            - schedule
            - database
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames:
    - bkp
```

```bash
# Create the CRD
kubectl apply -f crd-backup.yaml

# Verify CRD created
kubectl get crd
kubectl get crd backups.stable.example.com

# Describe CRD
kubectl describe crd backups.stable.example.com

# Check API resources (backup should appear)
kubectl api-resources | grep backup
```

### Create Custom Resource from CRD

```yaml
# backup-cr.yaml
apiVersion: stable.example.com/v1
kind: Backup
metadata:
  name: database-backup
  namespace: production
spec:
  schedule: "0 2 * * *"
  database: "postgresql"
  retention: 7
```

```bash
# Create custom resource
kubectl apply -f backup-cr.yaml

# List custom resources
kubectl get backups
kubectl get backups -n production
kubectl get bkp  # Using short name

# Describe custom resource
kubectl describe backup database-backup

# Get YAML
kubectl get backup database-backup -o yaml

# Delete custom resource
kubectl delete backup database-backup
```

## Advanced CRD Features

### CRD with Validation

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              type:
                type: string
                enum:
                - postgresql
                - mysql
                - mongodb
              version:
                type: string
                pattern: '^[0-9]+\.[0-9]+$'
              replicas:
                type: integer
                minimum: 1
                maximum: 10
              storage:
                type: string
                pattern: '^[0-9]+Gi$'
            required:
            - type
            - version
            - storage
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
    - db
```

### CRD with Status Subresource

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: applications.apps.example.com
spec:
  group: apps.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
              image:
                type: string
          status:
            type: object
            properties:
              availableReplicas:
                type: integer
              conditions:
                type: array
                items:
                  type: object
                  properties:
                    type:
                      type: string
                    status:
                      type: string
                    lastTransitionTime:
                      type: string
    subresources:
      status: {}
  scope: Namespaced
  names:
    plural: applications
    singular: application
    kind: Application
```

### CRD with Additional Printer Columns

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: instances.compute.example.com
spec:
  group: compute.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: string
              region:
                type: string
              status:
                type: string
    additionalPrinterColumns:
    - name: Size
      type: string
      jsonPath: .spec.size
    - name: Region
      type: string
      jsonPath: .spec.region
    - name: Status
      type: string
      jsonPath: .spec.status
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
  scope: Namespaced
  names:
    plural: instances
    singular: instance
    kind: Instance
```

```bash
# When listing, you'll see custom columns
kubectl get instances
# NAME         SIZE      REGION      STATUS     AGE
# my-instance  large     us-west-2   Running    5m
```

## Operators

### What is an Operator?

An Operator is:
1. **CRD** - Defines custom resource type
2. **Controller** - Watches custom resources and manages Kubernetes resources
3. **Domain Knowledge** - Encodes operational knowledge

### Popular Operators

| Operator | Purpose |
|----------|---------|
| **Prometheus Operator** | Manages Prometheus monitoring |
| **etcd Operator** | Manages etcd clusters |
| **PostgreSQL Operator** | Manages PostgreSQL databases |
| **MongoDB Operator** | Manages MongoDB databases |
| **cert-manager** | Manages TLS certificates |
| **NGINX Ingress Operator** | Manages NGINX Ingress |

### Deploy an Operator (Example: Prometheus Operator)

```bash
# Add Prometheus community Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Operator
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Check CRDs created by operator
kubectl get crd | grep monitoring.coreos.com

# You'll see CRDs like:
# - prometheuses.monitoring.coreos.com
# - servicemonitors.monitoring.coreos.com
# - prometheusrules.monitoring.coreos.com
# - alertmanagers.monitoring.coreos.com

# Check operator pod
kubectl get pods -n monitoring

# List Prometheus custom resources
kubectl get prometheus -n monitoring
kubectl get servicemonitor -n monitoring
kubectl get prometheusrule -n monitoring
```

### Create Custom Resource for Operator

```yaml
# servicemonitor-example.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
```

```bash
# Apply ServiceMonitor
kubectl apply -f servicemonitor-example.yaml

# Verify
kubectl get servicemonitor -n monitoring
kubectl describe servicemonitor my-app-monitor -n monitoring
```

### Simple Operator Example (Conceptual)

An operator typically consists of:

1. **CRD** - Defines what users can request
2. **Controller** - Watches CRD and reconciles state

```yaml
# CRD: website.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: websites.web.example.com
spec:
  group: web.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              domain:
                type: string
              replicas:
                type: integer
              image:
                type: string
  scope: Namespaced
  names:
    plural: websites
    singular: website
    kind: Website
```

```yaml
# Custom Resource: mysite.yaml
apiVersion: web.example.com/v1
kind: Website
metadata:
  name: my-website
spec:
  domain: "example.com"
  replicas: 3
  image: "nginx:latest"
```

The operator controller would:
- Watch for Website resources
- Create Deployment with specified replicas and image
- Create Service
- Create Ingress for the domain
- Update status of Website resource

## Manage CRDs and Custom Resources

### List and Inspect

```bash
# List all CRDs
kubectl get crd
kubectl get crds

# List CRDs with details
kubectl get crd -o wide

# Describe specific CRD
kubectl describe crd <crd-name>

# Get CRD YAML
kubectl get crd <crd-name> -o yaml

# List custom resources (example: backups)
kubectl get backups
kubectl get backups --all-namespaces
kubectl get backups -A

# Get custom resource details
kubectl describe backup <resource-name>
kubectl get backup <resource-name> -o yaml
```

### Update CRDs

```bash
# Update CRD
kubectl apply -f updated-crd.yaml

# Edit CRD directly
kubectl edit crd <crd-name>

# Patch CRD
kubectl patch crd <crd-name> --type=merge -p '{"spec":{"versions":[...]}}'
```

### Delete CRDs

```bash
# Delete custom resources first
kubectl delete backup --all

# Then delete CRD
kubectl delete crd backups.stable.example.com

# Delete CRD from file
kubectl delete -f crd-backup.yaml

# WARNING: Deleting CRD deletes ALL custom resources of that type!
```

## Troubleshooting Tips

### CRD Not Creating

```bash
# Check if CRD was applied
kubectl get crd | grep <crd-name>

# Check for errors in CRD definition
kubectl apply -f crd.yaml --dry-run=server

# Describe CRD for events
kubectl describe crd <crd-name>

# Check API server logs
kubectl logs -n kube-system -l component=kube-apiserver

# Common issues:
# 1. Invalid YAML syntax
# 2. Wrong apiVersion
# 3. Missing required fields in schema
# 4. Duplicate CRD name
```

### Custom Resource Not Valid

```bash
# Error: "validation failed"

# Check CRD schema
kubectl get crd <crd-name> -o yaml

# Validate custom resource against schema
kubectl apply -f custom-resource.yaml --dry-run=server

# Check validation errors
kubectl describe <resource-type> <resource-name>

# Common issues:
# 1. Missing required fields
# 2. Wrong data type
# 3. Value doesn't match enum
# 4. Pattern mismatch
```

### Operator Not Working

```bash
# Check operator pod is running
kubectl get pods -n <operator-namespace>

# Check operator logs
kubectl logs -n <operator-namespace> <operator-pod>

# Check RBAC permissions
kubectl describe serviceaccount <operator-sa> -n <operator-namespace>
kubectl describe clusterrole <operator-role>
kubectl describe clusterrolebinding <operator-binding>

# Check if CRDs exist
kubectl get crd | grep <operator-crd>

# Check custom resource status
kubectl get <custom-resource> <name> -o yaml
# Look at status section

# Common issues:
# 1. Operator pod not running
# 2. Missing RBAC permissions
# 3. CRDs not installed
# 4. Custom resource validation failed
# 5. Operator can't reach API server
```

### Can't Delete Custom Resource

```bash
# Resource stuck in Terminating state

# Check for finalizers
kubectl get <resource-type> <name> -o yaml | grep -A 5 finalizers

# Remove finalizers (use with caution)
kubectl patch <resource-type> <name> -p '{"metadata":{"finalizers":[]}}' --type=merge

# Force delete (last resort)
kubectl delete <resource-type> <name> --force --grace-period=0

# Check if operator is running (it should handle finalizers)
kubectl get pods -n <operator-namespace>
```

## Key Files and Locations

| Location | Purpose |
|----------|---------|
| `/etc/kubernetes/manifests/` | Static pod manifests (if operator runs there) |
| CRDs stored in etcd | API server persists CRDs |
| Custom Resources in etcd | Custom resources stored like other Kubernetes objects |

## Exam Tips

1. **CRDs extend the API** - They add new resource types
2. **Check CRD exists** before creating custom resources
3. **Use kubectl api-resources** to see new resource types
4. **Operators need RBAC** - ServiceAccount, Role, RoleBinding
5. **CRD names** follow pattern: `<plural>.<group>`
6. **Use short names** for convenience (define in CRD)
7. **Delete custom resources first** before deleting CRD
8. **Check operator logs** for troubleshooting
9. **Validation is in openAPIV3Schema** section
10. **Time management** - CRDs can be complex, don't overthink

## Common Mistakes

- ❌ Wrong API group in custom resource
- ❌ Missing required fields in custom resource spec
- ❌ Deleting CRD before deleting custom resources
- ❌ Typo in CRD name (plural vs singular)
- ❌ Not checking if CRD is created before using it
- ❌ Wrong apiVersion in CRD or custom resource
- ❌ Missing RBAC for operator
- ❌ Not checking operator pod status
- ❌ Invalid OpenAPI schema in CRD
- ❌ Forgetting to specify storage version in CRD

## Quick Reference

### CRD Commands

```bash
# List CRDs
kubectl get crd

# Create CRD
kubectl apply -f crd.yaml

# Delete CRD
kubectl delete crd <crd-name>

# Describe CRD
kubectl describe crd <crd-name>

# Check new API resources
kubectl api-resources | grep <group>
```

### Custom Resource Commands

```bash
# Create custom resource
kubectl apply -f custom-resource.yaml

# List custom resources
kubectl get <resource-type>
kubectl get <short-name>

# Describe
kubectl describe <resource-type> <name>

# Delete
kubectl delete <resource-type> <name>

# Get YAML
kubectl get <resource-type> <name> -o yaml
```

### Operator Commands

```bash
# Install operator (Helm example)
helm install <release> <chart> -n <namespace> --create-namespace

# Check operator pod
kubectl get pods -n <namespace>

# Check operator logs
kubectl logs -n <namespace> <pod-name>

# List operator CRDs
kubectl get crd | grep <operator-domain>

# List custom resources created by operator
kubectl get <resource-type> -A
```

### Quick CRD Template

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: <plural>.<group>
spec:
  group: <group>
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              # Define your fields here
  scope: Namespaced  # or Cluster
  names:
    plural: <plural>
    singular: <singular>
    kind: <Kind>
    shortNames:
    - <short>
```

## Example: Complete CRD Workflow

```bash
# 1. Create CRD
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              schedule:
                type: string
              database:
                type: string
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames:
    - bkp
EOF

# 2. Verify CRD
kubectl get crd backups.stable.example.com
kubectl api-resources | grep backup

# 3. Create custom resource
cat <<EOF | kubectl apply -f -
apiVersion: stable.example.com/v1
kind: Backup
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"
  database: "postgres"
EOF

# 4. List custom resources
kubectl get backups
kubectl get bkp

# 5. Describe
kubectl describe backup daily-backup

# 6. Cleanup
kubectl delete backup daily-backup
kubectl delete crd backups.stable.example.com
```
