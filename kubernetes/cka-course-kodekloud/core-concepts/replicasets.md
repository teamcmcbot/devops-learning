# Kubernetes ReplicaSets

## Executive Summary

A **ReplicaSet** ensures that a specified number of pod replicas are running at any given time. It provides:

- **High Availability**: Automatically replaces failed pods
- **Load Balancing**: Distributes traffic across multiple pod instances
- **Scaling**: Easily scale up or down the number of replicas

> **Note**: ReplicaSet replaced the older **ReplicationController**. Always use ReplicaSet (or Deployments) in modern Kubernetes.

---

## Key Differences: ReplicaSet vs ReplicationController

| Feature     | ReplicationController           | ReplicaSet                                     |
| ----------- | ------------------------------- | ---------------------------------------------- |
| API Version | `v1`                            | `apps/v1`                                      |
| Selector    | Implicit (from template labels) | Required (`matchLabels` or `matchExpressions`) |
| Status      | Legacy/Deprecated               | Current/Recommended                            |

---

## Real-World Usage

- **Web servers**: Maintain multiple nginx/apache instances
- **Microservices**: Ensure service availability
- **Stateless applications**: Any app that can run multiple identical instances
- **Usually managed through Deployments** rather than directly

---

## Common Commands

```bash
# Create ReplicaSet
kubectl create -f replicaset-definition.yaml

# List ReplicaSets
kubectl get replicaset
kubectl get rs

# Describe ReplicaSet
kubectl describe rs <replicaset-name>

# Delete ReplicaSet (also deletes pods)
kubectl delete rs <replicaset-name>

# Scale ReplicaSet
kubectl scale rs <replicaset-name> --replicas=5

# Scale using file reference
kubectl scale --replicas=6 -f replicaset-definition.yaml

# Edit ReplicaSet
kubectl edit rs <replicaset-name>

# Update ReplicaSet from file
kubectl replace -f replicaset-definition.yaml

# View pods created by ReplicaSet
kubectl get pods
```

---

## YAML Configuration

### Basic ReplicaSet Definition

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
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
      name: myapp-pod
      labels:
        app: myapp
        type: front-end
    spec:
      containers:
        - name: nginx-container
          image: nginx
```

### Structure Breakdown

```yaml
apiVersion: apps/v1 # Required: apps/v1 for ReplicaSet
kind: ReplicaSet # Required: Object type
metadata: # ReplicaSet metadata
  name: myapp-rs
  labels:
    app: myapp
spec:
  replicas: 3 # Number of pod replicas
  selector: # REQUIRED: How RS finds pods to manage
    matchLabels:
      app: myapp
  template: # Pod template (same as Pod spec)
    metadata:
      labels: # Labels MUST match selector
        app: myapp
    spec:
      containers:
        - name: nginx
          image: nginx
```

---

## Labels and Selectors

### Why They Matter

- ReplicaSet uses **selectors** to identify which pods to manage
- The `selector.matchLabels` must match the `template.metadata.labels`
- ReplicaSet can adopt existing pods that match the selector

### Selector Types

```yaml
# matchLabels - equality-based
selector:
  matchLabels:
    app: myapp
    tier: frontend

# matchExpressions - set-based (more flexible)
selector:
  matchExpressions:
    - key: app
      operator: In
      values:
        - myapp
        - myapp-v2
    - key: tier
      operator: NotIn
      values:
        - backend
```

---

## Scaling Methods

### Method 1: Edit YAML and Replace

```bash
# Edit replicas in YAML file, then:
kubectl replace -f replicaset-definition.yaml
```

### Method 2: kubectl scale

```bash
# Scale by name
kubectl scale rs myapp-replicaset --replicas=6

# Scale using file
kubectl scale --replicas=6 -f replicaset-definition.yaml
```

### Method 3: kubectl edit

```bash
kubectl edit rs myapp-replicaset
# Change replicas value and save
```

> **Note**: `kubectl scale` doesn't update the YAML file. For consistency, update the file directly.

---

## CKA Exam Relevance

### What to Know

- Create and manage ReplicaSets
- Understand selector-label relationship
- Scale ReplicaSets up and down
- Troubleshoot ReplicaSet issues
- Know that Deployments manage ReplicaSets (usually use Deployments instead)

### Common Exam Tasks

- Fix broken ReplicaSet YAML (missing/mismatched labels/selectors)
- Scale existing ReplicaSet
- Delete pods and observe ReplicaSet behavior

### Quick Troubleshooting

```bash
# Check ReplicaSet status
kubectl get rs

# Check if pods are being created
kubectl get pods

# Check events for issues
kubectl describe rs <name>

# Common issues:
# - Selector doesn't match template labels
# - Image pull errors
# - Resource constraints
```

### Important Points

1. **Template section is always required** - even if pods already exist
2. **Selector must match template labels** - common YAML error
3. **apiVersion is `apps/v1`** - NOT `v1`

---

## Quick Reference

| Command                                | Description        |
| -------------------------------------- | ------------------ |
| `kubectl get rs`                       | List ReplicaSets   |
| `kubectl describe rs <name>`           | Detailed RS info   |
| `kubectl scale rs <name> --replicas=N` | Scale RS           |
| `kubectl delete rs <name>`             | Delete RS and pods |
| `kubectl edit rs <name>`               | Edit RS live       |

---

## Official Documentation

- [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
