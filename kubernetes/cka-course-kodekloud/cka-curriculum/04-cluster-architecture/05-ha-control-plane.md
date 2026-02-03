# Implement and Configure a Highly Available Control Plane

## Exam Weight
Part of **25% - Cluster Architecture, Installation and Configuration**

## What Can Be Tested

- Understand HA control plane architecture
- Configure stacked etcd topology
- Configure external etcd topology
- Set up load balancer for API servers
- Add additional control plane nodes
- Troubleshoot HA control plane issues

## Sample Questions

1. **Initialize first control plane node with HA endpoint**
2. **Join additional control plane nodes to HA cluster**
3. **Configure load balancer for multiple API servers**
4. **Troubleshoot etcd cluster member issues**
5. **Verify HA control plane health**

## Official Documentation

- [HA Topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/)
- [Creating HA clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
- [Operating etcd clusters for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

## Key Concepts

### HA Control Plane Architecture

```
           Load Balancer (VIP)
                  |
    +-------------+-------------+
    |             |             |
API Server1   API Server2   API Server3
    |             |             |
    +-------------+-------------+
                  |
              etcd Cluster
```

### Topology Options

| Topology | Description | Pros | Cons |
|----------|-------------|------|------|
| **Stacked etcd** | etcd runs on control plane nodes | Simpler, fewer nodes | Coupled failure domain |
| **External etcd** | etcd on separate nodes | Better resilience | More complex, more nodes |

### Minimum Node Requirements

| Topology | Control Plane Nodes | etcd Nodes | Total |
|----------|---------------------|------------|-------|
| **Stacked** | 3 | 3 (co-located) | 3 |
| **External** | 2+ | 3 (separate) | 5+ |

## Stacked etcd Topology Setup

### Prerequisites

```bash
# On all control plane nodes:
# 1. Install kubeadm, kubelet, kubectl
# 2. Install container runtime (containerd)
# 3. Disable swap
# 4. Configure kernel modules and sysctl
# 5. Ensure unique hostname and MAC address
```

### Set Up Load Balancer

#### Option 1: HAProxy

```bash
# Install HAProxy (on separate LB node)
sudo apt-get update
sudo apt-get install -y haproxy

# Configure HAProxy
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend kubernetes-frontend
    bind *:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server controlplane1 192.168.1.11:6443 check
    server controlplane2 192.168.1.12:6443 check
    server controlplane3 192.168.1.13:6443 check
EOF

# Restart HAProxy
sudo systemctl restart haproxy
sudo systemctl enable haproxy

# Verify HAProxy is listening
sudo netstat -tulpn | grep :6443
```

#### Option 2: NGINX

```bash
# Install NGINX
sudo apt-get update
sudo apt-get install -y nginx

# Configure NGINX for TCP load balancing
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
events {}

stream {
    upstream kubernetes {
        server 192.168.1.11:6443;
        server 192.168.1.12:6443;
        server 192.168.1.13:6443;
    }

    server {
        listen 6443;
        proxy_pass kubernetes;
    }
}
EOF

# Test configuration
sudo nginx -t

# Restart NGINX
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verify
sudo netstat -tulpn | grep :6443
```

### Initialize First Control Plane

```bash
# Create kubeadm config file
cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.28.0
controlPlaneEndpoint: "loadbalancer.example.com:6443"
networking:
  podSubnet: "192.168.0.0/16"
EOF

# Initialize first control plane
sudo kubeadm init --config=kubeadm-config.yaml --upload-certs

# Output will show:
# 1. kubeadm join command for control plane nodes
# 2. kubeadm join command for worker nodes
# 3. Certificate key (valid for 2 hours)

# Example output:
# kubeadm join loadbalancer.example.com:6443 --token abc123.xyz789 \
#   --discovery-token-ca-cert-hash sha256:abc123... \
#   --control-plane --certificate-key abc123...

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verify first control plane
kubectl get nodes
kubectl get pods -n kube-system
```

### Join Additional Control Planes

```bash
# On second and third control plane nodes
# Use the join command from kubeadm init output

sudo kubeadm join loadbalancer.example.com:6443 \
  --token abc123.xyz789 \
  --discovery-token-ca-cert-hash sha256:abc123... \
  --control-plane --certificate-key abc123...

# If certificate key expired, generate new one
# On first control plane:
sudo kubeadm init phase upload-certs --upload-certs

# Configure kubectl on additional control planes
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify on any control plane
kubectl get nodes
# Should show all 3 control plane nodes
```

## External etcd Topology Setup

### Set Up External etcd Cluster

```bash
# On each etcd node (etcd1, etcd2, etcd3)

# Install etcd
ETCD_VER=v3.5.9
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd.tar.gz
tar xzvf /tmp/etcd.tar.gz -C /tmp
sudo mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/

# Create etcd user
sudo useradd -s /sbin/nologin -M etcd

# Create directories
sudo mkdir -p /var/lib/etcd /etc/etcd
sudo chown -R etcd:etcd /var/lib/etcd

# Generate certificates (on CA node, then distribute)
# ... certificate generation steps ...

# Create etcd service
sudo tee /etc/systemd/system/etcd.service > /dev/null <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/etcd-io/etcd

[Service]
Type=notify
User=etcd
ExecStart=/usr/local/bin/etcd \\
  --name etcd1 \\
  --data-dir /var/lib/etcd \\
  --listen-client-urls https://192.168.1.21:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://192.168.1.21:2379 \\
  --listen-peer-urls https://192.168.1.21:2380 \\
  --initial-advertise-peer-urls https://192.168.1.21:2380 \\
  --cert-file=/etc/etcd/server.crt \\
  --key-file=/etc/etcd/server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-cert-file=/etc/etcd/peer.crt \\
  --peer-key-file=/etc/etcd/peer.key \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --initial-cluster etcd1=https://192.168.1.21:2380,etcd2=https://192.168.1.22:2380,etcd3=https://192.168.1.23:2380 \\
  --initial-cluster-token etcd-cluster \\
  --initial-cluster-state new
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start etcd
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

# Verify etcd cluster
ETCDCTL_API=3 etcdctl \
  --endpoints=https://192.168.1.21:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/server.crt \
  --key=/etc/etcd/server.key \
  member list

ETCDCTL_API=3 etcdctl \
  --endpoints=https://192.168.1.21:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/server.crt \
  --key=/etc/etcd/server.key \
  endpoint health
```

### Initialize Control Plane with External etcd

```bash
# Create kubeadm config
cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.28.0
controlPlaneEndpoint: "loadbalancer.example.com:6443"
networking:
  podSubnet: "192.168.0.0/16"
etcd:
  external:
    endpoints:
      - https://192.168.1.21:2379
      - https://192.168.1.22:2379
      - https://192.168.1.23:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
EOF

# Copy etcd certificates to control plane
sudo mkdir -p /etc/kubernetes/pki/etcd
sudo cp /etc/etcd/ca.crt /etc/kubernetes/pki/etcd/
sudo cp /etc/etcd/client.crt /etc/kubernetes/pki/apiserver-etcd-client.crt
sudo cp /etc/etcd/client.key /etc/kubernetes/pki/apiserver-etcd-client.key

# Initialize
sudo kubeadm init --config=kubeadm-config.yaml --upload-certs
```

## Verification and Health Checks

### Verify Control Plane Nodes

```bash
# Check all nodes
kubectl get nodes -o wide

# Should see multiple control plane nodes
# controlplane1   Ready    control-plane   5m    v1.28.0
# controlplane2   Ready    control-plane   3m    v1.28.0
# controlplane3   Ready    control-plane   1m    v1.28.0

# Check control plane pods
kubectl get pods -n kube-system -o wide | grep -E "(api|scheduler|controller)"

# Should see pods on all control plane nodes
```

### Verify etcd Cluster

```bash
# Check etcd members
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list

# Check etcd health
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Check etcd status
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status --write-out=table
```

### Test HA Functionality

```bash
# Create a test deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Check deployment
kubectl get deployment nginx
kubectl get pods -o wide

# Simulate control plane failure (on one control plane)
sudo systemctl stop kubelet

# Verify cluster still works
kubectl get nodes
kubectl get pods

# Create new resource to test write operations
kubectl run test --image=nginx

# Start kubelet again
sudo systemctl start kubelet
```

## Troubleshooting Tips

### Control Plane Node Won't Join

```bash
# Error: "error execution phase upload-certs"

# 1. Certificate key expired (valid for 2 hours)
# Generate new certificate key
sudo kubeadm init phase upload-certs --upload-certs

# 2. Use new certificate key in join command
sudo kubeadm join loadbalancer.example.com:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <new-key>

# 3. Check token is valid
kubeadm token list

# 4. Generate new token if needed
kubeadm token create --print-join-command
```

### etcd Cluster Unhealthy

```bash
# Check etcd member status
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379,https://192.168.1.12:2379,https://192.168.1.13:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Check etcd logs
sudo crictl ps | grep etcd
sudo crictl logs <etcd-container-id>

# Check connectivity between etcd members
nc -zv 192.168.1.12 2380

# Remove unhealthy member
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member remove <member-id>
```

### Load Balancer Issues

```bash
# Check if LB is listening
nc -zv loadbalancer.example.com 6443

# Test from control plane nodes
curl -k https://loadbalancer.example.com:6443/healthz

# Check HAProxy status
sudo systemctl status haproxy
sudo tail -f /var/log/haproxy.log

# Check backend servers
echo "show servers state" | sudo socat stdio /var/lib/haproxy/stats

# Verify all API servers are healthy
for i in 192.168.1.11 192.168.1.12 192.168.1.13; do
  echo "Checking $i"
  curl -k https://$i:6443/healthz
done
```

### API Server Not Starting on Additional Control Planes

```bash
# Check API server logs
sudo crictl ps -a | grep kube-apiserver
sudo crictl logs <container-id>

# Common issues:
# 1. Certificates not properly copied
ls -la /etc/kubernetes/pki/

# 2. Wrong controlPlaneEndpoint
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep advertise

# 3. etcd connectivity
# Test from API server pod
kubectl exec -it -n kube-system kube-apiserver-controlplane2 -- sh
# Then try to connect to etcd

# 4. Check kubelet
sudo systemctl status kubelet
sudo journalctl -xeu kubelet
```

## Key Files and Locations

### Stacked etcd

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/etcd.yaml` | etcd static pod manifest |
| `/var/lib/etcd/` | etcd data directory |
| `/etc/kubernetes/pki/etcd/` | etcd certificates |

### External etcd

| File/Directory | Purpose |
|----------------|---------|
| `/var/lib/etcd/` | etcd data (on etcd nodes) |
| `/etc/etcd/` | etcd config and certs |
| `/etc/systemd/system/etcd.service` | etcd systemd service |

### Control Plane

| File/Directory | Purpose |
|----------------|---------|
| `/etc/kubernetes/manifests/` | Static pod manifests |
| `/etc/kubernetes/pki/` | Kubernetes certificates |
| `/etc/kubernetes/admin.conf` | Admin kubeconfig |

## Exam Tips

1. **Stacked etcd is simpler** - Prefer if not specified
2. **Load balancer is required** - Set up before kubeadm init
3. **Use --upload-certs** - Shares certs between control planes
4. **Certificate key expires in 2 hours** - Generate new if needed
5. **Test load balancer** before initializing cluster
6. **controlPlaneEndpoint** must point to load balancer
7. **Check etcd health** after adding each control plane
8. **Minimum 3 control planes** for HA
9. **All control planes need same kubeconfig**
10. **Practice the complete workflow**

## Common Mistakes

- ❌ No load balancer configured
- ❌ Wrong controlPlaneEndpoint address
- ❌ Certificate key expired when joining
- ❌ Not using --upload-certs flag
- ❌ Joining control plane without --control-plane flag
- ❌ Trying to join with expired token
- ❌ Load balancer not pointing to all API servers
- ❌ Firewall blocking etcd ports (2379, 2380)
- ❌ Not verifying etcd cluster health
- ❌ Adding even number of control planes (should be odd)

## Quick Reference

### HA Stacked etcd Setup

```bash
# 1. Set up load balancer (HAProxy/NGINX)

# 2. Initialize first control plane
sudo kubeadm init \
  --control-plane-endpoint="loadbalancer.example.com:6443" \
  --pod-network-cidr=192.168.0.0/16 \
  --upload-certs

# 3. Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 4. Install CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 5. Join additional control planes
sudo kubeadm join loadbalancer.example.com:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <key>

# 6. Verify
kubectl get nodes
kubectl get pods -n kube-system
```

### etcd Commands

```bash
# Member list
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list

# Health check
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Cluster status
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status --write-out=table
```
