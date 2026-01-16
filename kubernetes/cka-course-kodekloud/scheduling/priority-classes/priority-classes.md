# Priority Classes in Kubernetes

## Overview

**Priority Classes** enable you to assign priority levels to Pods, ensuring that critical workloads are scheduled before less important ones. This is crucial in resource-constrained environments where the scheduler must make decisions about which Pods get scheduled first and which Pods can be preempted (evicted) to make room for higher-priority workloads.

**Key Concepts**:

- Assign **numerical priority values** to Pods
- Higher value = **higher priority**
- Control **scheduling order** and **preemption** behavior
- Protect **critical system components** and applications

---

## Why Priority Classes?

### The Problem

In a typical Kubernetes cluster, you run workloads with varying importance:

- **Control plane components**: Critical for cluster operation (highest priority)
- **Production databases**: Business-critical data (high priority)
- **Production applications**: Customer-facing services (high priority)
- **Development workloads**: Testing and development (medium priority)
- **Batch jobs**: Background processing (low priority)

**Without priority classes:**

- All Pods are treated equally
- Batch jobs might consume resources needed by critical applications
- No guaranteed scheduling order for important workloads
- Critical Pods might wait while less important ones run

### The Solution: Priority Classes

Priority classes solve these issues by:

1. **Ensuring critical Pods are scheduled first**
2. **Enabling preemption** of low-priority Pods when resources are scarce
3. **Protecting system components** with reserved priority ranges
4. **Providing control** over scheduling behavior

---

## How Priority Classes Work

### The Scheduling Process

```
┌─────────────────────────────────────────────────────────┐
│           Scheduling Queue                              │
│                                                         │
│  ┌──────────────────┐   Priority: 10000000            │
│  │ Critical App Pod │   Status: Pending               │
│  └──────────────────┘   ▲ Scheduled FIRST             │
│                                                         │
│  ┌──────────────────┐   Priority: 1000                 │
│  │ Prod Database    │   Status: Pending               │
│  └──────────────────┘   ▲ Scheduled SECOND            │
│                                                         │
│  ┌──────────────────┐   Priority: 100                  │
│  │ Dev App Pod      │   Status: Pending               │
│  └──────────────────┘   ▲ Scheduled THIRD             │
│                                                         │
│  ┌──────────────────┐   Priority: 0 (default)          │
│  │ Batch Job Pod    │   Status: Pending               │
│  └──────────────────┘   ▲ Scheduled LAST              │
│                                                         │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │   Kubernetes          │
            │   Scheduler           │
            │                       │
            │ 1. Sort by priority   │
            │ 2. Find suitable node │
            │ 3. Bind pod to node   │
            └───────────────────────┘
```

### Priority Ranges

| Priority Range                  | Reserved For      | Examples                             |
| ------------------------------- | ----------------- | ------------------------------------ |
| **2,000,000,000 to 2 billion**  | System components | kube-apiserver, etcd, coredns        |
| **-2 billion to 1,000,000,000** | User applications | Databases, critical apps, batch jobs |
| **0**                           | Default priority  | Pods without priorityClassName       |

**Built-in Priority Classes:**

- `system-cluster-critical`: Priority 2,000,000,000
- `system-node-critical`: Priority 2,000,010,000

---

## Creating Priority Classes

### Basic Priority Class

```yaml
# priority-class-high.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
description: "Priority class for critical production applications"
```

**Apply the priority class:**

```bash
kubectl apply -f priority-class-high.yaml

# Verify creation
kubectl get priorityclass high-priority
```

---

### Priority Class with Global Default

Only **one** priority class can be marked as the global default:

```yaml
# priority-class-default.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: medium-priority
value: 100
globalDefault: true
description: "Default priority for all pods without explicit priorityClassName"
```

**Behavior:**

- Pods without `priorityClassName` get this priority (100)
- Replaces the default priority of 0
- Only one priority class can have `globalDefault: true`

---

### Priority Class with Preemption Policy

Control whether higher-priority Pods can evict lower-priority ones:

```yaml
# priority-class-preempt.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-priority
value: 10000000
preemptionPolicy: PreemptLowerPriority # Default: allows preemption
description: "Critical apps that can preempt lower priority pods"
```

```yaml
# priority-class-no-preempt.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: important-no-preempt
value: 5000000
preemptionPolicy: Never # Won't preempt, will wait in queue
description: "Important apps that wait rather than preempt"
```

