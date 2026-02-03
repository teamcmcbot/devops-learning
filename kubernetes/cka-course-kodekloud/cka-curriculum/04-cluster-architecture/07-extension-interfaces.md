# Understand Extension Interfaces (CNI, CSI, CRI)

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Understand Container Runtime Interface (CRI)
- Understand Container Network Interface (CNI)
- Understand Container Storage Interface (CSI)
- Know which runtime, network, and storage plugins to use
- Troubleshoot plugin issues
- Install and configure CNI plugins

## Sample Questions

1. **Identify the container runtime being used**
2. **Install a CNI plugin (Calico, Weave, Flannel)**
3. **Troubleshoot pod networking issues related to CNI**
4. **List available storage classes from CSI driver**
5. **Check which CRI socket kubelet is using**

## Official Documentation

- [Container Runtime Interface (CRI)](https://kubernetes.io/docs/concepts/architecture/cri/)
- [Network Plugins (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

## Key Concepts

### Extension Interfaces Overview

| Interface | Purpose | Examples |
|-----------|---------|----------|
| **CRI** | Container runtime communication | containerd, CRI-O, Docker (deprecated) |
| **CNI** | Pod networking | Calico, Flannel, Weave Net, Cilium |
| **CSI** | Storage provisioning | AWS EBS, Azure Disk, GCE PD, Ceph |

### Architecture

```
┌─────────────────────────────────────────┐
│           Kubernetes                    │
│  ┌──────────┐  ┌──────────┐            │
│  │ kubelet  │  │  kube-   │            │
│  │          │  │ controller│            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│  ┌────▼─────────────▼──────────────┐   │
│  │     Extension Interfaces        │   │
│  ├──────────┬─────────┬───────────┤   │
│  │   CRI    │   CNI   │    CSI    │   │
│  └────┬─────┴────┬────┴─────┬─────┘   │
└───────┼──────────┼──────────┼─────────┘
        │          │          │
   ┌────▼────┐┌───▼────┐┌───▼─────┐
   │Container││Network ││ Storage │
   │ Runtime ││ Plugin ││  Driver │
   └─────────┘└────────┘└─────────┘
```

## Container Runtime Interface (CRI)

### Overview

CRI is a plugin interface that enables kubelet to use different container runtimes without recompiling Kubernetes.

### Supported Container Runtimes

| Runtime | Status | Socket Path |
|---------|--------|-------------|
| **containerd** | Recommended | `/run/containerd/containerd.sock` |
| **CRI-O** | Supported | `/var/run/crio/crio.sock` |
| **Docker** | Deprecated (removed in v1.24) | N/A |

### Check Container Runtime

```bash
# Check runtime from node
kubectl get nodes -o wide
# Look at CONTAINER-RUNTIME column

# Check kubelet config
ps aux | grep kubelet | grep container-runtime-endpoint

# Check CRI socket
ls -la /run/containerd/containerd.sock
ls -la /var/run/crio/crio.sock

# Verify containerd is running
sudo systemctl status containerd

# Check containerd version
sudo containerd --version

# Using crictl (CRI CLI tool)
sudo crictl version
sudo crictl info
```

### Configure kubelet to use CRI

```bash
# Check kubelet configuration
sudo cat /var/lib/kubelet/config.yaml | grep -A 5 containerRuntime

# Or check systemd unit
sudo systemctl cat kubelet

# containerd socket (default)
# --container-runtime-endpoint=unix:///run/containerd/containerd.sock

# CRI-O socket
# --container-runtime-endpoint=unix:///var/run/crio/crio.sock
```

### Using crictl (CRI CLI)

```bash
# Set crictl endpoint
export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock

# Or configure crictl
sudo tee /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

# List containers
sudo crictl ps
sudo crictl ps -a

# List images
sudo crictl images

# Pull image
sudo crictl pull nginx:latest

# Inspect container
sudo crictl inspect <container-id>

# View container logs
sudo crictl logs <container-id>

# Execute command in container
sudo crictl exec -it <container-id> sh

# Stop container
sudo crictl stop <container-id>

# Remove container
sudo crictl rm <container-id>

# List pods
sudo crictl pods

# Inspect pod
sudo crictl inspectp <pod-id>
```

## Container Network Interface (CNI)

### Overview

CNI is a standard for configuring network interfaces in Linux containers. It handles:
- IP address allocation
- Network connectivity between pods
- Network policies

### Popular CNI Plugins

| Plugin | Use Case | Network Policy | Overlay |
|--------|----------|----------------|---------|
| **Calico** | Production, Network Policy | ✅ Yes | Optional |
| **Flannel** | Simple overlay networking | ❌ No | ✅ Yes (VXLAN) |
| **Weave Net** | Simplicity, encryption | ✅ Yes | ✅ Yes |
| **Cilium** | Advanced, eBPF-based | ✅ Yes | ✅ Yes |
| **Multus** | Multiple network interfaces | N/A | N/A |

### CNI Configuration Location

```bash
# CNI configuration directory
ls -la /etc/cni/net.d/

# CNI binary plugins
ls -la /opt/cni/bin/

# Example CNI config file
cat /etc/cni/net.d/10-calico.conflist
```

### Install CNI Plugins

#### Calico

```bash
# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verify Calico pods
kubectl get pods -n kube-system | grep calico

# Check Calico nodes
kubectl get nodes

# View Calico configuration
kubectl get configmap -n kube-system calico-config -o yaml

# Check CNI config created by Calico
cat /etc/cni/net.d/10-calico.conflist
```

#### Flannel

```bash
# Install Flannel (requires --pod-network-cidr=10.244.0.0/16)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Verify Flannel
kubectl get pods -n kube-system | grep flannel

# Check Flannel config
kubectl get configmap -n kube-system kube-flannel-cfg -o yaml

# View CNI config
cat /etc/cni/net.d/10-flannel.conflist
```

#### Weave Net

```bash
# Install Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Verify Weave
kubectl get pods -n kube-system | grep weave

# Check Weave status
kubectl exec -n kube-system <weave-pod> -c weave -- /home/weave/weave --local status

# View CNI config
cat /etc/cni/net.d/10-weave.conflist
```

### Troubleshoot CNI

```bash
# Check if CNI plugin is installed
ls -la /opt/cni/bin/

# Check CNI configuration
ls -la /etc/cni/net.d/
cat /etc/cni/net.d/*.conf*

# Check CNI pods
kubectl get pods -n kube-system -o wide

# Describe CNI pod
kubectl describe pod -n kube-system <cni-pod-name>

# View CNI pod logs
kubectl logs -n kube-system <cni-pod-name>

# For multi-container pods (like Calico)
kubectl logs -n kube-system <calico-pod> -c calico-node

# Test pod networking
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
kubectl get pod test-pod -o wide
kubectl exec test-pod -- ping -c 2 <another-pod-ip>

# Check pod can resolve DNS
kubectl exec test-pod -- nslookup kubernetes.default
```

## Container Storage Interface (CSI)

### Overview

CSI is a standard for exposing storage systems to containerized workloads. It enables:
- Dynamic volume provisioning
- Volume snapshots
- Volume expansion
- Volume cloning

### CSI Architecture

```
┌──────────────────────────────────────────┐
│         Kubernetes                       │
│  ┌────────────────┐                      │
│  │ kube-controller│                      │
│  │    -manager    │                      │
│  └────────┬───────┘                      │
│           │                               │
│  ┌────────▼───────┐                      │
│  │ CSI Controller │                      │
│  │    Plugin      │                      │
│  └────────┬───────┘                      │
└───────────┼───────────────────────────────┘
            │
     ┌──────▼────────┐
     │ CSI Node      │
     │ Plugin        │
     └──────┬────────┘
            │
     ┌──────▼────────┐
     │ Storage       │
     │ Backend       │
     └───────────────┘
```

### Common CSI Drivers

| Provider | Driver | Storage Type |
|----------|--------|--------------|
| **AWS** | aws-ebs-csi-driver | EBS volumes |
| **Azure** | azuredisk-csi-driver | Azure Disks |
| **GCP** | gce-pd-csi-driver | Persistent Disks |
| **NFS** | nfs-subdir-external-provisioner | NFS shares |
| **Ceph** | ceph-csi | RBD, CephFS |

### Check CSI Drivers

```bash
# List storage classes (created by CSI drivers)
kubectl get storageclass
kubectl get sc

# Describe storage class
kubectl describe sc <storageclass-name>

# Check CSI driver pods
kubectl get pods -n kube-system | grep csi

# Check CSI node info
kubectl get csinodes
kubectl describe csinode <node-name>

# Check CSI drivers
kubectl get csidrivers
kubectl describe csidriver <driver-name>

# Check volume attachments
kubectl get volumeattachments
```

### CSI Driver Configuration

```yaml
# Example: StorageClass using CSI driver
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com  # CSI driver name
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### Install CSI Driver (AWS EBS Example)

```bash
# Add Helm repo
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

# Install driver
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system

# Verify installation
kubectl get pods -n kube-system | grep ebs-csi

# Check CSI driver
kubectl get csidrivers
# NAME: ebs.csi.aws.com

# Create storage class
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: WaitForFirstConsumer
EOF

# Test with PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 5Gi
EOF

# Verify PVC
kubectl get pvc test-pvc
```

## Troubleshooting Tips

### CRI Issues

```bash
# Container runtime not working
sudo systemctl status containerd

# Check logs
sudo journalctl -xeu containerd

# Restart runtime
sudo systemctl restart containerd

# Verify socket exists
ls -la /run/containerd/containerd.sock

# Test with crictl
sudo crictl ps

# Check kubelet is using correct socket
ps aux | grep kubelet | grep container-runtime-endpoint
```

### CNI Issues

```bash
# Pods stuck in ContainerCreating
kubectl describe pod <pod-name>
# Look for: "network plugin is not ready"

# Check CNI plugin installed
ls -la /opt/cni/bin/
ls -la /etc/cni/net.d/

# Install CNI if missing
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check CNI pods running
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# Check CNI pod logs
kubectl logs -n kube-system <cni-pod-name>

# For Calico
kubectl logs -n kube-system -l k8s-app=calico-node -c calico-node

# Common issues:
# 1. No CNI plugin installed
# 2. CNI pods not running
# 3. Wrong pod network CIDR
# 4. Firewall blocking pod network
```

### CSI Issues

```bash
# PVC stuck in Pending
kubectl describe pvc <pvc-name>
# Look for events

# Check storage class exists
kubectl get sc

# Check CSI driver pods
kubectl get pods -n kube-system | grep csi

# Check CSI driver logs
kubectl logs -n kube-system <csi-driver-pod>

# Check volume attachment
kubectl get volumeattachment
kubectl describe volumeattachment <attachment-name>

# Common issues:
# 1. No CSI driver installed
# 2. Wrong storage class name
# 3. No default storage class
# 4. Insufficient cloud permissions
# 5. CSI driver not running
```

## Key Files and Locations

| Path | Purpose |
|------|---------|
| `/run/containerd/containerd.sock` | containerd CRI socket |
| `/var/run/crio/crio.sock` | CRI-O socket |
| `/etc/crictl.yaml` | crictl configuration |
| `/etc/cni/net.d/` | CNI configuration files |
| `/opt/cni/bin/` | CNI binary plugins |
| `/var/lib/kubelet/config.yaml` | kubelet configuration |

## Exam Tips

1. **Know default CRI socket** - `/run/containerd/containerd.sock`
2. **CNI must be installed** after kubeadm init
3. **Calico is most common** CNI in exams
4. **Use crictl** instead of docker commands
5. **Check /etc/cni/net.d/** for CNI config
6. **StorageClass provisioner** field indicates CSI driver
7. **CNI pods are in kube-system** namespace
8. **Verify CNI logs** if pods stuck in ContainerCreating
9. **Each interface is independent** - can mix and match
10. **Documentation is your friend** - refer for installation commands

## Common Mistakes

- ❌ Using docker commands instead of crictl
- ❌ Not installing CNI after cluster initialization
- ❌ Wrong pod network CIDR for CNI plugin
- ❌ Not checking if CNI pods are running
- ❌ Confusing CRI socket paths
- ❌ Trying to use Docker as CRI in v1.24+
- ❌ Not setting CONTAINER_RUNTIME_ENDPOINT for crictl
- ❌ Forgetting CSI driver needs cloud permissions
- ❌ Not checking storage class provisioner
- ❌ Mixing CNI plugins (installing multiple)

## Quick Reference

### CRI Commands

```bash
# Check runtime
kubectl get nodes -o wide

# crictl commands (like docker)
sudo crictl ps                    # List containers
sudo crictl images                # List images
sudo crictl logs <container-id>   # View logs
sudo crictl exec -it <id> sh      # Execute command
sudo crictl info                  # Runtime info
```

### CNI Commands

```bash
# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Install Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Install Weave
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Check CNI
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"
ls /etc/cni/net.d/
ls /opt/cni/bin/
```

### CSI Commands

```bash
# Check storage
kubectl get sc                    # Storage classes
kubectl get csidrivers            # CSI drivers
kubectl get csinodes              # CSI node info
kubectl get volumeattachments     # Volume attachments

# Test CSI
kubectl apply -f pvc.yaml         # Create PVC
kubectl get pvc                   # Check status
```

### Interface Summary

| Interface | Managed By | Location | Purpose |
|-----------|----------|----------|---------|
| **CRI** | kubelet | `/run/containerd/` | Container operations |
| **CNI** | kubelet | `/etc/cni/net.d/` | Pod networking |
| **CSI** | kube-controller-manager | Various | Storage provisioning |
