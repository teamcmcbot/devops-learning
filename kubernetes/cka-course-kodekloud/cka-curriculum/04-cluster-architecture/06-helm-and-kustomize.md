# Use Helm and Kustomize to Install Cluster Components

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Install applications using Helm charts
- Manage Helm releases (install, upgrade, rollback, uninstall)
- Use Kustomize to customize Kubernetes manifests
- Create and apply kustomization files
- Understand overlays and patches in Kustomize
- Choose between Helm and Kustomize for different scenarios

## Sample Questions

1. **Install a Helm chart from a repository**
2. **Upgrade a Helm release with custom values**
3. **Use Kustomize to customize a deployment**
4. **Create overlays for dev and prod environments**
5. **Rollback a Helm release to previous version**

## Official Documentation

- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kubectl Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/)

## Key Concepts

### Helm vs Kustomize

| Aspect | Helm | Kustomize |
|--------|------|-----------|
| **Templating** | Uses Go templates | No templates, overlays |
| **Package Manager** | Yes (charts) | No |
| **Customization** | values.yaml | kustomization.yaml |
| **Complexity** | More features | Simpler |
| **Release Management** | Tracks releases | No release concept |
| **Learning Curve** | Steeper | Gentler |

## Helm

### Install Helm

```bash
# Download and install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version

# Add tab completion (optional)
echo 'source <(helm completion bash)' >> ~/.bashrc
source ~/.bashrc
```

### Basic Helm Commands

```bash
# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable

# Update repositories
helm repo update

# List repositories
helm repo list

# Search for charts
helm search repo nginx
helm search repo mysql

# Search Artifact Hub
helm search hub wordpress
```

### Install Applications with Helm

```bash
# Install a chart
helm install my-nginx bitnami/nginx

# Install with custom release name
helm install my-release bitnami/mysql

# Install with specific namespace
helm install my-nginx bitnami/nginx --namespace web --create-namespace

# Install with custom values
helm install my-db bitnami/mysql \
  --set auth.rootPassword=secret123 \
  --set auth.database=mydb

# Install with values file
helm install my-db bitnami/mysql -f values.yaml

# Dry run (test without installing)
helm install my-nginx bitnami/nginx --dry-run --debug

# Install specific chart version
helm install my-nginx bitnami/nginx --version 13.2.4
```

### Manage Helm Releases

```bash
# List releases
helm list
helm list --all-namespaces
helm ls -A

# Get release info
helm status my-nginx
helm get all my-nginx
helm get values my-nginx
helm get manifest my-nginx

# Upgrade release
helm upgrade my-nginx bitnami/nginx

# Upgrade with new values
helm upgrade my-nginx bitnami/nginx --set replicaCount=3

# Upgrade with values file
helm upgrade my-nginx bitnami/nginx -f new-values.yaml

# Upgrade or install (if doesn't exist)
helm upgrade --install my-nginx bitnami/nginx

# Rollback to previous version
helm rollback my-nginx

# Rollback to specific revision
helm rollback my-nginx 2

# Show release history
helm history my-nginx

# Uninstall release
helm uninstall my-nginx

# Uninstall but keep history
helm uninstall my-nginx --keep-history
```

### Custom Values File

```yaml
# values.yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

```bash
# Use the values file
helm install my-nginx bitnami/nginx -f values.yaml

# Override specific values
helm install my-nginx bitnami/nginx -f values.yaml --set replicaCount=5
```

### Inspect Charts

```bash
# Show chart information
helm show chart bitnami/nginx

# Show values
helm show values bitnami/nginx

# Show all information
helm show all bitnami/nginx

# Show README
helm show readme bitnami/nginx

# Download chart
helm pull bitnami/nginx

# Download and extract
helm pull bitnami/nginx --untar

# Download specific version
helm pull bitnami/nginx --version 13.2.4 --untar
```

## Kustomize

### Kustomize Basics

Kustomize is built into `kubectl` (v1.14+):

```bash
# Check kubectl version
kubectl version --client

# Apply kustomization
kubectl apply -k <directory>

