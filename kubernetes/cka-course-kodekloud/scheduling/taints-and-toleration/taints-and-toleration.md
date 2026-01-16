# Taints and Tolerations in Kubernetes

## Overview

Taints and Tolerations work together to ensure that pods are **not scheduled** onto inappropriate nodes. This is about **restrictions** and **preferences** rather than direct pod-to-node assignment.

**Key Concept**:

- **Taints** are applied to **nodes** (repel pods)
- **Tolerations** are applied to **pods** (allow pods to tolerate taints)

## Real-World Analogy

Think of taints as a "bug spray" applied to nodes:

- Nodes with taint = "I have bug spray, only bugs that are immune can land on me"
- Pods with tolerations = "I'm immune to this specific bug spray, I can land here"
- Pods without tolerations = "I can't tolerate this bug spray, I won't land here"

---

## Taint Effects

There are **three taint effects** that determine what happens to pods:

### 1. NoSchedule (Hard Restriction)

```bash
kubectl taint nodes node1 app=blue:NoSchedule
```

- **Effect**: New pods without matching tolerations will **NOT** be scheduled on this node
- **Existing Pods**: Remain running (not affected)
- **Use Case**: Reserve nodes for specific workloads (e.g., GPU nodes for ML workloads)

### 2. PreferNoSchedule (Soft Restriction)

```bash
kubectl taint nodes node1 app=blue:PreferNoSchedule
```

- **Effect**: Scheduler **tries to avoid** placing pods without matching tolerations
- **Existing Pods**: Remain running (not affected)
- **Fallback**: If no other nodes are available, pods may still be scheduled here
- **Use Case**: Prefer certain workloads but allow others if necessary

### 3. NoExecute (Hard Restriction + Eviction)

```bash
kubectl taint nodes node1 app=blue:NoExecute
```

- **Effect**: New pods without matching tolerations will **NOT** be scheduled
- **Existing Pods**: Pods without matching tolerations are **evicted immediately**
- **Use Case**: Immediate isolation (e.g., maintenance, security zones, node draining)

---

## Taint Commands

### Apply Taint to Node

```bash
# Basic syntax
kubectl taint nodes <node-name> <key>=<value>:<effect>

# Examples
kubectl taint nodes node1 app=blue:NoSchedule
kubectl taint nodes node1 env=production:PreferNoSchedule
kubectl taint nodes node1 dedicated=gpu:NoExecute
```

### Remove Taint from Node

```bash
# Add a minus sign (-) at the end
kubectl taint nodes <node-name> <key>:<effect>-

# Examples
kubectl taint nodes node1 app:NoSchedule-
kubectl taint nodes node1 env:PreferNoSchedule-
kubectl taint nodes node1 dedicated:NoExecute-
```

### View Node Taints

```bash
# Describe node to see taints
kubectl describe node <node-name> | grep -i taint

# Get taints using jsonpath
kubectl get nodes -o jsonpath='{.items[*].spec.taints}'
```

---

## Tolerations in Pods

Tolerations allow pods to be scheduled on tainted nodes. They must match the taint exactly (key, value, effect).

### Toleration Syntax (YAML)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: nginx
      image: nginx
  tolerations:
    - key: "app"
      operator: "Equal"
      value: "blue"
      effect: "NoSchedule"
```

### Toleration Operators

#### 1. Equal (Default)

Matches when key, value, and effect are equal

```yaml
tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```

#### 2. Exists

Matches any value for the specified key and effect

```yaml
tolerations:
  - key: "app"
    operator: "Exists"
    effect: "NoSchedule"
```

#### 3. Tolerate All Taints

Matches all taints (wildcard)

```yaml
tolerations:
  - operator: "Exists"
```

### Toleration with Time Limit (NoExecute only)

```yaml
tolerations:
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300 # Pod can stay for 5 minutes before eviction
```

---

## Practical Examples

### Example 1: Dedicated Node for Production

**Node Setup:**

```bash
kubectl taint nodes prod-node1 env=production:NoSchedule
```

**Pod Configuration:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
spec:
  containers:
    - name: app
      image: myapp:prod
  tolerations:
    - key: "env"
      operator: "Equal"
      value: "production"
      effect: "NoSchedule"
```

**Result**: Only pods with `env=production:NoSchedule` toleration can run on `prod-node1`

---

### Example 2: GPU Node Reservation

**Node Setup:**

```bash
kubectl taint nodes gpu-node1 hardware=gpu:NoSchedule
```

**Pod Configuration:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ml-training
spec:
  containers:
    - name: tensorflow
      image: tensorflow/tensorflow:latest-gpu
  tolerations:
    - key: "hardware"
      operator: "Equal"
      value: "gpu"
      effect: "NoSchedule"
```

**Result**: GPU workloads can access the node; regular workloads cannot

---

### Example 3: Node Maintenance with Eviction

**Scenario**: Need to drain a node for maintenance and evict all pods immediately

**Node Setup:**

```bash
kubectl taint nodes node1 maintenance=true:NoExecute
```

**Result**:

- All pods **without** matching tolerations are evicted immediately
- New pods cannot be scheduled unless they have the toleration

---

## Understanding the Matching Logic

### Scenario Walkthrough

#### Node A Setup:

```bash
kubectl taint nodes nodeA app=blue:NoSchedule
```

#### Pod Configurations:

**Pod A** (✅ **WILL** be scheduled on Node A):

```yaml
tolerations:
  - key: "app"
    value: "blue"
    effect: "NoSchedule"
