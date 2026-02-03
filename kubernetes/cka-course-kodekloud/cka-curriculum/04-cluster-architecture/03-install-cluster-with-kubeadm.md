# Use kubeadm to Install a Basic Cluster

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Initialize a control plane with kubeadm init
- Join worker nodes to the cluster
- Configure kubectl for cluster access
- Install a CNI plugin (Calico, Weave, Flannel)
- Troubleshoot cluster initialization issues
- Generate and use join tokens

## Sample Questions

1. **Initialize a cluster on the control plane node**
2. **Install a CNI plugin to enable pod networking**
3. **Generate a join token and add a worker node**
4. **Configure kubectl to access the cluster**
5. **Troubleshoot node not ready status**

## Official Documentation

- [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Installing Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)
- [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/)

## Key Concepts

### Cluster Initialization Workflow

```
1. kubeadm init (control plane)
   ↓
2. Configure kubectl
   ↓
3. Install CNI plugin
   ↓
4. kubeadm join (worker nodes)
   ↓
5. Verify cluster
```

### kubeadm Components

| Component | Purpose |
|-----------|---------|
| **kubeadm init** | Initialize control plane |
| **kubeadm join** | Join nodes to cluster |
| **kubeadm token** | Manage bootstrap tokens |
| **kubeadm reset** | Undo cluster initialization |
| **kubeadm upgrade** | Upgrade cluster version |

## Initialize Control Plane

### Basic Initialization

```bash
# Initialize cluster
sudo kubeadm init

# The output will show:
# 1. Pre-flight checks
# 2. Certificate generation
# 3. Control plane components
# 4. kubeadm join command
```

### Initialize with Options

```bash
# Initialize with pod network CIDR
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Initialize with specific Kubernetes version
sudo kubeadm init --kubernetes-version=v1.28.0

# Initialize with API server advertise address
sudo kubeadm init --apiserver-advertise-address=192.168.1.10

# Initialize with custom control plane endpoint (for HA)
sudo kubeadm init --control-plane-endpoint=cluster-endpoint:6443

# Combine multiple options
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=192.168.1.10 \
  --kubernetes-version=v1.28.0
```

### Configure kubectl (Run as Regular User)

```bash
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify
kubectl get nodes
kubectl cluster-info
```

### Configure kubectl (Alternative for Root)

```bash
# Set KUBECONFIG environment variable
export KUBECONFIG=/etc/kubernetes/admin.conf

# Add to shell profile
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
source ~/.bashrc
```

## Install CNI Plugin

### Option 1: Calico

```bash
# Apply Calico manifest
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verify Calico pods
kubectl get pods -n kube-system | grep calico

# Check nodes become Ready
kubectl get nodes
```

### Option 2: Weave Net

```bash
# Apply Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Verify Weave pods
kubectl get pods -n kube-system | grep weave

# Check nodes
kubectl get nodes
```

### Option 3: Flannel

```bash
# Apply Flannel (requires --pod-network-cidr=10.244.0.0/16)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Verify Flannel pods
kubectl get pods -n kube-system | grep flannel

# Check nodes
kubectl get nodes
```

## Join Worker Nodes

### Generate Join Command

```bash
# On control plane, create join token
kubeadm token create --print-join-command

# Output example:
# kubeadm join 192.168.1.10:6443 --token abcdef.0123456789abcdef \
#   --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

### Join Worker Node

```bash
# On worker node, run the join command
sudo kubeadm join 192.168.1.10:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:1234567890abcdef...

# Verify on control plane
kubectl get nodes
```

### Token Management

```bash
# List tokens
kubeadm token list

# Create new token
kubeadm token create

# Create token with custom TTL
kubeadm token create --ttl 2h

# Create token that never expires (not recommended)
kubeadm token create --ttl 0

# Delete token
kubeadm token delete <token>

# Get CA cert hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
  openssl rsa -pubin -outform der 2>/dev/null | \
  openssl dgst -sha256 -hex | sed 's/^.* //'
```

## Verify Cluster

```bash
# Check nodes
kubectl get nodes
kubectl get nodes -o wide

# Check all pods
kubectl get pods --all-namespaces

# Check system pods
kubectl get pods -n kube-system

# Check component status
kubectl get componentstatuses
kubectl get cs  # Short form

# Cluster info
kubectl cluster-info
kubectl cluster-info dump

# Check API server
kubectl get --raw /healthz
kubectl get --raw /readyz
```

## Complete Example

### Control Plane Setup

```bash
# 1. Initialize cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# 2. Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 3. Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 4. Wait for control plane to be Ready
kubectl get nodes
# Should show: controlplane   Ready    control-plane   1m   v1.28.0

# 5. Generate join command for workers
kubeadm token create --print-join-command
```

### Worker Node Setup

```bash
# 1. Join cluster (using command from control plane)
sudo kubeadm join 192.168.1.10:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:1234567890abcdef...

# 2. Verify on control plane
kubectl get nodes
# Should show:
# controlplane   Ready    control-plane   5m   v1.28.0
# node01         Ready    <none>          1m   v1.28.0
```

## Troubleshooting Tips

### Node Not Ready

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Common cause: CNI not installed
kubectl get pods -n kube-system
# Should see CNI pods (calico, weave, flannel)

# Check kubelet status
sudo systemctl status kubelet

# Check kubelet logs
sudo journalctl -xeu kubelet

# Check for CNI config
ls /etc/cni/net.d/
```

