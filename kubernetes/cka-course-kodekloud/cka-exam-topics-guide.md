# CKA Exam Topics Guide

Detailed breakdown of each CKA exam topic with what to know and how it may be tested.

---

## Storage – 10%

### 1. Implement storage classes and dynamic volume provisioning

**What to know:**

- StorageClass defines the "class" of storage (e.g., fast SSD, slow HDD)
- Dynamic provisioning automatically creates PVs when PVCs are created
- `provisioner` field specifies which volume plugin to use
- `reclaimPolicy` can be `Delete` or `Retain`

**How it's tested:**

- Create a StorageClass with specific parameters
- Create a PVC that uses dynamic provisioning via `storageClassName`
- Verify that a PV is automatically created

```bash
# Useful commands
kubectl get storageclass
kubectl describe storageclass <name>
```

---

### 2. Configure volume types, access modes and reclaim policies

**What to know:**

- **Volume types:** `emptyDir`, `hostPath`, `persistentVolumeClaim`, `configMap`, `secret`
- **Access modes:** `ReadWriteOnce (RWO)`, `ReadOnlyMany (ROX)`, `ReadWriteMany (RWX)`
- **Reclaim policies:** `Retain` (keep data), `Delete` (remove data), `Recycle` (deprecated)

**How it's tested:**

- Create a PV with specific access mode and reclaim policy
- Create a Pod that mounts an `emptyDir` or `hostPath` volume
- Modify reclaim policy of existing PV

```bash
# Change reclaim policy
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

---

### 3. Manage persistent volumes and persistent volume claims

**What to know:**

- PV is cluster-level storage resource (provisioned by admin or dynamically)
- PVC is a request for storage by a user/pod
- Binding: PVC binds to PV that matches capacity and access mode
- PVC status: `Pending`, `Bound`, `Lost`

**How it's tested:**

- Create a PV with specific capacity and access mode
- Create a PVC that binds to the PV
- Create a Pod that uses the PVC
- Troubleshoot why a PVC is stuck in `Pending` state
- Expand a PVC (if StorageClass allows)

```bash
# Common troubleshooting
kubectl get pv,pvc
kubectl describe pvc <name>  # Check events for binding issues
```

---

## Troubleshooting – 30%

> ⚠️ **This is the largest domain (30%)** - expect multiple troubleshooting questions!

### 1. Troubleshoot clusters and nodes

**What to know:**

- Check node status: `Ready`, `NotReady`, `SchedulingDisabled`
- Common issues: kubelet not running, network issues, disk pressure, memory pressure
- Node conditions: `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`

**How it's tested:**

- Fix a node that shows `NotReady` status
- Identify why pods are not being scheduled to a node
- Uncordon a node after maintenance

```bash
kubectl get nodes
kubectl describe node <node-name>
systemctl status kubelet
journalctl -u kubelet
```

---

### 2. Troubleshoot cluster components

**What to know:**

- Control plane components: `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `etcd`
- Location of manifests: `/etc/kubernetes/manifests/` (static pods)
- Component logs location varies: `journalctl` for systemd, `kubectl logs` for pods
- Common issues: certificate expiry, misconfiguration, connectivity

**How it's tested:**

- Fix a broken kube-apiserver (wrong flag, missing certificate)
- Fix kube-scheduler or controller-manager not running
- Identify which component is failing from symptoms

```bash
# Check static pod manifests
ls /etc/kubernetes/manifests/

# Check component status
kubectl get componentstatuses  # deprecated but may still work
kubectl get pods -n kube-system

# View logs
kubectl logs -n kube-system kube-apiserver-<node>
crictl ps
crictl logs <container-id>
```

---

### 3. Monitor cluster and application resource usage

**What to know:**

- `kubectl top nodes` - shows CPU/memory usage of nodes
- `kubectl top pods` - shows CPU/memory usage of pods
- Requires metrics-server to be installed
- Resource requests vs limits vs actual usage

**How it's tested:**

- Identify the pod consuming most CPU/memory in a namespace
- Find nodes with high resource utilization
- Sort pods by resource usage

```bash
kubectl top nodes
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=cpu
kubectl top pod <pod-name> --containers
```

---

### 4. Manage and evaluate container output streams

**What to know:**

- `stdout` and `stderr` are captured as container logs
- Multi-container pods: specify container with `-c`
- Previous container logs: `--previous` flag
- Follow logs in real-time: `-f` flag

**How it's tested:**

- Retrieve logs from a specific container in a multi-container pod
- Get logs from a crashed/restarted container
- Save logs to a file

```bash
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -f
kubectl logs <pod-name> --since=1h
kubectl logs <pod-name> > /path/to/output.log
```

---

### 5. Troubleshoot services and networking

**What to know:**

