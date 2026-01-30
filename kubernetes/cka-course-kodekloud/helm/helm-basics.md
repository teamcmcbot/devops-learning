# Helm Basics

## Executive Summary

Helm is the **package manager for Kubernetes** - it simplifies deploying and managing complex applications by packaging all Kubernetes resources (Deployments, Services, ConfigMaps, Secrets, etc.) into a single unit called a **Chart**.

**Key Concepts:**

| Term            | Description                                       |
| --------------- | ------------------------------------------------- |
| **Chart**       | Package containing all K8s resource definitions   |
| **Release**     | Instance of a chart running in a cluster          |
| **Revision**    | Version of a release (tracks upgrades/rollbacks)  |
| **Repository**  | Collection of charts (like Docker Hub for images) |
| **values.yaml** | Configuration file for customizing deployments    |

**Why Use Helm?**

- Deploy complex apps with a single command
- Easily upgrade, rollback, and uninstall applications
- Centralized configuration via `values.yaml`
- Version control for deployments
- Share and reuse application packages

---

## Helm Architecture

```
┌──────────────────────────────────────────────────────┐
│                  Helm CLI (Client)                    │
│    helm install, upgrade, rollback, uninstall        │
└──────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────┐
│              Chart Repository                         │
│    (Artifact Hub, Bitnami, etc.)                     │
│    Contains: Chart.yaml, templates/, values.yaml     │
└──────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────┐
│              Kubernetes Cluster                       │
│    Release metadata stored as Secrets                │
│    Deployed resources: Deployments, Services, etc.   │
└──────────────────────────────────────────────────────┘
```

---

## Chart Structure

```
mychart/
├── Chart.yaml          # Chart metadata (name, version, dependencies)
├── values.yaml         # Default configuration values
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl    # Template helpers
├── charts/             # Dependent charts
└── README.md           # Documentation
```

### Chart.yaml Example

```yaml
apiVersion: v2
name: my-app
description: A Helm chart for my application
type: application
version: 1.0.0 # Chart version
appVersion: "1.16.0" # Application version
dependencies:
  - name: mariadb
    version: 9.x.x
    repository: https://charts.bitnami.com/bitnami
```

### values.yaml Example

```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.21.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
```

### Template Example (deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-app
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
```

---

## Essential Helm Commands

### Repository Management

```bash
# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# List configured repositories
helm repo list

# Update repository cache
helm repo update

# Remove a repository
helm repo remove bitnami
```

### Searching for Charts

```bash
# Search Artifact Hub (online)
helm search hub wordpress

# Search local repositories
helm search repo nginx

# Search with versions
helm search repo nginx --versions
```

### Installing Charts

```bash
# Install a chart (creates a release)
helm install <release-name> <chart>

# Examples:
helm install my-wordpress bitnami/wordpress
helm install my-nginx bitnami/nginx

# Install with custom values
helm install my-app bitnami/nginx --set replicaCount=3

# Install with values file
helm install my-app bitnami/nginx -f custom-values.yaml

# Install specific version
helm install my-app bitnami/nginx --version 9.5.0

# Install in specific namespace
helm install my-app bitnami/nginx -n my-namespace

# Dry run (preview without installing)
helm install my-app bitnami/nginx --dry-run
```

### Managing Releases

```bash
# List all releases
helm list
helm list -A              # All namespaces
helm list -n <namespace>  # Specific namespace

# Get release status
helm status <release-name>

# Get release history
helm history <release-name>

# Get values used in release
helm get values <release-name>

# Get all release information
helm get all <release-name>
```

### Upgrading Releases

```bash
# Upgrade to latest chart version
helm upgrade <release-name> <chart>

# Upgrade with new values
helm upgrade my-app bitnami/nginx --set replicaCount=5

# Upgrade with values file
helm upgrade my-app bitnami/nginx -f new-values.yaml

# Install or upgrade (create if doesn't exist)
helm upgrade --install my-app bitnami/nginx
```

### Rollback Releases

```bash
# Rollback to previous revision
helm rollback <release-name>

