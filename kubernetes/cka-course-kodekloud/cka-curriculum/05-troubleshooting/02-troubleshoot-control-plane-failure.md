# Troubleshoot Control Plane Component Failure

## Exam Weight
Part of **30% - Troubleshooting**

## What Can Be Tested

- Diagnose API server failures
- Fix scheduler issues
- Troubleshoot controller manager problems
- Resolve etcd cluster issues
- Fix control plane component misconfigurations
- Restore control plane functionality

## Sample Questions

1. **API server is not responding - diagnose and fix**
2. **Scheduler stopped scheduling pods - investigate**
3. **Controller manager can't create ReplicaSets - troubleshoot**
4. **etcd cluster member is unhealthy - fix**
5. **Control plane component certificate has expired - renew**

## Official Documentation

- [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/)
- [etcd Operation Guide](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
- [PKI certificates and requirements](https://kubernetes.io/docs/setup/best-practices/certificates/)

## Key Concepts

### Control Plane Components

```
┌───────────────────────────────────────────┐
│          Control Plane Node               │
│                                           │
│  ┌──────────────┐    ┌────────────────┐  │
│  │ kube-        │◄──►│    etcd        │  │
│  │ apiserver    │    │   (storage)    │  │
│  └──────┬───────┘    └────────────────┘  │
│         │                                 │
│         ▼                                 │
│  ┌──────────────┐    ┌────────────────┐  │
│  │ kube-        │    │ kube-          │  │
│  │ scheduler    │    │ controller-    │  │
│  │              │    │ manager        │  │
│  └──────────────┘    └────────────────┘  │
└───────────────────────────────────────────┘
```

### Component Dependencies

```
etcd → API Server → Scheduler
  │                     ↓
  └─────────────→ Controller Manager
```

## API Server Troubleshooting

### Check API Server Status

```bash
# Check if API server container is running
sudo crictl ps | grep kube-apiserver

# Check API server pod (if API is accessible)
kubectl get pods -n kube-system | grep apiserver

# Check API server logs
sudo crictl logs <kube-apiserver-container-id>

# Or using kubectl
kubectl logs -n kube-system kube-apiserver-<node-name>

# Test API server health endpoints
curl -k https://localhost:6443/healthz
curl -k https://localhost:6443/readyz
curl -k https://localhost:6443/livez

# Check if API server is listening
sudo netstat -tulpn | grep 6443
sudo lsof -i :6443
```

### Common API Server Issues

#### Issue 1: API Server Not Starting

```bash
# Check manifest file
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Common problems:
# 1. YAML syntax error
# 2. Wrong etcd endpoints
# 3. Certificate path errors
# 4. Missing volumes

# Validate YAML syntax
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | python3 -m yaml

# Check kubelet is processing the manifest
sudo journalctl -u kubelet | grep apiserver

# Check if manifest directory is correct
ps aux | grep kubelet | grep "pod-manifest-path"

# Should show: --pod-manifest-path=/etc/kubernetes/manifests
```

#### Issue 2: Can't Connect to etcd

```bash
# Check etcd is running
sudo crictl ps | grep etcd

# Test etcd connectivity from API server perspective
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt \
  --key=/etc/kubernetes/pki/apiserver-etcd-client.key \
  endpoint health

# Check etcd endpoint in API server manifest
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd-servers

# Should be: --etcd-servers=https://127.0.0.1:2379

# Fix etcd endpoint if wrong
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
# Update --etcd-servers flag
```

#### Issue 3: Certificate Issues

```bash
# Check API server certificates
sudo ls -la /etc/kubernetes/pki/ | grep apiserver

# Should see:
# apiserver.crt
# apiserver.key
# apiserver-kubelet-client.crt
# apiserver-kubelet-client.key
# apiserver-etcd-client.crt
# apiserver-etcd-client.key

# Check certificate expiration
sudo kubeadm certs check-expiration

# Check specific certificate
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A 2 Validity

# Renew certificates
sudo kubeadm certs renew apiserver
sudo kubeadm certs renew apiserver-kubelet-client
sudo kubeadm certs renew apiserver-etcd-client

# Restart API server (remove and restore manifest)
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
sleep 10
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

#### Issue 4: Port Already in Use

```bash
# Check what's using port 6443
sudo lsof -i :6443
sudo netstat -tulpn | grep 6443

# Kill the process if needed
sudo kill -9 <PID>

# Or change the port in manifest (not recommended)
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
# Update --secure-port=6443
```

### Fix API Server Manifest

```bash
# Backup current manifest
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver.yaml.backup

# Edit manifest
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Common fixes:
# 1. Fix etcd endpoint: --etcd-servers=https://127.0.0.1:2379
# 2. Fix certificate paths
# 3. Fix volume mounts
# 4. Fix command flags

# API server will automatically restart after saving
# Wait for restart
watch sudo crictl ps | grep kube-apiserver

# Verify API server is working
kubectl get nodes
kubectl cluster-info
```

## Scheduler Troubleshooting

### Check Scheduler Status

```bash
# Check scheduler pod
kubectl get pods -n kube-system | grep scheduler

# Check scheduler container
sudo crictl ps | grep kube-scheduler

# Check scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Or
sudo crictl logs <kube-scheduler-container-id>
```

### Common Scheduler Issues

#### Issue 1: Scheduler Not Running

```bash
# Check if scheduler container exists
sudo crictl ps -a | grep kube-scheduler

# Check manifest
sudo cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Check for errors in manifest
# Common issues:
# - Wrong kubeconfig path
# - Missing volumes
# - Syntax errors

# Check kubelet is processing manifest
sudo journalctl -u kubelet | grep scheduler
```

#### Issue 2: Pods Stuck in Pending

```bash
# Check scheduler logs for why pods aren't scheduled
kubectl logs -n kube-system kube-scheduler-<node-name>

# Look for messages like:
# "0/3 nodes are available: insufficient cpu"
# "0/3 nodes are available: node(s) had taints"

# Describe the pending pod
kubectl describe pod <pod-name>

# Check Events section for scheduling failures

# Common reasons:
# 1. No nodes available
kubectl get nodes

# 2. Nodes are tainted
kubectl describe nodes | grep -i taints

# Remove taint if needed
kubectl taint nodes <node-name> <taint-key>-

# 3. Resource constraints
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# 4. Pod has node selector that doesn't match
kubectl get pod <pod-name> -o yaml | grep -A 5 nodeSelector

# 5. Affinity/Anti-affinity rules
kubectl get pod <pod-name> -o yaml | grep -A 10 affinity
```

#### Issue 3: Leader Election Failed

```bash
# Check scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name> | grep -i leader

# Should see: "successfully acquired lease"

# If not, check:
# 1. Can scheduler reach API server?
# 2. RBAC permissions correct?

# Check scheduler service account
kubectl get sa -n kube-system | grep scheduler

# Check lease
kubectl get lease -n kube-system kube-scheduler
kubectl describe lease -n kube-system kube-scheduler
```

### Fix Scheduler Manifest

```bash
# Backup manifest
sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

# Edit manifest
sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml

# Verify kubeconfig path
# Should be: --kubeconfig=/etc/kubernetes/scheduler.conf

# Verify volume mounts match

# Scheduler will restart automatically
watch kubectl get pods -n kube-system | grep scheduler

# Verify scheduling works
kubectl run test --image=nginx
kubectl get pod test -w
```

## Controller Manager Troubleshooting

### Check Controller Manager Status

```bash
# Check controller manager pod
kubectl get pods -n kube-system | grep controller-manager

# Check container
sudo crictl ps | grep kube-controller-manager

# Check logs
kubectl logs -n kube-system kube-controller-manager-<node-name>

# Or
sudo crictl logs <kube-controller-manager-container-id>
```

### Common Controller Manager Issues

#### Issue 1: Controllers Not Running

```bash
# Check controller manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name>

# Look for:
# - "Started <controller-name>"
# - Any error messages

# Check which controllers are enabled
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "Started"

# If controllers aren't starting, check manifest
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml
```

#### Issue 2: ReplicaSets Not Creating Pods

```bash
# Check ReplicaSet
kubectl describe rs <replicaset-name>

# Check Events for errors

# Check controller manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep -i replicaset

# Check if replication controller is running
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "Started deployment controller"
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "Started replicaset controller"
```

#### Issue 3: Service Accounts Not Being Created

```bash
# Check controller manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep -i "serviceaccount"

# Check if service account controller is running
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep "Started serviceaccount controller"

# Check manifest for service account flags
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep service-account

# Should see:
# --service-account-private-key-file=/etc/kubernetes/pki/sa.key

# Verify key file exists
sudo ls -la /etc/kubernetes/pki/sa.key
```

#### Issue 4: Leader Election Issues

```bash
# Check logs for leader election
kubectl logs -n kube-system kube-controller-manager-<node-name> | grep -i leader

# Check lease
kubectl get lease -n kube-system kube-controller-manager
kubectl describe lease -n kube-system kube-controller-manager
```

### Fix Controller Manager Manifest

```bash
# Backup manifest
sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp/

# Edit manifest
sudo vi /etc/kubernetes/manifests/kube-controller-manager.yaml

# Common fixes:
# 1. Verify kubeconfig: --kubeconfig=/etc/kubernetes/controller-manager.conf
# 2. Verify service account key: --service-account-private-key-file=/etc/kubernetes/pki/sa.key
# 3. Verify cluster signing cert: --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
# 4. Verify cluster signing key: --cluster-signing-key-file=/etc/kubernetes/pki/ca.key

# Controller manager will restart automatically
watch kubectl get pods -n kube-system | grep controller-manager

# Test functionality
kubectl create deployment test --image=nginx --replicas=3
kubectl get deployment test
kubectl get rs
kubectl get pods
```

## etcd Troubleshooting

### Check etcd Status

```bash
# Check etcd container
sudo crictl ps | grep etcd

# Check etcd pod
kubectl get pods -n kube-system | grep etcd

# Check etcd logs
sudo crictl logs <etcd-container-id>

# Or
kubectl logs -n kube-system etcd-<node-name>

# Check etcd health
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Check etcd members
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list

# Check etcd status
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status --write-out=table
```

### Common etcd Issues

#### Issue 1: etcd Not Starting

```bash
# Check etcd manifest
sudo cat /etc/kubernetes/manifests/etcd.yaml

# Common issues:
# 1. Wrong data directory path
# 2. Certificate path errors
# 3. Port already in use
# 4. Data directory permissions

# Check data directory
sudo ls -la /var/lib/etcd/
sudo df -h /var/lib/etcd/

# Check permissions
sudo ls -ld /var/lib/etcd/

# Fix permissions if needed
sudo chown -R root:root /var/lib/etcd/

# Check ports
sudo lsof -i :2379
sudo lsof -i :2380
```

#### Issue 2: etcd Data Corruption

```bash
# Symptoms: etcd logs show corruption errors

# Solution: Restore from backup
# 1. Stop API server
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# 2. Restore snapshot
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-restore

# 3. Update etcd manifest to use new data directory
sudo vi /etc/kubernetes/manifests/etcd.yaml

# Change:
# - --data-dir=/var/lib/etcd
# To:
# - --data-dir=/var/lib/etcd-restore

# Also update volume hostPath:
#   volumes:
#   - hostPath:
#       path: /var/lib/etcd-restore
#       type: DirectoryOrCreate
#     name: etcd-data

# 4. Start API server
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/

# 5. Wait for pods to restart
watch kubectl get pods -n kube-system

# 6. Verify
kubectl get all --all-namespaces
```

#### Issue 3: etcd Out of Space

```bash
# Check disk space
df -h /var/lib/etcd/

# Check etcd database size
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status --write-out=table

# Compact etcd history
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  compact <revision>

# Get current revision
REV=$(ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status --write-out="json" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['Status']['header']['revision'])")

# Compact and defragment
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  compact $REV

ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  defrag
```

## Troubleshooting Workflow

### Step-by-Step Debugging

```bash
# 1. Check all control plane components are running
sudo crictl ps | grep kube

# Should see:
# - kube-apiserver
# - kube-scheduler
# - kube-controller-manager
# - etcd

# 2. Check which component is failing
kubectl get pods -n kube-system

# 3. Check logs of failing component
sudo crictl logs <container-id>

# 4. Check manifest file
sudo cat /etc/kubernetes/manifests/<component>.yaml

# 5. Check certificates
sudo kubeadm certs check-expiration

# 6. Check etcd specifically
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# 7. Check kubelet
sudo systemctl status kubelet
sudo journalctl -u kubelet | grep -i error

# 8. Fix the issue and verify
kubectl get pods -n kube-system
kubectl get nodes
```

## Key Files and Locations

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/kube-apiserver.yaml` | API server static pod |
| `/etc/kubernetes/manifests/kube-scheduler.yaml` | Scheduler static pod |
| `/etc/kubernetes/manifests/kube-controller-manager.yaml` | Controller manager static pod |
| `/etc/kubernetes/manifests/etcd.yaml` | etcd static pod |
| `/etc/kubernetes/pki/` | Certificates directory |
| `/etc/kubernetes/admin.conf` | Admin kubeconfig |
| `/etc/kubernetes/scheduler.conf` | Scheduler kubeconfig |
| `/etc/kubernetes/controller-manager.conf` | Controller manager kubeconfig |
| `/var/lib/etcd/` | etcd data directory |

## Exam Tips

1. **Check component status first** - `sudo crictl ps | grep kube`
2. **Logs are critical** - Always check logs for errors
3. **Manifest files** - Most issues are in manifests
4. **etcd is key** - If etcd is down, API server won't work
5. **Certificate expiration** - Common cause of failures
6. **Automatic restart** - Static pods restart when manifest changes
7. **Backup first** - Always backup manifests before editing
8. **Test connectivity** - Ensure components can reach each other
9. **Time management** - Quick wins: restart kubelet, check certificates
10. **Documentation** - Refer to troubleshooting guides

## Common Mistakes

- ❌ Not checking logs first
- ❌ Editing wrong manifest file
- ❌ Breaking YAML syntax when editing
- ❌ Not backing up manifest before changes
- ❌ Forgetting automatic restart after manifest change
- ❌ Not checking certificate expiration
- ❌ Wrong etcd endpoints in API server
- ❌ Not verifying etcd health
- ❌ Ignoring volume mount paths in manifests
- ❌ Not waiting for pods to restart

## Quick Reference

### Component Health Check

```bash
# All control plane components
sudo crictl ps | grep kube
kubectl get pods -n kube-system

# API Server
curl -k https://localhost:6443/healthz

# etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Certificates
sudo kubeadm certs check-expiration

# Kubelet
sudo systemctl status kubelet
```

### Quick Fixes

```bash
# Restart all control plane components
sudo systemctl restart kubelet

# Restart specific component (edit manifest)
sudo mv /etc/kubernetes/manifests/<component>.yaml /tmp/
sleep 5
sudo mv /tmp/<component>.yaml /etc/kubernetes/manifests/

# Renew all certificates
sudo kubeadm certs renew all
sudo systemctl restart kubelet

# etcd restore
ETCDCTL_API=3 etcdctl snapshot restore /opt/backup.db --data-dir=/var/lib/etcd-restore
# Then update etcd manifest data-dir
```
