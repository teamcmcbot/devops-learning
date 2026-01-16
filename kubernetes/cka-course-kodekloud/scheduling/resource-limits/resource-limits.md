# Resource Requests and Limits in Kubernetes

## Overview

**Resource Requests and Limits** are mechanisms in Kubernetes to control how much CPU and memory (RAM) a container can consume. They help ensure fair resource distribution across pods and prevent any single pod from monopolizing node resources.

**Key Concepts**:

- **Requests**: Minimum guaranteed resources a container needs
- **Limits**: Maximum resources a container can consume
- Applied at the **container level** (not pod level)

---

## Why Resource Management Matters

### The Problem Without Resource Controls

Imagine a 3-node cluster where each node has:

- **4 CPUs**
- **8 GB Memory**

**Scenario 1: No Resource Controls**

- Pod 1 uses 3.5 CPUs and 7 GB memory
- Pod 2 needs 2 CPUs and 2 GB memory
- Pod 2 cannot be scheduled (insufficient resources)
- Node resources are inefficiently utilized

**Scenario 2: With Resource Requests**

- Pod 1 requests 2 CPUs and 4 GB (guaranteed)
- Pod 2 requests 1 CPU and 2 GB (guaranteed)
- Both pods can be scheduled
- Fair resource distribution

---

## Resource Requests

### What Are Resource Requests?

**Resource Requests** define the **minimum** CPU and memory that a container is **guaranteed** to receive. The Kubernetes scheduler uses requests to:

1. Find a node with sufficient available resources
2. Reserve those resources for the pod
3. Ensure the pod gets its requested resources

### Request Syntax

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "1Gi" # Request 1 Gigabyte of memory
          cpu: "1" # Request 1 CPU core
```

### CPU Units

CPU can be specified in different units:

| Value          | Meaning                      |
| -------------- | ---------------------------- |
| `1` or `1000m` | 1 full CPU core              |
| `500m`         | 0.5 CPU core (half a core)   |
| `100m`         | 0.1 CPU core (10% of a core) |
| `0.5`          | 0.5 CPU core                 |

**Note**: "m" stands for "milli" (1/1000). `100m = 0.1 CPU`

**Cloud Equivalents**:

- 1 CPU = 1 AWS vCPU
- 1 CPU = 1 GCP Core
- 1 CPU = 1 Azure vCore

### Memory Units

Memory can be specified in different units:

| Unit | Meaning               | Example |
| ---- | --------------------- | ------- |
| `Ki` | Kibibyte (1024 bytes) | `256Ki` |
| `Mi` | Mebibyte (1024 Ki)    | `128Mi` |
| `Gi` | Gibibyte (1024 Mi)    | `2Gi`   |
| `K`  | Kilobyte (1000 bytes) | `256K`  |
| `M`  | Megabyte (1000 K)     | `128M`  |
| `G`  | Gigabyte (1000 M)     | `2G`    |

**Common Usage**: Use binary units (Ki, Mi, Gi) as they align with how memory is actually measured.

---

## Resource Limits

### What Are Resource Limits?

**Resource Limits** define the **maximum** CPU and memory a container can consume. Limits prevent a container from using excessive resources that could affect other pods on the same node.

### Limit Syntax

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "512Mi"
          cpu: "500m"
        limits:
          memory: "1Gi"
          cpu: "1"
```

### What Happens When Limits Are Exceeded?

#### CPU Limits - Throttling

- Container is **throttled** (slowed down)
- CPU usage is capped at the limit
- Container continues running
- Performance degrades but no crash

#### Memory Limits - Termination

- Container is **terminated** (killed)
- Pod status shows: `OOMKilled` (Out Of Memory)
- Container may be restarted if restart policy allows
- Data loss may occur

**Visual:**

```
CPU Limit Exceeded  → Throttle (slow down)
Memory Limit Exceeded → OOMKilled (terminate)
```

---

## Practical Examples

### Example 1: Basic Pod with Requests and Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
    - name: webapp
      image: nginx
      resources:
        requests:
          memory: "256Mi"
          cpu: "250m" # Guaranteed: 0.25 CPU, 256 MB
        limits:
          memory: "512Mi"
          cpu: "500m" # Max allowed: 0.5 CPU, 512 MB
