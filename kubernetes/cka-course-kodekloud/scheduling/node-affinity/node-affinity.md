# Node Affinity in Kubernetes

## Overview

**Node Affinity** is an advanced pod scheduling feature that allows you to constrain which nodes your pods can be scheduled on, based on node labels. It's a more expressive and flexible alternative to **Node Selectors**.

**Key Concept**:

- Node Affinity provides **complex matching rules** with operators like `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`
- Supports both **required** (hard) and **preferred** (soft) constraints
- Allows **OR logic** and **NOT logic** for sophisticated scheduling

---

## Why Node Affinity Over Node Selectors?

| Feature          | Node Selectors | Node Affinity             |
| ---------------- | -------------- | ------------------------- |
| Matching Logic   | AND only       | AND, OR, NOT, IN, NotIn   |
| Multiple Values  | ❌ No          | ✅ Yes (`In` operator)    |
| Exclusion        | ❌ No          | ✅ Yes (`NotIn` operator) |
| Soft Preferences | ❌ No          | ✅ Yes (preferred rules)  |
| Operator Support | Equality only  | 6 operators               |
| Complexity       | Simple         | Complex but flexible      |

---

## Node Affinity Types

Node Affinity has two types based on scheduling behavior:

### 1. **requiredDuringSchedulingIgnoredDuringExecution** (Hard Constraint)

- **Required**: Pod **MUST** be placed on matching nodes
- **During Scheduling**: Rule enforced at scheduling time
- **Ignored During Execution**: If labels change after pod is running, pod continues running
- **Behavior**: Pod stays **Pending** if no matching nodes exist

**Use Case**: Absolute requirements (e.g., GPU nodes for ML training, production-only nodes)

### 2. **preferredDuringSchedulingIgnoredDuringExecution** (Soft Constraint)

- **Preferred**: Scheduler **TRIES** to place pod on matching nodes
- **During Scheduling**: Rule is a preference, not a requirement
- **Ignored During Execution**: If labels change after pod is running, pod continues running
- **Behavior**: Pod will be scheduled even if no matching nodes exist

**Use Case**: Preferences without blocking (e.g., prefer SSD nodes but allow HDD)

### Future Types (Not Yet Implemented)

- `requiredDuringSchedulingRequiredDuringExecution`: Pod evicted if labels no longer match
- `preferredDuringSchedulingRequiredDuringExecution`: Preferred with eviction on mismatch

---

## Basic Syntax

### Required Node Affinity (Hard Constraint)

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
                  - xlarge
```

### Preferred Node Affinity (Soft Constraint)

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
              - key: disktype
                operator: In
                values:
                  - ssd
```

---

## Operators in Node Affinity

Node Affinity supports six operators for matching:

### 1. **In** - Value must be in the list

```yaml
matchExpressions:
  - key: size
    operator: In
    values:
      - large
      - xlarge
# Matches nodes with label: size=large OR size=xlarge
```

### 2. **NotIn** - Value must NOT be in the list

```yaml
matchExpressions:
  - key: env
    operator: NotIn
    values:
      - development
      - testing
# Matches nodes WITHOUT labels: env=development or env=testing
```

### 3. **Exists** - Key must exist (any value)

```yaml
matchExpressions:
  - key: gpu
    operator: Exists
# Matches nodes with label key "gpu" (regardless of value)
```

### 4. **DoesNotExist** - Key must NOT exist

```yaml
matchExpressions:
  - key: maintenance
    operator: DoesNotExist
# Matches nodes WITHOUT the "maintenance" label key
```

### 5. **Gt** (Greater Than) - For numeric comparison

```yaml
matchExpressions:
  - key: cpu-cores
    operator: Gt
    values:
      - "8"
# Matches nodes where cpu-cores > 8
```

### 6. **Lt** (Less Than) - For numeric comparison

```yaml
matchExpressions:
  - key: memory-gb
    operator: Lt
    values:
      - "32"
# Matches nodes where memory-gb < 32
```

---

## Practical Examples

### Example 1: OR Logic - Multiple Acceptable Values

**Scenario**: Run pod on either large OR xlarge nodes

