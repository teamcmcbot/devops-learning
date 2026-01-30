# Imperative vs Declarative Approach

## Executive Summary

Kubernetes supports two approaches to manage resources:

| Approach        | Description                                     | Best For                                |
| --------------- | ----------------------------------------------- | --------------------------------------- |
| **Imperative**  | Tell Kubernetes _what to do_ step by step       | Quick tasks, exams, one-time operations |
| **Declarative** | Tell Kubernetes _what you want_ (desired state) | Production, GitOps, team collaboration  |

---

## Imperative Approach

### Direct Commands (No YAML)

```bash
# Create resources
kubectl run nginx --image=nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80

# Update resources
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx nginx=nginx:1.19

# Delete resources
kubectl delete pod nginx
kubectl delete deployment nginx
```

### Imperative with YAML Files

```bash
# Create from file
kubectl create -f pod.yaml

# Update from file (must exist)
kubectl replace -f pod.yaml

# Delete from file
kubectl delete -f pod.yaml

# Force replace (delete and recreate)
kubectl replace --force -f pod.yaml
```

### Pros & Cons

| Pros                    | Cons                               |
| ----------------------- | ---------------------------------- |
| Fast for one-time tasks | No record of changes               |
| Good for exam scenarios | Harder to track in teams           |
| Immediate results       | May cause drift from desired state |

---

## Declarative Approach

### The `kubectl apply` Command

```bash
# Create or update resource
kubectl apply -f pod.yaml

# Apply all files in directory
kubectl apply -f ./manifests/

# Apply recursively
kubectl apply -R -f ./manifests/
```

### How `kubectl apply` Works

1. Compares **local file**, **live object**, and **last-applied-configuration**
2. Performs a **three-way merge**
3. Stores configuration as annotation on object

### Pros & Cons

| Pros               | Cons                            |
| ------------------ | ------------------------------- |
| Version controlled | Slightly slower for quick tasks |
| Team-friendly      | Requires maintaining YAML files |
| GitOps compatible  | More setup initially            |
| Idempotent         | -                               |

---

## CKA Exam Strategy

### Use Imperative for Speed

```bash
# Create pod
kubectl run nginx --image=nginx

# Create deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Expose as service
kubectl expose deployment nginx --port=80 --type=NodePort

# Scale
kubectl scale deployment nginx --replicas=5

# Update image
kubectl set image deployment nginx nginx=nginx:1.19
```

### Generate YAML with `--dry-run`

```bash
# Generate pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Generate deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml

# Generate service YAML
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > svc.yaml

# Generate with specific options
kubectl run nginx --image=nginx --port=80 --labels="app=web" --dry-run=client -o yaml
```

### Quick Edit and Apply

```bash
# Generate YAML → Edit → Apply
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
vim deploy.yaml  # Make changes
kubectl apply -f deploy.yaml
```

---

## Common Imperative Commands Reference

### Pods

```bash
kubectl run <name> --image=<image>
kubectl run <name> --image=<image> --port=<port>
kubectl run <name> --image=<image> --labels="key=value"
kubectl run <name> --image=<image> --env="KEY=VALUE"
kubectl run <name> --image=<image> --command -- <cmd> <args>
```

### Deployments

```bash
kubectl create deployment <name> --image=<image>
kubectl create deployment <name> --image=<image> --replicas=<n>
kubectl scale deployment <name> --replicas=<n>
kubectl set image deployment/<name> <container>=<image>
```

### Services

```bash
kubectl expose pod <pod> --port=<port>
kubectl expose deployment <deploy> --port=<port> --type=NodePort
kubectl expose deployment <deploy> --port=<port> --target-port=<tport>
kubectl create service clusterip <name> --tcp=<port>:<tport>
kubectl create service nodeport <name> --tcp=<port>:<tport>
```

### ConfigMaps & Secrets

```bash
kubectl create configmap <name> --from-literal=key=value
kubectl create configmap <name> --from-file=<path>
kubectl create secret generic <name> --from-literal=key=value
kubectl create secret generic <name> --from-file=<path>
```

### Namespaces

```bash
kubectl create namespace <name>
```

---

## `kubectl apply` vs `kubectl create` vs `kubectl replace`

| Command           | Behavior                                                   |
| ----------------- | ---------------------------------------------------------- |
| `kubectl create`  | Creates new object; fails if exists                        |
| `kubectl replace` | Updates existing object; fails if doesn't exist            |
| `kubectl apply`   | Creates if not exists; updates if exists (three-way merge) |

### Best Practice

- Use `kubectl apply` for declarative management
- Use `kubectl create` / `kubectl run` for quick imperative tasks
- Avoid mixing approaches on the same resources

---

## CKA Exam Tips

### Time-Saving Shortcuts

```bash
# Set alias
alias k=kubectl

# Enable autocompletion
source <(kubectl completion bash)

# Quick namespace switch
kubectl config set-context --current --namespace=dev
```

### Exam Workflow

1. **Quick creates**: Use imperative commands
2. **Complex configs**: Generate YAML with `--dry-run`, edit, then apply
3. **Updates**: Use `kubectl edit` or `kubectl set`
4. **Troubleshooting**: Use `kubectl describe`, `kubectl logs`

### Common Exam Patterns

```bash
# Create pod with specific requirements
kubectl run nginx --image=nginx --port=80 --labels="tier=web" -n dev

# Create deployment and expose
kubectl create deployment webapp --image=nginx --replicas=3
kubectl expose deployment webapp --port=80 --type=NodePort

# Quick YAML generation and modification
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
# Edit pod.yaml to add required specs
kubectl apply -f pod.yaml
```

---

## Quick Reference

| Task              | Imperative Command                                         |
| ----------------- | ---------------------------------------------------------- |
| Create pod        | `kubectl run nginx --image=nginx`                          |
| Create deployment | `kubectl create deployment nginx --image=nginx`            |
| Expose deployment | `kubectl expose deployment nginx --port=80`                |
| Scale             | `kubectl scale deployment nginx --replicas=5`              |
| Update image      | `kubectl set image deployment nginx nginx=nginx:1.19`      |
| Edit resource     | `kubectl edit deployment nginx`                            |
| Generate YAML     | `kubectl run nginx --image=nginx --dry-run=client -o yaml` |

---

## Official Documentation

- [Managing Resources](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Declarative Management](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)
