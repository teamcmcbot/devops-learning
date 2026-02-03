# Prepare Infrastructure to Deploy a Kubernetes Cluster

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Understand requirements for nodes (master and worker)
- Configure system requirements (swap, firewall, ports)
- Install container runtime (containerd)
- Set up networking prerequisites
- Configure kernel modules and sysctl parameters
- Verify prerequisites before kubeadm init

## Sample Questions

1. **Disable swap on all nodes**
2. **Configure required kernel modules for networking**
3. **Install and configure containerd as container runtime**
4. **Set up required firewall rules and ports**
5. **Verify system requirements before cluster installation**

## Official Documentation

- [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [Container Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
- [Ports and Protocols](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)

## Key Concepts

### Node Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 2 GB | 4+ GB |
| **Disk** | 20 GB | 50+ GB |
| **Network** | Full network connectivity | Low latency |
| **OS** | Linux (Ubuntu, CentOS, etc.) | LTS version |

### Control Plane vs Worker Nodes

| Node Type | Components | Resources |
|-----------|------------|-----------|
| **Control Plane** | API server, etcd, scheduler, controller-manager | Higher CPU/RAM |
| **Worker Node** | kubelet, kube-proxy, container runtime | Based on workload |

## Required Ports

### Control Plane Nodes

| Port | Protocol | Purpose | Used By |
|------|----------|---------|---------|
| 6443 | TCP | Kubernetes API Server | All |
| 2379-2380 | TCP | etcd server client API | kube-apiserver, etcd |
| 10250 | TCP | Kubelet API | Control plane |
| 10259 | TCP | kube-scheduler | Self |
| 10257 | TCP | kube-controller-manager | Self |

### Worker Nodes

| Port | Protocol | Purpose | Used By |
|------|----------|---------|---------|
| 10250 | TCP | Kubelet API | Control plane |
| 30000-32767 | TCP | NodePort Services | All |

## System Prerequisites

### 1. Disable Swap

Kubernetes requires swap to be disabled.

```bash
# Check if swap is enabled
free -h
swapon --show

# Disable swap temporarily
sudo swapoff -a

# Disable swap permanently
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Verify swap is disabled
free -h
# Swap should show 0
```

### 2. Load Kernel Modules

```bash
# Load required modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Load modules now
sudo modprobe overlay
sudo modprobe br_netfilter

# Verify modules are loaded
lsmod | grep br_netfilter
lsmod | grep overlay
```

### 3. Configure sysctl Parameters

```bash
# Configure kernel parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters
sudo sysctl --system

# Verify settings
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

## Container Runtime Installation

### Install containerd

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl

# Install containerd
sudo apt-get install -y containerd

# Create default configuration
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Configure systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Verify containerd is running
sudo systemctl status containerd
```

### Alternative: Install from Docker Repository

```bash
# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt-get update

# Install containerd
sudo apt-get install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enable systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

## Install kubeadm, kubelet, and kubectl

```bash
# Update package index and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index
sudo apt-get update

# Install kubelet, kubeadm, and kubectl
sudo apt-get install -y kubelet kubeadm kubectl

# Hold packages at current version
sudo apt-mark hold kubelet kubeadm kubectl

# Verify installation
kubeadm version
kubelet --version
kubectl version --client

# Enable kubelet service
sudo systemctl enable kubelet
```

### Install Specific Version

```bash
# List available versions
apt-cache madison kubeadm

# Install specific version
sudo apt-get install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubeadm kubectl
```

## Firewall Configuration

### Ubuntu (UFW)

```bash
# Control Plane Node
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

# Worker Node
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp

# Reload firewall
sudo ufw reload
sudo ufw status
```

### CentOS/RHEL (firewalld)

```bash
# Control Plane Node
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp

# Worker Node
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp

# Reload firewall
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

### Disable Firewall (Development Only)

```bash
# Ubuntu
sudo ufw disable

# CentOS/RHEL
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

## Network Configuration

### Set Hostnames

```bash
# Control Plane Node
sudo hostnamectl set-hostname controlplane

# Worker Node
sudo hostnamectl set-hostname node01

# Verify
hostnamectl
```

### Configure /etc/hosts

```bash
# Add entries to /etc/hosts on all nodes
sudo tee -a /etc/hosts <<EOF
192.168.1.10 controlplane
192.168.1.11 node01
192.168.1.12 node02
EOF

# Verify
cat /etc/hosts
ping -c 2 controlplane
```

### Check Network Connectivity

```bash
# Test connectivity between nodes
ping -c 4 192.168.1.11

# Check if ports are accessible
nc -zv 192.168.1.10 6443

# Check listening ports
sudo netstat -tulpn | grep LISTEN
```

## Verification Checklist

### Pre-Installation Verification Script

```bash
#!/bin/bash

echo "=== Kubernetes Installation Prerequisites Check ==="

# Check OS
echo -n "OS: "
cat /etc/os-release | grep PRETTY_NAME

# Check CPU cores
echo -n "CPU Cores: "
nproc

# Check RAM
echo -n "RAM: "
free -h | grep Mem | awk '{print $2}'

# Check Disk
echo -n "Disk Space: "
df -h / | tail -1 | awk '{print $4}'

# Check Swap
echo -n "Swap Status: "
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "Disabled ✓"
else
    echo "Enabled ✗ (Must be disabled)"
fi

# Check br_netfilter module
echo -n "br_netfilter module: "
if lsmod | grep br_netfilter > /dev/null; then
    echo "Loaded ✓"
else
    echo "Not loaded ✗"
fi

# Check overlay module
echo -n "overlay module: "
if lsmod | grep overlay > /dev/null; then
    echo "Loaded ✓"
else
    echo "Not loaded ✗"
fi

# Check sysctl parameters
echo "Sysctl parameters:"
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.ipv4.ip_forward

# Check containerd
echo -n "containerd status: "
if systemctl is-active --quiet containerd; then
    echo "Running ✓"
else
    echo "Not running ✗"
fi

# Check if kubeadm is installed
echo -n "kubeadm: "
if command -v kubeadm &> /dev/null; then
    kubeadm version -o short
else
    echo "Not installed ✗"
fi

echo "=== End of Check ==="
```

### Save and run the script

```bash
# Save the script
cat > check-prereqs.sh << 'EOF'
[paste script above]
EOF

# Make executable
chmod +x check-prereqs.sh

# Run
./check-prereqs.sh
```

## Troubleshooting Tips

### Swap Still Enabled

```bash
# Error: "The system has swap enabled"

# Check swap status
free -h
swapon --show

# Disable temporarily
sudo swapoff -a

# Disable permanently
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Verify /etc/fstab
cat /etc/fstab | grep swap
```

### Kernel Modules Not Loading

```bash
# Error: "br_netfilter module not loaded"

# Manually load module
sudo modprobe br_netfilter

# Check if loaded
lsmod | grep br_netfilter

# Persist module loading
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf

# If module doesn't exist, install
sudo apt-get install -y linux-modules-extra-$(uname -r)
```

### containerd Not Starting

```bash
# Check status
sudo systemctl status containerd

# Check logs
sudo journalctl -xeu containerd

# Common issues:
# 1. Config file syntax error
sudo containerd config default | sudo tee /etc/containerd/config.toml

# 2. Missing dependencies
sudo apt-get install -y runc

# Restart service
sudo systemctl restart containerd
```

### Port Already in Use

```bash
# Check what's using port 6443
sudo lsof -i :6443
sudo netstat -tulpn | grep 6443

# Kill process if needed
sudo kill -9 <PID>

# Or change the port (not recommended for API server)
```

### DNS Resolution Issues

```bash
# Check DNS
nslookup kubernetes.io

# Check /etc/resolv.conf
cat /etc/resolv.conf

# Test connectivity
ping -c 4 8.8.8.8

# Temporarily use Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

## Key Files and Locations

| File/Directory | Purpose |
|----------------|---------|
| `/etc/containerd/config.toml` | containerd configuration |
| `/etc/modules-load.d/k8s.conf` | Kernel modules to load at boot |
| `/etc/sysctl.d/k8s.conf` | Kernel parameters |
| `/etc/fstab` | File systems to mount (check swap here) |
| `/etc/hosts` | Static hostname resolution |
| `/var/log/syslog` | System logs |
| `/var/lib/kubelet/` | kubelet data directory |

## Exam Tips

1. **Disable swap first** - Most common prerequisite issue
2. **Load kernel modules** - br_netfilter and overlay
3. **Configure sysctl** - IP forwarding and bridge filtering
4. **Verify containerd** - Must be running before kubeadm init
5. **Check hostname** - Should be unique and resolvable
6. **Test connectivity** - Between control plane and workers
7. **Use verification script** - Check all prerequisites
8. **Time management** - Infrastructure prep is quick, don't overthink
9. **Default config works** - Don't customize unless asked
10. **Document commands** - Practice the exact sequence

## Common Mistakes

- ❌ Forgetting to disable swap permanently
- ❌ Not loading kernel modules
- ❌ Skipping sysctl configuration
- ❌ Wrong systemd cgroup driver in containerd
- ❌ Firewall blocking required ports
- ❌ Not verifying containerd is running
- ❌ Installing incompatible versions
- ❌ Not holding package versions with apt-mark
- ❌ Missing /etc/hosts entries for nodes
- ❌ Not testing connectivity before kubeadm init

## Quick Reference

### Complete Setup Script (Ubuntu)

```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install kubeadm, kubelet, kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Infrastructure preparation complete!"
```
