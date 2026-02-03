# Workload Autoscaling

## Exam Weight
Part of **15% - Workloads and Scheduling**

## What Can Be Tested

- Create Horizontal Pod Autoscaler (HPA)
- Configure HPA with CPU and memory metrics
- Troubleshoot HPA not scaling
- Understand metrics-server requirements
- Configure custom metrics for HPA
- Set min/max replicas
- Understand scaling behavior and policies

## Sample Questions

1. **Create an HPA for a deployment to scale between 2-10 replicas based on 70% CPU**
2. **Troubleshoot why HPA shows `<unknown>` for metrics**
3. **Create HPA using memory utilization**
4. **Verify metrics-server is running and functional**
5. **Check current resource utilization of pods**

## Official Documentation

- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)

## Key Concepts

### HPA Overview

**Horizontal Pod Autoscaler** automatically scales the number of pods based on:
- CPU utilization
- Memory utilization
- Custom metrics
- External metrics

### HPA Formula
```
desiredReplicas = ceil[currentReplicas * (currentMetricValue / targetMetricValue)]
```

**Example:**
- Current: 3 replicas at 90% CPU
- Target: 50% CPU
- Desired = ceil[3 * (90/50)] = ceil[5.4] = 6 replicas

### Prerequisites

1. **Metrics Server** must be installed and running
2. **Resource requests** must be defined in pod spec
3. **Deployment/ReplicaSet** must exist (not bare pods)

## Imperative Commands

```bash
# Create HPA (CPU-based)
kubectl autoscale deployment nginx --cpu-percent=70 --min=2 --max=10

# Get HPAs
kubectl get hpa

# Describe HPA (shows current metrics and events)
kubectl describe hpa nginx

# Get HPA with metrics
kubectl get hpa nginx -w

# Edit HPA
kubectl edit hpa nginx

# Delete HPA
kubectl delete hpa nginx

# Check metrics-server is running
kubectl get pods -n kube-system | grep metrics-server

# View node metrics
kubectl top nodes

# View pod metrics
kubectl top pods

# View pod metrics in specific namespace
kubectl top pods -n <namespace>

# View pod metrics with containers
kubectl top pods --containers

# Sort by CPU or memory
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
```

## YAML Examples

### HPA with CPU Target
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### HPA with Memory Target
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 3
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### HPA with Multiple Metrics
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-metric-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

### Deployment with Resource Requests (Required for HPA)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:v1
        resources:
          requests:
            cpu: 100m      # Required for CPU-based HPA
            memory: 128Mi  # Required for memory-based HPA
          limits:
            cpu: 200m
            memory: 256Mi
```

## Troubleshooting Tips

### HPA Shows `<unknown>` for Metrics
```bash
# Check HPA status
kubectl describe hpa <hpa-name>

# Common causes:

# 1. Metrics-server not installed/running
kubectl get pods -n kube-system | grep metrics-server

# 2. Metrics-server not responding
kubectl top nodes  # Should show metrics, not error

# 3. No resource requests defined in deployment
kubectl get deployment <name> -o yaml | grep -A5 resources

# 4. Pods not ready
kubectl get pods -l app=<app-label>

# Fix: Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For local clusters (minikube, kind), may need insecure TLS:
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

### HPA Not Scaling
```bash
# Check current metrics vs target
kubectl get hpa <hpa-name>

# Check HPA events
kubectl describe hpa <hpa-name>

# Check if metrics are being collected
kubectl top pods -l app=<app-label>

# Verify deployment has correct label selector
kubectl get deployment <name> -o yaml | grep -A3 selector

# Check for errors in HPA controller
kubectl logs -n kube-system <kube-controller-manager-pod> | grep -i hpa

# Generate load to test scaling
kubectl run -it --rm load-generator --image=busybox -- /bin/sh
# Inside container:
# while true; do wget -q -O- http://<service-name>; done
```

### Metrics-Server Not Working
```bash
# Check metrics-server deployment
kubectl get deployment metrics-server -n kube-system

# Check metrics-server pods
kubectl get pods -n kube-system | grep metrics-server

# Check metrics-server logs
kubectl logs -n kube-system deployment/metrics-server

# Common errors and fixes:

# Error: x509 certificate signed by unknown authority
# Fix: Add --kubelet-insecure-tls flag
kubectl edit deployment metrics-server -n kube-system
# Add to args: --kubelet-insecure-tls

# Error: unable to fetch metrics
# Check kubelet metrics endpoint
kubectl get --raw /api/v1/nodes/<node-name>/proxy/metrics/resource
```

