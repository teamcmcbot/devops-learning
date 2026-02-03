# Troubleshoot Clusters and Nodes

## Exam Weight
Part of **30% - Troubleshooting**

## What Can Be Tested

- Diagnose cluster component failures (API server, scheduler, controller-manager, etcd)
- Troubleshoot node issues (NotReady, network, disk, kubelet)
- Check and interpret logs from control plane components
- Verify cluster health
- Fix certificate and authentication issues
- Restore cluster functionality

## Sample Questions

1. **Fix a NotReady node**
2. **Troubleshoot API server not responding**
3. **Restore etcd from backup after data loss**
4. **Fix kubelet service not starting**
5. **Diagnose scheduler not scheduling pods**

## Official Documentation

- [Troubleshooting Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)
- [Debug Nodes](https://kubernetes.io/docs/tasks/debug/debug-cluster/monitor-node-health/)
- [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/)

## Key Concepts

### Cluster Architecture

```
Control Plane Components          Worker Node Components
┌──────────────────────┐          ┌──────────────────────┐
│ kube-apiserver       │◄────────►│ kubelet              │
│ etcd                 │          │ kube-proxy           │
│ kube-scheduler       │          │ Container Runtime    │
│ kube-controller-mgr  │          │ CNI Plugin           │
└──────────────────────┘          └──────────────────────┘
```

### Troubleshooting Workflow

```
1. Identify the problem
   ↓
2. Gather information (logs, status, describe)
   ↓
3. Form hypothesis
   ↓
4. Test and verify
   ↓
5. Fix and confirm
```

## General Cluster Health Checks

### Check Cluster Status

```bash
# Check nodes
kubectl get nodes
kubectl get nodes -o wide

# Check all system pods
kubectl get pods -n kube-system

# Check component status (deprecated but still useful)
kubectl get componentstatuses
kubectl get cs

# Check cluster info
kubectl cluster-info
kubectl cluster-info dump

# Check API server health
kubectl get --raw /healthz
kubectl get --raw /readyz
kubectl get --raw /livez
```

### Verify Control Plane Components

```bash
# On control plane node, check static pods
sudo crictl ps | grep kube
# Should see:
# - kube-apiserver
# - kube-scheduler
# - kube-controller-manager
# - etcd

# Check static pod manifests
ls -la /etc/kubernetes/manifests/

# Check if pods are running
kubectl get pods -n kube-system -l tier=control-plane
```

## Troubleshoot Node Issues

### Node in NotReady State

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Look for:
# - Conditions (Ready, MemoryPressure, DiskPressure, PIDPressure)
# - Events

# Common issues and fixes:

# 1. Kubelet not running
ssh <node-name>
sudo systemctl status kubelet
sudo systemctl start kubelet

# Check kubelet logs
sudo journalctl -u kubelet -f
sudo journalctl -u kubelet --since "10 minutes ago"

# 2. Container runtime (containerd) not running
sudo systemctl status containerd
sudo systemctl start containerd

# 3. Network plugin not ready
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"
# Ensure CNI pods are running

# 4. Disk pressure
df -h
sudo find /var/log -type f -exec du -h {} + | sort -rh | head -20
sudo journalctl --vacuum-size=100M

# 5. Memory pressure
free -h
top
ps aux --sort=-%mem | head -20

# 6. Certificate issues
sudo ls -la /var/lib/kubelet/pki/
sudo kubeadm certs check-expiration
```

### Kubelet Not Starting

```bash
# Check kubelet status
sudo systemctl status kubelet

# Check kubelet logs
sudo journalctl -u kubelet --no-pager

# Common issues:

# 1. Swap enabled
free -h
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2. Wrong container runtime socket
ps aux | grep kubelet | grep container-runtime-endpoint
# Should show: --container-runtime-endpoint=unix:///run/containerd/containerd.sock

# 3. Missing kubeconfig
ls -la /etc/kubernetes/kubelet.conf

# 4. Port 10250 already in use
sudo lsof -i :10250
sudo netstat -tulpn | grep 10250

# 5. Wrong kubelet configuration
sudo cat /var/lib/kubelet/config.yaml

# Restart kubelet
sudo systemctl restart kubelet
sudo systemctl enable kubelet

# Check status again
sudo systemctl status kubelet
```

### Node Disk Full

```bash
# Check disk usage
df -h

# Find large files
sudo du -h / 2>/dev/null | sort -rh | head -20

# Common locations to check:
# /var/log - Log files
# /var/lib/containerd - Container images and layers
# /var/lib/kubelet/pods - Pod data

# Clean up container images
sudo crictl images
sudo crictl rmi --prune

# Clean up unused containers
sudo crictl ps -a
sudo crictl rm <container-id>

# Clean up logs
sudo find /var/log -type f -name "*.log" -mtime +7 -delete
sudo journalctl --vacuum-size=500M

# Clean up evicted pods (from control plane)
kubectl get pods --all-namespaces | grep Evicted
kubectl delete pod --field-selector=status.phase==Failed --all-namespaces
```

## Troubleshoot Control Plane Components

### API Server Issues

```bash
# Check API server is running
sudo crictl ps | grep kube-apiserver

# Check API server logs
sudo crictl logs <kube-apiserver-container-id>

# Or using kubectl (if API is partially working)
kubectl logs -n kube-system kube-apiserver-<node-name>

# Check API server manifest
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Common issues:

# 1. etcd not reachable
# Check etcd is running
sudo crictl ps | grep etcd

# Test etcd connection
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# 2. Certificate issues
ls -la /etc/kubernetes/pki/
sudo kubeadm certs check-expiration

# Renew certificates
sudo kubeadm certs renew all

# 3. Port 6443 in use or blocked
sudo lsof -i :6443
sudo netstat -tulpn | grep 6443

# 4. Manifest file error
# Check for YAML syntax errors
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep error

# Test manifest
sudo kubelet --dry-run

# Fix: Edit manifest
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
# API server will restart automatically
```

### Scheduler Not Scheduling

```bash
# Check scheduler is running
kubectl get pods -n kube-system | grep scheduler

# Check scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Check scheduler configuration
kubectl get configmap -n kube-system kube-scheduler-config -o yaml

# Common issues:

# 1. Scheduler pod not running
sudo crictl ps | grep kube-scheduler

# Check manifest
sudo cat /etc/kubernetes/manifests/kube-scheduler.yaml

# 2. Scheduler has no leader election
kubectl logs -n kube-system kube-scheduler-<node-name> | grep "leader"

# 3. All nodes are unschedulable
kubectl get nodes
kubectl describe node <node-name> | grep -i taints

# Remove taint if needed
kubectl taint nodes <node-name> <taint-key>-

# 4. Pods stuck in Pending
kubectl describe pod <pod-name>
# Check Events section for scheduling failures

# Common reasons pods don't schedule:
# - Insufficient resources
# - Node selectors don't match
# - Taints/tolerations
# - Pod affinity/anti-affinity
# - PersistentVolume not available
```

### Controller Manager Issues

```bash
# Check controller manager is running
kubectl get pods -n kube-system | grep controller-manager

# Check logs
kubectl logs -n kube-system kube-controller-manager-<node-name>

# Check manifest
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml

# Common issues:

# 1. Can't connect to API server
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "connection"

# 2. Leader election issues
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "leader"

# 3. Certificate issues
ls -la /etc/kubernetes/pki/
sudo kubeadm certs check-expiration

# 4. Missing service account token
kubectl get serviceaccount -n kube-system | grep controller
```

### etcd Issues

```bash
# Check etcd is running
sudo crictl ps | grep etcd

# Check etcd health
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Check etcd logs
sudo crictl logs <etcd-container-id>

# Or
kubectl logs -n kube-system etcd-<node-name>

# Common issues:

# 1. etcd data corruption
# Restore from backup
ETCDCTL_API=3 etcdctl snapshot restore /opt/backup.db --data-dir=/var/lib/etcd-restore

# Update etcd manifest to use new data directory
sudo vi /etc/kubernetes/manifests/etcd.yaml

# 2. etcd member not healthy (HA cluster)
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list

# Remove unhealthy member
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member remove <member-id>

# 3. Port 2379 or 2380 blocked
sudo lsof -i :2379
sudo lsof -i :2380

# 4. Disk I/O issues
iostat -x 1 5
sudo iotop
```

## Certificate Issues

```bash
# Check certificate expiration
sudo kubeadm certs check-expiration

# Renew all certificates
sudo kubeadm certs renew all

# Renew specific certificate
sudo kubeadm certs renew apiserver
sudo kubeadm certs renew front-proxy-client

# Restart control plane components after renewal
# They will pick up new certificates automatically
# Or manually restart kubelet
sudo systemctl restart kubelet

# Verify new certificates
sudo kubeadm certs check-expiration

# Update kubeconfig after certificate renewal
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

## Network Issues

```bash
# Check CNI plugin is installed
ls -la /etc/cni/net.d/
ls -la /opt/cni/bin/

# Check CNI pods are running
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# Check CNI pod logs
kubectl logs -n kube-system <cni-pod-name>

# For Calico
kubectl logs -n kube-system -l k8s-app=calico-node -c calico-node

# Test pod-to-pod connectivity
kubectl run test1 --image=busybox --restart=Never -- sleep 3600
kubectl run test2 --image=busybox --restart=Never -- sleep 3600

# Get pod IPs
kubectl get pods -o wide

# Test connectivity from test1 to test2
kubectl exec test1 -- ping -c 2 <test2-ip>

# Test DNS resolution
kubectl exec test1 -- nslookup kubernetes.default

# Check kube-proxy
kubectl get pods -n kube-system | grep kube-proxy
kubectl logs -n kube-system <kube-proxy-pod>

# Check kube-proxy mode
kubectl logs -n kube-system <kube-proxy-pod> | grep "proxy mode"
```

## Cluster Recovery Scenarios

### Scenario 1: etcd Data Deleted

```bash
# Symptoms: All resources are gone

# Solution: Restore from etcd backup
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-restore

# Update etcd manifest
sudo vi /etc/kubernetes/manifests/etcd.yaml
# Change data-dir to /var/lib/etcd-restore

sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/

# Wait for pods to restart
watch kubectl get pods -n kube-system

# Verify data
kubectl get all --all-namespaces
```

### Scenario 2: Control Plane Down

```bash
# Check what's down
sudo crictl ps
kubectl get pods -n kube-system

# Restart all control plane components
sudo systemctl restart kubelet

# Or remove and re-add manifests
sudo mv /etc/kubernetes/manifests/*.yaml /tmp/
sleep 10
sudo mv /tmp/*.yaml /etc/kubernetes/manifests/

# Wait for pods to start
watch sudo crictl ps
```

### Scenario 3: All Nodes NotReady

```bash
# Usually CNI issue

# Check CNI pods
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# If no CNI pods, reinstall
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Wait for CNI pods to run
kubectl get pods -n kube-system -w

# Nodes should become Ready
kubectl get nodes
```

## Troubleshooting Tips

### Gather Information

```bash
# System logs
sudo journalctl -xe
sudo journalctl -u kubelet --since "10 minutes ago"
sudo journalctl -u containerd --since "10 minutes ago"

# Describe resources
kubectl describe node <node-name>
kubectl describe pod <pod-name> -n kube-system

# Get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n kube-system --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods -n kube-system

# System resources
free -h
df -h
uptime
```

### Common Commands for Troubleshooting

```bash
# Control plane component logs
sudo crictl logs <container-id>
kubectl logs -n kube-system <pod-name>

# Kubelet logs
sudo journalctl -u kubelet -f

# Check processes
ps aux | grep kube
ps aux | grep containerd

# Check listening ports
sudo netstat -tulpn | grep -E "6443|2379|10250|10251|10252"

# Check certificates
sudo ls -la /etc/kubernetes/pki/
sudo kubeadm certs check-expiration

# Check config files
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml
sudo cat /var/lib/kubelet/config.yaml

# Test connectivity
ping <node-ip>
nc -zv <node-ip> 6443
curl -k https://<node-ip>:6443/healthz
```

## Key Files and Locations

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/` | Static pod manifests for control plane |
| `/etc/kubernetes/pki/` | Certificates and keys |
| `/var/lib/kubelet/config.yaml` | Kubelet configuration |
| `/var/lib/kubelet/pki/` | Kubelet certificates |
| `/var/lib/etcd/` | etcd data directory |
| `/etc/cni/net.d/` | CNI configuration |
| `/var/log/pods/` | Pod logs |
| `/var/lib/containerd/` | Container runtime data |

### Important Logs

```bash
# Kubelet
sudo journalctl -u kubelet

# Containerd
sudo journalctl -u containerd

# API server (control plane)
sudo crictl logs $(sudo crictl ps | grep kube-apiserver | awk '{print $1}')

# Scheduler
sudo crictl logs $(sudo crictl ps | grep kube-scheduler | awk '{print $1}')

# Controller manager
sudo crictl logs $(sudo crictl ps | grep kube-controller-manager | awk '{print $1}')

# etcd
sudo crictl logs $(sudo crictl ps | grep etcd | awk '{print $1}')
```

## Exam Tips

1. **Start with kubectl get nodes** - First indicator of cluster health
2. **Check system pods** - `kubectl get pods -n kube-system`
3. **Describe is your friend** - Always describe nodes/pods for events
4. **Logs, logs, logs** - journalctl for kubelet, crictl logs for control plane
5. **Common culprits**: swap enabled, kubelet not running, CNI missing
6. **Certificate expiration** - Check with kubeadm certs check-expiration
7. **etcd backup/restore** - Practice this thoroughly
8. **Restart kubelet** - Solves many issues
9. **Time management** - Don't spend too long on one issue
10. **Use documentation** - Refer to troubleshooting guides

## Common Mistakes

- ❌ Not checking node status first
- ❌ Forgetting to check system pods
- ❌ Not reading describe output events
- ❌ Overlooking kubelet logs (journalctl)
- ❌ Not verifying CNI plugin is installed
- ❌ Forgetting swap must be disabled
- ❌ Not checking certificate expiration
- ❌ Skipping etcd health check
- ❌ Not verifying containerd is running
- ❌ Restarting wrong component

## Quick Reference

### Health Check Sequence

```bash
# 1. Check nodes
kubectl get nodes

# 2. Check system pods
kubectl get pods -n kube-system

# 3. Check specific node
kubectl describe node <node-name>

# 4. Check kubelet (on node)
sudo systemctl status kubelet
sudo journalctl -u kubelet --since "5 minutes ago"

# 5. Check control plane (on control plane)
sudo crictl ps | grep kube

# 6. Check etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# 7. Check certificates
sudo kubeadm certs check-expiration
```

### Quick Fixes

```bash
# Node NotReady
sudo systemctl restart kubelet
sudo systemctl restart containerd

# Swap enabled
sudo swapoff -a

# No CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Certificates expired
sudo kubeadm certs renew all
sudo systemctl restart kubelet

# Control plane down
sudo systemctl restart kubelet
```
