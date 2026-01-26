# Role-Based Access Control (RBAC)

## Executive Summary

RBAC is the standard method for managing authorization in Kubernetes. It controls what actions users and service accounts can perform on cluster resources. RBAC uses Roles (namespace-scoped) and RoleBindings to grant permissions to users or groups.

## Key Concepts

| Resource               | Scope        | Purpose                                     |
| ---------------------- | ------------ | ------------------------------------------- |
| **Role**               | Namespace    | Defines permissions within a namespace      |
| **RoleBinding**        | Namespace    | Binds Role to users/groups/service accounts |
| **ClusterRole**        | Cluster-wide | Defines permissions across all namespaces   |
| **ClusterRoleBinding** | Cluster-wide | Binds ClusterRole to users/groups           |

### Authorization Modes

- **RBAC** - Role-based (recommended)
- **ABAC** - Attribute-based (requires API server restart for changes)
- **Node** - For kubelet authorization
- **Webhook** - External authorization service

## Real-World Usage

- Restricting developers to specific namespaces
- Creating read-only access for monitoring tools
- Granting admin access to cluster operators
- Limiting CI/CD pipelines to deployment permissions only

## YAML Configurations

### Role Definition

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: dev # Role is namespace-scoped
rules:
  - apiGroups: [""] # "" = core API group
    resources: ["pods"]
    verbs: ["list", "get", "create", "update", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "get"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "create"]
```

### RoleBinding Definition

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: dev
subjects:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io
# Can also bind to Group or ServiceAccount:
# - kind: Group
#   name: developers
#   apiGroup: rbac.authorization.k8s.io
# - kind: ServiceAccount
#   name: my-sa
#   namespace: dev
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

### Restrict Access to Specific Resources

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
    resourceNames: ["blue-pod", "green-pod"] # Only these specific pods
```

## Common Commands

### Create Roles and Bindings

```bash
# Create role imperatively
kubectl create role developer \
  --verb=get,list,create,delete \
  --resource=pods \
  --namespace=dev

# Create rolebinding imperatively
kubectl create rolebinding dev-user-binding \
  --role=developer \
  --user=dev-user \
  --namespace=dev

# Create role from YAML
kubectl apply -f role.yaml

# Create rolebinding from YAML
kubectl apply -f rolebinding.yaml
```

### View Roles and Bindings

```bash
# List roles
kubectl get roles -n dev

# List rolebindings
kubectl get rolebindings -n dev

# Describe role
kubectl describe role developer -n dev

# Describe rolebinding
kubectl describe rolebinding dev-user-binding -n dev
```

### Test Permissions

```bash
# Check if you can perform an action
kubectl auth can-i create pods
kubectl auth can-i delete nodes

# Check permissions as another user
kubectl auth can-i create pods --as dev-user
kubectl auth can-i create pods --as dev-user --namespace dev

# Check permissions for a service account
kubectl auth can-i create pods --as system:serviceaccount:dev:my-sa

# List all permissions for current user
kubectl auth can-i --list

# List all permissions in a namespace
kubectl auth can-i --list --namespace=dev
```

## API Groups Reference

| API Group                   | Resources                                                               |
| --------------------------- | ----------------------------------------------------------------------- |
| `""` (core)                 | pods, services, configmaps, secrets, persistentvolumeclaims, namespaces |
| `apps`                      | deployments, replicasets, statefulsets, daemonsets                      |
| `batch`                     | jobs, cronjobs                                                          |
| `networking.k8s.io`         | networkpolicies, ingresses                                              |
| `rbac.authorization.k8s.io` | roles, rolebindings, clusterroles, clusterrolebindings                  |

## Common Verbs

| Verb               | Description                |
| ------------------ | -------------------------- |
| `get`              | Read a specific resource   |
| `list`             | List resources             |
| `watch`            | Watch for changes          |
| `create`           | Create new resources       |
| `update`           | Modify existing resources  |
| `patch`            | Partially modify resources |
| `delete`           | Delete resources           |
| `deletecollection` | Delete multiple resources  |

## CKA Exam Tips

### What to Expect

- Create Roles and RoleBindings
- Troubleshoot permission issues
- Test user permissions with `kubectl auth can-i`
- Modify existing RBAC policies

### Quick Reference

```bash
# Create a quick read-only role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Bind to user
kubectl create rolebinding read-pods --role=pod-reader --user=jane

# Verify
kubectl auth can-i get pods --as jane
```

## Official Documentation

- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Authorization Overview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)
