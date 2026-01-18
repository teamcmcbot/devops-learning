# Admission Controllers - CKA Cheatsheet

## Executive Summary

**Admission Controllers** are plugins that intercept API requests **after authentication and authorization** but **before** the object is persisted to etcd. They can **validate**, **mutate**, or **reject** requests based on custom rules.

**Key Points:**

- Execute after Authentication → Authorization → **Admission Control**
- Two types: **Validating** (accept/reject) and **Mutating** (modify requests)
- Enforce policies RBAC cannot (e.g., "no latest tag", "no root containers")
- Configured via `--enable-admission-plugins` flag on kube-apiserver

---

## Request Flow

```
kubectl create pod
        │
        ▼
┌──────────────────┐
│  Authentication  │  Who are you? (certificates, tokens)
└────────┬─────────┘
         ▼
┌──────────────────┐
│  Authorization   │  Are you allowed? (RBAC)
└────────┬─────────┘
         ▼
┌──────────────────┐
│    Admission     │  Should we allow/modify this?
│   Controllers    │  (Validating & Mutating)
└────────┬─────────┘
         ▼
┌──────────────────┐
│      etcd        │  Persist the object
└──────────────────┘
```

---

## Types of Admission Controllers

| Type           | Purpose            | Example                                |
| -------------- | ------------------ | -------------------------------------- |
| **Mutating**   | Modify the request | Add default values, inject sidecars    |
| **Validating** | Accept or reject   | Block images from untrusted registries |

**Order:** Mutating runs first → then Validating

---

## Built-In Admission Controllers

| Controller            | Purpose                                                               |
| --------------------- | --------------------------------------------------------------------- |
| `NamespaceLifecycle`  | Reject requests to non-existent namespaces, protect system namespaces |
| `LimitRanger`         | Enforce default resource limits in namespace                          |
| `ServiceAccount`      | Auto-mount service account tokens                                     |
| `DefaultStorageClass` | Assign default StorageClass to PVCs                                   |
| `NodeRestriction`     | Limit what kubelets can modify                                        |
| `AlwaysPullImages`    | Force image pull on every pod creation                                |
| `PodSecurity`         | Enforce Pod Security Standards                                        |
| `ResourceQuota`       | Enforce namespace resource quotas                                     |

---

## Real-World Use Cases

| Use Case                    | Admission Controller                |
| --------------------------- | ----------------------------------- |
| Block `latest` image tag    | Custom ValidatingWebhook            |
| Inject sidecar containers   | MutatingWebhook (e.g., Istio)       |
| Enforce resource limits     | LimitRanger                         |
| Require specific labels     | Custom ValidatingWebhook            |
| Block privileged containers | PodSecurity                         |
| Auto-create namespaces      | NamespaceAutoProvision (deprecated) |

---

## Quick Reference

### View Enabled Admission Controllers

```bash
# Check enabled plugins (on control plane node)
kubectl exec -n kube-system kube-apiserver-controlplane -- kube-apiserver -h | grep enable-admission-plugins

# Or check the API server manifest
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep admission-plugins

# Or via process
ps aux | grep kube-apiserver | grep admission-plugins
```

---

### Enable Admission Controllers

**Edit kube-apiserver manifest:**

```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
    - command:
        - kube-apiserver
        - --authorization-mode=Node,RBAC
        - --enable-admission-plugins=NodeRestriction,NamespaceLifecycle,LimitRanger
      image: registry.k8s.io/kube-apiserver:v1.28.0
      name: kube-apiserver
```

---

### Disable Admission Controllers

```yaml
# Add to kube-apiserver command
- --disable-admission-plugins=DefaultStorageClass
```

---

### Default Enabled Controllers (v1.28+)

```
NamespaceLifecycle, LimitRanger, ServiceAccount,
TaintNodesByCondition, PodSecurity, Priority,
DefaultTolerationSeconds, DefaultStorageClass,
StorageObjectInUseProtection, PersistentVolumeClaimResize,
RuntimeClass, CertificateApproval, CertificateSigning,
ClusterTrustBundleAttest, CertificateSubjectRestriction,
DefaultIngressClass, MutatingAdmissionWebhook,
ValidatingAdmissionPolicy, ValidatingAdmissionWebhook, ResourceQuota
```

---

## Common Commands

```bash
# List all available admission plugins
kube-apiserver -h | grep enable-admission-plugins

# Check if specific controller is enabled
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -A 20 "command:"

# After modifying kube-apiserver.yaml, wait for restart
kubectl get pods -n kube-system -w

# Test namespace lifecycle controller
kubectl run nginx --image=nginx -n non-existent-namespace
# Error: namespaces "non-existent-namespace" not found
```

---

## Namespace Lifecycle Example

**Without `NamespaceLifecycle` (deprecated `NamespaceExists`):**

```bash
kubectl run nginx --image=nginx -n blue
# Error: namespaces "blue" not found
```

**What `NamespaceLifecycle` does:**

- Rejects requests to non-existent namespaces
- Prevents deletion of system namespaces (`default`, `kube-system`, `kube-public`)
- Ensures namespace deletion cascades properly

---

## Deprecated Controllers

| Deprecated               | Replaced By                            |
| ------------------------ | -------------------------------------- |
| `NamespaceExists`        | `NamespaceLifecycle`                   |
| `NamespaceAutoProvision` | `NamespaceLifecycle`                   |
| `PodSecurityPolicy`      | `PodSecurity` (Pod Security Admission) |

---

## Admission Webhooks (Dynamic Admission Control)

