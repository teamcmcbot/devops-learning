# Monitor Cluster Components and Applications Using Metrics

## Exam Weight
Part of **30% - Troubleshooting**

## What Can Be Tested

- Install and configure metrics-server
- View resource usage with kubectl top
- Monitor node and pod resource consumption
- Identify resource-constrained nodes
- Find resource-hungry pods
- Troubleshoot metrics-server issues

## Sample Questions

1. **Install metrics-server in the cluster**
2. **Find the pod consuming the most CPU**
3. **Identify node with highest memory usage**
4. **Troubleshoot why `kubectl top` is not working**
5. **Find pods in a namespace sorted by memory usage**

## Official Documentation

- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [Resource Metrics Pipeline](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)
- [Tools for Monitoring Resources](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/)

## Key Concepts

### Monitoring Architecture

```
┌──────────────────────────────────────────────┐
│                 kubectl top                   │
│         (User Interface)                      │
└───────────────────┬──────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│          Metrics API                          │
│    (k8s.io/metrics, metrics.k8s.io/v1beta1)  │
└───────────────────┬──────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│         Metrics Server                        │
│    (Collects resource metrics)                │
└───────────────────┬──────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│          kubelet (cAdvisor)                   │
│    (Exposes container metrics)                │
└──────────────────────────────────────────────┘
```

### Metrics Types

| Metric Type | Provided By | Use Case |
|-------------|-------------|----------|
| **Resource Metrics** | metrics-server | CPU, Memory usage (kubectl top) |
| **Custom Metrics** | Custom metrics adapter | Application metrics (HPA) |
| **External Metrics** | External adapter | Cloud provider metrics |

## Install Metrics Server

### Installation Methods

#### Method 1: kubectl apply (Recommended for Exam)

```bash
# Download and apply metrics-server manifest
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify deployment
kubectl get deployment metrics-server -n kube-system

# Check pods
kubectl get pods -n kube-system | grep metrics-server

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s
```

#### Method 2: Helm

```bash
# Add metrics-server Helm repo
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

# Install metrics-server
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system

# Verify
kubectl get deployment metrics-server -n kube-system
```

### Configure for Development/Lab Environments

For self-signed certificates or testing environments:

```bash
# Download manifest
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Edit to add --kubelet-insecure-tls flag
vi components.yaml

# Find the Deployment section and add under args:
# spec:
#   containers:
#   - args:
#     - --kubelet-insecure-tls
#     - --cert-dir=/tmp
#     - --secure-port=4443

# Apply modified manifest
kubectl apply -f components.yaml
```

Or patch existing deployment:

```bash
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

# Wait for rollout
kubectl rollout status deployment metrics-server -n kube-system
```

## Using kubectl top

### Monitor Nodes

```bash
# View node resource usage
kubectl top nodes

# Output example:
# NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# controlplane   150m         7%     1200Mi          15%
# node01         100m         5%     800Mi           10%

# Sort by CPU
kubectl top nodes --sort-by=cpu

# Sort by memory
kubectl top nodes --sort-by=memory

# Show labels
kubectl top nodes --show-labels

# Specific node
kubectl top node node01
```

### Monitor Pods

```bash
# View pod resource usage (current namespace)
kubectl top pods

# All namespaces
kubectl top pods --all-namespaces
kubectl top pods -A

# Specific namespace
kubectl top pods -n kube-system

# Sort by CPU
kubectl top pods --sort-by=cpu

# Sort by memory
kubectl top pods --sort-by=memory

# With container breakdown
kubectl top pods --containers

# Example output:
# POD         NAME       CPU(cores)   MEMORY(bytes)
# my-pod      nginx      10m          50Mi
# my-pod      sidecar    5m           20Mi

# Show labels
kubectl top pods --show-labels

# Filter with label selector
kubectl top pods -l app=nginx

# Specific pod
kubectl top pod my-pod
```

### Advanced Queries

```bash
# Find top 5 CPU consuming pods
kubectl top pods -A --sort-by=cpu | head -6

# Find top 5 memory consuming pods
kubectl top pods -A --sort-by=memory | head -6

# Pods in specific namespace sorted by CPU
kubectl top pods -n production --sort-by=cpu

# Containers in pods sorted by memory
kubectl top pods --containers --sort-by=memory

# Get metrics in JSON format (for scripting)
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods

# Pretty print JSON
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | python3 -m json.tool
```

## Analyze Resource Usage

### Identify Resource Issues

```bash
# 1. Find nodes with high CPU usage
kubectl top nodes --sort-by=cpu

# 2. Find pods causing high CPU on that node
kubectl top pods -A --sort-by=cpu | grep <node-name>

# Or
kubectl top pods -A -o wide | grep <node-name>

# 3. Check node capacity
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# 4. Find which pod is using most resources
kubectl top pods -A --sort-by=cpu | head -10

# 5. Check pod's resource requests and limits
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Limits\|Requests"

# 6. Check for pod evictions
kubectl get events --sort-by='.lastTimestamp' | grep -i evict
```