- Service not routing traffic: check selectors match pod labels
- Endpoints: `kubectl get endpoints` shows which pods are backing a service
- DNS resolution: pods should resolve `<service>.<namespace>.svc.cluster.local`
- Common issues: wrong port, no matching pods, network policy blocking traffic

**How it's tested:**

- Fix a service that doesn't route traffic to pods
- Debug DNS resolution issues
- Verify connectivity between pods/services

```bash
kubectl get svc,endpoints
kubectl describe svc <name>

# Test DNS from a pod
kubectl run tmp --image=busybox:1.28 --rm -it -- nslookup <service-name>

# Test connectivity
kubectl run tmp --image=busybox:1.28 --rm -it -- wget -qO- http://<service>:<port>
```

---

## Workloads and Scheduling – 15%

### 1. Understand application deployments and how to perform rolling update and rollbacks

**What to know:**

- Deployment manages ReplicaSets which manage Pods
- Rolling update strategy: `maxSurge`, `maxUnavailable`
- Rollback to previous revision
- Check rollout status and history

**How it's tested:**

- Create a Deployment with specific replica count and image
- Update the image (trigger rolling update)
- Rollback to a previous revision
- Check rollout status

```bash
kubectl create deployment nginx --image=nginx:1.19 --replicas=3

# Update image
kubectl set image deployment/nginx nginx=nginx:1.20

# Check status
kubectl rollout status deployment/nginx

# View history
kubectl rollout history deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2
```

---

### 2. Use ConfigMaps and Secrets to configure applications

**What to know:**

- ConfigMap: stores non-sensitive configuration data
- Secret: stores sensitive data (base64 encoded, not encrypted by default)
- Mount as volume or expose as environment variables
- Create from literal, file, or directory

**How it's tested:**

- Create ConfigMap/Secret from literal values or files
- Mount ConfigMap/Secret as volume in a Pod
- Expose ConfigMap/Secret as environment variables
- Update ConfigMap and verify pod sees changes (requires restart or volume mount)

```bash
# Create ConfigMap
kubectl create configmap my-config --from-literal=key=value
kubectl create configmap my-config --from-file=config.txt

# Create Secret
kubectl create secret generic my-secret --from-literal=password=secret

# Use in pod (env var)
env:
- name: MY_VAR
  valueFrom:
    configMapKeyRef:
      name: my-config
      key: key

# Use in pod (volume)
volumes:
- name: config-vol
  configMap:
    name: my-config
```

---

### 3. Configure workload autoscaling

**What to know:**

- HorizontalPodAutoscaler (HPA) scales pods based on CPU/memory metrics
- Requires metrics-server
- `minReplicas`, `maxReplicas`, `targetCPUUtilizationPercentage`

**How it's tested:**

- Create an HPA for a Deployment
- Set target CPU utilization percentage
- Verify HPA is working

```bash
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

kubectl get hpa
kubectl describe hpa <name>
```

---

### 4. Understand the primitives used to create robust, self-healing, application deployments

**What to know:**

- **ReplicaSet:** ensures desired number of pod replicas
- **Deployment:** manages ReplicaSets, enables rolling updates
- **DaemonSet:** runs one pod per node
- **StatefulSet:** for stateful applications with stable network identity
- **Liveness probes:** restart container if it fails
- **Readiness probes:** remove from service if not ready

**How it's tested:**

- Create a Deployment with liveness/readiness probes
- Create a DaemonSet
- Configure probe parameters (initialDelaySeconds, periodSeconds, etc.)

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

### 5. Configure Pod admission and scheduling (limits, node affinity, etc.)

**What to know:**

- **Resource requests:** minimum resources guaranteed
- **Resource limits:** maximum resources allowed
- **Node selectors:** simple node assignment by label
- **Node affinity:** advanced node selection rules
- **Taints and tolerations:** repel pods unless tolerated
- **Pod affinity/anti-affinity:** co-locate or spread pods

**How it's tested:**

- Schedule a pod on a specific node using nodeSelector or nodeName
- Configure node affinity rules
- Add tolerations to a pod to schedule on tainted nodes
- Set resource requests and limits

```bash
# Label a node
kubectl label node <node-name> disktype=ssd

# Taint a node
kubectl taint nodes <node-name> key=value:NoSchedule

# Remove taint
kubectl taint nodes <node-name> key=value:NoSchedule-
```

```yaml
# nodeSelector
nodeSelector:
  disktype: ssd

# Toleration
tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"

# Resources
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

---

## Cluster Architecture, Installation and Configuration – 25%

### 1. Manage role based access control (RBAC)

**What to know:**

- **Role:** permissions within a namespace
- **ClusterRole:** permissions cluster-wide or across namespaces
- **RoleBinding:** binds Role to user/group/serviceaccount in a namespace
- **ClusterRoleBinding:** binds ClusterRole cluster-wide
- Verbs: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`

