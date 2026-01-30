# Kubernetes Pods

## Executive Summary

A **Pod** is the smallest deployable unit in Kubernetes. It encapsulates one or more containers that share the same network namespace, storage volumes, and lifecycle. Pods are the basic building blocks for running applications in Kubernetes.

### Key Concepts

- Pods are **ephemeral** - they can be created, destroyed, and replaced
- Containers in a pod share the same IP address and can communicate via `localhost`
- Scaling means adding more pods, NOT adding containers to existing pods
- Multi-container pods are for **helper/sidecar** containers, not multiple instances of the same app

---

## Real-World Usage

| Scenario                 | Description                              |
| ------------------------ | ---------------------------------------- |
| **Single Container Pod** | Most common - one application per pod    |
| **Sidecar Pattern**      | Main app + logging/monitoring agent      |
| **Ambassador Pattern**   | Main app + proxy container               |
| **Adapter Pattern**      | Main app + data transformation container |

---

## Common Commands

### Creating Pods

```bash
# Imperative - create a pod quickly
kubectl run nginx --image=nginx

# Imperative with labels
kubectl run nginx --image=nginx --labels="app=web,tier=frontend"

# Imperative with port exposure
kubectl run nginx --image=nginx --port=80

# Create from YAML file
kubectl create -f pod-definition.yaml

# Create/update declaratively
kubectl apply -f pod-definition.yaml
```

### Viewing Pods

```bash
# List pods in current namespace
kubectl get pods

# List pods with more details
kubectl get pods -o wide

# List pods in all namespaces
kubectl get pods -A

# List pods with labels
kubectl get pods --show-labels

# Filter by label
kubectl get pods -l app=nginx
```

### Pod Details & Troubleshooting

```bash
# Describe pod (events, status, containers)
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# View logs for specific container (multi-container pod)
kubectl logs <pod-name> -c <container-name>

# Stream logs
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Execute in specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash
```

### Managing Pods

```bash
# Delete pod
kubectl delete pod <pod-name>

# Delete pod immediately (force)
kubectl delete pod <pod-name> --grace-period=0 --force

# Edit pod (limited fields can be edited)
kubectl edit pod <pod-name>

# Generate YAML from running pod
kubectl get pod <pod-name> -o yaml > pod.yaml
```

---

## YAML Configuration

### Basic Pod Definition

```yaml
apiVersion: v1
kind: Pod
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

### Pod with Multiple Containers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
    - name: main-app
      image: nginx
      ports:
        - containerPort: 80
    - name: sidecar
      image: busybox
      command: ["sh", "-c", 'while true; do echo "logging..."; sleep 5; done']
```

### Pod with Resource Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
    - name: nginx
      image: nginx
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
```

### Pod with Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
    - name: myapp
      image: myapp:1.0
      env:
        - name: DATABASE_HOST
          value: "mysql-service"
        - name: DATABASE_PORT
          value: "3306"
```

---

## Four Required Fields in YAML

| Field        | Description                          | Example               |
| ------------ | ------------------------------------ | --------------------- |
| `apiVersion` | API version to use                   | `v1` for pods         |
| `kind`       | Type of Kubernetes object            | `Pod`                 |
| `metadata`   | Object identification (name, labels) | `name: myapp-pod`     |
| `spec`       | Specification/desired state          | Container definitions |

---

## CKA Exam Relevance

### What to Know

- Create pods using both imperative and declarative methods
- Understand pod lifecycle and states
- Troubleshoot pod issues using `describe` and `logs`
- Know how to generate YAML quickly using `--dry-run=client -o yaml`

### Quick YAML Generation (Exam Tip!)

```bash
# Generate pod YAML without creating
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Generate pod with port
kubectl run nginx --image=nginx --port=80 --dry-run=client -o yaml

# Generate pod with labels
kubectl run nginx --image=nginx --labels="app=web" --dry-run=client -o yaml
```

### Pod States

| State       | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `Pending`   | Pod accepted but not yet running (scheduling, image pulling) |
| `Running`   | Pod bound to node, containers running                        |
| `Succeeded` | All containers terminated successfully                       |
| `Failed`    | All containers terminated, at least one failed               |
| `Unknown`   | Pod state cannot be determined                               |

---

## Official Documentation

- [Pods Overview](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Multi-container Pods](https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers)
