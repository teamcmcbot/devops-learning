# Role-Based Access Control (RBAC)

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Create Roles and ClusterRoles
- Create RoleBindings and ClusterRoleBindings
- Create ServiceAccounts
- Grant permissions to users and service accounts
- Troubleshoot permission denied errors
- Understand RBAC API groups and verbs
- Test permissions with `kubectl auth can-i`

## Sample Questions

1. **Create a Role that allows reading pods in default namespace**
2. **Create a ServiceAccount and bind it to a Role**
3. **Grant cluster-admin permissions to a user**
4. **Troubleshoot why a user cannot list deployments**
5. **Check if a service account can create pods**

## Official Documentation

- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)

## Key Concepts

### RBAC Components

```
User/ServiceAccount → RoleBinding/ClusterRoleBinding → Role/ClusterRole → API Resources
```

| Resource | Scope | Purpose |
|----------|-------|---------|
| **Role** | Namespace | Define permissions in a namespace |
| **ClusterRole** | Cluster-wide | Define cluster-wide or namespaced permissions |
| **RoleBinding** | Namespace | Bind Role to subjects in namespace |
| **ClusterRoleBinding** | Cluster-wide | Bind ClusterRole to subjects cluster-wide |
| **ServiceAccount** | Namespace | Identity for pods |

### Role vs ClusterRole

| Aspect | Role | ClusterRole |
|--------|------|-------------|
| **Scope** | Single namespace | Cluster-wide or all namespaces |
| **Resources** | Namespaced resources only | All resources including cluster-scoped |
| **Use Case** | App-specific permissions | Admin, cluster resources |

## Imperative Commands

```bash
# Create ServiceAccount
kubectl create serviceaccount my-sa

# Create Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Create ClusterRole
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods

# Create RoleBinding
kubectl create rolebinding my-binding --role=pod-reader --user=john

# Create ClusterRoleBinding
kubectl create clusterrolebinding my-binding --clusterrole=cluster-admin --user=jane

# Bind ServiceAccount
kubectl create rolebinding sa-binding --role=pod-reader --serviceaccount=default:my-sa

# Check permissions
kubectl auth can-i create pods
kubectl auth can-i list pods --as=john
kubectl auth can-i delete nodes --as=system:serviceaccount:default:my-sa

# Check all permissions for user
kubectl auth can-i --list --as=john

# Get RBAC resources
kubectl get roles,rolebindings
kubectl get clusterroles,clusterrolebindings
kubectl get serviceaccounts
kubectl get sa

# Describe resources
kubectl describe role pod-reader
kubectl describe rolebinding my-binding
kubectl describe serviceaccount my-sa
```

## YAML Examples

### ServiceAccount
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-serviceaccount
  namespace: default
```

### Role - Basic Permissions
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]  # "" indicates core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### Role - Multiple Resources
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

### Role - Specific Resource Names
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-updater
  namespace: default
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]  # Only this specific ConfigMap
  verbs: ["get", "update"]
```

### ClusterRole - Cluster-Scoped Resources
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

### RoleBinding - Bind to User
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### RoleBinding - Bind to ServiceAccount
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-pod-reader
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-serviceaccount
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRoleBinding - Bind to User
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
subjects:
- kind: User
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRoleBinding - Bind ServiceAccount Cluster-Wide
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sa-cluster-admin
subjects:
- kind: ServiceAccount
  name: my-sa
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### Pod Using ServiceAccount
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-serviceaccount
  containers:
  - name: nginx
    image: nginx
```

### Complete Example: ServiceAccount with Permissions
```yaml
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: production
---
# Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "update", "patch"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: production
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
---
# Pod using ServiceAccount
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: production
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: myapp:v1
```

## Common API Groups and Resources

| API Group | Resources | Example Verbs |
|-----------|-----------|---------------|
| **""** (core) | pods, services, configmaps, secrets, pv, pvc | get, list, create, delete |
| **apps** | deployments, replicasets, statefulsets, daemonsets | get, list, create, update, delete |
| **batch** | jobs, cronjobs | get, list, create, delete |
| **rbac.authorization.k8s.io** | roles, rolebindings, clusterroles | get, list, create |
| **networking.k8s.io** | networkpolicies, ingresses | get, list, create, delete |
| **storage.k8s.io** | storageclasses | get, list |

## Common Verbs

| Verb | HTTP Method | Purpose |
|------|-------------|---------|
| **get** | GET | Read single resource |
| **list** | GET | List resources |
| **watch** | GET | Watch for changes |
| **create** | POST | Create resource |
| **update** | PUT | Update entire resource |
| **patch** | PATCH | Partial update |
| **delete** | DELETE | Delete resource |
| **deletecollection** | DELETE | Delete multiple resources |

## Troubleshooting Tips

### Permission Denied Error

```bash
# Error: "Error from server (Forbidden): pods is forbidden"

# Check current user
kubectl auth whoami

# Test specific permission
kubectl auth can-i get pods
kubectl auth can-i list deployments --namespace=production

# Test as another user
kubectl auth can-i list pods --as=john
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa

# List all permissions for user
kubectl auth can-i --list --as=john

# Check RoleBindings
kubectl get rolebindings
kubectl describe rolebinding <binding-name>

