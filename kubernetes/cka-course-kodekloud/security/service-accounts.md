# Service Accounts

## Executive Summary

Service Accounts provide identity for processes running in pods. Unlike user accounts (for humans), service accounts are for applications and automated processes that need to interact with the Kubernetes API. Every namespace has a default service account automatically created.

## Key Concepts

| Account Type        | Purpose                                 | Managed By                  |
| ------------------- | --------------------------------------- | --------------------------- |
| **User Account**    | Human users (admins, developers)        | External identity providers |
| **Service Account** | Applications, bots, automated processes | Kubernetes                  |

### Token Changes (v1.22+)

- **Pre v1.22**: Tokens stored as Secrets, no expiration
- **v1.22+**: TokenRequest API generates time-bound, audience-bound tokens
- **v1.24+**: Tokens not auto-created as Secrets; use `kubectl create token`

## Real-World Usage

- CI/CD pipelines (Jenkins, GitLab) deploying applications
- Monitoring tools (Prometheus) querying cluster metrics
- Custom dashboards accessing Kubernetes API
- Controllers and operators managing resources

## YAML Configurations

### Basic Pod with Service Account

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  serviceAccountName: my-service-account
  containers:
    - name: my-app
      image: my-app:latest
```

### Disable Auto-Mount Token

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  automountServiceAccountToken: false
  containers:
    - name: my-app
      image: my-app:latest
```

### Service Account Definition

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-sa
  namespace: default
```

### Create Non-Expiring Token (Not Recommended)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-sa-token
  annotations:
    kubernetes.io/service-account.name: dashboard-sa
type: kubernetes.io/service-account-token
```

## Common Commands

### Create and Manage Service Accounts

```bash
# Create service account
kubectl create serviceaccount dashboard-sa

# List service accounts
kubectl get serviceaccounts
kubectl get sa

# Describe service account
kubectl describe sa dashboard-sa

# Delete service account
kubectl delete sa dashboard-sa
```

### Generate and Use Tokens

```bash
# Generate token (v1.24+)
kubectl create token dashboard-sa

# Generate token with custom duration
kubectl create token dashboard-sa --duration=24h

# Generate token for specific audience
kubectl create token dashboard-sa --audience=api
```

### View Token in Pod

```bash
# Token is mounted at this path in pods
/var/run/secrets/kubernetes.io/serviceaccount/token

# View token from inside pod
kubectl exec -it my-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

# List all files in service account mount
kubectl exec -it my-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/
# Output: ca.crt, namespace, token
```

### Use Service Account Token with API

```bash
# Get token
TOKEN=$(kubectl create token dashboard-sa)

# Query API with token
curl -k https://<api-server>:6443/api/v1/namespaces/default/pods \
  --header "Authorization: Bearer $TOKEN"
```

## Service Account with RBAC

### Grant Permissions to Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: pod-reader-sa
    namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Imperative Commands

```bash
# Create service account
kubectl create sa pod-reader-sa

# Create role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Bind role to service account
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=default:pod-reader-sa
```

## Token Projection (v1.22+)

Modern token mounting uses projected volumes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access
          readOnly: true
  volumes:
    - name: kube-api-access
      projected:
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - fieldRef:
                    fieldPath: metadata.namespace
                  path: namespace
```

## CKA Exam Tips

### What to Expect

- Create service accounts
- Assign service accounts to pods
- Bind RBAC roles to service accounts
- Generate tokens for external access

### Quick Reference

```bash
# Complete flow: SA + Role + Binding
kubectl create sa my-sa
kubectl create role my-role --verb=get,list --resource=pods
kubectl create rolebinding my-binding --role=my-role --serviceaccount=default:my-sa

# Test permissions
kubectl auth can-i get pods --as system:serviceaccount:default:my-sa
```

### Default Service Account

```bash
# Every namespace has a 'default' service account
kubectl get sa -n kube-system

# Pods use 'default' SA if not specified
kubectl describe pod <pod-name> | grep "Service Account"
```

## Official Documentation

- [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Configure Service Accounts for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Managing Service Account Tokens](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)