**Preemption Policies:**

- `PreemptLowerPriority` (default): Can evict lower-priority Pods
- `Never`: Waits in queue, doesn't evict any Pods

---

## Using Priority Classes in Pods

### Assigning Priority to a Pod

```yaml
# pod-with-priority.yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-app
  labels:
    app: critical
spec:
  priorityClassName: high-priority # Reference the priority class
  containers:
    - name: app
      image: nginx
      ports:
        - containerPort: 80
```

**Apply and verify:**

```bash
kubectl apply -f pod-with-priority.yaml

# Check pod priority
kubectl get pod critical-app -o yaml | grep priority
# Output shows:
# priority: 1000000
# priorityClassName: high-priority
```

---

### Using Priority in Deployments

```yaml
# deployment-with-priority.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prod
  template:
    metadata:
      labels:
        app: prod
    spec:
      priorityClassName: high-priority # All pods get this priority
      containers:
        - name: app
          image: nginx
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
```

---

## Pod Priority and Preemption

### Scenario 1: Scheduling with Available Resources

**Initial State:**

- 3 nodes with sufficient resources
- Pending Pods: Critical App (priority 7), Job (priority 5)

```
Resources Available: ✅

┌─────────────────┐
│ Critical App    │  Priority: 7
│ Status: Pending │  → Scheduled FIRST ✅
└─────────────────┘

┌─────────────────┐
│ Batch Job       │  Priority: 5
│ Status: Pending │  → Scheduled SECOND ✅
└─────────────────┘

Result: Both scheduled, no preemption needed
```

---

### Scenario 2: Preemption When Resources Are Scarce

**Initial State:**

- Cluster is at capacity
- Running: Batch Job (priority 5)
- Pending: New Critical App (priority 7)

**With preemptionPolicy: PreemptLowerPriority**

```
Before Preemption:
┌────────────┐  ┌────────────┐  ┌────────────┐
│   Node 1   │  │   Node 2   │  │   Node 3   │
│            │  │            │  │            │
│ Batch Job  │  │ Batch Job  │  │ Batch Job  │
│ Priority:5 │  │ Priority:5 │  │ Priority:5 │
│ Running ✅  │  │ Running ✅  │  │ Running ✅  │
└────────────┘  └────────────┘  └────────────┘

New Pod Arrives:
┌──────────────────┐
│ Critical App     │  Priority: 7
│ Status: Pending  │  Needs resources!
└──────────────────┘

After Preemption:
┌────────────┐  ┌────────────┐  ┌────────────┐
│   Node 1   │  │   Node 2   │  │   Node 3   │
│            │  │            │  │            │
│Critical App│  │ Batch Job  │  │ Batch Job  │
│ Priority:7 │  │ Priority:5 │  │ Priority:5 │
│ Running ✅  │  │ Running ✅  │  │ Running ✅  │
└────────────┘  └────────────┘  └────────────┘

┌──────────────────┐
│ Batch Job        │  Priority: 5
│ Status: Pending  │  Evicted! ❌
└──────────────────┘
```

**With preemptionPolicy: Never**

```
┌──────────────────┐
│ Critical App     │  Priority: 7
│ Status: Pending  │  Waits in queue, no preemption
└──────────────────┘

No pods evicted, waits for resources to become available
```

---

## Practical Examples

### Example 1: Three-Tier Priority System

Create priority classes for different workload types:

```yaml
# critical-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical
value: 10000000
preemptionPolicy: PreemptLowerPriority
description: "Mission-critical production applications"
---
# high-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high
value: 1000000
preemptionPolicy: PreemptLowerPriority
description: "Important production workloads"
---
# low-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low
value: 100
preemptionPolicy: Never
description: "Batch jobs and non-critical workloads"
```

**Apply all:**

```bash
kubectl apply -f critical-priority.yaml
kubectl apply -f high-priority.yaml
kubectl apply -f low-priority.yaml

kubectl get priorityclass
# NAME                      VALUE        GLOBAL-DEFAULT   AGE
# critical                  10000000     false            10s
# high                      1000000      false            10s
# low                       100          false            10s
# system-cluster-critical   2000000000   false            30d
# system-node-critical      2000010000   false            30d
```

---

### Example 2: Production Database with High Priority

