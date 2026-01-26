# Cluster Roles and ClusterRoleBindings

## Executive Summary

ClusterRoles and ClusterRoleBindings extend RBAC to cluster-scoped resources (nodes, persistent volumes, namespaces) and can also grant permissions across all namespaces. Use these when you need cluster-wide permissions or access to non-namespaced resources.

## Key Concepts

### Namespaced vs Cluster-Scoped Resources

| Namespaced Resources        | Cluster-Scoped Resources          |
| --------------------------- | --------------------------------- |
| pods, deployments, services | nodes                             |
| configmaps, secrets         | persistentvolumes                 |
| roles, rolebindings         | clusterroles, clusterrolebindings |
| jobs, cronjobs              | namespaces                        |
| replicasets, statefulsets   | storageclasses                    |

### Check Resource Scope

```bash
# List namespaced resources
kubectl api-resources --namespaced=true

# List cluster-scoped resources
kubectl api-resources --namespaced=false
```

## Real-World Usage

- Granting cluster administrator access
- Managing nodes across the cluster
- Creating storage administrators for PV management
- Providing read access to all namespaces for monitoring

## YAML Configurations

### ClusterRole for Node Administration

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-administrator
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list", "get", "create", "delete"]
```

### ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
subjects:
  - kind: User
    name: cluster-admin
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-administrator
  apiGroup: rbac.authorization.k8s.io
```

### Storage Administrator ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: storage-admin
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "create", "delete"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "create", "delete"]
```

### ClusterRole for All Pods (All Namespaces)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader-all-namespaces
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-global
subjects:
  - kind: User
    name: monitoring-user
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader-all-namespaces
  apiGroup: rbac.authorization.k8s.io
```

## Common Commands

### Create ClusterRoles and Bindings

```bash
# Create clusterrole imperatively
kubectl create clusterrole node-admin \
  --verb=get,list,create,delete \
  --resource=nodes

# Create clusterrolebinding
kubectl create clusterrolebinding node-admin-binding \
  --clusterrole=node-admin \
  --user=admin-user

# Create from YAML
kubectl apply -f clusterrole.yaml
kubectl apply -f clusterrolebinding.yaml
```

### View ClusterRoles and Bindings

```bash
# List clusterroles
kubectl get clusterroles

# List clusterrolebindings
kubectl get clusterrolebindings

# Describe clusterrole
kubectl describe clusterrole cluster-admin

# Describe clusterrolebinding
kubectl describe clusterrolebinding cluster-admin-binding
```

### Test Permissions

```bash
# Check cluster-wide permissions
kubectl auth can-i delete nodes --as admin-user

# Check permissions on cluster-scoped resources
kubectl auth can-i list persistentvolumes --as storage-admin
```

## Default ClusterRoles

Kubernetes includes several built-in ClusterRoles:

| ClusterRole     | Description                                        |
| --------------- | -------------------------------------------------- |
| `cluster-admin` | Full cluster access (superuser)                    |
| `admin`         | Admin access within a namespace                    |
| `edit`          | Read/write access to most resources in a namespace |
| `view`          | Read-only access to most resources in a namespace  |

```bash
# View default clusterroles
kubectl get clusterroles | grep -E "^(cluster-admin|admin|edit|view)"

# Describe the cluster-admin role
kubectl describe clusterrole cluster-admin
```

## ClusterRole vs Role Binding Combinations

| ClusterRole + RoleBinding        | Result                                                            |
| -------------------------------- | ----------------------------------------------------------------- |
| ClusterRole + RoleBinding        | ClusterRole permissions apply only in the RoleBinding's namespace |
| ClusterRole + ClusterRoleBinding | Permissions apply cluster-wide                                    |

```yaml
# ClusterRole with RoleBinding (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-dev
  namespace: dev # Only applies in dev namespace
subjects:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole # Using ClusterRole
  name: pod-reader-all-namespaces
  apiGroup: rbac.authorization.k8s.io
```

## CKA Exam Tips

### What to Expect

- Create ClusterRoles for node/PV management
- Bind ClusterRoles to users for cluster-wide access
- Distinguish between namespaced and cluster-scoped resources
- Use default ClusterRoles appropriately

### Quick Reference

```bash
# Quick cluster admin setup
kubectl create clusterrolebinding admin-user-binding \
  --clusterrole=cluster-admin \
  --user=admin-user

# Verify
kubectl auth can-i '*' '*' --as admin-user
```

## Official Documentation

- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Default ClusterRoles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings)
