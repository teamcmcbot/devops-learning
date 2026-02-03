# Pod Admission and Scheduling

## Exam Weight
Part of **15% - Workloads and Scheduling**

## What Can Be Tested

- Configure resource requests and limits
- Use node selectors
- Configure node affinity and anti-affinity
- Configure pod affinity and anti-affinity
- Use taints and tolerations
- Understand static pods
- Configure pod priority and preemption
- Use DaemonSets

## Sample Questions

1. **Schedule a pod only on nodes with label `disktype=ssd`**
2. **Configure a pod to avoid nodes where another pod with label `app=db` is running**
3. **Add toleration to pod for node taint `key=value:NoSchedule`**
4. **Set resource requests (CPU: 100m, Memory: 128Mi) and limits (CPU: 200m, Memory: 256Mi)**
5. **Create a DaemonSet to run monitoring agent on all nodes**
6. **Configure pod priority to ensure critical pods are scheduled first**

## Official Documentation

- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Node Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity)
- [Pod Priority and Preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

## Key Concepts

### Scheduling Methods

| Method | Use Case | Strictness |
|--------|----------|------------|
| **nodeSelector** | Simple node selection | Hard requirement |
| **Node Affinity** | Complex node selection rules | Soft or hard |
| **Pod Affinity** | Schedule near specific pods | Soft or hard |
| **Pod Anti-Affinity** | Schedule away from specific pods | Soft or hard |
| **Taints/Tolerations** | Repel pods from nodes (unless tolerated) | Hard requirement |

### Resource Requests vs Limits

| Aspect | Requests | Limits |
|--------|----------|--------|
| **Purpose** | Guaranteed resources | Maximum resources |
| **Scheduling** | Used by scheduler | Not used for scheduling |
| **Behavior** | Pod won't be scheduled if insufficient | Pod throttled (CPU) or killed (memory) if exceeded |
| **Default** | 0 (no minimum) | Unlimited |

## Imperative Commands

```bash
# Node operations
kubectl get nodes --show-labels
kubectl label nodes <node-name> disktype=ssd
kubectl label nodes <node-name> disktype-  # Remove label

# Taints
kubectl taint nodes <node-name> key=value:NoSchedule
kubectl taint nodes <node-name> key=value:NoExecute
kubectl taint nodes <node-name> key-  # Remove taint

# Describe node to see taints and labels
kubectl describe node <node-name>

# Check pod scheduling
kubectl get pods -o wide  # Shows which node
kubectl describe pod <pod-name>  # Shows events

# Resource usage
kubectl top nodes
kubectl top pods

# Set resource limits (for deployment)
kubectl set resources deployment nginx --requests=cpu=100m,memory=128Mi --limits=cpu=200m,memory=256Mi

# Create DaemonSet (must use YAML)
kubectl apply -f daemonset.yaml

# Get DaemonSets
kubectl get daemonsets
kubectl get ds
```

## YAML Examples

### NodeSelector - Simple Node Selection
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-ssd
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
```

### Node Affinity - Required
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-required
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
            - nvme
  containers:
  - name: nginx
    image: nginx
```

### Node Affinity - Preferred (Soft)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-preferred
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - us-west-1
  containers:
  - name: nginx
    image: nginx
```

### Pod Affinity - Schedule Near Other Pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - cache
        topologyKey: kubernetes.io/hostname
  containers:
  - name: webapp
    image: webapp:v1
```

### Pod Anti-Affinity - Schedule Away From Other Pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-anti-affinity
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - webapp
        topologyKey: kubernetes.io/hostname
  containers:
  - name: webapp
    image: webapp:v1
```

### Tolerations - Allow Scheduling on Tainted Nodes
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  - key: "key2"
    operator: "Exists"
    effect: "NoExecute"
  containers:
  - name: nginx
    image: nginx
```

### Resource Requests and Limits
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: app
    image: webapp:v1
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"      # 0.25 CPU
      limits:
        memory: "256Mi"
        cpu: "500m"      # 0.5 CPU
```

### DaemonSet - Run on All Nodes
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      tolerations:
      # Allow on master nodes
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluentd:v1
        resources:
          requests:
            memory: 200Mi
            cpu: 100m
          limits:
            memory: 500Mi
            cpu: 200m
```

### Priority Class
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority for critical pods"
---
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: critical-app:v1
```

### Static Pod (placed in /etc/kubernetes/manifests/)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

## Troubleshooting Tips

### Pod Stuck in Pending - No Nodes Match Selector
```bash
# Check pod events
kubectl describe pod <pod-name>

# Common error: "0/3 nodes are available: 3 node(s) didn't match node selector"

# Check required labels
kubectl get pod <pod-name> -o yaml | grep nodeSelector -A5

# Check which nodes have the label
kubectl get nodes -l disktype=ssd

# Fix: Add label to node
kubectl label nodes <node-name> disktype=ssd

# Or remove nodeSelector from pod
kubectl edit pod <pod-name>  # Usually need to recreate pod
```

### Pod Pending - Insufficient Resources
```bash
# Check events
kubectl describe pod <pod-name>

# Error: "Insufficient cpu" or "Insufficient memory"

# Check resource requests
kubectl describe pod <pod-name> | grep -A5 "Requests:"

# Check node capacity
kubectl describe nodes | grep -A5 "Allocated resources:"

# Solutions:
# 1. Reduce resource requests
# 2. Add more nodes
# 3. Delete other pods to free resources
```

### Pod Not Scheduled - Taint Without Toleration
```bash
# Check events
kubectl describe pod <pod-name>

# Error: "0/3 nodes are available: 3 node(s) had taint"

# Check node taints
kubectl describe nodes | grep Taints

# Add toleration to pod
kubectl edit pod <pod-name>

# Or remove taint from node
kubectl taint nodes <node-name> key:NoSchedule-
```

### Pod Evicted - Resource Limit Exceeded
```bash
# Check pod status
kubectl get pods

# STATUS: "Evicted" or "OOMKilled"

# Check events
kubectl describe pod <pod-name>

# For OOMKilled: Increase memory limit
kubectl set resources deployment <name> --limits=memory=512Mi

# For Evicted: Check node pressure
kubectl describe nodes | grep -i "pressure"
```

### DaemonSet Not Running on All Nodes
```bash
# Check DaemonSet
kubectl get daemonset -o wide

# Check why not on specific node
kubectl describe daemonset <name>

# Common reason: Taints on nodes
kubectl describe node <node-name> | grep Taints

# Add tolerations to DaemonSet
kubectl edit daemonset <name>
```

### Check Why Pod Not Scheduled
```bash
# Detailed events
kubectl describe pod <pod-name>

# Check scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Check node status
kubectl get nodes
kubectl describe node <node-name>
```

## Key Files and Locations

### Scheduler
- **Component**: `kube-scheduler`
- **Pod**: `kubectl get pods -n kube-system | grep scheduler`
- **Config**: `/etc/kubernetes/manifests/kube-scheduler.yaml`
- **Logs**: `kubectl logs -n kube-system kube-scheduler-<node>`

### Static Pod Directory
- **Location**: `/etc/kubernetes/manifests/`
- **Config**: Set in kubelet config (`staticPodPath`)
- **Check**: `ps aux | grep kubelet | grep static`

### Kubelet Config
- **Location**: `/var/lib/kubelet/config.yaml`
- **Static Pod Path**: Look for `staticPodPath` setting

## Exam Tips

1. **nodeSelector is simplest** - use for basic node selection
2. **Affinity more powerful** - multiple operators, soft/hard
3. **Taints repel, tolerations allow** - taint node, tolerate in pod
4. **Resource requests for scheduling** - limits for runtime enforcement
5. **1000m = 1 CPU core** - 100m = 0.1 core
6. **DaemonSets ignore unschedulable** - use tolerations for master nodes
7. **Static pods** managed by kubelet, not API server
8. **Priority higher = scheduled first** - can preempt lower priority
9. **Check `kubectl describe node`** - shows taints, labels, capacity
10. **`requiredDuring...` = hard**, **`preferredDuring...` = soft**

## Common Mistakes

- ❌ Using nodeSelector with operator (use affinity instead)
- ❌ Forgetting to add toleration for tainted nodes
- ❌ Setting limits without requests (requests default to limits)
- ❌ CPU limits too restrictive (causes throttling)
- ❌ Memory limit too low (causes OOMKill)
- ❌ DaemonSet without toleration for control-plane
- ❌ Wrong topologyKey in affinity (must be valid label key)
- ❌ Mixing nodeSelector and nodeAffinity (nodeAffinity overrides)

## Quick Reference

```bash
# Label node
kubectl label nodes node01 disktype=ssd

# Taint node
kubectl taint nodes node01 key=value:NoSchedule

# Create pod with nodeSelector
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
EOF

# Check scheduling
kubectl get pods -o wide
kubectl describe pod test-pod

# Set resources for deployment
kubectl set resources deployment webapp \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi

# Check node capacity
kubectl describe nodes | grep -A7 "Allocated resources:"

# Remove taint
kubectl taint nodes node01 key:NoSchedule-
```

## Affinity Operators

| Operator | Meaning |
|----------|---------|
| `In` | Label value in list |
| `NotIn` | Label value not in list |
| `Exists` | Label key exists (any value) |
| `DoesNotExist` | Label key doesn't exist |
| `Gt` | Greater than (numeric) |
| `Lt` | Less than (numeric) |

## Taint Effects

| Effect | Behavior |
|--------|----------|
| `NoSchedule` | New pods not scheduled (existing remain) |
| `PreferNoSchedule` | Try to avoid scheduling (soft) |
| `NoExecute` | New pods not scheduled, existing evicted |

## Resource Units

### CPU
- `1` or `1000m` = 1 CPU core
- `100m` = 0.1 core (10%)
- `500m` = 0.5 core (50%)

### Memory
- `128Mi` = 128 Mebibytes
- `1Gi` = 1 Gibibyte
- `1024Mi` = 1Gi