```

**Behavior**:

- Guaranteed minimum: 250m CPU, 256 Mi memory
- Can burst up to: 500m CPU, 512 Mi memory
- CPU throttled if exceeds 500m
- OOMKilled if exceeds 512 Mi memory

---

### Example 2: High-Performance Database Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-db
spec:
  containers:
    - name: postgres
      image: postgres:14
      resources:
        requests:
          memory: "2Gi"
          cpu: "1"
        limits:
          memory: "4Gi"
          cpu: "2"
```

**Use Case**: Database needs guaranteed resources but can use more during peak loads

---

### Example 3: Deployment with Resources

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
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
```

**Result**: Each of the 3 replicas gets:

- Guaranteed: 100m CPU, 128 Mi memory
- Maximum: 200m CPU, 256 Mi memory

---

### Example 4: Multi-Container Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
spec:
  containers:
    - name: main-app
      image: myapp:latest
      resources:
        requests:
          memory: "512Mi"
          cpu: "500m"
        limits:
          memory: "1Gi"
          cpu: "1"
    - name: logging-sidecar
      image: fluentd
      resources:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "256Mi"
          cpu: "200m"
```

**Total Pod Resources**:

- Requests: 600m CPU, 640 Mi memory
- Limits: 1.2 CPU, 1.28 Gi memory

---

## Default Behaviors and Scenarios

### Scenario 1: No Requests, No Limits (Default)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: unrestricted-pod
spec:
  containers:
    - name: app
      image: nginx
      # No resources specified
```

**Behavior**:

- ✅ Pod can be scheduled on any node (no minimum requirement)
- ⚠️ Can consume ALL available CPU and memory
- ⚠️ May starve other pods
- ⚠️ May impact node stability

**Risk**: High - Can cause resource contention

---

### Scenario 2: Only Limits Specified (No Requests)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: limits-only
spec:
  containers:
    - name: app
      image: nginx
      resources:
        limits:
          memory: "512Mi"
          cpu: "500m"
```

**Behavior**:

- Kubernetes automatically sets **requests = limits**
- Equivalent to:
  ```yaml
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"
  ```
- Pod is guaranteed 512 Mi memory and 500m CPU
- Cannot use more than 512 Mi / 500m

**Use Case**: When you want guaranteed resources equal to maximum

---

### Scenario 3: Only Requests Specified (No Limits)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: requests-only
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "256Mi"
          cpu: "250m"
```

**Behavior**:

- ✅ Guaranteed minimum: 256 Mi memory, 250m CPU
- ✅ Can use MORE if available on node
- ⚠️ No upper bound on resource consumption
- ⚠️ May use all available resources during bursts

**Use Case**: Burstable workloads that need guaranteed minimum but can utilize idle resources

---

### Scenario 4: Both Requests and Limits (Recommended)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: balanced-pod
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "256Mi"
          cpu: "250m"
        limits:
          memory: "512Mi"
          cpu: "500m"
```

**Behavior**:

- ✅ Guaranteed: 256 Mi memory, 250m CPU
- ✅ Can burst up to: 512 Mi memory, 500m CPU
- ✅ Protected from consuming too much
- ✅ Protected from being starved

**Use Case**: Most production workloads - best practice

---

## Quality of Service (QoS) Classes

Kubernetes assigns a QoS class to each pod based on its resource configuration:

### 1. **Guaranteed** (Highest Priority)

**Conditions**:

- Every container has requests AND limits
- Requests = Limits for both CPU and memory

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Characteristics**:

- Highest scheduling priority
- Last to be evicted under resource pressure
- Most stable

---

### 2. **Burstable** (Medium Priority)

**Conditions**:

- At least one container has requests OR limits
- Requests ≠ Limits (or only one is specified)

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Characteristics**:

- Can use more than requested
- Evicted after BestEffort pods
- Good for variable workloads

---

### 3. **BestEffort** (Lowest Priority)

**Conditions**:

- No requests or limits specified for any container

```yaml
# No resources specified
```

**Characteristics**:

- Lowest priority
- First to be evicted under resource pressure
- Can use idle resources
- Risky for production

