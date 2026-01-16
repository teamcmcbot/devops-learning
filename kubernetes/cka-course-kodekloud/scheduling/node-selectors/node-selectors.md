# Node Selectors in Kubernetes

## Overview

**Node Selectors** are the simplest way to constrain pods to run on specific nodes in a Kubernetes cluster. They use **labels** on nodes and **selectors** in pod specifications to match pods to nodes.

**Key Concept**:

- Node Selectors provide a **simple key-value matching** mechanism
- Pods will only be scheduled on nodes that have ALL the specified labels

---

## How Node Selectors Work

### The Process:

1. **Label nodes** with key-value pairs (e.g., `size=large`, `env=production`)
2. **Add nodeSelector** to pod spec with matching key-value pairs
3. **Kubernetes scheduler** places the pod only on nodes with matching labels

### Real-World Analogy

Think of node selectors as "room requirements" for hotel booking:

- Nodes = Hotel rooms with labels like "view=ocean", "floor=high", "size=suite"
- Pod = Guest with requirements "view=ocean"
- Scheduler = Hotel manager who only books rooms matching the requirements

---

## Basic Syntax

### Step 1: Label Nodes

```bash
# Label a node
kubectl label nodes <node-name> <key>=<value>

# Examples:
kubectl label nodes node01 size=large
kubectl label nodes node02 size=medium
kubectl label nodes node03 env=production
kubectl label nodes node04 disktype=ssd

# View node labels
kubectl get nodes --show-labels

# View specific label
kubectl get nodes -L size,env
```

### Step 2: Add nodeSelector to Pod Spec

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: nginx
      image: nginx
  nodeSelector:
    size: large # Pod will only run on nodes with label "size=large"
```

---

## Practical Examples

### Example 1: Run Pod on Large Node

**Label the node:**

```bash
kubectl label nodes node01 size=large
```

**Pod definition (pod-large.yaml):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
spec:
  containers:
    - name: processor
      image: data-processor:latest
      resources:
        requests:
          memory: "16Gi"
          cpu: "4"
  nodeSelector:
    size: large
```

**Deploy:**

```bash
kubectl apply -f pod-large.yaml
```

**Result**: Pod will only be scheduled on `node01` (or any other node with `size=large` label)

---

### Example 2: Production Environment

**Label nodes:**

```bash
kubectl label nodes node01 env=production
kubectl label nodes node02 env=production
kubectl label nodes node03 env=development
```

**Pod definition (prod-app.yaml):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
spec:
  containers:
    - name: app
      image: myapp:prod
  nodeSelector:
    env: production
```

**Result**: Pod will be scheduled on either `node01` or `node02`, but NOT on `node03`

---

### Example 3: Multiple Labels (AND Logic)

**Label nodes:**

```bash
kubectl label nodes node01 size=large env=production disktype=ssd
kubectl label nodes node02 size=large env=development
```

**Pod definition (demanding-app.yaml):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demanding-app
spec:
  containers:
    - name: app
      image: myapp:latest
  nodeSelector:
    size: large
    env: production
    disktype: ssd
```

**Result**:

- Pod will **ONLY** be scheduled on `node01` (has ALL three labels)
- Pod will **NOT** be scheduled on `node02` (missing `disktype=ssd` label)
- All labels in nodeSelector must match (AND logic)

---

### Example 4: Using with Deployment

