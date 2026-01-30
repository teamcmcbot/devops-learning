# Kubernetes Namespaces

## Executive Summary

**Namespaces** provide a mechanism for isolating groups of resources within a single cluster. They are useful for:

- **Resource isolation**: Separate environments (dev, staging, prod)
- **Access control**: Apply RBAC policies per namespace
- **Resource quotas**: Limit CPU, memory, pod count per namespace
- **Organization**: Group related resources together

---

## Default Namespaces

| Namespace           | Purpose                                                  |
| ------------------- | -------------------------------------------------------- |
| **default**         | Default namespace for objects with no other namespace    |
| **kube-system**     | System components (API server, controller manager, etc.) |
| **kube-public**     | Publicly accessible resources, readable by all users     |
| **kube-node-lease** | Node heartbeat data for node health                      |

---

## Real-World Usage

| Scenario                   | Description                        |
| -------------------------- | ---------------------------------- |
| **Multi-tenant clusters**  | Isolate teams/projects             |
| **Environment separation** | dev, staging, prod in same cluster |
| **Resource management**    | Apply quotas per team              |
| **Access control**         | Different RBAC rules per namespace |

---

## Common Commands

### Viewing Namespaces

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# View resources in specific namespace
kubectl get pods -n kube-system
kubectl get all -n dev

# View resources in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces
```

### Creating Namespaces

```bash
# Imperative
kubectl create namespace dev
kubectl create ns prod

# From YAML
kubectl create -f namespace.yaml
kubectl apply -f namespace.yaml
```

### Working with Namespaces

```bash
# Create resource in specific namespace
kubectl create deployment nginx --image=nginx -n dev
kubectl apply -f deployment.yaml -n dev

# Set default namespace for current context
kubectl config set-context --current --namespace=dev

# Verify current namespace
kubectl config view --minify | grep namespace

# Delete namespace (deletes all resources in it!)
kubectl delete namespace dev
```

---

## YAML Configuration

### Namespace Definition

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

### Pod in Specific Namespace

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: dev # Specify namespace here
  labels:
    app: myapp
spec:
  containers:
    - name: nginx
      image: nginx
```

### ResourceQuota for Namespace

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dev
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 5Gi
    limits.cpu: "10"
    limits.memory: 10Gi
```

### LimitRange for Namespace

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: dev
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "256Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      type: Container
```

---

## Cross-Namespace Communication

### DNS Format

```
<service-name>.<namespace>.svc.cluster.local
```

### Examples

```bash
# Same namespace - just use service name
mysql.connect("db-service")

# Different namespace - use full DNS name
mysql.connect("db-service.dev.svc.cluster.local")

# Or shorter versions
mysql.connect("db-service.dev.svc")
mysql.connect("db-service.dev")
```

---

## CKA Exam Relevance

### What to Know

- Create and manage namespaces
- Work with resources across namespaces
- Set default namespace for context
- Apply ResourceQuotas
- Cross-namespace service communication

### Quick Commands (Exam Tips!)

```bash
# Create namespace quickly
kubectl create ns dev

# Run pod in namespace
kubectl run nginx --image=nginx -n dev

# Get all resources in namespace
kubectl get all -n dev

# Switch default namespace
kubectl config set-context --current --namespace=dev

# Create resource in namespace from YAML
kubectl apply -f pod.yaml -n dev
```

### Common Exam Tasks

1. Create namespace
2. Deploy resources to specific namespace
3. Apply ResourceQuota to namespace
4. List resources across all namespaces
5. Access service in different namespace

### Important Points

- Resources are namespace-scoped by default
- Some resources are cluster-scoped (nodes, PVs, namespaces)
- Deleting namespace deletes ALL resources in it
- Use `-n` flag to specify namespace in commands

---

## Namespace-Scoped vs Cluster-Scoped Resources

| Namespace-Scoped | Cluster-Scoped    |
| ---------------- | ----------------- |
| Pods             | Nodes             |
| Services         | PersistentVolumes |
| Deployments      | ClusterRoles      |
| ConfigMaps       | Namespaces        |
| Secrets          | StorageClasses    |

```bash
# List namespace-scoped resources
kubectl api-resources --namespaced=true

# List cluster-scoped resources
kubectl api-resources --namespaced=false
```

---

## Quick Reference

| Command                                                 | Description                 |
| ------------------------------------------------------- | --------------------------- |
| `kubectl get ns`                                        | List namespaces             |
| `kubectl create ns <name>`                              | Create namespace            |
| `kubectl get pods -n <ns>`                              | List pods in namespace      |
| `kubectl get pods -A`                                   | List pods in all namespaces |
| `kubectl config set-context --current --namespace=<ns>` | Set default namespace       |
| `kubectl delete ns <name>`                              | Delete namespace            |

---

## Official Documentation

- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