# Rollback to specific revision
helm rollback <release-name> <revision-number>

# Example
helm rollback my-app 1
```

### Uninstalling Releases

```bash
# Uninstall a release
helm uninstall <release-name>

# Uninstall and keep history
helm uninstall <release-name> --keep-history
```

### Working with Charts Locally

```bash
# Download chart as archive
helm pull bitnami/nginx

# Download and extract
helm pull bitnami/nginx --untar

# Install from local directory
helm install my-app ./nginx

# Show chart information
helm show chart bitnami/nginx
helm show values bitnami/nginx
helm show all bitnami/nginx
```

---

## Customizing Chart Values

### Method 1: Using --set flag

```bash
# Single value
helm install my-app bitnami/nginx --set replicaCount=3

# Multiple values
helm install my-app bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=NodePort

# Nested values
helm install my-app bitnami/nginx --set image.tag=1.21.0

# Array values
helm install my-app mychart --set servers[0].host=server1
```

### Method 2: Using values file

```bash
# Create custom-values.yaml
cat <<EOF > custom-values.yaml
replicaCount: 3
image:
  tag: "1.21.0"
service:
  type: NodePort
  nodePort: 30080
EOF

# Install with values file
helm install my-app bitnami/nginx -f custom-values.yaml

# Multiple values files (later files override earlier)
helm install my-app bitnami/nginx -f values1.yaml -f values2.yaml
```

### Method 3: Modify chart directly

```bash
# Pull and extract chart
helm pull bitnami/nginx --untar

# Edit values.yaml
vi nginx/values.yaml

# Install from local chart
helm install my-app ./nginx
```

---

## Real-World Example: WordPress Deployment

```bash
# Add Bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create custom values
cat <<EOF > wordpress-values.yaml
wordpressUsername: admin
wordpressPassword: secretpassword
wordpressEmail: admin@example.com
wordpressBlogName: "My Blog"

service:
  type: LoadBalancer

mariadb:
  auth:
    rootPassword: rootpassword
    password: dbpassword

persistence:
  size: 10Gi
EOF

# Install WordPress
helm install my-blog bitnami/wordpress -f wordpress-values.yaml

# Check status
helm status my-blog

# List releases
helm list

# Upgrade to new version
helm upgrade my-blog bitnami/wordpress -f wordpress-values.yaml

# Rollback if issues
helm rollback my-blog 1

# Uninstall when done
helm uninstall my-blog
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Install applications** using Helm
2. **Upgrade/Rollback** releases
3. **Customize** chart parameters
4. **Search** for charts
5. **Manage** repositories

### Key Commands to Remember

| Task          | Command                              |
| ------------- | ------------------------------------ |
| Add repo      | `helm repo add <name> <url>`         |
| Update repos  | `helm repo update`                   |
| Search        | `helm search repo <chart>`           |
| Install       | `helm install <release> <chart>`     |
| List releases | `helm list`                          |
| Upgrade       | `helm upgrade <release> <chart>`     |
| Rollback      | `helm rollback <release> <revision>` |
| Uninstall     | `helm uninstall <release>`           |
| Get values    | `helm get values <release>`          |
| History       | `helm history <release>`             |

### Quick Reference

```bash
# Complete workflow example
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx
helm install my-nginx bitnami/nginx --set replicaCount=2
helm list
helm upgrade my-nginx bitnami/nginx --set replicaCount=3
helm history my-nginx
helm rollback my-nginx 1
helm uninstall my-nginx
```

### Common Flags

| Flag                   | Purpose                    |
| ---------------------- | -------------------------- |
| `-n, --namespace`      | Specify namespace          |
| `-f, --values`         | Specify values file        |
| `--set`                | Override individual values |
| `--version`            | Chart version to install   |
| `--dry-run`            | Simulate installation      |
| `-A, --all-namespaces` | All namespaces             |

---

## Official Documentation

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Commands](https://helm.sh/docs/helm/helm/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Artifact Hub](https://artifacthub.io/)
- [Bitnami Charts](https://github.com/bitnami/charts)
