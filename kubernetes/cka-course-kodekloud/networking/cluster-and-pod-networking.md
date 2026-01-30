# Cluster & Pod Networking with CNI

## Executive Summary

Kubernetes networking ensures that every pod gets a unique IP address and can communicate with any other pod across the cluster without NAT. The Container Network Interface (CNI) is the standard that enables pluggable networking solutions.

**Core Networking Requirements:**

- Every pod gets a unique IP address
- Pods on a node can communicate with all pods on all nodes
- Agents on a node can communicate with all pods on that node
- No NAT required for pod-to-pod communication

**Key Components:**
| Component | Purpose |
|-----------|---------|
| CNI Plugin | Manages pod networking (Weave, Calico, Flannel, etc.) |
| Bridge Network | Virtual switch connecting pods on each node |
| veth pairs | Virtual ethernet cables connecting pods to bridge |
| IPAM | IP Address Management for pods |

---

## Cluster Networking Prerequisites

### Required Ports

| Port        | Component          | Purpose                  |
| ----------- | ------------------ | ------------------------ |
| 6443        | API Server         | Kubernetes API access    |
| 10250       | Kubelet            | Node agent communication |
| 10259       | Kube-scheduler     | Scheduling operations    |
| 10257       | Controller-manager | Cluster state management |
| 2379-2380   | etcd               | Cluster data store       |
| 30000-32767 | NodePort Services  | External service access  |

### Network Verification Commands

```bash
# View network interfaces
ip link

# View IP addresses
ip addr

# View routing table
ip route

# Check IP forwarding
cat /proc/sys/net/ipv4/ip_forward

# View active listening ports
netstat -plnt

# Check ARP table
arp
```

---

## Container Network Interface (CNI)

### What is CNI?

CNI is a standard that defines how container runtimes should configure networking for containers. When a pod is created, the kubelet invokes the CNI plugin to:

1. Create network namespace for the pod
2. Attach the pod to the network
3. Assign IP address

### CNI Directory Structure

```bash
# CNI plugin binaries
ls /opt/cni/bin
# Output: bridge, flannel, host-local, loopback, weave-net, etc.

# CNI configuration files
ls /etc/cni/net.d
# Output: 10-weave.conflist, 10-flannel.conflist, etc.
```

### Sample CNI Bridge Configuration

```json
{
  "cniVersion": "0.2.0",
  "name": "mynet",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "subnet": "10.244.0.0/16",
    "routes": [{ "dst": "0.0.0.0/0" }]
  }
}
```

**Configuration Fields:**

- `type`: Plugin type (bridge, weave, flannel)
- `bridge`: Name of the bridge interface
- `isGateway`: Bridge acts as gateway for pods
- `ipMasq`: Enable IP masquerading (NAT)
- `ipam`: IP Address Management settings

---

## Pod Networking

### How Pods Get IP Addresses

1. Pod is scheduled to a node
2. Kubelet invokes CNI plugin
3. CNI creates network namespace
4. veth pair connects pod to bridge
5. IPAM assigns IP from subnet
6. Routes configured for pod communication

### Pod Network Architecture

```
Node 1 (192.168.1.11)          Node 2 (192.168.1.12)
┌─────────────────────┐        ┌─────────────────────┐
│  Pod A (10.244.1.2) │        │  Pod C (10.244.2.2) │
│  Pod B (10.244.1.3) │        │  Pod D (10.244.2.3) │
│         │           │        │         │           │
│    cni0 bridge      │        │    cni0 bridge      │
│   (10.244.1.1)      │        │   (10.244.2.1)      │
└─────────────────────┘        └─────────────────────┘
         │                              │
         └──────────── Network ─────────┘
```

---

## CNI Plugins (Weave Example)

### How Weave Works

- Deploys agent (DaemonSet) on each node
- Agents form peer-to-peer network
- Maintains cluster topology information
- Encapsulates packets for cross-node communication
- Default IP range: `10.32.0.0/12` (~1 million IPs)

### Deploy Weave CNI

```bash
# Deploy Weave
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Verify Weave pods
kubectl get pods -n kube-system -l name=weave-net

# Check pod routes
kubectl exec <pod-name> -- ip route
```

### Common CNI Plugins

| Plugin      | Features                       |
| ----------- | ------------------------------ |
| **Weave**   | Easy setup, encryption support |
| **Calico**  | Network policies, BGP routing  |
| **Flannel** | Simple overlay network         |
| **Cilium**  | eBPF-based, advanced security  |

---

## Common Commands

```bash
# View CNI configuration
cat /etc/cni/net.d/*.conf

# Check CNI plugin in use
ls /etc/cni/net.d/

# View pod IP addresses
kubectl get pods -o wide

# Check node network interfaces
ip addr show

# View bridge interfaces
ip link show type bridge

# Check routing table
ip route

# Inspect CNI plugin logs (for Weave)
kubectl logs -n kube-system -l name=weave-net

# View kubelet CNI configuration
ps aux | grep kubelet | grep cni
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Troubleshoot pod networking issues**
2. **Identify CNI plugin in use**
3. **Check pod IP allocation**
4. **Verify cluster network configuration**

### Key Points to Remember

| Topic              | Remember                                 |
| ------------------ | ---------------------------------------- |
| CNI binaries       | Located at `/opt/cni/bin`                |
| CNI config         | Located at `/etc/cni/net.d`              |
| Pod IP range       | Usually `10.244.0.0/16` or similar       |
| Required ports     | 6443 (API), 10250 (kubelet), 2379 (etcd) |
| CNI responsibility | Assign IP, create veth, configure routes |

### Troubleshooting Checklist

- [ ] CNI plugin installed? Check `/opt/cni/bin`
- [ ] CNI configured? Check `/etc/cni/net.d`
- [ ] Pods getting IPs? `kubectl get pods -o wide`
- [ ] Can pods communicate? `kubectl exec <pod> -- ping <other-pod-ip>`
- [ ] CNI pods running? `kubectl get pods -n kube-system`

---

## Official Documentation

- [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [CNI Specification](https://github.com/containernetworking/cni/blob/master/SPEC.md)
- [Installing Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)