### Compare Usage vs Requests/Limits

```bash
# Get pod resource specs
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].resources}'

# Compare with actual usage
kubectl top pod <pod-name>

# Example analysis:
# Pod requests: 100m CPU, 128Mi memory
# Pod limits: 200m CPU, 256Mi memory
# Actual usage: 150m CPU, 200Mi memory
# Status: Within limits, but above requests

# List all pods with resource specs
kubectl get pods -o custom-columns=\
NAME:.metadata.name,\
CPU_REQ:.spec.containers[*].resources.requests.cpu,\
CPU_LIM:.spec.containers[*].resources.limits.cpu,\
MEM_REQ:.spec.containers[*].resources.requests.memory,\
MEM_LIM:.spec.containers[*].resources.limits.memory
```

### Node Capacity Analysis

```bash
# Check node allocatable resources
kubectl describe node <node-name> | grep -A 10 "Allocatable"

# Example output:
# Allocatable:
#   cpu:                2
#   memory:             8Gi
#   pods:               110

# Check allocated resources (requests)
kubectl describe node <node-name> | grep -A 10 "Allocated resources"

# Example output:
# Allocated resources:
#   Resource           Requests    Limits
#   --------           --------    ------
#   cpu                1200m (60%)  2000m (100%)
#   memory             4Gi (50%)    6Gi (75%)

# Find pods on specific node
kubectl get pods -A -o wide --field-selector spec.nodeName=<node-name>

# Sum up resource usage on node
kubectl top pods -A -o wide | grep <node-name> | awk '{sum+=$2} END {print "Total CPU: " sum "m"}'
```

## Troubleshoot Metrics Server

### Check Metrics Server Status

```bash
# Check deployment
kubectl get deployment metrics-server -n kube-system

# Check pods
kubectl get pods -n kube-system | grep metrics-server

# Check pod status
kubectl describe pod -l k8s-app=metrics-server -n kube-system

# Check logs
kubectl logs -n kube-system -l k8s-app=metrics-server

# Check metrics API availability
kubectl get apiservices | grep metrics

# Should show:
# v1beta1.metrics.k8s.io    kube-system/metrics-server   True

# Test metrics API
kubectl get --raw /apis/metrics.k8s.io/v1beta1
```

### Common Issues and Fixes

#### Issue 1: kubectl top not working

```bash
# Error: "error: Metrics API not available"

# Check if metrics-server is deployed
kubectl get deployment -n kube-system metrics-server

# If not found, install it
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check if pods are running
kubectl get pods -n kube-system | grep metrics-server

# Check logs for errors
kubectl logs -n kube-system -l k8s-app=metrics-server

# Check API service
kubectl get apiservices v1beta1.metrics.k8s.io

# If Available=False, check metrics-server service
kubectl get svc -n kube-system metrics-server
```

#### Issue 2: TLS Certificate Errors

```bash
# Error in metrics-server logs:
# "x509: cannot validate certificate"

# Solution 1: Add --kubelet-insecure-tls flag (dev/test only)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

# Solution 2: Properly configure kubelet certificates (production)
# Ensure kubelet is configured with proper certificates

# Wait for rollout
kubectl rollout status deployment metrics-server -n kube-system

# Verify
kubectl top nodes
```

#### Issue 3: Can't Reach Kubelet

```bash
# Error: "dial tcp <node-ip>:10250: i/o timeout"

# Check kubelet is running on nodes
ssh <node>
sudo systemctl status kubelet

# Check kubelet is listening on 10250
sudo netstat -tulpn | grep 10250

# Check firewall
sudo ufw status
sudo iptables -L | grep 10250

# Check metrics-server can resolve node names
kubectl exec -n kube-system -it <metrics-server-pod> -- nslookup <node-name>

# Add --kubelet-preferred-address-types flag if needed
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
  }
]'
```

#### Issue 4: Metrics Not Updated

```bash
# Metrics are stale (not updating)

# Check metrics-server is running
kubectl get pods -n kube-system | grep metrics-server

# Restart metrics-server
kubectl rollout restart deployment metrics-server -n kube-system

# Wait for rollout
kubectl rollout status deployment metrics-server -n kube-system

# Metrics are scraped every ~15-60 seconds
# Wait a minute and try again
sleep 60
kubectl top nodes
```

#### Issue 5: Insufficient Permissions

```bash
# Check metrics-server service account
kubectl get sa -n kube-system metrics-server

# Check cluster role
kubectl get clusterrole system:metrics-server

# Check cluster role binding
kubectl get clusterrolebinding system:metrics-server

# Verify RBAC is correct
kubectl describe clusterrole system:metrics-server
kubectl describe clusterrolebinding system:metrics-server
```