### HPA Scales Too Aggressively/Slowly
```bash
# Check scaling behavior
kubectl describe hpa <hpa-name> | grep -A10 "Behavior"

# Adjust behavior in HPA spec
kubectl edit hpa <hpa-name>

# Add behavior section:
# behavior:
#   scaleDown:
#     stabilizationWindowSeconds: 300  # Wait 5min before scaling down
#   scaleUp:
#     stabilizationWindowSeconds: 0    # Scale up immediately
```

### Check Resource Requests Missing
```bash
# Check if pods have resource requests
kubectl get pods -o=custom-columns=NAME:.metadata.name,CPU_REQUEST:.spec.containers[*].resources.requests.cpu,MEMORY_REQUEST:.spec.containers[*].resources.requests.memory

# Fix: Add resource requests to deployment
kubectl set resources deployment <name> --requests=cpu=100m,memory=128Mi
```

## Key Files and Locations

### Metrics Server
- **Deployment**: `kubectl get deployment -n kube-system metrics-server`
- **Config**: Can be edited via `kubectl edit deployment metrics-server -n kube-system`
- **Logs**: `kubectl logs -n kube-system deployment/metrics-server`

### HPA Controller
- **Component**: Part of `kube-controller-manager`
- **Logs**: `kubectl logs -n kube-system kube-controller-manager-<node> | grep horizontal`
- **Config**: `/etc/kubernetes/manifests/kube-controller-manager.yaml`

### HPA Sync Period
- Default: 15 seconds
- Configured in controller-manager: `--horizontal-pod-autoscaler-sync-period=15s`

## Exam Tips

1. **Check metrics-server first**: `kubectl top nodes` should work
2. **Resource requests required**: CPU/memory requests must be defined
3. **Use imperative command**: `kubectl autoscale deployment ...`
4. **Min replicas should be > 0**: Usually set 2+ for availability
5. **Target utilization as percentage**: 50-80% typical for CPU
6. **Watch HPA**: `kubectl get hpa -w` to see live metrics
7. **HPA only works with controllers**: Deployment, ReplicaSet, StatefulSet
8. **Cannot manually scale** when HPA active (HPA overrides)
9. **Check events**: `kubectl describe hpa` shows scaling decisions
10. **Allow time**: HPA takes ~3-5 minutes to stabilize

## Common Mistakes

- ❌ No resource requests defined in pod spec
- ❌ Metrics-server not installed or not working
- ❌ Trying to autoscale bare pods (must be deployment/replicaset)
- ❌ Setting minReplicas to 0 (causes issues)
- ❌ Manually scaling deployment while HPA active
- ❌ Setting target utilization too low (constant scaling)
- ❌ Not waiting long enough for HPA to react
- ❌ Forgetting namespace for HPA creation

## Quick Reference

```bash
# Install metrics-server (if needed)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify metrics-server
kubectl top nodes
kubectl top pods

# Create HPA
kubectl autoscale deployment webapp --cpu-percent=70 --min=2 --max=10

# Check HPA status
kubectl get hpa
kubectl describe hpa webapp

# Generate load for testing
kubectl run load-gen --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://webapp-service; done"

# Watch scaling
kubectl get hpa webapp -w
kubectl get pods -w

# Cleanup
kubectl delete hpa webapp
kubectl delete pod load-gen
```

## Testing Example

```bash
# Create deployment with resource requests
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
          limits:
            cpu: 500m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
spec:
  ports:
  - port: 80
  selector:
    app: php-apache
EOF

# Create HPA
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

# Check HPA
kubectl get hpa php-apache

# Generate load
kubectl run -it load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

# In another terminal, watch scaling
kubectl get hpa php-apache -w
kubectl get pods -w

# Stop load (Ctrl+C in load-generator)
# Watch scale down
kubectl get hpa php-apache -w

# Cleanup
kubectl delete deployment php-apache
kubectl delete service php-apache
kubectl delete hpa php-apache
```

## Scaling Behavior

### Scale Up
- **Default**: Up to double current replicas per 15 seconds
- **Max**: Limited by `maxReplicas`

### Scale Down
- **Default**: Wait 5 minutes of stable metrics before scaling down
- **Rate**: Maximum 50% of current replicas per 15 seconds

### Stabilization Window
- Prevents flapping (rapid scaling up/down)
- Scale up: considers last 0 seconds (immediate)
- Scale down: considers last 5 minutes (conservative)
