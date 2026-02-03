# Pod Connectivity

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Understand pod-to-pod communication
- Verify network connectivity between pods
- Troubleshoot pod network issues
- Understand CNI (Container Network Interface)
- Check pod IP addresses and network configuration
- Test connectivity using curl, wget, ping, nslookup
- Understand cluster networking requirements

## Sample Questions

1. **Test connectivity from one pod to another using curl**
2. **Verify DNS resolution between pods**
3. **Troubleshoot why a pod cannot reach another pod**
4. **Check which CNI plugin is being used in the cluster**
5. **Verify pod IP addresses and routing**

## Official Documentation

- [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

## Key Concepts

### Kubernetes Network Model

**Requirements:**
1. **All pods can communicate** with all other pods without NAT
2. **All nodes can communicate** with all pods without NAT
3. **Pod's IP** is the same as others see it (no NAT)

### Pod Networking

```
Pod A (10.244.1.5) → Pod B (10.244.2.10)
     ↓                      ↓
  Node 1                 Node 2
     ↓                      ↓
       CNI Plugin Routes Traffic
```

### CNI Plugins

| Plugin | Features | Use Case |
|--------|----------|----------|
| **Calico** | Network policies, BGP | Production, security |
| **Flannel** | Simple overlay network | Simple clusters |
| **Weave** | Mesh network, encryption | Multi-cloud |
| **Cilium** | eBPF-based, observability | Advanced networking |
| **Canal** | Calico + Flannel | Best of both |

## Imperative Commands

```bash
# Get pod IPs
kubectl get pods -o wide

# Get pod in specific namespace with IPs
kubectl get pods -n <namespace> -o wide

# Describe pod (shows IP, node)
kubectl describe pod <pod-name>

# Execute command in pod
kubectl exec <pod-name> -- <command>

# Interactive shell
kubectl exec -it <pod-name> -- /bin/sh

# Test connectivity from pod
kubectl exec <pod-name> -- curl http://<target-pod-ip>
kubectl exec <pod-name> -- wget -O- http://<target-pod-ip>
kubectl exec <pod-name> -- ping <target-pod-ip>

# DNS lookup from pod
kubectl exec <pod-name> -- nslookup <service-name>
kubectl exec <pod-name> -- nslookup <pod-ip>

# Check network interfaces in pod
kubectl exec <pod-name> -- ip addr
kubectl exec <pod-name> -- ifconfig

# Check routes in pod
kubectl exec <pod-name> -- ip route

# Test specific port
kubectl exec <pod-name> -- nc -zv <target-ip> <port>
kubectl exec <pod-name> -- telnet <target-ip> <port>

# Check CNI plugin
ls /etc/cni/net.d/
kubectl get pods -n kube-system | grep -E "calico|flannel|weave|cilium"

# Check node network
kubectl get nodes -o wide
```

## YAML Examples

### Test Pods for Network Debugging

```yaml
# BusyBox pod for network testing
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ["/bin/sh", "-c", "sleep 3600"]
```

```yaml
# Simple web server for testing
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

```yaml
# Client pod for testing connectivity
apiVersion: v1
kind: Pod
metadata:
  name: client
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
```

### Multi-Container Pod (Same Network Namespace)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-network
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c", "while true; do wget -O- localhost:80; sleep 5; done"]
```

## Troubleshooting Tips

### Test Pod-to-Pod Connectivity

```bash
# Step 1: Create test pods
kubectl run test-source --image=busybox --command -- sleep 3600
kubectl run test-target --image=nginx

# Step 2: Get target pod IP
TARGET_IP=$(kubectl get pod test-target -o jsonpath='{.status.podIP}')

# Step 3: Test connectivity
kubectl exec test-source -- wget -O- http://$TARGET_IP

# Expected: HTML from nginx
# If fails: Network issue
```

### Pod Cannot Reach Another Pod

```bash
# Check both pods are running
kubectl get pods -o wide

# Get pod IPs
kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'

# Test from source pod
kubectl exec <source-pod> -- ping <target-pod-ip>

# If ping fails:
# 1. Check pod is on same cluster
kubectl get pods --all-namespaces -o wide | grep <target-pod-ip>

# 2. Check CNI plugin is working
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# 3. Check node network
kubectl get nodes -o wide

# 4. Check for network policies blocking traffic
kubectl get networkpolicies --all-namespaces

# 5. Test from node
ssh <node>
curl http://<pod-ip>
```

### DNS Not Resolving

```bash
# Test DNS from pod
kubectl exec <pod-name> -- nslookup kubernetes.default

# Expected output: 
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

# If fails, check CoreDNS
kubectl get pods -n kube-system | grep coredns
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check DNS service
kubectl get svc -n kube-system kube-dns

# Test with specific DNS server
kubectl exec <pod-name> -- nslookup kubernetes.default 10.96.0.10
```

### Check CNI Configuration

```bash
# SSH to node
ssh <node-name>

# Check CNI config directory
ls -la /etc/cni/net.d/

# View CNI config
cat /etc/cni/net.d/*.conf

# Check CNI binaries
ls /opt/cni/bin/

# Check kubelet CNI settings
ps aux | grep kubelet | grep cni
```

### Pod Gets No IP Address

```bash
# Check pod status
kubectl describe pod <pod-name>

# Look for events like:
# "Failed to create pod sandbox"
# "CNI plugin not initialized"

# Check CNI pods
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# Restart CNI pods if needed
kubectl delete pods -n kube-system -l k8s-app=calico-node
```

### Network Performance Issues

```bash
# Check pod resource usage
kubectl top pods

# Check node resource usage
kubectl top nodes

# Test bandwidth between pods
# In source pod:
kubectl exec -it <source-pod> -- /bin/sh
# iperf -s

# In target pod:
kubectl exec -it <target-pod> -- /bin/sh
# iperf -c <source-pod-ip>

# Check for packet loss
kubectl exec <pod-name> -- ping -c 10 <target-ip>
```

### Check Network Routes

```bash
# From pod
kubectl exec <pod-name> -- ip route

# Expected output shows default gateway
# default via 10.244.0.1 dev eth0
# 10.244.0.0/24 dev eth0 scope link

# From node
ssh <node>
ip route

# Check iptables rules (affects service routing)
sudo iptables -t nat -L -n
```

## Key Files and Locations

### CNI Configuration
- **Config Directory**: `/etc/cni/net.d/`
- **CNI Binaries**: `/opt/cni/bin/`
- **Kubelet Config**: `/var/lib/kubelet/config.yaml` (networkPlugin setting)

### Network Plugin Locations
```bash
# Calico
/etc/cni/net.d/10-calico.conflist
kubectl get pods -n kube-system | grep calico

# Flannel
/etc/cni/net.d/10-flannel.conflist
kubectl get pods -n kube-system | grep flannel

# Weave
kubectl get pods -n kube-system | grep weave
```

### Check Kubelet Network Settings
```bash
# View kubelet config
cat /var/lib/kubelet/config.yaml | grep -i network

# Check kubelet process
ps aux | grep kubelet | grep network-plugin
```

## Exam Tips

1. **Use `kubectl get pods -o wide`** to see pod IPs and nodes
2. **Test with busybox or netshoot** images (have network tools)
3. **Pod IPs are ephemeral** - use Services for stable endpoints
4. **Same pod = localhost** - containers share network namespace
5. **DNS works** for Services, not individual pod IPs
6. **Check CNI first** if network issues cluster-wide
7. **Use `kubectl exec`** to test from pod's perspective
8. **Network policies** can block traffic (check if connectivity fails)
9. **CoreDNS** must be running for DNS resolution
10. **Pod CIDR** typically 10.244.0.0/16 or similar

## Common Mistakes

- ❌ Testing from local machine instead of inside pod
- ❌ Using service name when testing pod IPs directly
- ❌ Forgetting pods can communicate across namespaces by default
- ❌ Not checking if CNI plugin pods are running
- ❌ Assuming all images have network tools (use busybox/netshoot)
- ❌ Not considering network policies blocking traffic
- ❌ Testing before pods are fully ready

## Quick Reference

```bash
# Create test environment
kubectl run client --image=busybox --command -- sleep 3600
kubectl run server --image=nginx

# Get server IP
SERVER_IP=$(kubectl get pod server -o jsonpath='{.status.podIP}')

# Test connectivity
kubectl exec client -- wget -O- http://$SERVER_IP

# Test DNS
kubectl exec client -- nslookup server

# Check network from pod
kubectl exec client -- ip addr
kubectl exec client -- ip route

# Cleanup
kubectl delete pod client server
```

## Pod Network Namespace

**Key Concept**: All containers in a pod share:
- Network namespace
- IP address
- Network interfaces
- Ports

```bash
# Test: Access nginx from sidecar via localhost
kubectl exec <pod-name> -c sidecar -- wget -O- localhost:80
```

## Network Testing Checklist

```bash
# 1. Check pods are running
kubectl get pods -o wide

# 2. Get pod IPs
kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'

# 3. Test basic connectivity
kubectl exec <source> -- ping <target-ip>

# 4. Test application port
kubectl exec <source> -- curl http://<target-ip>:<port>

# 5. Test DNS resolution
kubectl exec <source> -- nslookup <service-name>

# 6. Check CNI plugin
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# 7. Check for network policies
kubectl get networkpolicies --all-namespaces

# 8. Check CoreDNS
kubectl get pods -n kube-system | grep coredns
```

## Common Network Ranges

| Range | Purpose |
|-------|---------|
| **10.244.0.0/16** | Pod CIDR (common default) |
| **10.96.0.0/12** | Service CIDR (common default) |
| **10.96.0.10** | CoreDNS Service IP (common) |
| **10.96.0.1** | Kubernetes Service IP |

## Network Debugging Images

```bash
# BusyBox (lightweight)
kubectl run test --image=busybox --command -- sleep 3600

# Nicolaka netshoot (all network tools)
kubectl run netshoot --image=nicolaka/netshoot -- sleep 3600

# Ubuntu (full OS)
kubectl run ubuntu --image=ubuntu -- sleep 3600

# Alpine (minimal)
kubectl run alpine --image=alpine -- sleep 3600
```