**Node labels:**

```bash
kubectl label nodes node01 size=large
kubectl label nodes node02 size=xlarge
kubectl label nodes node03 size=medium
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
spec:
  containers:
    - name: processor
      image: data-processor:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: size
                operator: In
                values:
                  - large
                  - xlarge
```

**Result**: Pod can be scheduled on `node01` (large) OR `node02` (xlarge), but NOT `node03` (medium)

---

### Example 2: NOT Logic - Exclusion

**Scenario**: Run pod on any node EXCEPT development nodes

**Node labels:**

```bash
kubectl label nodes node01 env=production
kubectl label nodes node02 env=staging
kubectl label nodes node03 env=development
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: prod-app
spec:
  containers:
    - name: app
      image: myapp:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: env
                operator: NotIn
                values:
                  - development
```

**Result**: Pod can be scheduled on `node01` or `node02`, but NOT `node03`

---

### Example 3: Multiple Conditions (AND Logic within term)

**Scenario**: Pod needs large node AND SSD disk

**Node labels:**

```bash
kubectl label nodes node01 size=large disktype=ssd
kubectl label nodes node02 size=large disktype=hdd
kubectl label nodes node03 size=medium disktype=ssd
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
spec:
  containers:
    - name: postgres
      image: postgres:14
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: size
                operator: In
                values:
                  - large
              - key: disktype
                operator: In
                values:
                  - ssd
```

**Result**: Pod can ONLY be scheduled on `node01` (has both labels)

---

### Example 4: Multiple Terms (OR Logic between terms)

**Scenario**: Pod needs (large node with SSD) OR (xlarge node with any disk)

**Node labels:**

```bash
kubectl label nodes node01 size=large disktype=ssd
kubectl label nodes node02 size=xlarge disktype=hdd
kubectl label nodes node03 size=medium disktype=ssd
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flexible-pod
spec:
  containers:
    - name: app
      image: myapp:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions: # Term 1: large + ssd
              - key: size
                operator: In
                values:
                  - large
              - key: disktype
                operator: In
                values:
                  - ssd
          - matchExpressions: # Term 2: xlarge (any disk)
              - key: size
                operator: In
                values:
                  - xlarge
```

**Result**: Pod can be scheduled on `node01` (matches term 1) OR `node02` (matches term 2)

---

### Example 5: Preferred Affinity with Weight

**Scenario**: Prefer SSD nodes, but allow HDD if needed

**Node labels:**

```bash
kubectl label nodes node01 disktype=ssd
kubectl label nodes node02 disktype=ssd
kubectl label nodes node03 disktype=hdd
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
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
              - key: disktype
                operator: In
                values:
                  - ssd
```

**Result**:

- Scheduler **prefers** `node01` or `node02` (SSD)
- If both SSD nodes are full, pod will be scheduled on `node03` (HDD)
- Pod will NOT remain Pending

---

### Example 6: Multiple Preferences with Different Weights

**Scenario**: Prefer SSD (weight 80) and prefer large nodes (weight 20)

**Node labels:**

```bash
kubectl label nodes node01 size=large disktype=ssd   # Best match: 80+20=100
kubectl label nodes node02 size=medium disktype=ssd  # Good match: 80
kubectl label nodes node03 size=large disktype=hdd   # OK match: 20
kubectl label nodes node04 size=small disktype=hdd   # No match: 0
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: optimized-app
spec:
  containers:
    - name: app
      image: myapp:latest
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 80
          preference:
            matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
        - weight: 20
          preference:
            matchExpressions:
              - key: size
                operator: In
                values:
                  - large
```

**Result**:

- Scheduler calculates scores: node01=100, node02=80, node03=20, node04=0
- Pod will most likely be scheduled on `node01` (highest score)
- If `node01` is unavailable, tries `node02`, then `node03`, then `node04`

---

### Example 7: Combining Required and Preferred

**Scenario**: MUST be on production node, PREFER SSD disk

**Node labels:**

```bash
kubectl label nodes node01 env=production disktype=ssd
kubectl label nodes node02 env=production disktype=hdd
kubectl label nodes node03 env=development disktype=ssd
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-app
spec:
  containers:
    - name: app
      image: myapp:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: env
                operator: In
                values:
                  - production
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
```

