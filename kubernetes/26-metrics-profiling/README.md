# Kubernetes Metrics & Profiling

This section covers resource monitoring and profiling in Kubernetes, focusing on understanding pod resource consumption and cluster metrics.

## 📊 Overview

Metrics profiling helps you:

- Monitor resource usage (CPU/Memory) of pods and nodes
- Make informed decisions about resource requests and limits
- Identify performance bottlenecks and resource-hungry components
- Plan for scaling and capacity management

## 🛠️ Prerequisites

### Minikube Setup (Recommended for Course)

```bash
# Start minikube with adequate resources
minikube start --memory=4096 --cpus=2

# Enable metrics-server addon
minikube addons enable metrics-server

# Verify metrics-server is running
kubectl get pods -n kube-system | grep metrics-server
```

### Docker Desktop Alternative

If using Docker Desktop instead of minikube:

```bash
# Manual metrics-server installation
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch for Docker Desktop (self-signed certificates)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'
```

## 📈 Basic Metrics Commands

### Pod Resource Usage

```bash
# View current CPU and memory usage for all pods
kubectl top pod

# View resource usage for specific namespace
kubectl top pod -n kube-system

# Sort by CPU usage
kubectl top pod --sort-by=cpu

# Sort by memory usage
kubectl top pod --sort-by=memory
```

### Node Resource Usage

```bash
# View node resource consumption
kubectl top node

# Detailed node information
kubectl describe node <node-name>
```

## 🎯 Sample Application Metrics

Based on the fleetman microservices application, here are typical resource consumption patterns:

| Component          | CPU (cores) | Memory (bytes) | Role                |
| ------------------ | ----------- | -------------- | ------------------- |
| position-tracker   | 26m         | 209Mi          | Heavy processing    |
| mongodb            | 26m         | 162Mi          | Database operations |
| queue              | 17m         | 249Mi          | Message buffering   |
| api-gateway        | 6m          | 161Mi          | Request routing     |
| position-simulator | 4m          | 189Mi          | Data generation     |
| webapp             | 1m          | 3Mi            | Static frontend     |

## 🔧 Resource Configuration Recommendations

Based on observed metrics, here are recommended resource requests and limits:

### High-Resource Components

**Position Tracker** (CPU-intensive):

```yaml
resources:
  requests:
    cpu: "25m"
    memory: "200Mi"
  limits:
    cpu: "100m"
    memory: "400Mi"
```

**Queue** (Memory-intensive):

```yaml
resources:
  requests:
    cpu: "15m"
    memory: "240Mi"
  limits:
    cpu: "50m"
    memory: "500Mi"
```

**MongoDB** (Database):

```yaml
resources:
  requests:
    cpu: "20m"
    memory: "150Mi"
  limits:
    cpu: "100m"
    memory: "512Mi"
```

### Low-Resource Components

**API Gateway**:

```yaml
resources:
  requests:
    cpu: "5m"
    memory: "150Mi"
  limits:
    cpu: "50m"
    memory: "300Mi"
```

**WebApp** (Static content):

```yaml
resources:
  requests:
    cpu: "1m"
    memory: "5Mi"
  limits:
    cpu: "10m"
    memory: "50Mi"
```

## 📊 Dashboard Integration

### Minikube Dashboard

```bash
# Launch Kubernetes dashboard
minikube dashboard

# Enable dashboard addon if not already enabled
minikube addons enable dashboard
```

### Docker Desktop Dashboard

For Docker Desktop users, manual installation required:

```bash
# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create admin service account
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa

# Get access token
kubectl create token dashboard-admin-sa

# Access via proxy
kubectl proxy
# Visit: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## 🔍 Analysis Techniques

### Continuous Monitoring

```bash
# Watch metrics in real-time
watch kubectl top pod

# Monitor specific pods
watch kubectl top pod -l app=position-tracker
```

### Resource Pressure Investigation

```bash
# Check for resource constraints
kubectl describe pod <pod-name> | grep -A 10 Events

# Look for OOMKilled or resource limits
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Node Capacity Planning

```bash
# Check node allocatable resources
kubectl describe node | grep -A 5 "Allocatable\|Allocated resources"

# View resource requests/limits across all pods
kubectl describe nodes | grep -A 3 "Resource.*Requests.*Limits"
```

## ⚠️ Course Context Notes

This section is based on a **5-7 year old Kubernetes course**. Key considerations:

### What's Still Relevant (2025):

- ✅ Core metrics-server concepts and `kubectl top` commands
- ✅ Resource requests/limits configuration patterns
- ✅ Basic dashboard functionality for cluster visibility

### What's Evolved:

- **Dashboard versions**: Course shows v2.7.0, current is v3.x+ with different UI
- **Monitoring ecosystem**: Production uses Prometheus/Grafana instead of basic metrics-server
- **Observability**: Modern clusters use OpenTelemetry, distributed tracing
- **Autoscaling**: VPA (Vertical Pod Autoscaler) and advanced HPA configurations

### Modern Alternatives:

- **Metrics**: Prometheus + Grafana stack
- **Dashboards**: Grafana, Rancher, Lens
- **Profiling**: APM tools like Datadog, New Relic
- **Cost optimization**: Tools like KubeCost, Goldilocks

## 🎯 Learning Objectives

By completing this section, you should understand:

1. **Resource monitoring**: How to measure pod and node resource consumption
2. **Capacity planning**: Setting appropriate resource requests and limits
3. **Performance analysis**: Identifying bottlenecks and optimization opportunities
4. **Cluster visibility**: Using dashboards for operational awareness
5. **Scaling decisions**: Data-driven approaches to horizontal and vertical scaling

## 📚 Additional Resources

- [Kubernetes Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Metrics Server Documentation](https://github.com/kubernetes-sigs/metrics-server)
- [Dashboard User Guide](https://github.com/kubernetes/dashboard/blob/master/docs/user/README.md)
- [Modern Observability Patterns](https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/)

## 🚀 Next Steps

After mastering basic metrics profiling:

1. Explore Horizontal Pod Autoscaler (HPA) based on CPU/memory metrics
2. Learn about custom metrics and vertical pod autoscaling
3. Investigate modern observability tools for production environments
4. Practice capacity planning for real-world workloads