```yaml
# postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-db
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      priorityClassName: critical # High priority
      containers:
        - name: postgres
          image: postgres:14
          env:
            - name: POSTGRES_PASSWORD
              value: secretpassword
          resources:
            requests:
              cpu: 500m
              memory: 1Gi
            limits:
              cpu: 1000m
              memory: 2Gi
```

---

### Example 3: Batch Job with Low Priority

```yaml
# batch-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing
spec:
  template:
    metadata:
      labels:
        app: batch
    spec:
      priorityClassName: low # Low priority, can be preempted
      containers:
        - name: processor
          image: busybox
          command: ["sh", "-c", "echo Processing data... && sleep 3600"]
      restartPolicy: Never
```

---

### Example 4: Development Namespace with Default Priority

```yaml
# dev-default-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: dev-priority
value: 50
globalDefault: false # Not global, but set in namespace
description: "Default priority for development workloads"
```

**Use in all dev pods:**

```yaml
# dev-app.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dev-app
  namespace: development
spec:
  priorityClassName: dev-priority
  containers:
    - name: app
      image: nginx
```

---

### Example 5: Mixed Priority Workloads

```yaml
# microservices.yaml
---
# API Gateway (Critical)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gateway
  template:
    metadata:
      labels:
        app: gateway
    spec:
      priorityClassName: critical
      containers:
        - name: gateway
          image: nginx
---
# Backend Service (High)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      priorityClassName: high
      containers:
        - name: backend
          image: myapp:latest
---
# Logging Agent (Low)
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logging-agent
spec:
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      priorityClassName: low
      containers:
        - name: fluentd
          image: fluentd
```

---

## Viewing and Managing Priority Classes

### List Priority Classes

```bash
# List all priority classes
kubectl get priorityclass

# Output:
# NAME                      VALUE        GLOBAL-DEFAULT   AGE
# system-cluster-critical   2000000000   false            30d
# system-node-critical      2000010000   false            30d
# high-priority             1000000      false            5m
# low-priority              100          false            5m

# Get priority class details
kubectl describe priorityclass high-priority

# Output:
# Name:              high-priority
# Value:             1000000
# GlobalDefault:     false
# PreemptionPolicy:  PreemptLowerPriority
# Description:       Priority class for critical production applications
```

---

### Check Pod Priority

```bash
# Get pod priority value
kubectl get pod critical-app -o jsonpath='{.spec.priority}'
# Output: 1000000

# Get priority class name
kubectl get pod critical-app -o jsonpath='{.spec.priorityClassName}'
# Output: high-priority

# View full priority details
kubectl get pod critical-app -o yaml | grep -A 5 priority
```

---

### Find Pods by Priority Class

```bash
# List all pods with specific priority class
kubectl get pods -A -o json | jq -r '.items[] | select(.spec.priorityClassName=="high-priority") | .metadata.name'

# Count pods per priority class
kubectl get pods -A -o json | jq -r '.items[].spec.priorityClassName' | sort | uniq -c

# Output:
#   45 high-priority
#   12 low-priority
#   3 system-cluster-critical
```

---

### Delete Priority Class

```bash
# Delete priority class (only if no pods are using it)
kubectl delete priorityclass low-priority

# Force delete (dangerous!)
kubectl delete priorityclass low-priority --force
```

---

## Preemption Behavior Details

### Preemption Process

When a high-priority Pod can't be scheduled:

1. **Scheduler identifies lower-priority Pods** that can be preempted
2. **Grace period** starts (default: 30 seconds)
3. **PreStop hooks** execute (if defined)
4. **SIGTERM** sent to containers
5. **Containers terminate gracefully**
6. **Resources freed**, high-priority Pod scheduled

```yaml
# Pod with graceful termination
apiVersion: v1
kind: Pod
metadata:
  name: graceful-app
spec:
  priorityClassName: low
  terminationGracePeriodSeconds: 60 # 60 seconds to shut down
  containers:
    - name: app
      image: myapp
      lifecycle:
        preStop:
          exec:
            command: ["/bin/sh", "-c", "sleep 10"] # Cleanup tasks
```

---

### Preemption Victims Selection

**Scheduler selects victims based on:**

1. **Priority**: Lower priority Pods first
2. **PriorityClass value**: Lowest values evicted first
3. **Resource usage**: Pods using more resources than requested
4. **Pod age**: Newer Pods preferred for eviction (less disruption)

**Example Scenario:**