---

## LimitRange - Namespace-Level Defaults

### What is LimitRange?

**LimitRange** is a policy object that sets default resource values and constraints for pods in a namespace. It ensures all pods have resource specifications even if developers don't specify them.

### CPU LimitRange Example

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
  namespace: dev
spec:
  limits:
    - default: # Default limit (if not specified)
        cpu: "500m"
      defaultRequest: # Default request (if not specified)
        cpu: "250m"
      max: # Maximum allowed limit
        cpu: "2"
      min: # Minimum required request
        cpu: "100m"
      type: Container
```

**Behavior**:

- Pod without CPU resources → Gets 250m request, 500m limit
- Pod requesting 50m CPU → Rejected (below 100m minimum)
- Pod requesting 3 CPU → Rejected (above 2 maximum)

### Memory LimitRange Example

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: memory-resource-constraint
  namespace: dev
spec:
  limits:
    - default:
        memory: "1Gi"
      defaultRequest:
        memory: "512Mi"
      max:
        memory: "2Gi"
      min:
        memory: "256Mi"
      type: Container
```

### Apply LimitRange

```bash
# Create LimitRange
kubectl apply -f limit-range-cpu.yaml
kubectl apply -f limit-range-memory.yaml

# View LimitRanges
kubectl get limitrange -n dev
kubectl describe limitrange cpu-resource-constraint -n dev
```

**Important**: LimitRange only affects pods created AFTER it's applied. Existing pods are not modified.

---

## ResourceQuota - Namespace-Level Caps

### What is ResourceQuota?

**ResourceQuota** limits the **total** resource consumption for ALL pods in a namespace combined. It prevents a namespace from consuming too many cluster resources.

### ResourceQuota Example

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "10" # Total CPU requests across all pods: max 10 cores
    requests.memory: "20Gi" # Total memory requests: max 20 GB
    limits.cpu: "20" # Total CPU limits: max 20 cores
    limits.memory: "40Gi" # Total memory limits: max 40 GB
    pods: "50" # Maximum 50 pods in namespace
```

### Comprehensive ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
  namespace: production
spec:
  hard:
    # Compute resources
    requests.cpu: "50"
    requests.memory: "100Gi"
    limits.cpu: "100"
    limits.memory: "200Gi"

    # Object counts
    pods: "100"
    services: "50"
    persistentvolumeclaims: "20"
    configmaps: "50"
    secrets: "50"
```

### Apply and Check ResourceQuota

```bash
# Create ResourceQuota
kubectl apply -f resource-quota.yaml

# View ResourceQuota
kubectl get resourcequota -n dev
kubectl describe resourcequota compute-quota -n dev

# Output shows:
# Name:            compute-quota
# Namespace:       dev
# Resource         Used   Hard
# --------         ----   ----
# limits.cpu       5      20
# limits.memory    10Gi   40Gi
# requests.cpu     2.5    10
# requests.memory  5Gi    20Gi
```

**Behavior**:

- If creating a new pod would exceed the quota → Pod creation is rejected
- Helps prevent resource exhaustion
- Essential for multi-tenant clusters

---

## Commands Reference

### Check Pod Resources

```bash
# View pod resource requests and limits
kubectl describe pod <pod-name>

# Get resource requests/limits in YAML
kubectl get pod <pod-name> -o yaml | grep -A 10 resources

# Check why pod is pending
kubectl describe pod <pod-name>
# Look for: "Insufficient cpu" or "Insufficient memory"

# View pod QoS class
kubectl get pod <pod-name> -o jsonpath='{.status.qosClass}'
```

### Monitor Resource Usage

```bash
# Check actual resource usage (requires metrics-server)
kubectl top pod <pod-name>
kubectl top pod --all-namespaces
kubectl top pod --sort-by=memory
kubectl top pod --sort-by=cpu

# Check node resource capacity and usage
kubectl top nodes
kubectl describe node <node-name> | grep -A 10 "Allocated resources"
```

### LimitRange and ResourceQuota