**How it's tested:**

- Create a Role with specific permissions
- Create a RoleBinding to grant access to a user or ServiceAccount
- Verify permissions using `kubectl auth can-i`

```bash
# Create role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Create rolebinding
kubectl create rolebinding read-pods --role=pod-reader --user=jane

# Check permissions
kubectl auth can-i get pods --as=jane
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa
```

---

### 2. Prepare underlying infrastructure for installing a Kubernetes cluster

**What to know:**

- Disable swap
- Configure container runtime (containerd)
- Load required kernel modules (`overlay`, `br_netfilter`)
- Set sysctl parameters for networking
- Open required ports (6443, 2379-2380, 10250, etc.)

**How it's tested:**

> ⚡ **Mostly theory** - you may be asked to verify settings or fix misconfigurations, but unlikely to set up from scratch.

```bash
# Disable swap
swapoff -a

# Check kernel modules
lsmod | grep br_netfilter

# Check sysctl
sysctl net.bridge.bridge-nf-call-iptables
```

---

### 3. Create and manage Kubernetes clusters using kubeadm

**What to know:**

- `kubeadm init` - initialize control plane
- `kubeadm join` - join worker nodes
- `kubeadm token` - manage bootstrap tokens
- `kubeadm reset` - undo kubeadm init/join

**How it's tested:**

- Join a new node to an existing cluster
- Generate a new join token
- Initialize a cluster with specific settings

```bash
# Initialize cluster
kubeadm init --pod-network-cidr=10.244.0.0/16

# Generate join command
kubeadm token create --print-join-command

# Join node
kubeadm join <control-plane>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

---

### 4. Manage the lifecycle of Kubernetes clusters

**What to know:**

- Upgrade control plane and worker nodes
- Drain nodes before maintenance
- Cordon/uncordon nodes
- Backup and restore etcd

**How it's tested:**

- Upgrade cluster from one version to another
- Drain a node, perform maintenance, uncordon
- Backup etcd snapshot
- Restore etcd from snapshot

```bash
# Upgrade kubeadm
apt-get update && apt-get install -y kubeadm=1.29.0-00

# Upgrade control plane
kubeadm upgrade plan
kubeadm upgrade apply v1.29.0

# Drain node
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Uncordon
kubectl uncordon <node>

# etcd backup
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# etcd restore
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored
```

---

### 5. Implement and configure a highly-available control plane

**What to know:**

- Multiple control plane nodes (3+ recommended)
- Load balancer in front of API servers
- etcd can be stacked (on control plane) or external
- Shared certificates across control plane nodes

**How it's tested:**

> ⚡ **Mostly theory** - understanding HA architecture. Practical tasks might involve checking HA setup or adding a control plane node.

---

### 6. Use Helm and Kustomize to install cluster components

**What to know:**

- **Helm:** package manager for Kubernetes, uses charts
- **Kustomize:** template-free customization, built into kubectl

**How it's tested:**

- Install a Helm chart with custom values
- List/upgrade/uninstall Helm releases
- Apply kustomization

```bash
# Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/nginx
helm list
helm upgrade my-release bitnami/nginx --set replicaCount=3
helm uninstall my-release

# Kustomize
kubectl apply -k ./kustomization-dir/
kubectl kustomize ./kustomization-dir/
```

---

### 7. Understand extension interfaces (CNI, CSI, CRI, etc.)

**What to know:**

- **CNI (Container Network Interface):** plugins for pod networking (Calico, Flannel, Weave)
- **CSI (Container Storage Interface):** plugins for storage (EBS, NFS, etc.)
- **CRI (Container Runtime Interface):** interface for container runtimes (containerd, CRI-O)

**How it's tested:**

> ⚡ **Mostly theory** - understanding what each interface does. May need to install a CNI plugin or troubleshoot networking related to CNI.

```bash
# Check CNI config
ls /etc/cni/net.d/

# Check container runtime
crictl info
```

---

### 8. Understand CRDs, install and configure operators

**What to know:**

- **CRD (Custom Resource Definition):** extends Kubernetes API with custom resources
- **Operator:** controller that manages CRDs with domain-specific logic
- CRDs define the schema, operators implement the logic

**How it's tested:**

- Create a CRD
- Create a custom resource based on a CRD
- Install an operator (usually via kubectl apply or Helm)

```bash
kubectl get crd
kubectl describe crd <name>
kubectl get <custom-resource>
```

---

## Services and Networking – 20%

### 1. Understand connectivity between Pods

**What to know:**

- All pods can communicate with each other without NAT
- Pods get unique IP addresses
- Containers within a pod share network namespace (localhost)
- CNI plugin handles pod networking

**How it's tested:**

> ⚡ **Mostly theory** - but may need to verify pod-to-pod connectivity or troubleshoot.

```bash
# Get pod IPs
kubectl get pods -o wide