### kubeadm init Failed

```bash
# Check pre-flight errors
sudo kubeadm init --dry-run

# Common issues:
# 1. Swap enabled
sudo swapoff -a

# 2. Port 6443 in use
sudo lsof -i :6443

# 3. containerd not running
sudo systemctl status containerd

# 4. Previous cluster exists
sudo kubeadm reset
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/etcd/

# Reset and try again
sudo kubeadm reset -f
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

### kubeadm join Failed

```bash
# Error: "couldn't validate the identity of the API Server"

# 1. Check token is valid
kubeadm token list

# 2. Generate new join command
kubeadm token create --print-join-command

# 3. Check network connectivity
ping -c 2 <control-plane-ip>
nc -zv <control-plane-ip> 6443

# 4. Check firewall
sudo ufw status
```

### Pods Stuck in Pending

```bash
# Check pod status
kubectl get pods --all-namespaces

# Describe pod
kubectl describe pod <pod-name> -n kube-system

# Common causes:
# 1. CNI not installed
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 2. Insufficient resources
kubectl describe nodes

# 3. Taints on control plane
kubectl describe node controlplane | grep Taints
# Remove taint if needed (not recommended for production)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Cannot Connect to API Server

```bash
# Error: "Unable to connect to the server"

# 1. Check if API server is running
sudo crictl ps | grep kube-apiserver

# 2. Check API server logs
sudo crictl logs <container-id>

# 3. Check kubeconfig
cat ~/.kube/config

# 4. Check API server endpoint
kubectl config view

# 5. Restart kubelet
sudo systemctl restart kubelet
```

### Token Expired

```bash
# Error: "token id 'abcdef' is expired"

# 1. Create new token on control plane
kubeadm token create

# 2. Generate join command
kubeadm token create --print-join-command

# 3. Use new command on worker
sudo kubeadm reset -f
sudo kubeadm join ...
```

## Key Files and Locations

### Control Plane

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/` | Static pod manifests (API server, etcd, etc.) |
| `/etc/kubernetes/admin.conf` | Admin kubeconfig |
| `/etc/kubernetes/pki/` | Certificates and keys |
| `/var/lib/etcd/` | etcd data directory |
| `~/.kube/config` | User kubeconfig file |

### Worker Node

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/kubelet.conf` | Kubelet kubeconfig |
| `/etc/kubernetes/bootstrap-kubelet.conf` | Bootstrap config |
| `/var/lib/kubelet/` | Kubelet data directory |
| `/etc/cni/net.d/` | CNI configuration |
| `/opt/cni/bin/` | CNI binaries |

### Important Logs

```bash
# Kubelet logs
sudo journalctl -u kubelet -f

# Container runtime logs
sudo journalctl -u containerd -f

# API server logs (control plane)
sudo crictl logs <kube-apiserver-container-id>

# Check all system pods logs
kubectl logs -n kube-system <pod-name>
```

## Exam Tips

1. **Save kubeadm init output** - Contains join command and instructions
2. **Configure kubectl immediately** - Cannot proceed without it
3. **Install CNI before joining workers** - Pods won't schedule otherwise
4. **Use --print-join-command** - Fastest way to get join command
5. **Check nodes with -o wide** - Shows more details
6. **Time saver**: Combine init options in one command
7. **Reset if stuck**: `kubeadm reset` cleans everything
8. **Verify each step**: Don't move forward if current step failed
9. **Check system pods**: All should be Running in kube-system
10. **Practice without notes**: Memorize the sequence

## Common Mistakes

- ❌ Forgetting to install CNI plugin
- ❌ Not configuring kubectl before using it
- ❌ Running kubectl as root without KUBECONFIG
- ❌ Wrong pod-network-cidr for CNI (Flannel needs 10.244.0.0/16)
- ❌ Using expired token to join nodes
- ❌ Not waiting for control plane to be Ready
- ❌ Joining worker before CNI is installed
- ❌ Not checking node status after join
- ❌ Forgetting sudo for kubeadm commands
- ❌ Not verifying prerequisites before init

## Quick Reference

### Minimal Cluster Setup

```bash
# Control Plane
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubeadm token create --print-join-command

# Worker Node
sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Verify
kubectl get nodes
kubectl get pods --all-namespaces
```

### Reset Cluster

```bash
# On all nodes
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf ~/.kube/config

# On control plane only
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/etcd/
```

### Common Commands

```bash
# Init variations
kubeadm init --dry-run                              # Test without creating
kubeadm init --pod-network-cidr=<cidr>              # Specify pod network
kubeadm init --apiserver-advertise-address=<ip>     # Specify API server IP
kubeadm init --ignore-preflight-errors=NumCPU       # Ignore specific checks

# Token management
kubeadm token list                                  # List tokens
kubeadm token create                                # Create token
kubeadm token delete <token>                        # Delete token
kubeadm token create --print-join-command           # Generate join command

# Cluster operations
kubeadm reset                                       # Reset node
kubeadm version                                     # Show version
kubeadm config print init-defaults                  # Show default config
```
