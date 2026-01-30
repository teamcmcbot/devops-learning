# Kustomize Basics

## Executive Summary

**Kustomize** is a native Kubernetes configuration management tool that allows you to customize YAML manifests without modifying the original files. It's built into `kubectl` and uses a **template-free** approach with plain YAML files.

**Key Concepts:**

| Term                   | Description                                               |
| ---------------------- | --------------------------------------------------------- |
| **Base**               | Shared/default configuration used across all environments |
| **Overlay**            | Environment-specific customizations (dev, stg, prod)      |
| **Transformer**        | Applies global changes (labels, namespaces, prefixes)     |
| **Patch**              | Targeted modifications to specific resources              |
| **kustomization.yaml** | Central file that defines resources and transformations   |

**Why Kustomize?**

- **No templating** - Uses plain, valid YAML files
- **Built into kubectl** - No separate installation needed
- **DRY principle** - Define once, customize per environment
- **Merge strategy** - Base + Overlay = Final manifests

---

## Kustomize vs Helm

| Feature            | Kustomize            | Helm                                  |
| ------------------ | -------------------- | ------------------------------------- |
| Templating         | Plain YAML overlays  | Go templates                          |
| Complexity         | Simple, readable     | More powerful, steeper learning curve |
| Package Management | No                   | Yes (charts)                          |
| Built into kubectl | Yes                  | No (separate install)                 |
| Use Case           | Environment variants | Full application packaging            |

**Choose Kustomize** for simple environment-specific customizations with readable YAML.

---

## Directory Structure

### Recommended Layout

```
k8s/
├── base/                          # Shared configuration
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/                      # Environment-specific
    ├── dev/
    │   └── kustomization.yaml
    ├── stg/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

### How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│    Base     │  +  │   Overlay    │  =  │ Final Manifests │
│ (replicas:1)│     │ (replicas:5) │     │  (replicas:5)   │
└─────────────┘     └──────────────┘     └─────────────────┘
```

---

## kustomization.yaml File

The central configuration file that tells Kustomize what to process.

### Basic Structure

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Resources to include
resources:
  - deployment.yaml
  - service.yaml
  # Or reference directories
  - api/
  - db/

# Transformations to apply
commonLabels:
  app: myapp

namespace: production

namePrefix: prod-
nameSuffix: -v1

commonAnnotations:
  branch: main
```

### Referencing Subdirectories

```yaml
# Root kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api/ # Contains its own kustomization.yaml
  - db/
  - cache/
```

Each subdirectory has its own `kustomization.yaml`:

```yaml
# api/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api-deployment.yaml
  - api-service.yaml
```

---

## Essential Commands

### Build and Preview

```bash
# Preview generated manifests (doesn't apply)
kustomize build <directory>
kustomize build k8s/base/
kustomize build k8s/overlays/prod/

# Using kubectl
kubectl kustomize <directory>
kubectl kustomize k8s/overlays/dev/
```

### Apply Configuration

```bash
# Method 1: Pipe to kubectl
kustomize build k8s/overlays/prod/ | kubectl apply -f -

# Method 2: Native kubectl (recommended)
kubectl apply -k k8s/overlays/prod/
kubectl apply -k .    # Current directory
```

### Delete Resources

```bash
# Method 1: Pipe to kubectl
kustomize build k8s/ | kubectl delete -f -

# Method 2: Native kubectl
kubectl delete -k k8s/overlays/prod/
```

---

## Common Transformers

Transformers apply changes globally to ALL resources.

### 1. Common Labels

```yaml
# kustomization.yaml
commonLabels:
  app: myapp
  team: platform
  env: production
```

**Result:** Labels added to all resources AND selectors.

### 2. Namespace

```yaml
# kustomization.yaml
namespace: production
```

**Result:** All resources placed in `production` namespace.

### 3. Name Prefix/Suffix

```yaml
# kustomization.yaml
namePrefix: prod-
nameSuffix: -v2
```

**Result:** `api-deployment` → `prod-api-deployment-v2`

### 4. Common Annotations

```yaml
# kustomization.yaml
commonAnnotations:
  branch: main
  commit: abc123
```

**Result:** Annotations added to all resource metadata.

### Combined Example

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

namespace: production
namePrefix: prod-
nameSuffix: -v1

commonLabels:
  app: myapp
  env: prod

commonAnnotations:
  managed-by: kustomize
```

---

## Image Transformer

Update container images without modifying deployment files.

### Change Image Name

```yaml
# kustomization.yaml
images:
  - name: nginx # Original image name
    newName: haproxy # New image name
```

### Change Image Tag

```yaml
# kustomization.yaml
images:
  - name: nginx
    newTag: "1.21.0"
```

### Change Both Name and Tag

```yaml
# kustomization.yaml
images:
  - name: nginx
    newName: my-registry/nginx
    newTag: "2.0"
```

### Multiple Images

```yaml
# kustomization.yaml
images:
  - name: nginx
    newTag: "1.21"
  - name: redis
    newTag: "7.0"
  - name: postgres
    newName: my-registry/postgres
    newTag: "15"
```

---

## Real-World Example

### Base Configuration

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

commonLabels:
  app: web-app
```

```yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: web
          image: nginx:1.20
          ports:
            - containerPort: 80
```

### Production Overlay

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

namespace: production
namePrefix: prod-

commonLabels:
  env: production

images:
  - name: nginx
    newTag: "1.21"

patches:
  - target:
      kind: Deployment
      name: web-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

### Deploy

```bash
# Preview production config
kubectl kustomize overlays/prod/

# Apply to cluster
kubectl apply -k overlays/prod/
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Apply configurations** using `kubectl apply -k`
2. **Modify kustomization.yaml** to add labels, namespace, images
3. **Create overlays** for different environments
4. **Use transformers** to customize resources

### Key Commands to Remember

| Task    | Command                   |
| ------- | ------------------------- |
| Preview | `kubectl kustomize <dir>` |
| Apply   | `kubectl apply -k <dir>`  |
| Delete  | `kubectl delete -k <dir>` |
| Build   | `kustomize build <dir>`   |

### Quick Kustomization Template

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml

namespace: myns
namePrefix: prefix-

commonLabels:
  app: myapp

images:
  - name: nginx
    newTag: "1.21"
```

### Common Mistakes to Avoid

- Forgetting `apiVersion` and `kind` in kustomization.yaml
- Using wrong path for resources/bases
- Not using `-k` flag (using `-f` instead)

---

## Official Documentation

- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [Kubernetes - Managing Objects with Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kustomize GitHub](https://github.com/kubernetes-sigs/kustomize)