For custom logic beyond built-in controllers, use **Admission Webhooks**:

| Webhook Type                 | Purpose                                      |
| ---------------------------- | -------------------------------------------- |
| `MutatingAdmissionWebhook`   | Modify objects (add labels, inject sidecars) |
| `ValidatingAdmissionWebhook` | Accept/reject based on custom rules          |

**Flow:** API Server → Mutating Webhooks → Validating Webhooks → etcd

---

### ValidatingWebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: "pod-policy.example.com"
webhooks:
  - name: "pod-policy.example.com"
    clientConfig:
      service:
        namespace: "webhook-namespace"
        name: "webhook-service"
      caBundle: "LS0tLS1CRUdJTi..." # Base64 encoded CA cert
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
        scope: "Namespaced"
    admissionReviewVersions: ["v1"]
    sideEffects: None
```

---

### MutatingWebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: "sidecar-injector.example.com"
webhooks:
  - name: "sidecar-injector.example.com"
    clientConfig:
      service:
        namespace: "webhook-namespace"
        name: "sidecar-injector-service"
      caBundle: "LS0tLS1CRUdJTi..."
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
    admissionReviewVersions: ["v1"]
    sideEffects: None
```

---

### Webhook Commands

```bash
# List webhook configurations
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Describe webhook
kubectl describe validatingwebhookconfigurations <name>

# Check webhook service exists
kubectl get svc -n webhook-namespace
```

---

### TLS Secret for Webhooks

**API Server → Webhook communication MUST be over HTTPS**

```bash
# Create TLS secret for webhook server
kubectl -n webhook-demo create secret tls webhook-server-tls \
    --cert "/root/keys/webhook-server-tls.crt" \
    --key "/root/keys/webhook-server-tls.key"
```

| Component  | Purpose                                                        |
| ---------- | -------------------------------------------------------------- |
| `tls.crt`  | Certificate - proves webhook identity                          |
| `tls.key`  | Private key - decrypts requests                                |
| `caBundle` | CA cert in WebhookConfiguration (so API server trusts webhook) |

**Webhook Deployment mounts the TLS secret:**

```yaml
spec:
  containers:
    - name: webhook
      volumeMounts:
        - name: tls-certs
          mountPath: /etc/webhook/certs
          readOnly: true
  volumes:
    - name: tls-certs
      secret:
        secretName: webhook-server-tls
```

**Get caBundle value:**

```bash
# Base64 encode CA cert for caBundle field
cat ca.crt | base64 | tr -d '\n'
```

---

### DefaultStorageClass Mutation Example

**Before mutation (no storageClassName):**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

**After DefaultStorageClass mutates it:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: default # Added by admission controller
```

---

## CKA Exam Scenarios

### Scenario 1: Identify Enabled Admission Controllers

**Question:** Which admission controllers are enabled on the cluster?

```bash
# Method 1: Check API server manifest
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep enable-admission-plugins

# Method 2: Check process
ps aux | grep kube-apiserver | grep enable-admission-plugins

# Method 3: Describe API server pod
kubectl describe pod kube-apiserver-controlplane -n kube-system | grep admission
```

---

### Scenario 2: Enable an Admission Controller

**Question:** Enable the `NamespaceAutoProvision` admission controller.

```bash
# Edit kube-apiserver manifest
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Add or modify the flag:
# --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision

# Wait for API server to restart
kubectl get pods -n kube-system -w
```

---

### Scenario 3: Disable an Admission Controller

**Question:** Disable the `DefaultStorageClass` admission controller.

```bash
# Edit kube-apiserver manifest
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Add the flag:
# --disable-admission-plugins=DefaultStorageClass

# Wait for restart
watch kubectl get pods -n kube-system
```

---

### Scenario 4: Troubleshoot Admission Controller Issue

**Question:** Pod creation fails with "namespace not found". Which admission controller is responsible?

**Answer:** `NamespaceLifecycle` (or deprecated `NamespaceExists`)

```bash
# Verify namespace doesn't exist
kubectl get namespace blue

# Create namespace first
kubectl create namespace blue

# Then create pod
kubectl run nginx --image=nginx -n blue
```

---

### Scenario 5: Understand What RBAC Cannot Do

**Question:** RBAC allows user to create pods, but you want to prevent using `latest` tag. How?

**Answer:** Use a **ValidatingAdmissionWebhook** or **ValidatingAdmissionPolicy** - admission controllers can enforce rules RBAC cannot.

---

## Exam Tips

1. **Know the order**: Authentication → Authorization → Admission Control
2. **Location of config**: `/etc/kubernetes/manifests/kube-apiserver.yaml`
3. **Flags to remember**:
   - `--enable-admission-plugins=Plugin1,Plugin2`
   - `--disable-admission-plugins=Plugin1`
4. **API server restarts automatically** when manifest changes
5. **NamespaceLifecycle** is the modern replacement for NamespaceExists
6. **Mutating runs before Validating**
7. **Cannot edit running pods** - admission controllers work on creation/update

---

## Quick Comparison: RBAC vs Admission Controllers

| Aspect          | RBAC                   | Admission Controllers            |
| --------------- | ---------------------- | -------------------------------- |
| **Controls**    | Who can do what        | How things are done              |
| **Scope**       | API operations         | Object content/values            |
| **Example**     | "User can create pods" | "Pods must have resource limits" |
| **Enforcement** | Allow/Deny operations  | Validate/Mutate objects          |

---

## Official Documentation

- [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Dynamic Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
- [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [Using Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-does-each-admission-controller-do)
