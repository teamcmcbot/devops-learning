# Image Security

## Executive Summary

Image security involves using trusted container images and securely pulling images from private registries. Kubernetes needs credentials to pull images from private registries, which are configured using Secrets of type `docker-registry` and referenced in pod specs with `imagePullSecrets`.

## Key Concepts

### Image Naming Convention

```
[registry]/[user/account]/[image]:[tag]

Examples:
nginx                           → docker.io/library/nginx:latest
myuser/myapp                    → docker.io/myuser/myapp:latest
gcr.io/google-samples/hello-app → gcr.io/google-samples/hello-app:latest
```

| Component | Default                   |
| --------- | ------------------------- |
| Registry  | docker.io (Docker Hub)    |
| Account   | library (official images) |
| Tag       | latest                    |

### Common Registries

- `docker.io` - Docker Hub
- `gcr.io` - Google Container Registry
- `k8s.gcr.io` - Kubernetes images
- `quay.io` - Red Hat Quay
- `<account>.dkr.ecr.<region>.amazonaws.com` - AWS ECR
- `<registry>.azurecr.io` - Azure Container Registry

## Real-World Usage

- Pulling images from private corporate registries
- Using cloud provider container registries (ECR, GCR, ACR)
- Implementing image scanning and vulnerability management
- Ensuring supply chain security for container images

## YAML Configurations

### Basic Pod with Private Registry Image

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-app
spec:
  containers:
    - name: app
      image: private-registry.io/apps/myapp:v1
  imagePullSecrets:
    - name: regcred
```

### Multiple Image Pull Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-registry-app
spec:
  containers:
    - name: app
      image: private-registry.io/apps/myapp:v1
    - name: sidecar
      image: another-registry.io/tools/sidecar:latest
  imagePullSecrets:
    - name: regcred-1
    - name: regcred-2
```

### Image Pull Secret in Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
imagePullSecrets:
  - name: regcred
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
    - name: app
      image: private-registry.io/apps/myapp:v1
```

## Common Commands

### Create Docker Registry Secret

```bash
# Create secret for private registry
kubectl create secret docker-registry regcred \
  --docker-server=private-registry.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myuser@example.com

# Create secret for Docker Hub
kubectl create secret docker-registry dockerhub-cred \
  --docker-server=docker.io \
  --docker-username=myuser \
  --docker-password=mypassword

# Create secret for AWS ECR
kubectl create secret docker-registry ecr-cred \
  --docker-server=123456789.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password)

# Create secret for GCR
kubectl create secret docker-registry gcr-cred \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat service-account.json)"
```

### View and Manage Secrets

```bash
# List secrets
kubectl get secrets

# Describe secret (shows type and data keys)
kubectl describe secret regcred

# View secret data (base64 encoded)
kubectl get secret regcred -o yaml

# Decode dockerconfigjson
kubectl get secret regcred -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

### Create Secret from Docker Config

```bash
# If already logged in via Docker
kubectl create secret generic regcred \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson
```

## Image Pull Policies

| Policy         | Behavior                                                    |
| -------------- | ----------------------------------------------------------- |
| `Always`       | Always pull image from registry                             |
| `IfNotPresent` | Pull only if not cached locally (default for tagged images) |
| `Never`        | Never pull, use local image only                            |

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: myapp:v1
      imagePullPolicy: Always
```

## CKA Exam Tips

### What to Expect

- Create docker-registry secrets
- Configure pods to pull from private registries
- Troubleshoot image pull errors

### Quick Reference

```bash
# Create registry secret (memorize this!)
kubectl create secret docker-registry <secret-name> \
  --docker-server=<registry-url> \
  --docker-username=<username> \
  --docker-password=<password>

# Add to pod spec
spec:
  imagePullSecrets:
  - name: <secret-name>
```

### Troubleshooting Image Pull Errors

```bash
# Check pod events for image pull errors
kubectl describe pod <pod-name>

# Common errors:
# - ErrImagePull: Can't pull image (auth or network issue)
# - ImagePullBackOff: Repeated failures to pull
# - InvalidImageName: Malformed image reference

# Verify secret exists
kubectl get secret <secret-name>

# Check if secret is correctly referenced
kubectl get pod <pod-name> -o yaml | grep -A 5 imagePullSecrets
```

## Official Documentation

- [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
- [Images](https://kubernetes.io/docs/concepts/containers/images/)