# Check ClusterRoleBindings
kubectl get clusterrolebindings | grep <user-name>
```

### ServiceAccount Cannot Perform Action

```bash
# Check if ServiceAccount exists
kubectl get sa <sa-name>

# Find RoleBindings for ServiceAccount
kubectl get rolebindings -o json | jq '.items[] | select(.subjects[]?.name=="<sa-name>")'

# Check what permissions SA has
kubectl auth can-i --list --as=system:serviceaccount:default:my-sa

# Test specific action
kubectl auth can-i create pods --as=system:serviceaccount:default:my-sa

# Check Role/ClusterRole rules
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>
```

### Role Not Working

```bash
# Verify Role exists
kubectl get role <role-name>

# Check Role rules
kubectl describe role <role-name>

# Verify RoleBinding exists
kubectl get rolebinding | grep <role-name>

# Check RoleBinding subjects
kubectl describe rolebinding <binding-name>

# Test permission
kubectl auth can-i <verb> <resource> --as=<user>

# Common issues:
# 1. Wrong API group in Role
# 2. Wrong namespace
# 3. RoleBinding in different namespace than Role
# 4. Wrong subject name in RoleBinding
```

### Finding Why User Has Permission

```bash
# List all RoleBindings for user
kubectl get rolebindings --all-namespaces -o json | \
  jq '.items[] | select(.subjects[]?.name=="<user-name>") | {namespace:.metadata.namespace, name:.metadata.name, role:.roleRef.name}'

# List all ClusterRoleBindings for user
kubectl get clusterrolebindings -o json | \
  jq '.items[] | select(.subjects[]?.name=="<user-name>") | {name:.metadata.name, role:.roleRef.name}'

# View ClusterRole permissions
kubectl describe clusterrole <clusterrole-name>
```

## Default ClusterRoles

| ClusterRole | Permissions |
|-------------|-------------|
| **cluster-admin** | Full access to everything |
| **admin** | Full access in namespace |
| **edit** | Read/write in namespace (no roles/rolebindings) |
| **view** | Read-only in namespace |

## Key Files and Locations

### ServiceAccount Tokens
- **Location in Pod**: `/var/run/secrets/kubernetes.io/serviceaccount/`
  - `token` - JWT token for authentication
  - `ca.crt` - CA certificate
  - `namespace` - Pod's namespace

```bash
# View token from inside pod
kubectl exec <pod-name> -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Decode JWT token (don't use in production - tokens are secrets!)
jwt=$(kubectl exec <pod-name> -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo $jwt | cut -d'.' -f2 | base64 -d
```

### RBAC Configuration
- **API Server**: RBAC enabled by default with `--authorization-mode=Node,RBAC`
- **Check**: `ps aux | grep kube-apiserver | grep authorization-mode`

## Exam Tips

1. **Use imperative commands** for speed: `kubectl create role/rolebinding`
2. **Test with `auth can-i`** before and after creating RBAC
3. **API group `""`** is core API (pods, services, etc.)
4. **ServiceAccount format**: `system:serviceaccount:<namespace>:<sa-name>`
5. **Default SA** in each namespace: `default`
6. **ClusterRole can be bound** with RoleBinding (namespace scope)
7. **Check both Role and RoleBinding** namespace match
8. **Verbs matter** - `get` doesn't include `list`
9. **resourceNames** for fine-grained control
10. **Use `--as`** flag to test permissions as another user

## Common Mistakes

- ❌ Wrong API group (e.g., `"apps"` for pods - should be `""`)
- ❌ Missing verb (e.g., can `get` but not `list`)
- ❌ RoleBinding in wrong namespace
- ❌ Wrong subject name format for ServiceAccount
- ❌ Using ClusterRoleBinding when RoleBinding is sufficient
- ❌ Not testing with `kubectl auth can-i`
- ❌ Granting excessive permissions (use least privilege)

## Quick Reference

```bash
# Create ServiceAccount
kubectl create sa my-sa

# Create Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Create RoleBinding
kubectl create rolebinding my-binding --role=pod-reader --serviceaccount=default:my-sa

# Test permission
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa

# Create pod with SA
kubectl run test --image=nginx --serviceaccount=my-sa

# View all permissions
kubectl auth can-i --list --as=system:serviceaccount:default:my-sa

# Cleanup
kubectl delete pod test
kubectl delete rolebinding my-binding
kubectl delete role pod-reader
kubectl delete sa my-sa
```

## RBAC Best Practices

1. **Least Privilege** - Grant minimum necessary permissions
2. **Namespace Isolation** - Use Roles instead of ClusterRoles when possible
3. **Specific Resources** - Use `resourceNames` for fine control
4. **Avoid wildcards** - Be explicit about verbs and resources
5. **Regular Audits** - Review permissions periodically
6. **ServiceAccounts for Pods** - Don't use default SA for apps
7. **Test Permissions** - Always verify with `auth can-i`

## Subject Types

```yaml
subjects:
# User
- kind: User
  name: jane@example.com
  apiGroup: rbac.authorization.k8s.io

# Group
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io

# ServiceAccount
- kind: ServiceAccount
  name: my-sa
  namespace: default
```