# View generated resources (dry-run)
kubectl kustomize <directory>

# Alternative using kustomize binary
kustomize build <directory> | kubectl apply -f -
```

### Directory Structure

```
my-app/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── replica-patch.yaml
    └── prod/
        ├── kustomization.yaml
        └── replica-patch.yaml
```

### Base Configuration

```yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: nginx:1.21
        ports:
        - containerPort: 80
```

```yaml
# base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
```

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

commonLabels:
  app: myapp
  managed-by: kustomize
```

### Overlays (Environment-Specific)

```yaml
# overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namePrefix: dev-

replicas:
- name: myapp
  count: 2

images:
- name: nginx
  newTag: 1.21-alpine

commonLabels:
  environment: dev
```

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namePrefix: prod-

replicas:
- name: myapp
  count: 5

images:
- name: nginx
  newTag: 1.21

commonLabels:
  environment: prod

patches:
- path: resource-patch.yaml
```

```yaml
# overlays/prod/resource-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

### Apply Kustomize Configurations

```bash
# View generated YAML (dev)
kubectl kustomize overlays/dev/

# Apply dev environment
kubectl apply -k overlays/dev/

# View generated YAML (prod)
kubectl kustomize overlays/prod/

# Apply prod environment
kubectl apply -k overlays/prod/

# Verify deployments
kubectl get deployments
# dev-myapp
# prod-myapp
```

### Kustomization Features

#### ConfigMap and Secret Generators

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

configMapGenerator:
- name: myapp-config
  literals:
  - APP_ENV=production
  - APP_DEBUG=false
  files:
  - config.properties

secretGenerator:
- name: myapp-secret
  literals:
  - DB_PASSWORD=secret123
  files:
  - ssh-key=id_rsa
```

#### Strategic Merge Patches

```yaml
# kustomization.yaml
patches:
- path: patch-deployment.yaml

# patch-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 5
  template:
    spec:
      containers:
      - name: myapp
        env:
        - name: NEW_VAR
          value: "new_value"
```

#### JSON Patches (RFC 6902)

```yaml
# kustomization.yaml
patches:
- target:
    kind: Deployment
    name: myapp
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: DEBUG
        value: "true"
```

#### Image Transformers

```yaml
# kustomization.yaml
images:
- name: nginx
  newName: myregistry/nginx
  newTag: v1.21.0
```

#### Name and Namespace Transformers

```yaml
# kustomization.yaml
namePrefix: app-
nameSuffix: -v2
namespace: production
```

## Complete Examples

### Example 1: Helm - Deploy WordPress

```bash
# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create values file
cat <<EOF > wordpress-values.yaml
wordpressUsername: admin
wordpressPassword: SuperSecret123
wordpressEmail: admin@example.com
service:
  type: ClusterIP
persistence:
  size: 10Gi
mariadb:
  auth:
    rootPassword: RootPass123
    database: wordpress
    username: wpuser
    password: wppass
EOF

# Install WordPress
helm install my-wordpress bitnami/wordpress \
  -f wordpress-values.yaml \
  --namespace wordpress \
  --create-namespace

# Check status
helm status my-wordpress -n wordpress
kubectl get pods -n wordpress

# Upgrade with new values
echo "replicaCount: 2" >> wordpress-values.yaml
helm upgrade my-wordpress bitnami/wordpress -f wordpress-values.yaml -n wordpress

# Rollback if needed
helm rollback my-wordpress -n wordpress

# Uninstall
helm uninstall my-wordpress -n wordpress
```

### Example 2: Kustomize - Multi-Environment App

```bash
# Create directory structure
mkdir -p ~/myapp/{base,overlays/{dev,prod}}

# Create base resources
cat <<EOF > ~/myapp/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
EOF

cat <<EOF > ~/myapp/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
EOF

cat <<EOF > ~/myapp/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF

# Create dev overlay
cat <<EOF > ~/myapp/overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
namePrefix: dev-
namespace: development
replicas:
- name: myapp
  count: 2
commonLabels:
  env: dev
EOF

# Create prod overlay
cat <<EOF > ~/myapp/overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
namePrefix: prod-
namespace: production
replicas:
- name: myapp
  count: 5