## Resource Monitoring Best Practices

### Regular Monitoring Tasks

```bash
# Daily health check script
cat <<'EOF' > check-cluster-resources.sh
#!/bin/bash

echo "=== Node Resource Usage ==="
kubectl top nodes --sort-by=memory

echo ""
echo "=== Top 10 CPU Consumers ==="
kubectl top pods -A --sort-by=cpu | head -11

echo ""
echo "=== Top 10 Memory Consumers ==="
kubectl top pods -A --sort-by=memory | head -11

echo ""
echo "=== Nodes Under Pressure ==="
kubectl get nodes -o json | \
  jq -r '.items[] | select(.status.conditions[] | select(.type=="MemoryPressure" or .type=="DiskPressure") | .status=="True") | .metadata.name'

echo ""
echo "=== Evicted Pods ==="
kubectl get pods -A --field-selector=status.phase=Failed | grep Evicted
EOF

chmod +x check-cluster-resources.sh
./check-cluster-resources.sh
```

### Set Up Alerts (Conceptual)

Based on metrics-server data, you would typically:
1. Monitor node CPU > 80%
2. Monitor node memory > 85%
3. Monitor pod CPU approaching limits
4. Watch for pod evictions
5. Track disk pressure conditions

## Key Files and Locations

| Location | Purpose |
|----------|---------|
| `/var/lib/kubelet/pod-resources/` | kubelet pod resource info |
| `/sys/fs/cgroup/` | cgroup resource limits |

### Metrics Server Configuration

```bash
# Metrics server deployment
kubectl get deployment metrics-server -n kube-system -o yaml

# Common flags:
# --kubelet-insecure-tls              # Skip kubelet TLS verification (dev only)
# --kubelet-preferred-address-types   # Node address type preference
# --metric-resolution=15s             # How often to scrape (default 60s)
# --cert-dir=/tmp                     # Certificate directory
```

## Exam Tips

1. **Install metrics-server first** - Can't use kubectl top without it
2. **--kubelet-insecure-tls** - Likely needed in exam environment
3. **Use --sort-by** - Quickly find resource hogs
4. **top -A** - Check all namespaces for problems
5. **Compare with requests/limits** - Use kubectl describe
6. **Check logs** - If metrics-server not working
7. **Wait for metrics** - Scraping takes ~60 seconds initially
8. **Practice installation** - Memorize kubectl apply command
9. **Time saver**: kubectl top pods -A | head -10
10. **Check APIService** - Ensure metrics API is available

## Common Mistakes

- ❌ Not installing metrics-server before using kubectl top
- ❌ Forgetting --kubelet-insecure-tls in lab environments
- ❌ Not waiting for metrics to be collected
- ❌ Using wrong namespace (-n vs -A)
- ❌ Not checking if metrics-server pod is running
- ❌ Ignoring metrics-server logs when troubleshooting
- ❌ Confusing resource usage with requests/limits
- ❌ Not using --sort-by to find top consumers
- ❌ Overlooking node capacity vs allocation
- ❌ Not verifying APIService registration

## Quick Reference

### Installation

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For dev/test (insecure TLS)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}
]'

# Verify
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
```

### Monitoring Commands

```bash
# Nodes
kubectl top nodes                      # All nodes
kubectl top nodes --sort-by=cpu        # Sort by CPU
kubectl top nodes --sort-by=memory     # Sort by memory

# Pods
kubectl top pods                       # Current namespace
kubectl top pods -A                    # All namespaces
kubectl top pods --sort-by=cpu         # Sort by CPU
kubectl top pods --sort-by=memory      # Sort by memory
kubectl top pods --containers          # Show containers

# Find top consumers
kubectl top pods -A --sort-by=cpu | head -6
kubectl top pods -A --sort-by=memory | head -6
```

### Troubleshooting

```bash
# Check metrics-server
kubectl get deployment metrics-server -n kube-system
kubectl get pods -n kube-system | grep metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server

# Check API
kubectl get apiservices | grep metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1

# Restart metrics-server
kubectl rollout restart deployment metrics-server -n kube-system
```

### Useful One-Liners

```bash
# Top 5 CPU pods across all namespaces
kubectl top pods -A --sort-by=cpu | head -6

# Top 5 memory pods
kubectl top pods -A --sort-by=memory | head -6

# Pods on specific node sorted by CPU
kubectl top pods -A -o wide | grep <node-name> | sort -k2 -n

# Check if any pod is being evicted
kubectl get events -A --sort-by='.lastTimestamp' | grep -i evict

# Node with most pods
kubectl get pods -A -o wide | awk '{print $8}' | sort | uniq -c | sort -rn | head -5
```