```bash
# View LimitRanges
kubectl get limitrange -n <namespace>
kubectl describe limitrange <name> -n <namespace>

# View ResourceQuotas
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <name> -n <namespace>

# Delete LimitRange or ResourceQuota
kubectl delete limitrange <name> -n <namespace>
kubectl delete resourcequota <name> -n <namespace>
```

### Generate Pod YAML with Resources

```bash
# Generate pod YAML (add resources manually)
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Edit pod.yaml to add resources section
vim pod.yaml

# Apply
kubectl apply -f pod.yaml
```

---

## Troubleshooting

### Pod Stuck in Pending - Insufficient Resources

**Symptom:**

```bash
kubectl get pods
# NAME          READY   STATUS    RESTARTS   AGE
# my-app        0/1     Pending   0          5m
```

**Check events:**

```bash
kubectl describe pod my-app

# Events:
#   Type     Reason            Message
#   ----     ------            -------
#   Warning  FailedScheduling  0/3 nodes are available: 3 Insufficient cpu.
```

**Solutions:**

1. **Reduce resource requests:**

   ```yaml
   resources:
     requests:
       cpu: "250m" # Reduced from 2
   ```

2. **Add more nodes to cluster**

3. **Delete unused pods to free resources**

4. **Check node capacity:**
   ```bash
   kubectl describe nodes | grep -A 10 "Allocated resources"
   ```

---

### Pod Terminated - OOMKilled

**Symptom:**

```bash
kubectl get pods
# NAME          READY   STATUS      RESTARTS   AGE
# my-app        0/1     OOMKilled   3          10m
```

**Check:**

```bash
kubectl describe pod my-app
# Last State:  Terminated
#   Reason:    OOMKilled
#   Exit Code: 137
```

**Solutions:**

1. **Increase memory limit:**

   ```yaml
   resources:
     limits:
       memory: "2Gi" # Increased from 1Gi
   ```

2. **Optimize application memory usage**

3. **Check for memory leaks in application**

---

### Pod Creation Rejected - Quota Exceeded

**Symptom:**

```bash
kubectl apply -f pod.yaml
# Error from server (Forbidden): error when creating "pod.yaml":
# pods "my-pod" is forbidden: exceeded quota: compute-quota,
# requested: requests.cpu=2, used: requests.cpu=9, limited: requests.cpu=10
```

**Check quota:**

```bash
kubectl describe resourcequota -n <namespace>
```

**Solutions:**

1. **Reduce pod resource requests**
2. **Delete unused pods**
3. **Increase namespace quota**
4. **Move pods to different namespace**

---

## Best Practices

### 1. Always Specify Requests and Limits

✅ **Do:**

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

❌ **Don't:**

```yaml
# No resources specified - risky!
```

### 2. Set Realistic Values

- **Profile your application** to understand actual resource needs
- **Monitor in non-prod** before setting production values
- **Leave headroom** for bursts (limits > requests)

### 3. Use LimitRange for Namespaces

Enforce minimum standards:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      type: Container
```

### 4. Use ResourceQuota for Multi-Tenancy

Prevent one team from consuming all resources:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
spec:
  hard:
    requests.cpu: "20"
    requests.memory: "40Gi"
```

### 5. Monitor Actual Usage

```bash
# Check if resources match actual usage
kubectl top pods

# Compare with requests/limits
kubectl describe pod <pod-name>
```

### 6. QoS Class Guidelines

| Workload Type      | QoS Class  | Configuration                     |
| ------------------ | ---------- | --------------------------------- |
| Critical services  | Guaranteed | requests = limits                 |
| Variable workloads | Burstable  | requests < limits                 |
| Batch jobs         | BestEffort | No resources (only if acceptable) |

---

## CKA Exam Tips and Scenarios

### What to Expect in CKA Exam

The CKA exam commonly tests resource management in these areas:

#### 1. **Create Pod with Resource Requests and Limits**

**Typical Question:**

> Create a pod named `webapp` using image `nginx` with the following resource specifications:
>
> - CPU request: 250m
> - CPU limit: 500m
> - Memory request: 256Mi
> - Memory limit: 512Mi

**Solution:**

```bash
# Generate base YAML
kubectl run webapp --image=nginx --dry-run=client -o yaml > webapp.yaml

# Edit webapp.yaml
vim webapp.yaml
```