```
High-priority Pod needs 2GB memory

Available Pods (all priority 100):
- Pod A: Using 1.5GB (requested 1GB)     ← Selected (over request)
- Pod B: Using 0.8GB (requested 1GB)
- Pod C: Using 1GB (requested 1GB)

Pod A evicted because it's using more than requested
```

---

## Troubleshooting

### Pod Stuck in Pending Due to Priority

**Problem:**

```bash
kubectl get pods
# NAME          READY   STATUS    RESTARTS   AGE
# my-app        0/1     Pending   0          5m
```

**Check 1: Verify priority class exists**

```bash
kubectl get pod my-app -o jsonpath='{.spec.priorityClassName}'
# Output: high-priority

kubectl get priorityclass high-priority
# Error: priorityclasses.scheduling.k8s.io "high-priority" not found
```

**Solution:** Create the missing priority class

```bash
kubectl apply -f priority-class.yaml
```

---

### Pod Not Preempting Lower-Priority Pods

**Problem:** High-priority Pod remains Pending despite lower-priority Pods running

**Check 1: Verify preemption policy**

```bash
kubectl get priorityclass critical -o yaml | grep preemptionPolicy
# Output: preemptionPolicy: Never  ← Won't preempt!
```

**Solution:** Change to `PreemptLowerPriority` if preemption is needed

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical
value: 10000000
preemptionPolicy: PreemptLowerPriority # Enable preemption
description: "Critical apps that can preempt"
```

**Check 2: Verify priority difference**

```bash
# High-priority pod
kubectl get pod pending-pod -o jsonpath='{.spec.priority}'
# Output: 1000

# Running pod
kubectl get pod running-pod -o jsonpath='{.spec.priority}'
# Output: 900

# Difference is only 100 - might not be enough for preemption
```

---

### Pods Evicted Unexpectedly

**Problem:** Pods keep getting evicted

**Check events:**

```bash
kubectl get events --sort-by='.lastTimestamp' | grep Preempted

# Output:
# 5m    Normal    Preempted    pod/batch-job-xyz    Preempted by higher priority pod
```

**Solution 1: Increase priority**

```yaml
spec:
  priorityClassName: high # Instead of low
```

**Solution 2: Use preemptionPolicy: Never**

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: protected-priority
value: 500
preemptionPolicy: Never # Won't be preempted
```

---

### Global Default Priority Not Applied

**Problem:** Pods still get priority 0 despite global default

**Check:**

```bash
kubectl get priorityclass
# Multiple priority classes with globalDefault: true

# Only one should have globalDefault: true
```

**Solution:** Remove `globalDefault: true` from all except one

```bash
kubectl edit priorityclass medium-priority
# Set globalDefault: false

kubectl edit priorityclass standard-priority
# Keep globalDefault: true
```

---

## Commands Reference

### Priority Class Management

```bash
# Create priority class
kubectl apply -f priority-class.yaml

# List priority classes
kubectl get priorityclass
kubectl get pc  # Short form

# Describe priority class
kubectl describe priorityclass high-priority

# Get priority class YAML
kubectl get priorityclass high-priority -o yaml

# Delete priority class
kubectl delete priorityclass low-priority

# Edit priority class
kubectl edit priorityclass medium-priority
```

---

### Pod Priority Operations

```bash
# Create pod with priority
kubectl run critical-pod --image=nginx --dry-run=client -o yaml > pod.yaml
# Edit pod.yaml to add priorityClassName
kubectl apply -f pod.yaml

# Check pod priority
kubectl get pod my-pod -o jsonpath='{.spec.priority}'
kubectl get pod my-pod -o jsonpath='{.spec.priorityClassName}'

# List pods sorted by priority
kubectl get pods -A -o json | jq -r '.items | sort_by(.spec.priority) | reverse | .[] | "\(.spec.priority) \(.metadata.namespace) \(.metadata.name)"'

# Find pods using specific priority class
kubectl get pods -A --field-selector spec.priorityClassName=high-priority

# View pod events (check for preemption)
kubectl describe pod my-pod | grep -A 10 Events
```

---

### Troubleshooting Commands

```bash
# Check preemption events
kubectl get events -A --field-selector reason=Preempted

# View scheduler logs
kubectl logs -n kube-system kube-scheduler-master

# Check pod priority in detail
kubectl get pod my-pod -o yaml | grep -A 5 priority

# List all priority classes with details
kubectl get priorityclass -o custom-columns=NAME:.metadata.name,VALUE:.value,GLOBAL:.globalDefault,PREEMPTION:.preemptionPolicy
```

