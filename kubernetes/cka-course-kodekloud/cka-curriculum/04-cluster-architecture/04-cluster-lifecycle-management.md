# Manage the Lifecycle of a Cluster

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Upgrade Kubernetes cluster using kubeadm
- Backup and restore etcd cluster data
- Drain, cordon, and uncordon nodes
- Add and remove nodes from cluster
- Manage cluster certificates
- Troubleshoot cluster upgrade issues

## Sample Questions

1. **Upgrade control plane from v1.27 to v1.28**
2. **Upgrade worker nodes one by one**
3. **Backup etcd snapshot and restore from backup**
4. **Drain a node for maintenance**
5. **Check certificate expiration and renew certificates**

## Official Documentation

- [Upgrading kubeadm clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Operating etcd clusters](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
- [Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)

## Key Concepts

### Cluster Upgrade Strategy

```
1. Upgrade control plane first
2. Upgrade worker nodes one at a time
3. Maintain version skew policy
```

### Version Skew Policy

| Component | Allowed Versions |
|-----------|------------------|
| **kube-apiserver** | n (current version) |
| **kubelet** | n, n-1, n-2 |
| **kubectl** | n+1, n, n-1 |
| **kube-controller-manager** | n, n-1 |
| **kube-scheduler** | n, n-1 |
| **kube-proxy** | n, n-1, n-2 |

## Cluster Upgrade

### Check Current Version

```bash
# Check all component versions
kubectl get nodes
kubeadm version
kubelet --version
kubectl version --short

# Check available upgrade versions
sudo apt-cache madison kubeadm
```

### Upgrade Control Plane

```bash
# 1. Upgrade kubeadm on control plane
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

# 2. Verify kubeadm version
kubeadm version

# 3. Check upgrade plan
sudo kubeadm upgrade plan

# 4. Apply upgrade
sudo kubeadm upgrade apply v1.28.0

# 5. Drain control plane node
kubectl drain controlplane --ignore-daemonsets

# 6. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

# 7. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# 8. Uncordon control plane
kubectl uncordon controlplane

# 9. Verify
kubectl get nodes
```

### Upgrade Worker Nodes

```bash
# On Control Plane: Drain worker node
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data

# On Worker Node: Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

# On Worker Node: Upgrade node config
sudo kubeadm upgrade node

# On Worker Node: Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

# On Worker Node: Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# On Control Plane: Uncordon worker
kubectl uncordon node01

# Verify
kubectl get nodes
```

## etcd Backup and Restore

### Backup etcd

```bash
# Set etcd parameters
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-backup.db

# Verify backup
ETCDCTL_API=3 etcdctl \
  --write-out=table snapshot status /opt/etcd-backup.db
```

### Restore etcd

```bash
# 1. Stop API server (control plane node)
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# 2. Restore from snapshot
ETCDCTL_API=3 etcdctl \
  --data-dir=/var/lib/etcd-restore \
  snapshot restore /opt/etcd-backup.db

# 3. Update etcd manifest to use new data directory
sudo vi /etc/kubernetes/manifests/etcd.yaml
# Change:
#   - --data-dir=/var/lib/etcd
# To:
#   - --data-dir=/var/lib/etcd-restore
# Also update the volume hostPath

# 4. Start API server
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/

# 5. Wait for pods to restart
kubectl get pods -n kube-system

# 6. Verify data
kubectl get all --all-namespaces
```

### Alternative: Restore with Cluster Recreation

```bash
# 1. Restore snapshot to new directory
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-from-backup

# 2. Update etcd pod manifest
sudo vi /etc/kubernetes/manifests/etcd.yaml
# Update hostPath volumes to point to /var/lib/etcd-from-backup

# 3. Wait for etcd pod to restart
kubectl get pods -n kube-system -w

# 4. Verify
kubectl get nodes
kubectl get pods --all-namespaces
```

## Node Management

### Drain Node

```bash
# Drain node (evict pods gracefully)
kubectl drain node01

# Drain with common options
kubectl drain node01 --ignore-daemonsets

# Force drain (dangerous)
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data --force

# Drain with grace period
kubectl drain node01 --grace-period=30

# Verify node is drained
kubectl get nodes
# node01 should show SchedulingDisabled
```

### Cordon Node

```bash
# Mark node as unschedulable (doesn't evict existing pods)
kubectl cordon node01

# Verify
kubectl get nodes
# node01 shows SchedulingDisabled

# Check node details
kubectl describe node node01 | grep Taints
```

### Uncordon Node

```bash
# Mark node as schedulable again
kubectl uncordon node01

# Verify
kubectl get nodes
# node01 should show Ready (no SchedulingDisabled)
```

### Remove Node from Cluster

```bash
# 1. Drain node
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data

# 2. Delete node from cluster
kubectl delete node node01

# 3. On the node itself, reset
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf ~/.kube/config
```

### Add Node to Cluster

```bash
# 1. On control plane, generate join command
kubeadm token create --print-join-command

# 2. On new node, join cluster
sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# 3. Verify on control plane
kubectl get nodes
```

## Certificate Management

### Check Certificate Expiration

```bash
# Check all certificates
sudo kubeadm certs check-expiration

# Output shows expiration dates for:
# - admin.conf
# - apiserver
# - apiserver-etcd-client
# - apiserver-kubelet-client
# - controller-manager.conf
# - etcd-healthcheck-client
# - etcd-peer
# - etcd-server
# - front-proxy-client
# - scheduler.conf

# Check specific certificate
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A 2 Validity
```

### Renew Certificates

```bash
# Renew all certificates
sudo kubeadm certs renew all

# Renew specific certificate
sudo kubeadm certs renew apiserver
sudo kubeadm certs renew front-proxy-client

# Restart control plane components
sudo crictl ps | grep kube-apiserver
sudo crictl stop <container-id>
# API server will restart automatically

# Or restart kubelet
sudo systemctl restart kubelet

# Verify new expiration
sudo kubeadm certs check-expiration
```

## Troubleshooting Tips

### Upgrade Failed on Control Plane

```bash
# Check upgrade plan first
sudo kubeadm upgrade plan

# Common issues:
# 1. Version mismatch
kubeadm version        # Should match target version
kubectl version        # Check client/server version

# 2. etcd not healthy
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# 3. Control plane components not ready
kubectl get pods -n kube-system

# 4. Check logs
sudo journalctl -xeu kubelet
```

### Node Drain Stuck

```bash
# Error: "pod has local storage"
kubectl drain node01 --delete-emptydir-data

# Error: "DaemonSet-managed pods"
kubectl drain node01 --ignore-daemonsets

# Error: "pod doesn't have controller"
kubectl drain node01 --force

# Check what pods are blocking
kubectl get pods -o wide | grep node01

# Delete stuck pods manually
kubectl delete pod <pod-name> --grace-period=0 --force
```

### etcd Restore Failed

```bash
# Check etcd pod logs
kubectl logs -n kube-system etcd-controlplane

# Check etcd data directory permissions
sudo ls -ld /var/lib/etcd-restore
sudo chown -R root:root /var/lib/etcd-restore

# Verify etcd manifest
sudo cat /etc/kubernetes/manifests/etcd.yaml

# Check if etcd container is running
sudo crictl ps | grep etcd

# If etcd won't start, check for:
# 1. Wrong data directory path
# 2. Volume mount issues
# 3. Certificate problems
```

### Node Won't Join After Upgrade

```bash
# Reset node completely
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf ~/.kube/config

# Generate new join token
kubeadm token create --print-join-command

# Join with new token
sudo kubeadm join ...

# Check kubelet status
sudo systemctl status kubelet

# Check kubelet logs
sudo journalctl -xeu kubelet
```

## Key Files and Locations

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/` | Static pod manifests |
| `/etc/kubernetes/pki/` | Certificates and keys |
| `/var/lib/etcd/` | etcd data directory |
| `/opt/etcd-backup.db` | etcd backup (convention) |
| `/etc/kubernetes/admin.conf` | Admin kubeconfig |
| `/etc/systemd/system/kubelet.service.d/` | Kubelet service config |

## Exam Tips

1. **Upgrade control plane first**, then workers
2. **Always drain before upgrading** nodes
3. **Use --ignore-daemonsets** when draining
4. **Check kubeadm upgrade plan** before applying
5. **Backup etcd before major changes**
6. **Remember ETCDCTL_API=3** for etcd commands
7. **Certificate paths** are in /etc/kubernetes/pki/
8. **Uncordon after upgrade** - don't forget!
9. **Upgrade one worker at a time** for availability
10. **Practice the exact command sequence**

## Common Mistakes

- ❌ Upgrading workers before control plane
- ❌ Not draining nodes before upgrade
- ❌ Forgetting to uncordon after upgrade
- ❌ Not setting ETCDCTL_API=3
- ❌ Wrong certificate paths in etcd commands
- ❌ Not verifying backup before restore
- ❌ Upgrading all workers simultaneously
- ❌ Skipping kubeadm upgrade plan
- ❌ Not holding package versions after upgrade
- ❌ Forgetting to restart kubelet after upgrade

## Quick Reference

### Upgrade Sequence

```bash
# Control Plane
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm
sudo kubeadm upgrade apply v1.28.0
kubectl drain controlplane --ignore-daemonsets
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload && sudo systemctl restart kubelet
kubectl uncordon controlplane

# Worker Node (on control plane first)
kubectl drain node01 --ignore-daemonsets

# Then on worker
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm
sudo kubeadm upgrade node
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload && sudo systemctl restart kubelet

# Back on control plane
kubectl uncordon node01
```

### etcd Backup/Restore

```bash
# Backup
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup.db

# Restore
ETCDCTL_API=3 etcdctl --data-dir=/var/lib/etcd-restore \
  snapshot restore /opt/backup.db
# Then update /etc/kubernetes/manifests/etcd.yaml
```

### Node Operations

```bash
kubectl drain <node> --ignore-daemonsets        # Prepare for maintenance
kubectl cordon <node>                           # Mark unschedulable
kubectl uncordon <node>                         # Mark schedulable
kubectl delete node <node>                      # Remove from cluster
```