**Result**:

- Pod can ONLY be scheduled on production nodes (`node01` or `node02`)
- Scheduler **prefers** `node01` (SSD) over `node02` (HDD)
- Pod will NOT be scheduled on `node03` (not production)

---

### Example 8: Exists Operator

**Scenario**: Run on any node that has GPU (regardless of GPU type)

**Node labels:**

```bash
kubectl label nodes node01 gpu=nvidia-v100
kubectl label nodes node02 gpu=nvidia-a100
kubectl label nodes node03 cpu=intel  # No GPU
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ml-training
spec:
  containers:
    - name: tensorflow
      image: tensorflow/tensorflow:latest-gpu
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: gpu
                operator: Exists
```

**Result**: Pod can be scheduled on `node01` or `node02` (both have `gpu` label), but NOT `node03`

---

### Example 9: DoesNotExist Operator

**Scenario**: Avoid nodes under maintenance

**Node labels:**

```bash
kubectl label nodes node01 maintenance=scheduled
kubectl label nodes node02 status=active
kubectl label nodes node03 status=active
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: production-app
spec:
  containers:
    - name: app
      image: myapp:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: maintenance
                operator: DoesNotExist
```

**Result**: Pod can be scheduled on `node02` or `node03`, but NOT `node01` (has maintenance label)

---

### Example 10: Numeric Comparison (Gt/Lt)

**Scenario**: Pod needs nodes with more than 8 CPU cores

**Node labels:**

```bash
kubectl label nodes node01 cpu-cores="4"
kubectl label nodes node02 cpu-cores="8"
kubectl label nodes node03 cpu-cores="16"
kubectl label nodes node04 cpu-cores="32"
```

**Pod definition:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: compute-intensive
spec:
  containers:
    - name: processor
      image: data-processor:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: cpu-cores
                operator: Gt
                values:
                  - "8"
```

**Result**: Pod can be scheduled on `node03` (16 cores) or `node04` (32 cores), but NOT `node01` or `node02`

---

## Understanding nodeSelectorTerms Logic

### AND Logic Within a Term

Multiple `matchExpressions` within ONE `nodeSelectorTerm` are combined with **AND**:

```yaml
nodeSelectorTerms:
  - matchExpressions:
      - key: size
        operator: In
        values: [large]
      - key: disktype
        operator: In
        values: [ssd]
# Node MUST have BOTH: size=large AND disktype=ssd
```

### OR Logic Between Terms

Multiple `nodeSelectorTerms` are combined with **OR**:

```yaml
nodeSelectorTerms:
  - matchExpressions: # Term 1
      - key: size
        operator: In
        values: [large]
  - matchExpressions: # Term 2
      - key: size
        operator: In
        values: [xlarge]
# Node must match Term 1 OR Term 2
```

### Complex Example: (A AND B) OR (C AND D)

```yaml
nodeSelectorTerms:
  - matchExpressions: # Term 1: size=large AND disktype=ssd
      - key: size
        operator: In
        values: [large]
      - key: disktype
        operator: In
        values: [ssd]
  - matchExpressions: # Term 2: size=xlarge AND region=us-east
      - key: size
        operator: In
        values: [xlarge]
      - key: region
        operator: In
        values: [us-east]
# Matches nodes with: (large + ssd) OR (xlarge + us-east)
```

---

## Weight in Preferred Affinity

The `weight` field (1-100) determines the importance of each preference:

```yaml
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 80 # Higher priority
    preference:
      matchExpressions:
        - key: disktype
          operator: In
          values: [ssd]
  - weight: 20 # Lower priority
    preference:
      matchExpressions:
        - key: zone
          operator: In
          values: [us-east-1a]