---

## CKA Exam Tips and Scenarios

### What to Expect in CKA Exam

Priority classes appear in these types of questions:

---

#### Scenario 1: **Create Priority Class**

**Typical Question:**

> Create a priority class named `critical-apps` with a value of `10000000` and description "For critical production applications".

**Solution:**

```bash
# Method 1: Using YAML
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-apps
value: 10000000
description: "For critical production applications"
EOF

# Method 2: Create file first
cat <<EOF > priority-class.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-apps
value: 10000000
description: "For critical production applications"
EOF

kubectl apply -f priority-class.yaml

# Verify
kubectl get priorityclass critical-apps
kubectl describe priorityclass critical-apps
```

---

#### Scenario 2: **Assign Priority to Existing Pod**

**Typical Question:**

> Update the pod `nginx-pod` to use priority class `high-priority`.

**Solution:**

```bash
# Option 1: Export, edit, delete, recreate
kubectl get pod nginx-pod -o yaml > nginx-pod.yaml

# Edit the file to add:
# spec:
#   priorityClassName: high-priority

kubectl delete pod nginx-pod
kubectl apply -f nginx-pod.yaml

# Option 2: Use kubectl replace --force
kubectl get pod nginx-pod -o yaml | \
  sed 's/spec:/spec:\n  priorityClassName: high-priority/' | \
  kubectl replace --force -f -

# Verify
kubectl get pod nginx-pod -o jsonpath='{.spec.priorityClassName}'
```

**Important:** Pods are immutable - can't edit priorityClassName directly!

---

#### Scenario 3: **Create Deployment with Priority**

**Typical Question:**

> Create a deployment named `web-app` with 3 replicas using image `nginx` and priority class `high-priority`.

**Solution:**

```bash
# Generate deployment YAML
kubectl create deployment web-app --image=nginx --replicas=3 --dry-run=client -o yaml > deployment.yaml

# Edit to add priorityClassName under spec.template.spec
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      priorityClassName: high-priority
      containers:
      - name: nginx
        image: nginx
EOF

kubectl apply -f deployment.yaml

# Verify all pods have the priority
kubectl get pods -l app=web-app -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.priorityClassName}{"\n"}{end}'
```

---

#### Scenario 4: **Set Global Default Priority**

**Typical Question:**

> Create a priority class named `standard` with value `500` and set it as the global default.

**Solution:**

```bash
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: standard
value: 500
globalDefault: true
description: "Default priority for all pods"
EOF

# Verify
kubectl get priorityclass standard -o yaml | grep globalDefault
# Output: globalDefault: true

# Test: Create pod without priority class
kubectl run test-pod --image=nginx

# Check if it got the default priority
kubectl get pod test-pod -o jsonpath='{.spec.priority}'
# Output: 500
```

**Important:** Only ONE priority class can have `globalDefault: true`!

---

#### Scenario 5: **Identify Pods with Specific Priority**

**Typical Question:**

> List all pods in the cluster that are using priority class `critical-apps`.

**Solution:**

```bash
# Method 1: Using grep
kubectl get pods -A -o yaml | grep -B 5 "priorityClassName: critical-apps"

# Method 2: Using jsonpath
kubectl get pods -A -o jsonpath='{range .items[?(@.spec.priorityClassName=="critical-apps")]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}'

# Method 3: Using jq
kubectl get pods -A -o json | jq -r '.items[] | select(.spec.priorityClassName=="critical-apps") | "\(.metadata.namespace)\t\(.metadata.name)"'

# Method 4: Simple output with custom columns
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,PRIORITY-CLASS:.spec.priorityClassName | grep critical-apps
```

---

#### Scenario 6: **Troubleshoot Pod Not Scheduling**

**Typical Question:**

> A pod named `app-pod` is stuck in Pending state. The pod uses priority class `high-priority`. Identify and fix the issue.

**Solution:**

```bash
# Step 1: Check pod status
kubectl describe pod app-pod

# Look for events like:
# Warning  FailedScheduling  priorityclass.scheduling.k8s.io "high-priority" not found

# Step 2: Verify priority class exists
kubectl get priorityclass high-priority
# If not found, that's the issue!

# Step 3: Check if priority class is referenced correctly
kubectl get pod app-pod -o yaml | grep priorityClassName

# Step 4: Create missing priority class
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
description: "High priority applications"
EOF

# Step 5: Verify pod now schedules
kubectl get pod app-pod
# Should show Running status
```