# Test connectivity
kubectl exec <pod1> -- ping <pod2-ip>
kubectl exec <pod1> -- curl <pod2-ip>:<port>
```

---

### 2. Define and enforce Network Policies

**What to know:**

- NetworkPolicy controls traffic flow at IP/port level
- By default, pods accept traffic from anywhere
- NetworkPolicy requires a CNI that supports it (Calico, Cilium, etc.)
- Types: Ingress (incoming), Egress (outgoing)

**How it's tested:**

- Create a NetworkPolicy to restrict ingress/egress traffic
- Allow traffic only from specific pods or namespaces
- Deny all traffic to a pod, then allow specific sources

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {} # applies to all pods
  policyTypes:
    - Ingress
    - Egress
  # No ingress/egress rules = deny all
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: api
      ports:
        - port: 80
```

---

### 3. Use ClusterIP, NodePort, LoadBalancer service types and endpoints

**What to know:**

- **ClusterIP:** internal only (default)
- **NodePort:** exposes on each node's IP at a static port (30000-32767)
- **LoadBalancer:** provisions external load balancer (cloud provider)
- **Endpoints:** IP addresses of pods backing a service

**How it's tested:**

- Create services of different types
- Expose a deployment as NodePort
- Troubleshoot service not reaching pods (check endpoints)

```bash
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl expose deployment nginx --port=80 --type=LoadBalancer

kubectl get endpoints
kubectl describe endpoints <service-name>
```

---

### 4. Use the Gateway API to manage Ingress traffic

**What to know:**

- Gateway API is the successor to Ingress
- Resources: `GatewayClass`, `Gateway`, `HTTPRoute`
- More expressive than Ingress, supports more protocols
- Requires Gateway API CRDs and a compatible controller

**How it's tested:**

- Create a Gateway and HTTPRoute
- Route traffic to different backends based on path/host

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
spec:
  parentRefs:
    - name: my-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /app
      backendRefs:
        - name: app-service
          port: 80
```

---

### 5. Know how to use Ingress controllers and Ingress resources

**What to know:**

- Ingress exposes HTTP/HTTPS routes to services
- Requires an Ingress Controller (nginx, traefik, etc.)
- Rules: host-based and path-based routing
- TLS termination

**How it's tested:**

- Create an Ingress resource with path-based routing
- Configure host-based routing
- Troubleshoot Ingress not routing traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
```

---

### 6. Understand and use CoreDNS

**What to know:**

- CoreDNS is the DNS server for Kubernetes
- Runs as a Deployment in `kube-system` namespace
- Service discovery: `<service>.<namespace>.svc.cluster.local`
- Pod DNS: `<pod-ip-dashed>.<namespace>.pod.cluster.local`
- ConfigMap `coredns` contains the Corefile

**How it's tested:**

- Troubleshoot DNS resolution issues
- Verify CoreDNS is running
- Modify CoreDNS configuration (Corefile)
- Test DNS resolution from a pod

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS ConfigMap
kubectl get configmap coredns -n kube-system -o yaml

# Test DNS from a pod
kubectl run tmp --image=busybox:1.28 --rm -it -- nslookup kubernetes
kubectl run tmp --image=busybox:1.28 --rm -it -- nslookup <service>.<namespace>
```

---

## Summary: Theory vs Practical

| Topic                         | Likely Tested Practically |
| ----------------------------- | ------------------------- |
| PV/PVC/StorageClass           | ✅ Yes                    |
| Troubleshoot nodes/components | ✅ Yes                    |
| kubectl top (metrics)         | ✅ Yes                    |
| Container logs                | ✅ Yes                    |
| Service troubleshooting       | ✅ Yes                    |
| Deployments/rollouts          | ✅ Yes                    |
| ConfigMaps/Secrets            | ✅ Yes                    |
| HPA                           | ✅ Yes                    |
| Probes (liveness/readiness)   | ✅ Yes                    |
| Node affinity/taints          | ✅ Yes                    |
| RBAC                          | ✅ Yes                    |
| kubeadm (join, upgrade)       | ✅ Yes                    |
| etcd backup/restore           | ✅ Yes                    |
| Helm                          | ✅ Yes                    |
| Network Policies              | ✅ Yes                    |
| Services (ClusterIP/NodePort) | ✅ Yes                    |
| Ingress                       | ✅ Yes                    |
| CoreDNS                       | ✅ Yes                    |
| Infrastructure prep           | ⚠️ Limited (verify/fix)   |
| HA control plane              | ⚠️ Theory mostly          |
| CNI/CSI/CRI                   | ⚠️ Theory mostly          |
| Pod networking concepts       | ⚠️ Theory mostly          |
