# Kubernetes Deployments

## Executive Summary

A **Deployment** provides declarative updates for Pods and ReplicaSets. It's the recommended way to manage stateless applications and offers:

- **Rolling Updates**: Gradually update pods without downtime
- **Rollbacks**: Easily revert to previous versions
- **Scaling**: Scale up/down the number of replicas
- **Pause/Resume**: Make multiple changes before rolling out

### Hierarchy

```
Deployment → ReplicaSet → Pods
```

When you create a Deployment, it automatically creates a ReplicaSet, which in turn creates the Pods.

---

## Real-World Usage

| Scenario                   | Description                                    |
| -------------------------- | ---------------------------------------------- |
| **Web Applications**       | Deploy and update web servers                  |
| **Microservices**          | Manage service versions and updates            |
| **CI/CD Pipelines**        | Automated deployments with rollback capability |
| **Blue/Green Deployments** | Manage multiple versions simultaneously        |

---

## Common Commands

### Creating Deployments

```bash
# Imperative - create deployment
kubectl create deployment nginx --image=nginx

# Imperative with replicas
kubectl create deployment nginx --image=nginx --replicas=3

# Create from YAML
kubectl create -f deployment-definition.yaml

# Declarative
kubectl apply -f deployment-definition.yaml
```

### Viewing Deployments

```bash
# List deployments
kubectl get deployments
kubectl get deploy

# Get all related objects
kubectl get all

# Detailed deployment info
kubectl describe deployment <name>

# Check rollout status
kubectl rollout status deployment/<name>

# View rollout history
kubectl rollout history deployment/<name>
```

### Scaling

```bash
# Scale deployment
kubectl scale deployment <name> --replicas=5

# Autoscale (HPA)
kubectl autoscale deployment <name> --min=3 --max=10 --cpu-percent=80
```

### Updating Deployments

```bash
# Update image
kubectl set image deployment/<name> <container>=<new-image>

# Example
kubectl set image deployment/nginx nginx=nginx:1.19

# Edit deployment
kubectl edit deployment <name>

# Apply changes from file
kubectl apply -f deployment-definition.yaml
```

### Rollbacks

```bash
# Rollback to previous version
kubectl rollout undo deployment/<name>

# Rollback to specific revision
kubectl rollout undo deployment/<name> --to-revision=2

# View revision history
kubectl rollout history deployment/<name>

# View specific revision
kubectl rollout history deployment/<name> --revision=2
```

### Pause/Resume (for multiple changes)

```bash
# Pause rollout
kubectl rollout pause deployment/<name>

# Make changes...
kubectl set image deployment/<name> nginx=nginx:1.19
kubectl set resources deployment/<name> -c nginx --limits=cpu=200m,memory=512Mi

# Resume rollout
kubectl rollout resume deployment/<name>
```

---

## YAML Configuration

### Basic Deployment Definition

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
    type: front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      type: front-end
  template:
    metadata:
      labels:
        app: myapp
        type: front-end
    spec:
      containers:
        - name: nginx-container
          image: nginx
```

### Deployment with Strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1 # Max pods over desired count
      maxUnavailable: 1 # Max unavailable during update
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
          image: nginx:1.18
          ports:
            - containerPort: 80
```

### Deployment Strategies

| Strategy                    | Description                                      |
| --------------------------- | ------------------------------------------------ |
| **RollingUpdate** (default) | Gradually replaces old pods with new ones        |
| **Recreate**                | Terminates all old pods before creating new ones |

```yaml
# RollingUpdate (default)
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%

# Recreate
spec:
  strategy:
    type: Recreate
```

---

## CKA Exam Relevance

### What to Know

- Create deployments imperatively and declaratively
- Scale deployments
- Perform rolling updates
- Rollback deployments
- Understand deployment strategies

### Quick YAML Generation (Exam Tip!)

```bash
# Generate deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml

# Generate with replicas
kubectl create deployment nginx --image=nginx --replicas=3 --dry-run=client -o yaml
```

### Common Exam Tasks

1. Create a deployment with specific image and replicas
2. Update deployment image version
3. Rollback a failed deployment
4. Scale a deployment
5. Check deployment rollout status

### Troubleshooting Deployments

```bash
# Check deployment status
kubectl get deploy

# Check ReplicaSet
kubectl get rs

# Check pods
kubectl get pods

# Describe for events/errors
kubectl describe deployment <name>

# Check rollout status
kubectl rollout status deployment/<name>
```

---

## Quick Reference

| Command                                             | Description       |
| --------------------------------------------------- | ----------------- |
| `kubectl create deployment <name> --image=<img>`    | Create deployment |
| `kubectl get deploy`                                | List deployments  |
| `kubectl scale deploy <name> --replicas=N`          | Scale             |
| `kubectl set image deploy/<name> <container>=<img>` | Update image      |
| `kubectl rollout status deploy/<name>`              | Check rollout     |
| `kubectl rollout history deploy/<name>`             | View history      |
| `kubectl rollout undo deploy/<name>`                | Rollback          |

---

## Official Documentation

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