commonLabels:
  env: prod
EOF

# Apply dev
kubectl create namespace development
kubectl apply -k ~/myapp/overlays/dev/

# Apply prod
kubectl create namespace production
kubectl apply -k ~/myapp/overlays/prod/

# Verify
kubectl get deployments -n development
kubectl get deployments -n production
```

## Troubleshooting Tips

### Helm Issues

```bash
# Helm release failed
helm status <release-name>
helm get manifest <release-name>
kubectl describe pod <pod-name>

# Check release history
helm history <release-name>

# Debug installation
helm install <release> <chart> --dry-run --debug

# List all releases including failed
helm list --all

# Uninstall stuck release
helm uninstall <release> --no-hooks

# Reset Helm (if corrupted)
rm -rf ~/.cache/helm
rm -rf ~/.config/helm
```

### Kustomize Issues

```bash
# Validate kustomization
kubectl kustomize <directory>

# Common errors:
# 1. Wrong file paths in resources
ls -la base/

# 2. Invalid YAML syntax
kubectl kustomize <directory> --enable-alpha-plugins

# 3. Base path incorrect
# Check bases: field points to correct directory

# Test locally
kubectl kustomize overlays/dev/ > /tmp/output.yaml
kubectl apply -f /tmp/output.yaml --dry-run=client
```

## Key Files and Locations

### Helm

| Location | Purpose |
|----------|---------|
| `~/.config/helm/` | Helm configuration |
| `~/.cache/helm/` | Cached charts |
| `~/.local/share/helm/` | Helm plugins |
| `/tmp/helm-*` | Temporary Helm files |

### Kustomize

| Location | Purpose |
|----------|---------|
| `base/` | Base resources (convention) |
| `overlays/` | Environment-specific overlays |
| `kustomization.yaml` | Kustomize configuration file |

## Exam Tips

1. **Helm is faster for standard apps** - Use for databases, monitoring tools
2. **Kustomize for custom apps** - Better for application-specific configs
3. **Practice helm install/upgrade/rollback** - Common exam scenarios
4. **Know kustomize directory structure** - base and overlays
5. **Use --dry-run** to verify before applying
6. **kubectl kustomize** shows generated YAML
7. **Helm repos need to be added first**
8. **Kustomize is built into kubectl** - No separate installation
9. **Check documentation** during exam for chart values
10. **Time management** - Don't spend too long on values

## Common Mistakes

- ❌ Not adding Helm repo before installing chart
- ❌ Wrong namespace for Helm release
- ❌ Forgetting --create-namespace flag
- ❌ Wrong base path in Kustomize overlays
- ❌ Not using -k flag with kubectl apply for Kustomize
- ❌ Typos in values.yaml (indentation matters)
- ❌ Not checking helm list output namespace
- ❌ Using kustomize command instead of kubectl kustomize
- ❌ Forgetting to helm repo update
- ❌ Wrong chart name or version

## Quick Reference

### Helm Quick Commands

```bash
# Install
helm install <release> <chart> -f values.yaml -n <namespace> --create-namespace

# Upgrade
helm upgrade <release> <chart> -f values.yaml

# Rollback
helm rollback <release> [revision]

# List
helm list -A

# Uninstall
helm uninstall <release> -n <namespace>

# Repos
helm repo add <name> <url>
helm repo update
helm search repo <keyword>

# Debug
helm install <release> <chart> --dry-run --debug
```

### Kustomize Quick Commands

```bash
# View generated YAML
kubectl kustomize <directory>

# Apply
kubectl apply -k <directory>

# Delete
kubectl delete -k <directory>

# Diff (if supported)
kubectl diff -k <directory>
```

### Common Helm Charts

```bash
# NGINX Ingress Controller
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

# Prometheus
helm install prometheus prometheus-community/prometheus -n monitoring --create-namespace

# Metrics Server
helm install metrics-server metrics-server/metrics-server -n kube-system

# PostgreSQL
helm install my-postgres bitnami/postgresql -n database --create-namespace
```
