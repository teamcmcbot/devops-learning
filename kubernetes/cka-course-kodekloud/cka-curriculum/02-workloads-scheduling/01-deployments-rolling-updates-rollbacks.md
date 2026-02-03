# Application Deployments, Rolling Updates and Rollbacks

## Exam Weight
Part of **15% - Workloads and Scheduling**

## What Can Be Tested

- Create and manage Deployments
- Perform rolling updates
- Rollback deployments to previous versions
- Pause and resume deployments
- Scale deployments
- Check rollout status and history
- Update deployment strategies (RollingUpdate vs Recreate)
- Configure maxSurge and maxUnavailable

## Sample Questions

1. **Create a deployment with 3 replicas running nginx:1.19**
2. **Update the deployment to nginx:1.20 and watch the rollout**
3. **Rollback the deployment to the previous version**
4. **Scale deployment to 5 replicas**
5. **Change deployment strategy to Recreate**
6. **Pause a rollout, make changes, then resume**

## Official Documentation

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Performing Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [Rollback a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)

## Key Concepts

### Deployment vs ReplicaSet vs Pod

```
Deployment
    ↓ (manages)
ReplicaSet
    ↓ (manages)
Pods
```

- **Deployment**: Declarative updates, rollout/rollback capability
- **ReplicaSet**: Ensures desired number of pods running
- **Pod**: Actual running container(s)

### Deployment Strategies

| Strategy | Behavior | Downtime | Use Case |
|----------|----------|----------|----------|
| **RollingUpdate** | Gradually replace old pods | ❌ No | Default, zero-downtime |
| **Recreate** | Kill all old pods, then create new | ✅ Yes | Database migrations, incompatible versions |

### RollingUpdate Parameters

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Max pods above desired count during update
    maxUnavailable: 0  # Max pods unavailable during update
```

## Imperative Commands

```bash
# Create deployment
kubectl create deployment nginx --image=nginx:1.19 --replicas=3

# Get deployments
kubectl get deployments
kubectl get deploy

# Describe deployment
kubectl describe deployment nginx

# Update image (triggers rollout)
kubectl set image deployment/nginx nginx=nginx:1.20

# Alternative: edit deployment
kubectl edit deployment nginx

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Check rollout status
kubectl rollout status deployment/nginx

# View rollout history
kubectl rollout history deployment/nginx

# View specific revision
kubectl rollout history deployment/nginx --revision=2

# Rollback to previous version
kubectl rollout undo deployment/nginx

# Rollback to specific revision
kubectl rollout undo deployment/nginx --to-revision=2

# Pause rollout
kubectl rollout pause deployment/nginx

# Resume rollout
kubectl rollout resume deployment/nginx

# Restart deployment (recreate pods)
kubectl rollout restart deployment/nginx

# Delete deployment
kubectl delete deployment nginx
```

## YAML Examples

### Basic Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
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
        image: nginx:1.19
        ports:
        - containerPort: 80
```

### Deployment with RollingUpdate Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2          # Max 2 extra pods during update (total 7)
      maxUnavailable: 1    # Max 1 pod can be unavailable (min 4 available)
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:v1
        ports:
        - containerPort: 8080
```

### Deployment with Recreate Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-app
spec:
  replicas: 1
  strategy:
    type: Recreate  # Kill all, then create new
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:12
```

### Deployment with Resource Limits
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:v1
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

### Deployment with Liveness/Readiness Probes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthy-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: healthy
  template:
    metadata:
      labels:
        app: healthy
    spec:
      containers:
      - name: app
        image: myapp:v1
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Troubleshooting Tips

### Rollout Stuck / Not Progressing
```bash
# Check rollout status
kubectl rollout status deployment/nginx

# Check events
kubectl describe deployment nginx

# Check ReplicaSets
kubectl get rs

# Common causes:
# 1. Image pull errors
kubectl get pods | grep ImagePull
kubectl describe pod <pod-name>

# 2. Insufficient resources
kubectl describe nodes | grep -A5 "Allocated resources"

# 3. Readiness probe failing
kubectl logs <pod-name>
kubectl describe pod <pod-name> | grep -A10 "Readiness"
```