```

- **Reason**: Exact match (key, value, effect)

**Pod B** (❌ **WILL NOT** be scheduled on Node A):

```yaml
tolerations:
  - key: "app"
    value: "blue"
    effect: "PreferNoSchedule"
```

- **Reason**: Effect mismatch (`PreferNoSchedule` ≠ `NoSchedule`)

**Pod C** (❌ **WILL NOT** be scheduled on Node A):

```yaml
tolerations:
  - key: "app"
    value: "red"
    effect: "NoSchedule"
```

- **Reason**: Value mismatch (`red` ≠ `blue`)

**Pod D** (❌ **WILL NOT** be scheduled on Node A):

```yaml
# No tolerations specified
```

- **Reason**: No toleration for the taint

---

## Important Notes

### 1. Taints and Tolerations Do NOT Guarantee Placement

- Tolerations allow a pod to be scheduled on a tainted node
- They do **NOT** guarantee the pod will be scheduled on that specific node
- The scheduler may place the pod on any node it tolerates
- To **guarantee** placement, use **Node Affinity** in combination with taints

### 2. Master Node Taint (Default)

By default, Kubernetes taints the master/control-plane node:

```bash
kubectl describe node <master-node> | grep Taint
# Output: node-role.kubernetes.io/control-plane:NoSchedule
```

This prevents user pods from being scheduled on the master node.

### 3. Multiple Taints on One Node

A node can have multiple taints:

```bash
kubectl taint nodes node1 app=blue:NoSchedule
kubectl taint nodes node1 env=prod:NoSchedule
```

A pod must have tolerations for **all** taints to be scheduled on the node.

### 4. Toleration Does Not Mean Affinity

- A pod with a toleration can be scheduled on nodes **with or without** that taint
- If you want to **force** a pod to a specific node, use **nodeSelector** or **Node Affinity**

---

## Common Use Cases

### 1. Dedicated Nodes

Reserve nodes for specific teams, environments, or applications

```bash
kubectl taint nodes node1 team=backend:NoSchedule
```

### 2. Special Hardware

Reserve nodes with special hardware (GPU, SSD, high memory)

```bash
kubectl taint nodes gpu-node1 hardware=gpu:NoSchedule
```

### 3. Node Maintenance

Safely drain nodes for maintenance

```bash
kubectl taint nodes node1 maintenance=scheduled:NoExecute
```

### 4. Node Failure Handling

Automatically evict pods from failing nodes

```bash
# Kubernetes adds this automatically
node.kubernetes.io/unreachable:NoExecute
node.kubernetes.io/not-ready:NoExecute
```

### 5. Multi-Tenancy

Isolate workloads from different tenants

```bash
kubectl taint nodes tenant1-node1 tenant=tenant1:NoSchedule
```

---

## Comparison with Node Affinity

| Feature        | Taints & Tolerations                  | Node Affinity                                  |
| -------------- | ------------------------------------- | ---------------------------------------------- |
| **Purpose**    | Restrict pods from nodes              | Attract pods to nodes                          |
| **Applied To** | Taints on nodes, Tolerations on pods  | Rules on pods                                  |
| **Behavior**   | Repel pods (negative)                 | Attract pods (positive)                        |
| **Guarantee**  | Does NOT guarantee placement          | Can require placement                          |
| **Use Case**   | "These pods should avoid these nodes" | "These pods should prefer/require these nodes" |

**Best Practice**: Use both together for fine-grained control:

- **Taints**: Prevent unwanted pods
- **Node Affinity**: Ensure desired placement

---

## Quick Reference Commands

```bash
# Add taint to node
kubectl taint nodes <node-name> <key>=<value>:<effect>

# Remove taint from node
kubectl taint nodes <node-name> <key>:<effect>-

# View node taints
kubectl describe node <node-name> | grep -i taint

# View all node taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Remove all taints from a node (be careful!)
kubectl taint nodes <node-name> <key>-

# Taint all worker nodes
kubectl taint nodes --all node-role.kubernetes.io/worker=:NoSchedule

# Remove taint from all nodes
kubectl taint nodes --all <key>:<effect>-
```

---

## Exam Tips (CKA/CKAD)

1. **Remember the three effects**: `NoSchedule`, `PreferNoSchedule`, `NoExecute`
2. **Syntax for tolerations**: Must match exactly (key, value, effect)
3. **Removing taints**: Add `-` at the end of the taint specification
4. **Master node taint**: Understand why user pods don't schedule on master by default
5. **NoExecute behavior**: Only effect that evicts existing pods
6. **Tolerations don't guarantee placement**: Use Node Affinity for guaranteed placement
7. **Quick pod generation**: Use `kubectl run` with `--dry-run=client -o yaml` and add tolerations manually

---

## Troubleshooting

### Pod Not Scheduling?

1. **Check node taints:**

```bash
kubectl describe nodes | grep -i taint
```

2. **Check pod tolerations:**

```bash
kubectl get pod <pod-name> -o yaml | grep -A 5 tolerations
```

3. **Check pod events:**

```bash
kubectl describe pod <pod-name>
# Look for: "0/N nodes are available: N node(s) had taints that the pod didn't tolerate"
```

### Common Issues

**Issue**: Pod stuck in Pending state

```
Events:
  Warning  FailedScheduling  pod failed to fit in any node
  0/3 nodes are available: 3 node(s) had taints that the pod didn't tolerate.
```

**Solution**: Add matching toleration to the pod spec

**Issue**: Pod evicted after adding NoExecute taint
**Solution**: This is expected behavior. Add toleration before applying NoExecute taint

---

## Additional Resources

- [Official Kubernetes Documentation: Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [kubectl Taint Reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint)