Add resources:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
    - name: webapp
      image: nginx
      resources:
        requests:
          cpu: "250m"
          memory: "256Mi"
        limits:
          cpu: "500m"
          memory: "512Mi"
```

```bash
kubectl apply -f webapp.yaml
kubectl get pod webapp
```

---

#### 2. **Create LimitRange**

**Typical Question:**

> Create a LimitRange in namespace `dev` with:
>
> - Default CPU limit: 500m
> - Default CPU request: 250m
> - Default memory limit: 512Mi
> - Default memory request: 256Mi

**Solution:**

```bash
# Create namespace
kubectl create namespace dev

# Create limitrange.yaml
cat <<EOF > limitrange.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: dev
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
    type: Container
EOF

kubectl apply -f limitrange.yaml
kubectl describe limitrange dev-limits -n dev
```

---

#### 3. **Create ResourceQuota**

**Typical Question:**

> Create a ResourceQuota in namespace `production` that limits:
>
> - Total CPU requests: 10 cores
> - Total memory requests: 20Gi
> - Maximum number of pods: 50

**Solution:**

```bash
# Create quota.yaml
cat <<EOF > quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    pods: "50"
EOF

kubectl apply -f quota.yaml
kubectl describe resourcequota prod-quota -n production
```

---

#### 4. **Troubleshoot Pending Pod**

**Typical Question:**

> A pod named `data-processor` is in Pending state. Identify the issue and fix it.

**Solution:**

```bash
# Check pod status
kubectl get pod data-processor

# Check events
kubectl describe pod data-processor
# Look for: "Insufficient cpu" or "Insufficient memory"

# Check node resources
kubectl describe nodes | grep -A 10 "Allocated resources"

# Solution: Edit pod to reduce resource requests
kubectl delete pod data-processor
kubectl edit pod data-processor  # Reduce requests
# or
kubectl get pod data-processor -o yaml > pod.yaml
vim pod.yaml  # Edit resources
kubectl apply -f pod.yaml
```

---

#### 5. **Identify QoS Class**

**Typical Question:**

> What QoS class will be assigned to this pod?

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          cpu: "250m"
        limits:
          cpu: "500m"
```

**Solution:**

```bash
# Apply and check
kubectl apply -f pod.yaml
kubectl get pod test-pod -o jsonpath='{.status.qosClass}'
# Output: Burstable

# Reason: Has requests and limits, but they're not equal
```

---

### Exam Time-Saving Tips

1. **Use kubectl run with dry-run:**

   ```bash
   kubectl run pod-name --image=nginx --dry-run=client -o yaml > pod.yaml
   ```

2. **Quickly add resources template:**

   ```yaml
   resources:
     requests:
       cpu: "250m"
       memory: "256Mi"
     limits:
       cpu: "500m"
       memory: "512Mi"
   ```

   Copy-paste and modify values

3. **Verify after creation:**

   ```bash
   kubectl describe pod <name> | grep -A 10 "Limits\|Requests"
   ```

4. **Check documentation during exam:**

   - Search for "resource management" in kubernetes.io docs
   - Look for examples to copy syntax

5. **Common pitfalls:**
   - Remember quotes around values: `"250m"` not `250m`
   - Correct indentation (resources under container, not pod)
   - Ensure namespace is specified if not default

---

### Practice Scenarios

#### Scenario 1: Multi-Container Pod

Create a pod with two containers, each with different resource requirements.

#### Scenario 2: Deployment Scaling

Create a deployment with 5 replicas, calculate total resource needs, and ensure cluster can accommodate it.

#### Scenario 3: Namespace Isolation

Set up LimitRange and ResourceQuota for a namespace to enforce resource governance.

#### Scenario 4: OOMKilled Investigation

Debug a pod that's being OOMKilled and adjust resources appropriately.

---

## Additional Resources

- [Official Kubernetes Documentation: Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Configure Default Memory Requests and Limits](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/)
- [Configure Default CPU Requests and Limits](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/cpu-default-namespace/)
- [Configure Minimum and Maximum Memory](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-constraint-namespace/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [LimitRange](https://kubernetes.io/docs/concepts/policy/limit-range/)
