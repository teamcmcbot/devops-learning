# Rolling Updates and Rollbacks - CKA Cheatsheet

## Executive Summary

**Rolling Updates and Rollbacks** are mechanisms to update deployments with zero/minimal downtime and revert to previous versions if issues occur.

**Key Points:**

- Each deployment update creates a new **revision**
- **Rolling Update** (default): Gradual replacement, zero downtime
- **Recreate**: All pods down, then all new pods up (has downtime)
- Kubernetes keeps old ReplicaSets for **rollback** capability
- Use `kubectl rollout` commands to manage updates

---

## Deployment Strategies

| Strategy                    | Behavior                           | Downtime        |
| --------------------------- | ---------------------------------- | --------------- |
| **RollingUpdate** (default) | Replace pods one-by-one            | ❌ No downtime  |
| **Recreate**                | Kill all old pods, then create new | ✅ Has downtime |

```
RollingUpdate:                    Recreate:
┌─────────────────────┐          ┌─────────────────────┐
│ v1  v1  v1  v1  v1  │          │ v1  v1  v1  v1  v1  │
│  ↓                  │          │  ↓   ↓   ↓   ↓   ↓  │
│ v2  v1  v1  v1  v1  │          │  ✗   ✗   ✗   ✗   ✗  │ ← Downtime!
│  ↓                  │          │  ↓   ↓   ↓   ↓   ↓  │
│ v2  v2  v1  v1  v1  │          │ v2  v2  v2  v2  v2  │
│  ↓                  │          └─────────────────────┘
│ v2  v2  v2  v2  v2  │
└─────────────────────┘
```

---

## Real-World Use Cases

| Use Case             | Strategy      | Why                            |
| -------------------- | ------------- | ------------------------------ |
| Production web app   | RollingUpdate | Zero downtime required         |
| Database migration   | Recreate      | Can't have mixed versions      |
| Canary deployment    | RollingUpdate | Gradual rollout, easy rollback |
| Dev/Test environment | Recreate      | Speed over availability        |

---

## Quick Reference

### Deployment with RollingUpdate (Default)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25% # Max pods above desired during update
      maxUnavailable: 25% # Max pods unavailable during update
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
          image: nginx:1.7.1
```

---

### Deployment with Recreate Strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 5
  strategy:
    type: Recreate # All pods killed before new ones created
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
          image: nginx:1.7.1
```

---

## Common Commands

### Rollout Management

```bash
# Check rollout status
kubectl rollout status deployment/myapp-deployment

# View rollout history
kubectl rollout history deployment/myapp-deployment

# View specific revision details
kubectl rollout history deployment/myapp-deployment --revision=2

# Rollback to previous revision
kubectl rollout undo deployment/myapp-deployment

# Rollback to specific revision
kubectl rollout undo deployment/myapp-deployment --to-revision=1

# Pause rollout (for canary testing)
kubectl rollout pause deployment/myapp-deployment

# Resume rollout
kubectl rollout resume deployment/myapp-deployment

# Restart deployment (recreate all pods)
kubectl rollout restart deployment/myapp-deployment
```

---

### Update Methods

```bash
# Method 1: Edit YAML and apply
kubectl apply -f deployment.yaml

# Method 2: Set image directly
kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1

# Method 3: Edit live deployment
kubectl edit deployment myapp-deployment

# Method 4: Patch deployment
kubectl patch deployment myapp-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.9.1"}]}}}}'
```

---

### Monitoring Updates

```bash
# Watch rollout progress
kubectl rollout status deployment/myapp-deployment -w

# Check ReplicaSets (see old and new)
kubectl get replicasets

# Describe deployment (see events)
kubectl describe deployment myapp-deployment

# Watch pods during rollout
kubectl get pods -w
```

---

## RollingUpdate Parameters

| Parameter        | Description                                    | Default |
| ---------------- | ---------------------------------------------- | ------- |
| `maxSurge`       | Max pods above desired count during update     | 25%     |
| `maxUnavailable` | Max pods that can be unavailable during update | 25%     |

**Examples:**

```yaml
# Aggressive update (faster, more resources)
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 50%
    maxUnavailable: 50%

# Conservative update (slower, safer)
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

---

## Record Changes for History

```bash
# Record command in revision history (deprecated but still works)
kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1 --record

# Or use annotation
kubectl annotate deployment/myapp-deployment kubernetes.io/change-cause="Updated to nginx 1.9.1"
```

**View recorded history:**

```bash
kubectl rollout history deployment/myapp-deployment
# REVISION  CHANGE-CAUSE
# 1         kubectl apply --filename=deployment.yaml
# 2         Updated to nginx 1.9.1
```

---

## CKA Exam Scenarios

### Scenario 1: Check Rollout Status

**Question:** Check the status of deployment `frontend` rollout.

```bash
kubectl rollout status deployment/frontend
```

---

### Scenario 2: Update Image

**Question:** Update deployment `webapp` to use image `nginx:1.19`.

```bash
kubectl set image deployment/webapp nginx=nginx:1.19
```

---

### Scenario 3: Rollback Deployment

**Question:** Deployment `api-server` has issues. Rollback to previous version.

```bash
kubectl rollout undo deployment/api-server
```

---

### Scenario 4: Rollback to Specific Revision

**Question:** Rollback deployment `backend` to revision 2.

```bash
# Check available revisions
kubectl rollout history deployment/backend

# Rollback to revision 2
kubectl rollout undo deployment/backend --to-revision=2
```

---

### Scenario 5: View Deployment Strategy

**Question:** What strategy is deployment `myapp` using?

```bash
kubectl describe deployment myapp | grep -i strategy
# Or
kubectl get deployment myapp -o yaml | grep -A 5 strategy
```

---

### Scenario 6: Change Strategy to Recreate

**Question:** Update deployment `db-app` to use Recreate strategy.

```bash
kubectl patch deployment db-app -p '{"spec":{"strategy":{"type":"Recreate"}}}'
# Or edit directly
kubectl edit deployment db-app
```

---

### Scenario 7: Identify Revision Differences

**Question:** What changed between revision 1 and revision 2?

```bash
kubectl rollout history deployment/myapp --revision=1
kubectl rollout history deployment/myapp --revision=2
```

---

## Exam Tips

1. **Default strategy is RollingUpdate** - no need to specify
2. **`kubectl set image`** is fastest for image updates
3. **`--record` flag is deprecated** - use annotations instead
4. **Rollback creates NEW revision** - doesn't delete history
5. **Check ReplicaSets** to see old/new during rollout
6. **`maxSurge` and `maxUnavailable`** can be number or percentage
7. **Recreate strategy** - look for events showing scale to 0 first

---

## Quick Command Reference

| Task                 | Command                                                   |
| -------------------- | --------------------------------------------------------- |
| Check rollout status | `kubectl rollout status deployment/<name>`                |
| View history         | `kubectl rollout history deployment/<name>`               |
| Rollback             | `kubectl rollout undo deployment/<name>`                  |
| Rollback to revision | `kubectl rollout undo deployment/<name> --to-revision=N`  |
| Update image         | `kubectl set image deployment/<name> container=image:tag` |
| Pause rollout        | `kubectl rollout pause deployment/<name>`                 |
| Resume rollout       | `kubectl rollout resume deployment/<name>`                |
| Restart deployment   | `kubectl rollout restart deployment/<name>`               |

---

## Official Documentation

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Performing a Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [Rolling Back a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)