---

#### Scenario 7: **Configure Preemption Policy**

**Typical Question:**

> Create a priority class `important-no-preempt` with value `5000000` that will NOT preempt lower-priority pods.

**Solution:**

```bash
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: important-no-preempt
value: 5000000
preemptionPolicy: Never
description: "Important apps that wait rather than preempt"
EOF

# Verify
kubectl get priorityclass important-no-preempt -o yaml | grep preemptionPolicy
# Output: preemptionPolicy: Never
```

---

### Exam Time-Saving Tips

1. **Know the Priority Class structure**:

   ```yaml
   apiVersion: scheduling.k8s.io/v1
   kind: PriorityClass
   metadata:
     name: <name>
   value: <number>
   globalDefault: <true/false>
   preemptionPolicy: <PreemptLowerPriority/Never>
   description: "<description>"
   ```

2. **Quick priority class creation**:

   ```bash
   cat <<EOF | kubectl apply -f -
   apiVersion: scheduling.k8s.io/v1
   kind: PriorityClass
   metadata:
     name: my-priority
   value: 1000
   description: "My priority class"
   EOF
   ```

3. **Remember common values**:

   - System critical: 2,000,000,000
   - User apps: -2 billion to 1 billion
   - Default: 0

4. **Can't edit pod priority**: Must delete and recreate

5. **Add priority to deployment template**:

   ```yaml
   spec:
     template:
       spec:
         priorityClassName: high-priority # Here!
   ```

6. **Check priority quickly**:

   ```bash
   kubectl get pod <name> -o jsonpath='{.spec.priority}'
   ```

7. **Only one global default** allowed

8. **Built-in priority classes**:
   - `system-cluster-critical`
   - `system-node-critical`

---

### Practice Scenarios

Complete these to prepare for the exam:

1. ✅ Create three priority classes: critical (10M), high (1M), low (100)
2. ✅ Deploy a pod with high priority
3. ✅ Create a deployment where all pods use critical priority
4. ✅ Set a global default priority class
5. ✅ List all pods using a specific priority class
6. ✅ Create priority class with `preemptionPolicy: Never`
7. ✅ Troubleshoot pod stuck pending due to missing priority class
8. ✅ Update existing deployment to use different priority
9. ✅ Identify which pods have the highest priority in the cluster
10. ✅ Explain why a pod was preempted (check events)

---

## Best Practices

### 1. Use Meaningful Priority Values

```yaml
# ✅ Good: Clear separation between tiers
critical: 10,000,000
high: 1,000,000
medium: 100,000
low: 1,000
```

```yaml
# ❌ Bad: Confusing, hard to manage
priority1: 123456
priority2: 123457
priority3: 123458
```

---

### 2. Reserve High Values for Critical Systems

```yaml
# ✅ Good: Reserve top values for system components
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: production-critical
value: 10000000 # Well below system range (2 billion)
```

---

### 3. Document Priority Classes

```yaml
# ✅ Good: Clear descriptions
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: production-db
value: 5000000
description: "Production databases - can preempt batch jobs and dev workloads"
preemptionPolicy: PreemptLowerPriority
```

---

### 4. Use Preemption Carefully

```yaml
# For critical apps that can afford to wait
preemptionPolicy: Never

# For truly critical apps that need immediate scheduling
preemptionPolicy: PreemptLowerPriority
```

---

### 5. Set Global Default Thoughtfully

```yaml
# Set a reasonable default so most apps don't need explicit priority
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: standard
value: 1000
globalDefault: true
description: "Standard priority for applications"
```

---

### 6. Combine with Resource Requests/Limits

```yaml
# Priority + resources = better scheduling
spec:
  priorityClassName: high-priority
  containers:
    - name: app
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 200m
          memory: 256Mi
```

---

### 7. Test Preemption Behavior

```bash
# In dev/staging, test what happens when high-priority pods arrive
# Ensure lower-priority pods handle eviction gracefully
```

---

## Additional Resources

- [Kubernetes Documentation: Pod Priority and Preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)
- [PriorityClass API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/priority-class-v1/)
- [Scheduler Configuration](https://kubernetes.io/docs/reference/scheduling/config/)
- [Pod Lifecycle: Termination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)