**Deployment with nodeSelector (deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx
      nodeSelector:
        disktype: ssd
```

**Result**: All 3 replicas will be scheduled only on nodes with `disktype=ssd` label

---

## Node Label Management

### View Labels

```bash
# Show all node labels
kubectl get nodes --show-labels

# Show specific label columns
kubectl get nodes -L size,env,disktype

# Describe node to see all labels
kubectl describe node <node-name>

# Get labels using jsonpath
kubectl get nodes -o jsonpath='{.items[*].metadata.labels}'
```

### Add Labels

```bash
# Add single label
kubectl label nodes <node-name> <key>=<value>

# Add multiple labels at once
kubectl label nodes node01 size=large env=production region=us-east

# Add label to multiple nodes
kubectl label nodes node01 node02 node03 disktype=ssd
```

### Update Labels

```bash
# Update existing label (will fail without --overwrite)
kubectl label nodes node01 size=xlarge --overwrite

# Force update
kubectl label nodes node01 size=medium --overwrite
```

### Remove Labels

```bash
# Remove label (add minus sign)
kubectl label nodes <node-name> <key>-

# Examples:
kubectl label nodes node01 size-
kubectl label nodes node01 env- disktype-
```

---

## Imperative Commands

### Create Pod with nodeSelector (Dry-run)

```bash
# Generate pod YAML
kubectl run my-pod --image=nginx --dry-run=client -o yaml > pod.yaml

# Edit pod.yaml to add nodeSelector manually
vim pod.yaml

# Apply
kubectl apply -f pod.yaml
```

**Note**: There's no imperative command to add nodeSelector directly. You must:

1. Generate YAML with `--dry-run=client -o yaml`
2. Edit the YAML to add nodeSelector
3. Apply the modified YAML

---

## Limitations of Node Selectors

### 1. **Only AND Logic** (No OR)

```yaml
# ❌ Cannot do: "size=large OR size=xlarge"
nodeSelector:
  size: large # Only exact match

# Solution: Use Node Affinity for complex logic
```

### 2. **No NOT Logic**

```yaml
# ❌ Cannot do: "NOT env=development"
nodeSelector:
  env: production # Only positive matching

# Solution: Use Node Affinity with NotIn operator
```

### 3. **Exact Match Only**

```yaml
# ❌ Cannot do: "size IN (large, xlarge)"
nodeSelector:
  size: large # Must match exactly

# Solution: Use Node Affinity for multiple values
```

### 4. **No Soft Preferences**

- Node Selectors are **hard requirements**
- Pod remains Pending if no matching node exists
- Cannot express "prefer this node, but allow others"

**Solution**: Use Node Affinity with `preferredDuringSchedulingIgnoredDuringExecution`

---

## When to Use Node Selectors

### ✅ Use Node Selectors When:

- Simple label-based scheduling is sufficient
- You need straightforward "this pod on that node type" logic
- All matching criteria are AND-based
- You want simple, readable configuration

### ❌ Use Node Affinity Instead When:

- You need OR logic (multiple possible values)
- You need NOT logic (exclusion rules)
- You want soft preferences (prefer but not require)
- You need complex matching expressions
- You need more advanced scheduling control

---

## Common Use Cases

### 1. Hardware-Based Scheduling

```bash
# Label GPU nodes
kubectl label nodes gpu-node1 hardware=gpu
kubectl label nodes gpu-node2 hardware=gpu

# Label SSD nodes
kubectl label nodes ssd-node1 disktype=ssd
```

```yaml
# ML training pod on GPU
apiVersion: v1
kind: Pod
metadata:
  name: ml-training
spec:
  containers:
    - name: tensorflow
      image: tensorflow/tensorflow:latest-gpu
  nodeSelector:
    hardware: gpu
```

### 2. Environment Isolation

```bash
# Label by environment
kubectl label nodes prod-node1 prod-node2 env=production
kubectl label nodes dev-node1 dev-node2 env=development
kubectl label nodes stage-node1 env=staging
```

```yaml
# Production workload
apiVersion: v1
kind: Pod
metadata:
  name: prod-api
spec:
  containers:
    - name: api
      image: myapi:latest
  nodeSelector:
    env: production
```

### 3. Geographical Location

```bash
# Label by region/zone
kubectl label nodes node1 node2 region=us-east
kubectl label nodes node3 node4 region=eu-west
kubectl label nodes node5 node6 region=ap-south
```

```yaml
# Region-specific pod
apiVersion: v1
kind: Pod
metadata:
  name: regional-app
spec:
  containers:
    - name: app
      image: myapp:latest
  nodeSelector:
    region: us-east
```

### 4. Node Size/Capacity

```bash
# Label by node capacity
kubectl label nodes node1 size=small    # 2CPU, 4GB RAM
kubectl label nodes node2 size=medium   # 4CPU, 8GB RAM
kubectl label nodes node3 size=large    # 8CPU, 16GB RAM
kubectl label nodes node4 size=xlarge   # 16CPU, 32GB RAM
```

```yaml
# Resource-intensive pod
apiVersion: v1
kind: Pod
metadata:
  name: heavy-workload
spec:
  containers:
    - name: processor
      image: data-processor:latest
  nodeSelector:
    size: xlarge
```

---

## Troubleshooting

### Pod Stuck in Pending State

**Symptom:**

```bash
kubectl get pods
# NAME     READY   STATUS    RESTARTS   AGE
# my-pod   0/1     Pending   0          2m
```

**Check events:**

```bash
kubectl describe pod my-pod
# Events:
#   Warning  FailedScheduling  pod failed to fit in any node
#   0/3 nodes are available: 3 node(s) didn't match Pod's node affinity/selector.
```

**Common Causes:**

1. **No nodes with matching labels**

   ```bash
   # Check if any nodes have the required label
   kubectl get nodes -L size

   # If no nodes match, either:
   # Option 1: Add label to a node
   kubectl label nodes node01 size=large

   # Option 2: Update pod nodeSelector
   kubectl delete pod my-pod
   # Edit pod.yaml and reapply
   ```

2. **Typo in label key or value**

   ```bash
   # Check exact label on node
   kubectl get nodes --show-labels | grep size

   # Check pod's nodeSelector
   kubectl get pod my-pod -o yaml | grep -A 3 nodeSelector
   ```

3. **Case sensitivity**

   ```yaml
   # ❌ Wrong - labels are case-sensitive
   nodeSelector:
     Size: large  # Capital 'S'

   # ✅ Correct
   nodeSelector:
     size: large  # Lowercase 's'
   ```

### Node Labels Not Showing

```bash
# Check if label was applied
kubectl get nodes -L size

# If missing, reapply
kubectl label nodes node01 size=large

# Verify
kubectl describe node node01 | grep -i labels
```

---

## Comparison: Node Selectors vs Node Affinity vs Taints/Tolerations

| Feature              | Node Selectors        | Node Affinity           | Taints & Tolerations  |
| -------------------- | --------------------- | ----------------------- | --------------------- |
| **Complexity**       | Simple                | Complex                 | Medium                |
| **Purpose**          | Attract pods to nodes | Attract pods to nodes   | Repel pods from nodes |
| **Logic**            | AND only              | AND, OR, NOT, IN, NotIn | Match/No Match        |
| **Flexibility**      | Low                   | High                    | Medium                |
| **Soft Preferences** | No                    | Yes                     | No                    |
| **Use Case**         | Simple placement      | Complex placement rules | Node restrictions     |
| **When to Use**      | Basic needs           | Advanced scheduling     | Prevent unwanted pods |

**Best Practice**:

- Start with **Node Selectors** for simple cases
- Graduate to **Node Affinity** when you need more flexibility
- Use **Taints & Tolerations** to complement either approach for node-level restrictions

---

## Migration Path: Node Selectors → Node Affinity

If you outgrow Node Selectors, here's how to migrate:

**Before (Node Selector):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: nginx
      image: nginx
  nodeSelector:
    size: large
```

**After (Node Affinity - Required):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: nginx
      image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: size
                operator: In
                values:
                  - large
```

**After (Node Affinity - Preferred):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: nginx
      image: nginx
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
              - key: size
                operator: In
                values:
                  - large
```

---

## Quick Reference Commands

```bash
# Label nodes
kubectl label nodes <node-name> <key>=<value>
kubectl label nodes node01 size=large env=prod

# View node labels
kubectl get nodes --show-labels
kubectl get nodes -L size,env,disktype

# Update label
kubectl label nodes <node-name> <key>=<value> --overwrite

# Remove label
kubectl label nodes <node-name> <key>-

# Check why pod is pending
kubectl describe pod <pod-name>
kubectl get events --field-selector involvedObject.name=<pod-name>

# Check nodes with specific label
kubectl get nodes -l size=large
kubectl get nodes -l 'size in (large,xlarge)'
```

---

## CKA Exam Tips

1. **Label nodes first**, then create pods - this order prevents scheduling issues
2. **Always verify labels** with `kubectl get nodes --show-labels`
3. **Use `--show-labels`** frequently to check node labels
4. **Remember case sensitivity** - `Size` ≠ `size`
5. **Check pod events** if stuck in Pending state
6. **No imperative command** for nodeSelector - must use YAML
7. **Use dry-run** to generate YAML, then add nodeSelector manually
8. **nodeSelector requires exact match** - consider Node Affinity for flexibility

---

## Additional Resources

- [Official Kubernetes Documentation: Node Selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)
- [Node Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Assigning Pods to Nodes](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/)
