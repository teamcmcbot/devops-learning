# Horizontal Pod Autoscaler (HPA) - CKA Cheatsheet

## Executive Summary

The **Horizontal Pod Autoscaler (HPA)** automatically scales the number of pod replicas in a Deployment, ReplicaSet, or StatefulSet based on observed metrics (CPU, memory, or custom metrics). It eliminates the need for manual scaling by continuously monitoring resource usage via the **metrics-server**.

**Key Points:**

- Automatically adds/removes pods based on metric thresholds
- Requires **metrics-server** to be installed in the cluster
- Uses `autoscaling/v2` API (stable since K8s 1.23)
- Supports CPU, memory, and custom/external metrics
- Scales between defined `minReplicas` and `maxReplicas`

---

## How HPA Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Metrics Server │────▶│       HPA       │────▶│   Deployment    │
│  (collects CPU/ │     │ (evaluates &    │     │ (adjusts        │
│   memory data)  │     │  decides scale) │     │  replicas)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**Scaling Formula:**

```
desiredReplicas = ceil[currentReplicas × (currentMetricValue / desiredMetricValue)]
```

---

## Real-World Usage Example

**Scenario:** An e-commerce website experiences traffic spikes during flash sales. Instead of manually monitoring and scaling:

- HPA monitors CPU utilization of web server pods
- When CPU > 50%, HPA automatically adds more pods (up to max 10)
- When traffic subsides, HPA scales down to save resources (min 2 pods)

**Benefits:**

- No manual intervention needed during traffic spikes
- Cost-efficient: scales down when demand drops
- Maintains consistent performance under load

---

## Prerequisites

### Metrics Server Must Be Installed

```bash
# Check if metrics-server is running
kubectl get pods -n kube-system | grep metrics-server

# Verify metrics are available
kubectl top nodes
kubectl top pods
```

### Pods Must Have Resource Requests Defined

```yaml
resources:
  requests:
    cpu: "250m" # Required for CPU-based HPA
    memory: "256Mi" # Required for memory-based HPA
  limits:
    cpu: "500m"
    memory: "512Mi"
```

---

## Common Commands

### Imperative Commands

```bash
# Create HPA for a deployment (CPU-based)
kubectl autoscale deployment my-app --min=1 --max=10 --cpu=50%

# View HPA status
kubectl get hpa

# View HPA details
kubectl describe hpa my-app

# Delete HPA
kubectl delete hpa my-app

# Manual scaling (without HPA)
kubectl scale deployment my-app --replicas=3
```

### Monitoring Commands

```bash
# Check current pod resource usage
kubectl top pod

# Watch HPA scaling in real-time
kubectl get hpa -w

# Get HPA in YAML format
kubectl get hpa my-app -o yaml
```

---

## YAML Configurations

### Basic HPA - CPU Based (autoscaling/v2)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### HPA with Multiple Metrics (CPU + Memory)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### Sample Deployment with Resource Requests

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
              cpu: "250m" # HPA uses this for calculations
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

---

## HPA Behavior Configuration

### Control Scale Up/Down Speed

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300 # Wait 5 min before scaling down
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Create an HPA** using imperative command (`kubectl autoscale`)
- **Create an HPA** from YAML manifest
- **Troubleshoot** why HPA shows `<unknown>` for metrics (missing metrics-server or resource requests)
- **Verify** HPA is working and scaling correctly
- **Modify** existing HPA settings (min/max replicas, target utilization)

### Key Things to Remember:

| Item             | Value                                       |
| ---------------- | ------------------------------------------- |
| API Version      | `autoscaling/v2`                            |
| Requires         | metrics-server running                      |
| Pod requirement  | Must have `resources.requests` defined      |
| Default cooldown | 5 minutes for scale-down                    |
| Target reference | `scaleTargetRef` points to Deployment/RS/SS |

### Quick Imperative Command:

```bash
# Most likely exam command format
kubectl autoscale deployment <name> --min=<min> --max=<max> --cpu=<value>%

# Can also specify memory
kubectl autoscale deployment <name> --min=<min> --max=<max> --cpu=50% --memory=70%
```

### Common Troubleshooting:

| Issue                  | Cause                | Solution                           |
| ---------------------- | -------------------- | ---------------------------------- |
| `<unknown>` in TARGETS | No metrics-server    | Install metrics-server             |
| `<unknown>` in TARGETS | No resource requests | Add `requests` to pod spec         |
| Not scaling            | Target not reached   | Check actual vs target utilization |
| Not scaling down       | Stabilization window | Wait for cooldown period           |

### HPA Status Output Explained:

```bash
$ kubectl get hpa
NAME     REFERENCE           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
my-app   Deployment/my-app   45%/50%   1         10        3          5m
#                            ↑    ↑
#                         current target
```

---

## Official Documentation Links

- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [autoscaling/v2 API](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [Resource Management for Pods](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
