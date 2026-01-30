# Kustomize Patches and Overlays

## Executive Summary

**Patches** allow surgical, targeted modifications to specific Kubernetes resources, while **Overlays** enable environment-specific configurations by combining a base with customizations. **Components** provide reusable configuration blocks that can be selectively included across overlays.

| Feature        | Purpose                                           |
| -------------- | ------------------------------------------------- |
| **Patches**    | Modify specific fields in targeted resources      |
| **Overlays**   | Environment-specific customization (dev/stg/prod) |
| **Components** | Reusable optional features across overlays        |

---

## Patches Overview

Patches provide fine-grained control over resource modifications.

### Patch Types

| Type                | Description                   | Best For                  |
| ------------------- | ----------------------------- | ------------------------- |
| **JSON 6902**       | Precise path-based operations | Complex, specific changes |
| **Strategic Merge** | Kubernetes-aware merging      | Simpler, readable changes |

### Patch Operations

| Operation | Description           |
| --------- | --------------------- |
| `add`     | Insert new element    |
| `remove`  | Delete element        |
| `replace` | Update existing value |

---

## JSON 6902 Patches

### Basic Structure

```yaml
# kustomization.yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

### Inline vs Separate File

**Inline (in kustomization.yaml):**

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

**Separate File:**

```yaml
# kustomization.yaml
patches:
  - path: replica-patch.yaml
    target:
      kind: Deployment
      name: api-deployment
```

```yaml
# replica-patch.yaml
- op: replace
  path: /spec/replicas
  value: 5
```

### Common Examples

**Change Replica Count:**

```yaml
patches:
  - target:
      kind: Deployment
      name: web-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
```

**Change Deployment Name:**

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /metadata/name
        value: web-deployment
```

**Update Label:**

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /spec/template/metadata/labels/component
        value: web
```

**Add New Label:**

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: add
        path: /spec/template/metadata/labels/org
        value: KodeKloud
```

**Remove Label:**

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: remove
        path: /spec/template/metadata/labels/org
```

---

## List Operations (Containers)

### Replace Container (by index)

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0
        value:
          name: haproxy
          image: haproxy
```

### Add Container (append to list)

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: add
        path: /spec/template/spec/containers/-
        value:
          name: sidecar
          image: busybox
```

### Remove Container (by index)

```yaml
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: remove
        path: /spec/template/spec/containers/1
```

---

## Strategic Merge Patches

More readable, Kubernetes-native approach.

### Basic Example

```yaml
# kustomization.yaml
patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: api-deployment
      spec:
        replicas: 5
```

### Using Separate File

```yaml
# kustomization.yaml
patches:
  - replica-patch.yaml
```

```yaml
# replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 5
```

### Update Container Image

```yaml
# image-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
        - name: nginx # Match by container name
          image: haproxy # New image
```

### Add Container

```yaml
# sidecar-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
        - name: sidecar
          image: busybox
```

### Delete Container

```yaml
# delete-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
        - $patch: delete
          name: database
```

### Remove Label (set to null)

```yaml
# remove-label-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    metadata:
      labels:
        org: null # null removes the key
```

---

## Overlays

Overlays customize base configurations per environment.

### Directory Structure

```
k8s/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── stg/
    │   └── kustomization.yaml
    └── prod/
        ├── kustomization.yaml
        └── grafana-deployment.yaml   # Additional resource
```

### Base Configuration

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
```

```yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.20
```

### Development Overlay

```yaml
# overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base # Reference base

namespace: dev

patches:
  - target:
      kind: Deployment
      name: nginx-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
```

### Production Overlay

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base
  - grafana-deployment.yaml # Additional prod-only resource

namespace: production

namePrefix: prod-

images:
  - name: nginx
    newTag: "1.21"

patches:
  - target:
      kind: Deployment
      name: nginx-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

### Deploy Overlays

```bash
# Deploy to dev
kubectl apply -k overlays/dev/

# Deploy to production
kubectl apply -k overlays/prod/

# Preview before applying
kubectl kustomize overlays/prod/
```

---

## Components

Reusable configuration blocks for optional features.

### When to Use Components

- Optional features needed by some (not all) overlays
- Avoid duplicating configuration across overlays
- Keep features modular and maintainable

### Directory Structure

```
k8s/
├── base/
│   └── kustomization.yaml
├── components/
│   ├── caching/
│   │   ├── kustomization.yaml
│   │   └── redis-deployment.yaml
│   └── database/
│       ├── kustomization.yaml
│       ├── postgres-deployment.yaml
│       └── deployment-patch.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml      # Uses: db
    ├── premium/
    │   └── kustomization.yaml      # Uses: caching, db
    └── selfhosted/
        └── kustomization.yaml      # Uses: caching
```

### Component Definition

```yaml
# components/database/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component # Note: Component, not Kustomization

resources:
  - postgres-deployment.yaml

secretGenerator:
  - name: postgres-cred
    literals:
      - password=postgres123

patches:
  - deployment-patch.yaml
```

```yaml
# components/database/deployment-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
        - name: api
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-cred
                  key: password
```

### Using Components in Overlays

```yaml
# overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/database # Include database component
```

```yaml
# overlays/premium/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/database
  - ../../components/caching # Include both components
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Create patches** to modify replica count, labels, images
2. **Set up overlays** for different environments
3. **Apply environment-specific** configurations
4. **Understand patch syntax** (JSON 6902 and strategic merge)

### Quick Reference

| Task             | JSON 6902                                  | Strategic Merge         |
| ---------------- | ------------------------------------------ | ----------------------- |
| Change replicas  | `op: replace, path: /spec/replicas`        | `spec: replicas: N`     |
| Add label        | `op: add, path: /metadata/labels/key`      | `labels: key: value`    |
| Remove label     | `op: remove, path: /metadata/labels/key`   | `labels: key: null`     |
| Add container    | `op: add, path: /spec/.../containers/-`    | Just add container spec |
| Delete container | `op: remove, path: /spec/.../containers/N` | `$patch: delete`        |

### Common Overlay Pattern

```yaml
# overlays/<env>/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

namespace: <environment>

namePrefix: <env>-

images:
  - name: nginx
    newTag: "<version>"

patches:
  - target:
      kind: Deployment
      name: <deployment-name>
    patch: |-
      - op: replace
        path: /spec/replicas
        value: <count>
```

### Key Points

- **JSON 6902**: Use paths like `/spec/replicas`, indices for lists
- **Strategic Merge**: Match by `metadata.name`, more readable
- **Overlays**: Use `resources: - ../../base` to reference base
- **Components**: `kind: Component` with `apiVersion: kustomize.config.k8s.io/v1alpha1`

---

## Official Documentation

- [Kustomize Patches](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/)
- [Kustomize Components](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/components/)
- [Strategic Merge Patch](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/)
- [JSON Patch RFC 6902](https://datatracker.ietf.org/doc/html/rfc6902)
