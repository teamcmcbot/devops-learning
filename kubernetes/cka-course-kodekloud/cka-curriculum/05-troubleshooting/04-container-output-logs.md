# Manage and Evaluate Container Output Streams (Logs)

## Exam Weight
Part of **30% - Troubleshooting**

## What Can Be Tested

- View container logs with kubectl logs
- Stream real-time logs
- View logs from previous container instances
- Access logs from multi-container pods
- Troubleshoot application issues using logs
- Find and analyze kubelet and container runtime logs

## Sample Questions

1. **View logs of a specific container in a multi-container pod**
2. **Stream logs from all pods with a specific label**
3. **View logs from a crashed container (previous instance)**
4. **Find errors in application logs**
5. **Troubleshoot why logs are not available**

## Official Documentation

- [Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [kubectl logs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs)
- [Debug Running Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)

## Key Concepts

### Logging Levels

```
┌─────────────────────────────────────────┐
│     Application Level                   │
│  (Container stdout/stderr)              │
│                                         │
│  kubectl logs <pod> -c <container>      │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│     Node Level                          │
│  /var/log/pods/                         │
│  /var/log/containers/                   │
│                                         │
│  Managed by container runtime          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│     Cluster Level (optional)            │
│  Logging backend (ELK, Loki, etc.)      │
└─────────────────────────────────────────┘
```

### Log Types

| Log Type | Location | Access Method |
|----------|----------|---------------|
| **Container logs** | `/var/log/pods/` | `kubectl logs` |
| **kubelet logs** | `journalctl` | `journalctl -u kubelet` |
| **Container runtime** | `journalctl` | `journalctl -u containerd` |
| **Control plane** | Static pod logs | `kubectl logs -n kube-system` |
| **Application logs** | stdout/stderr | `kubectl logs` |

## Basic Log Commands

### View Pod Logs

```bash
# View logs of a pod (single container)
kubectl logs <pod-name>

# View logs with namespace
kubectl logs <pod-name> -n <namespace>

# View logs from specific container (multi-container pod)
kubectl logs <pod-name> -c <container-name>

# Stream logs in real-time
kubectl logs -f <pod-name>
kubectl logs --follow <pod-name>

# View logs from previous container instance (crashed/restarted)
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -p

# Limit number of lines
kubectl logs <pod-name> --tail=50

# Show logs since timestamp
kubectl logs <pod-name> --since=1h
kubectl logs <pod-name> --since=10m
kubectl logs <pod-name> --since=2024-01-01T10:00:00Z

# Show logs since time ago
kubectl logs <pod-name> --since-time=2024-01-15T10:00:00Z

# Include timestamps
kubectl logs <pod-name> --timestamps
kubectl logs <pod-name> --timestamps=true
```

## Advanced Log Queries

### Multi-Container Pods

```bash
# List containers in pod
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'

# View logs from specific container
kubectl logs <pod-name> -c <container-name>

# View logs from all containers
kubectl logs <pod-name> --all-containers=true

# Stream logs from all containers with prefix
kubectl logs <pod-name> --all-containers=true --prefix=true

# View logs from init container
kubectl logs <pod-name> -c <init-container-name>

# Example: Pod with nginx and sidecar
kubectl logs my-pod -c nginx
kubectl logs my-pod -c sidecar
kubectl logs my-pod --all-containers=true
```

### Label Selectors

```bash
# View logs from pods with specific label
kubectl logs -l app=nginx

# Stream logs from multiple pods
kubectl logs -l app=nginx -f

# Limit to pods with multiple labels
kubectl logs -l app=nginx,env=prod

# View logs from pods in specific namespace
kubectl logs -l app=nginx -n production
```

### Previous Container Instances

```bash
# When pod crashes and restarts, view previous logs
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -p

# Previous logs from specific container
kubectl logs <pod-name> -c <container-name> --previous

# Check restart count
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[*].restartCount}'

# Check why container restarted
kubectl describe pod <pod-name> | grep -A 10 "Last State"
```

## Filter and Search Logs

### Using grep

```bash
# Search for errors
kubectl logs <pod-name> | grep -i error

# Search for warnings
kubectl logs <pod-name> | grep -i warn

# Case-insensitive search
kubectl logs <pod-name> | grep -i "connection failed"

# Show context around matches
kubectl logs <pod-name> | grep -A 5 -B 5 "error"

# Multiple patterns
kubectl logs <pod-name> | grep -E "error|warn|fail"

# Exclude patterns
kubectl logs <pod-name> | grep -v "debug"

# Count occurrences
kubectl logs <pod-name> | grep -c "error"
```

### Combining with Other Tools

```bash
# View last 100 lines with errors
kubectl logs <pod-name> --tail=100 | grep error

# Stream and filter errors
kubectl logs <pod-name> -f | grep -i error

# Save logs to file
kubectl logs <pod-name> > pod.log

# View large logs with less
kubectl logs <pod-name> | less

# Search within less (press / then type pattern)
kubectl logs <pod-name> | less
# Then: /error

# Extract specific fields (JSON logs)
kubectl logs <pod-name> | jq '.level,.message'

# Count log levels
kubectl logs <pod-name> | jq -r '.level' | sort | uniq -c
```

## Node-Level Logs

### Container Logs on Node

```bash
# SSH to node
ssh <node-name>

# View pod log files
sudo ls -la /var/log/pods/

# Log directory structure:
# /var/log/pods/<namespace>_<pod-name>_<uid>/<container-name>/

# View specific pod logs
sudo cat /var/log/pods/<namespace>_<pod>_<uid>/<container>/0.log

# Tail logs
sudo tail -f /var/log/pods/<namespace>_<pod>_<uid>/<container>/0.log

# View container symlinks
sudo ls -la /var/log/containers/

# Container log format:
# <pod-name>_<namespace>_<container-name>-<container-id>.log

# View via symlink
sudo tail -f /var/log/containers/<pod>_<namespace>_<container>-<id>.log
```

### kubelet Logs

```bash
# View kubelet logs
sudo journalctl -u kubelet

# Follow kubelet logs
sudo journalctl -u kubelet -f

# Logs since time
sudo journalctl -u kubelet --since "10 minutes ago"
sudo journalctl -u kubelet --since "2024-01-15 10:00:00"

# Last 100 lines
sudo journalctl -u kubelet -n 100

# Search in kubelet logs
sudo journalctl -u kubelet | grep -i error

# Output to file
sudo journalctl -u kubelet --since today > kubelet.log

# No pager
sudo journalctl -u kubelet --no-pager

# Reverse order (newest first)
sudo journalctl -u kubelet -r
```

### Container Runtime Logs

```bash
# containerd logs
sudo journalctl -u containerd

# Follow containerd logs
sudo journalctl -u containerd -f

# Since time
sudo journalctl -u containerd --since "1 hour ago"

# Search for errors
sudo journalctl -u containerd | grep -i error

# CRI-O logs (if using CRI-O)
sudo journalctl -u crio
```

## Control Plane Component Logs

### Static Pod Logs

```bash
# API Server logs
kubectl logs -n kube-system kube-apiserver-<node-name>

# Scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Controller Manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name>

# etcd logs
kubectl logs -n kube-system etcd-<node-name>

# Stream control plane logs
kubectl logs -n kube-system kube-apiserver-<node-name> -f

# Previous instance (if restarted)
kubectl logs -n kube-system kube-apiserver-<node-name> --previous
```

### Using crictl

```bash
# List containers
sudo crictl ps

# Get logs via crictl
sudo crictl logs <container-id>

# Tail logs
sudo crictl logs --tail=50 <container-id>

# Follow logs
sudo crictl logs -f <container-id>

# Control plane component logs
sudo crictl ps | grep kube-apiserver
sudo crictl logs <kube-apiserver-container-id>
```

## Troubleshoot Logging Issues

### Issue 1: No Logs Available

```bash
# Error: "Unable to retrieve container logs"

# Check if pod exists
kubectl get pod <pod-name>

# Check pod status
kubectl describe pod <pod-name>

# Check if container is running
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[*].state}'

# If container is waiting or terminated
kubectl describe pod <pod-name> | grep -A 10 "State:"

# Check events
kubectl get events --field-selector involvedObject.name=<pod-name>

# Try previous logs if restarted
kubectl logs <pod-name> --previous
```

### Issue 2: Logs Truncated

```bash
# Log size limits apply

# Check current log size on node
ssh <node>
sudo ls -lh /var/log/pods/<namespace>_<pod>_<uid>/<container>/

# View full logs from node
sudo cat /var/log/pods/<namespace>_<pod>_<uid>/<container>/*.log

# Increase --max-log-size in kubelet config (not exam-relevant)
```

### Issue 3: Multi-Container Pod Logs

```bash
# Error: "a container name must be specified"

# List containers
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'

# Specify container
kubectl logs <pod-name> -c <container-name>

# View all containers
kubectl logs <pod-name> --all-containers=true
```

### Issue 4: Previous Container Logs Not Available

```bash
# Check if container was restarted
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[*].restartCount}'

# If restartCount=0, no previous logs
# If restartCount>0, previous logs should exist

# Try to get previous logs
kubectl logs <pod-name> --previous

# If still no logs, they may have been garbage collected
# Check on node
ssh <node>
sudo find /var/log/pods -name "*<pod>*"
```

## Practical Examples

### Example 1: Debug Crashing Application

```bash
# Application keeps crashing
kubectl get pods
# NAME            READY   STATUS             RESTARTS   AGE
# my-app-abc123   0/1     CrashLoopBackOff   5          5m

# Check current logs (may be empty if crashes immediately)
kubectl logs my-app-abc123

# Check previous logs
kubectl logs my-app-abc123 --previous

# Look for errors
kubectl logs my-app-abc123 --previous | grep -i error

# Check why it crashed
kubectl describe pod my-app-abc123 | grep -A 10 "Last State"

# Output:
#     Last State:     Terminated
#       Reason:       Error
#       Exit Code:    1
#       Message:      Connection to database failed
```

### Example 2: Monitor Multiple Pods

```bash
# Stream logs from all nginx pods
kubectl logs -l app=nginx -f --prefix=true

# Output:
# [pod/nginx-1] 192.168.1.1 - - [15/Jan/2024] "GET / HTTP/1.1" 200
# [pod/nginx-2] 192.168.1.2 - - [15/Jan/2024] "GET / HTTP/1.1" 200

# Save logs from all pods
for pod in $(kubectl get pods -l app=nginx -o name); do
  kubectl logs $pod > ${pod//\//-}.log
done
```

### Example 3: Find Recent Errors

```bash
# Last hour logs with errors
kubectl logs <pod-name> --since=1h | grep -i error

# Count errors
kubectl logs <pod-name> --since=1h | grep -c -i error

# Unique error messages
kubectl logs <pod-name> | grep -i error | sort | uniq

# Errors with context
kubectl logs <pod-name> | grep -A 3 -B 3 -i error
```

### Example 4: Application with JSON Logs

```bash
# Application logs JSON
kubectl logs my-app

# Output:
# {"level":"info","msg":"Server started","port":8080}
# {"level":"error","msg":"Database connection failed","error":"timeout"}

# Extract error messages
kubectl logs my-app | jq 'select(.level=="error") | .msg'

# Count by level
kubectl logs my-app | jq -r '.level' | sort | uniq -c

# Filter by field
kubectl logs my-app | jq 'select(.port==8080)'
```

## Logs Analysis Best Practices

### Quick Troubleshooting Checklist

```bash
# 1. Check pod status
kubectl get pod <pod-name>

# 2. View current logs
kubectl logs <pod-name>

# 3. If empty or pod restarted, check previous
kubectl logs <pod-name> --previous

# 4. Check events
kubectl describe pod <pod-name> | grep -A 20 Events

# 5. For multi-container pods, check each container
kubectl logs <pod-name> --all-containers=true

# 6. Search for errors
kubectl logs <pod-name> | grep -i -E "error|fail|exception"

# 7. Check kubelet logs if needed
ssh <node>
sudo journalctl -u kubelet | grep <pod-name>
```

### Common Log Patterns to Search

```bash
# Errors and exceptions
kubectl logs <pod> | grep -i -E "error|exception|fatal|panic"

# Connection issues
kubectl logs <pod> | grep -i -E "connection|timeout|refused|unreachable"

# Authentication/Authorization
kubectl logs <pod> | grep -i -E "unauthorized|forbidden|denied|authentication"

# Resource issues
kubectl logs <pod> | grep -i -E "memory|oom|out of memory|disk|space"

# Startup issues
kubectl logs <pod> | grep -i -E "starting|started|failed to start|initialization"
```

## Key Locations

### Log Locations on Nodes

| Location | Contents |
|----------|----------|
| `/var/log/pods/` | Pod logs organized by namespace/pod/container |
| `/var/log/containers/` | Symlinks to pod logs |
| `/var/lib/docker/containers/` | Docker container logs (if using Docker) |
| `/var/lib/containerd/` | containerd data |

### System Logs

```bash
# kubelet
sudo journalctl -u kubelet

# containerd
sudo journalctl -u containerd

# System messages
sudo tail -f /var/log/syslog      # Ubuntu/Debian
sudo tail -f /var/log/messages    # CentOS/RHEL

# Kernel messages
sudo dmesg | tail -50
```

## Exam Tips

1. **Use -f to stream** - Catch issues as they happen
2. **--previous is crucial** - For crashed containers
3. **Specify container** - In multi-container pods use -c
4. **grep is your friend** - Filter for errors quickly
5. **Check events** - kubectl describe shows related events
6. **Time-based filtering** - Use --since=1h for recent issues
7. **Label selectors** - View logs from multiple related pods
8. **journalctl for kubelet** - When pod logs aren't enough
9. **Practice log patterns** - Know where system logs are
10. **Read carefully** - Question may specify which container

## Common Mistakes

- ❌ Forgetting --previous for crashed containers
- ❌ Not specifying container name in multi-container pods
- ❌ Using wrong namespace (-n flag)
- ❌ Not using grep to filter large logs
- ❌ Ignoring timestamps flag for correlation
- ❌ Not checking kubectl describe events
- ❌ Overlooking kubelet logs on node
- ❌ Trying to view logs of pending pods
- ❌ Not streaming logs during active debugging
- ❌ Missing --all-containers flag for multi-container pods

## Quick Reference

### Essential Commands

```bash
# Basic logs
kubectl logs <pod>
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -c <container>

# Previous/crashed container
kubectl logs <pod> --previous

# Real-time streaming
kubectl logs <pod> -f

# Last N lines
kubectl logs <pod> --tail=50

# Since time
kubectl logs <pod> --since=1h

# Multiple pods by label
kubectl logs -l app=nginx

# All containers in pod
kubectl logs <pod> --all-containers=true

# With timestamps
kubectl logs <pod> --timestamps
```

### Troubleshooting Pattern

```bash
# 1. Check pod status
kubectl get pod <pod> -o wide

# 2. View logs
kubectl logs <pod>

# 3. If restarted, check previous
kubectl logs <pod> -p

# 4. Search for errors
kubectl logs <pod> | grep -i error

# 5. Check events
kubectl describe pod <pod> | grep -A 20 Events

# 6. Check kubelet (on node)
ssh <node>
sudo journalctl -u kubelet | grep <pod>
```

### System Logs

```bash
# kubelet
sudo journalctl -u kubelet -f

# containerd
sudo journalctl -u containerd -f

# Control plane
kubectl logs -n kube-system kube-apiserver-<node> -f
```
