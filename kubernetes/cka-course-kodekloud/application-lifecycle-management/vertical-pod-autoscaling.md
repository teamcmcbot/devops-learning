# Vertical Pod Autoscaler (VPA) - CKA Cheatsheet

## Executive Summary

The **Vertical Pod Autoscaler (VPA)** automatically adjusts CPU and memory **requests/limits** for pods based on actual usage. Unlike HPA (which adds more pods), VPA optimizes resource allocation for individual pods by analyzing metrics and recommending or applying changes.

**Key Points:**

- Adjusts resources **per pod** (not pod count)
- Requires separate installation (not built into K8s by default)
- Three components: **Recommender**, **Updater**, **Admission Controller**
- May cause pod restarts when updating resources (unless in-place resize is enabled)
- API: `autoscaling.k8s.io/v1`

---

## VPA vs HPA Comparison

| Aspect         | VPA (Vertical)                     | HPA (Horizontal)             |
| -------------- | ---------------------------------- | ---------------------------- |
| What it scales | CPU/memory per pod                 | Number of pods               |
| Pod restarts   | Yes (recreates pods)               | No                           |
| Best for       | Stateful apps, databases, JVM apps | Stateless apps, web services |
| Traffic spikes | Less effective (restart delay)     | Ideal (instant pod addition) |
| Focus          | Right-sizing resources             | Distributing load            |

---

## Real-World Usage Example

**Scenario:** A Java application initially configured with 256Mi memory keeps getting OOMKilled. Instead of manually adjusting memory:

- VPA monitors actual memory usage over time
- Recommends increasing memory to 512Mi based on usage patterns
- Automatically recreates pod with optimized resources

**Benefits:**

- No manual monitoring/adjustment needed
- Prevents over-provisioning (cost savings)
- Prevents under-provisioning (OOM crashes)

---

## VPA Components

```
┌─────────────────────────────────────────────────────────────┐
│                         VPA System                          │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Recommender   │     Updater     │   Admission Controller  │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Monitors metrics│ Evicts pods with│ Mutates new pod specs   │
│ Analyzes usage  │ outdated specs  │ with recommendations    │
│ Generates recs  │ Triggers update │ on pod creation         │
└─────────────────┴─────────────────┴─────────────────────────┘
```

---

## Installation

### Install VPA from GitHub

```bash
# Apply VPA components
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml

# Verify installation
kubectl get pods -n kube-system | grep vpa
```

### Expected Components

```bash
$ kubectl get pods -n kube-system | grep vpa
vpa-admission-controller-xxxx   1/1   Running
vpa-recommender-xxxx            1/1   Running
vpa-updater-xxxx                1/1   Running
```

---

## Common Commands

```bash
# List all VPA resources
kubectl get vpa

# Describe VPA (see recommendations)
kubectl describe vpa <vpa-name>

# Get VPA in YAML format
kubectl get vpa <vpa-name> -o yaml

# Delete VPA
kubectl delete vpa <vpa-name>

# Check pod resource usage
kubectl top pod

# View VPA recommendations
kubectl describe vpa <vpa-name> | grep -A 10 Recommendation
```

---

## YAML Configurations

### Basic VPA - Auto Mode

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Auto" # Automatically apply recommendations
```

### VPA with Resource Policies (Min/Max Limits)

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
      - containerName: "my-app"
        minAllowed:
          cpu: "250m"
          memory: "256Mi"
        maxAllowed:
          cpu: "2"
          memory: "2Gi"
        controlledResources: ["cpu", "memory"]
```

### VPA - Recommendation Only (Off Mode)

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Off" # Only provide recommendations, don't apply
```

---

## Update Modes

| Mode       | Behavior                                                                 |
| ---------- | ------------------------------------------------------------------------ |
| `Off`      | VPA only provides recommendations; no automatic updates                  |
| `Initial`  | Applies recommendations only at pod creation; no updates to running pods |
| `Recreate` | Evicts and recreates pods when recommendations differ significantly      |
| `Auto`     | Currently same as `Recreate`; will use in-place updates when available   |

---

## VPA Status & Recommendations

### Check Recommendations

```bash
$ kubectl describe vpa my-app-vpa
```

### Sample Output

```yaml
Status:
  Recommendation:
    Container Recommendations:
      - containerName: my-app
        lowerBound:
          cpu: "100m"
          memory: "128Mi"
        target: # Recommended values
          cpu: "500m"
          memory: "512Mi"
        upperBound:
          cpu: "1"
          memory: "1Gi"
        uncappedTarget: # Without min/max constraints
          cpu: "600m"
          memory: "600Mi"
```

| Field            | Meaning                                   |
| ---------------- | ----------------------------------------- |
| `target`         | Recommended resource values               |
| `lowerBound`     | Minimum recommended (won't go below)      |
| `upperBound`     | Maximum recommended (won't go above)      |
| `uncappedTarget` | Recommendation without policy constraints |

---

## Sample Deployment for VPA

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: nginx
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Create a VPA** resource for a deployment
- **Configure update modes** (`Auto`, `Off`, `Initial`)
- **Set resource policies** (min/max allowed)
- **Read recommendations** from VPA status
- **Understand VPA vs HPA** differences

### Key Things to Remember:

| Item         | Value                                   |
| ------------ | --------------------------------------- |
| API Version  | `autoscaling.k8s.io/v1`                 |
| Kind         | `VerticalPodAutoscaler`                 |
| Target field | `spec.targetRef` (points to Deployment) |
| Update modes | `Off`, `Initial`, `Recreate`, `Auto`    |
| Requires     | VPA components installed separately     |

### Quick YAML Template:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: <name>
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: <deployment-name>
  updatePolicy:
    updateMode: "Auto"
```

### Common Exam Mistakes:

- Forgetting VPA must be **installed separately** (not built-in like HPA)
- Using wrong API group (`autoscaling.k8s.io` not `autoscaling`)
- Confusing `updateMode` values
- Not understanding that VPA **restarts pods** (unlike in-place resize)

### VPA vs HPA Quick Decision:

- Need more pods? → **HPA**
- Need bigger pods? → **VPA**
- Stateless web app? → **HPA**
- Database/stateful? → **VPA** (with caution)

---

## Official Documentation Links

- [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- [VPA Installation](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#installation)
- [Resource Management for Pods](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (for comparison)
- [Autoscaling in Kubernetes](https://kubernetes.io/docs/concepts/workloads/autoscaling/)