### Pods Not Updating After Image Change
```bash
# Verify deployment was actually updated
kubectl describe deployment nginx | grep Image

# Check if rollout happened
kubectl rollout history deployment/nginx

# Force recreate pods
kubectl rollout restart deployment/nginx

# Check if pods are using old ReplicaSet
kubectl get rs -o wide
```

### Rollback Not Working
```bash
# Check history exists
kubectl rollout history deployment/nginx

# If no history, might need to record changes
kubectl set image deployment/nginx nginx=nginx:1.20 --record

# Manual rollback: scale down new RS, scale up old RS
kubectl get rs
kubectl scale rs/<old-rs-name> --replicas=3
kubectl scale rs/<new-rs-name> --replicas=0
```

### Deployment Scaling Issues
```bash
# Check if HPA (HorizontalPodAutoscaler) is controlling replicas
kubectl get hpa

# If HPA exists, it overrides manual scaling
# Either delete HPA or adjust HPA settings
kubectl delete hpa <hpa-name>
```

### Check Resource Usage During Rollout
```bash
# Watch pods during rollout
kubectl get pods -w

# Watch in detail
kubectl get pods -l app=nginx -o wide -w

# Check events in real-time
kubectl get events --watch
```

## Key Files and Locations

### Deployment Controller
- **Component**: `kube-controller-manager`
- **Logs**: `kubectl logs -n kube-system kube-controller-manager-<node>`
- **Config**: `/etc/kubernetes/manifests/kube-controller-manager.yaml`

### Check Deployment Controller
```bash
# Check controller manager is running
kubectl get pods -n kube-system | grep controller-manager

# View logs for deployment issues
kubectl logs -n kube-system kube-controller-manager-<node> | grep deployment
```

## Exam Tips

1. **Use imperative commands for speed**: `kubectl create deployment` then `kubectl set image`
2. **Watch rollout**: `kubectl rollout status deployment/name -w`
3. **Check history before rollback**: `kubectl rollout history deployment/name`
4. **Default strategy is RollingUpdate** - only specify if you need Recreate
5. **maxUnavailable: 0 = zero downtime** (but slower rollout)
6. **maxSurge: 100% = blue-green style** (double resources temporarily)
7. **Pause/resume useful** for making multiple changes at once
8. **Rollout restart** to recreate all pods without changing spec
9. **Selector must match template labels**
10. **Use `--record` flag** to track command in history (deprecated but useful)

## Common Mistakes

- ❌ Selector labels don't match template labels
- ❌ Forgetting to specify `--replicas` (defaults to 1)
- ❌ Using wrong image tag in `kubectl set image`
- ❌ Trying to rollback when no history exists
- ❌ Not watching rollout status (missing errors)
- ❌ Setting maxUnavailable too high (causes downtime)
- ❌ Editing ReplicaSet directly (deployment will override it)
- ❌ Deleting ReplicaSet (deployment recreates it)

## Quick Reference

```bash
# Create deployment (imperative)
kubectl create deployment nginx --image=nginx:1.19 --replicas=3

# Update image
kubectl set image deployment/nginx nginx=nginx:1.20

# Watch rollout
kubectl rollout status deployment/nginx

# Scale
kubectl scale deployment/nginx --replicas=5

# Rollback
kubectl rollout undo deployment/nginx

# Check history
kubectl rollout history deployment/nginx

# Pause/resume
kubectl rollout pause deployment/nginx
# ... make changes ...
kubectl rollout resume deployment/nginx

# Restart (recreate all pods)
kubectl rollout restart deployment/nginx

# Export to YAML
kubectl get deployment nginx -o yaml > deployment.yaml

# Apply changes from file
kubectl apply -f deployment.yaml
```

## Testing Rollout

```bash
# Create deployment
kubectl create deployment test --image=nginx:1.19 --replicas=3

# Watch pods in another terminal
kubectl get pods -w

# Update image
kubectl set image deployment/test nginx=nginx:1.20

# Check rollout status
kubectl rollout status deployment/test

# Verify new image
kubectl describe deployment test | grep Image

# Check history
kubectl rollout history deployment/test

# Rollback
kubectl rollout undo deployment/test

# Verify rollback
kubectl rollout status deployment/test
kubectl describe deployment test | grep Image

# Cleanup
kubectl delete deployment test
```