```

**How Scoring Works:**

1. For each node, start with score = 0
2. For each matching preference, add its weight to the score
3. Scheduler prefers nodes with higher total scores

**Example Calculation:**

- Node A: disktype=ssd, zone=us-east-1a → Score = 80 + 20 = 100
- Node B: disktype=ssd, zone=us-east-1b → Score = 80
- Node C: disktype=hdd, zone=us-east-1a → Score = 20
- Node D: disktype=hdd, zone=us-east-1b → Score = 0

Scheduler tries to place pod on Node A first.

---

## Common Use Cases

### 1. Multi-Region Deployment with Region Preference

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
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
              - key: region
                operator: In
                values:
                  - us-east-1
        - weight: 50
          preference:
            matchExpressions:
              - key: region
                operator: In
                values:
                  - us-west-1
```

### 2. GPU Workload with Fallback

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ml-job
spec:
  containers:
    - name: training
      image: ml-training:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: hardware
                operator: In
                values:
                  - gpu
                  - tpu # Accept either GPU or TPU
```

### 3. Avoid Spot/Preemptible Instances for Critical Apps

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-database
spec:
  containers:
    - name: postgres
      image: postgres:14
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: instance-type
                operator: NotIn
                values:
                  - spot
                  - preemptible
```

### 4. High-Memory Nodes for Data Processing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-analyzer
spec:
  containers:
    - name: analyzer
      image: data-analyzer:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: memory-gb
                operator: Gt
                values:
                  - "64"
```

---

## Combining with Other Scheduling Features

### Node Affinity + Taints & Tolerations

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: special-app
spec:
  containers:
    - name: app
      image: myapp:latest
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "special-workload"
      effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: workload-type
                operator: In
                values:
                  - special
```

**Use Case**: Node has taint to repel general pods + label for affinity matching

---

## Troubleshooting

### Pod Stuck in Pending - Required Affinity Not Satisfied

**Symptom:**

```bash
kubectl get pods
# NAME     READY   STATUS    RESTARTS   AGE
# my-pod   0/1     Pending   0          5m
```

**Check events:**

```bash
kubectl describe pod my-pod
# Events:
#   Warning  FailedScheduling  pod failed to fit in any node
#   0/3 nodes are available: 3 node(s) didn't match Pod's node affinity/selector.
```

**Debug steps:**

1. **Check pod's affinity rules:**

```bash
kubectl get pod my-pod -o yaml | grep -A 20 affinity
```

2. **Check node labels:**

```bash
kubectl get nodes --show-labels
```

3. **Verify matching:**

```bash
# If pod requires size=large
kubectl get nodes -l size=large

# If no nodes returned, add label:
kubectl label nodes node01 size=large
```

### Preferred Affinity Not Working as Expected

**Issue**: Pod scheduled on "wrong" node despite preferences

**Reason**: Preferred affinity is a soft constraint - scheduler considers many factors:

- Resource availability
- Other pods' constraints
- Load balancing

**Solution**: Use `required` affinity if placement is critical

---

## Deployment with Node Affinity

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
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: disktype
                    operator: In
                    values:
                      - ssd
```

**Result**: All 3 replicas will be scheduled only on nodes with `disktype=ssd`

---

## Quick Reference

### Required Affinity Template

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: <label-key>
              operator: <In|NotIn|Exists|DoesNotExist|Gt|Lt>
              values:
                - <value>
```

### Preferred Affinity Template

```yaml
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: <1-100>
        preference:
          matchExpressions:
            - key: <label-key>
              operator: <In|NotIn|Exists|DoesNotExist|Gt|Lt>
              values:
                - <value>
```

---

## CKA Exam Tips

1. **No imperative command** for node affinity - must use YAML
2. **Use `--dry-run=client -o yaml`** to generate base YAML, then add affinity
3. **Remember the structure**: `affinity.nodeAffinity.requiredDuring...` or `preferredDuring...`
4. **Multiple values in `In`** operator = OR logic
5. **Multiple matchExpressions in one term** = AND logic
6. **Multiple nodeSelectorTerms** = OR logic between terms
7. **Weight range**: 1-100 for preferred affinity
8. **Check official docs** during exam for exact syntax - it's nested and easy to mistype
9. **Exists/DoesNotExist** don't need `values` field
10. **Gt/Lt** operators need quotes around numeric values

---

## Additional Resources

- [Official Kubernetes Documentation: Node Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity)
- [Affinity and Anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
- [Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/)
