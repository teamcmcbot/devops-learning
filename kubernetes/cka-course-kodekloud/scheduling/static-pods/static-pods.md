# Static Pods in Kubernetes

## Overview

**Static Pods** are pods that are created and managed directly by the **kubelet** on a specific node, without the involvement of the Kubernetes API server or other control plane components. They run independently and are perfect for bootstrapping control plane components.

**Key Concepts**:

- Created by **kubelet alone** (no API server needed)
- Defined by **pod manifest files** in a specific directory
- Automatically restarted if they crash
- Cannot be managed by kubectl commands (except viewing)

---

## Why Static Pods?

### The Problem

In a typical Kubernetes cluster:

- **kube-apiserver** receives pod creation requests
- **kube-scheduler** decides which node runs the pod
- **kubelet** creates the pod based on API server instructions

**But what if there's no API server?**

- How do you run pods on a standalone node?
- How do you bootstrap control plane components themselves?

### The Solution: Static Pods

Static pods allow the kubelet to:

- Operate independently without a control plane
- Manage pods using local manifest files
- Bootstrap critical control plane components
- Self-heal by automatically restarting failed pods

---

## How Static Pods Work

### Standalone Mode (No Cluster)

```
┌─────────────────────────────────────┐
│         Worker Node                 │
│                                     │
│  ┌──────────────┐                  │
│  │   kubelet    │                  │
│  └──────┬───────┘                  │
│         │ monitors                 │
│         ▼                           │
│  ┌──────────────────────┐          │
│  │ /etc/kubernetes/     │          │
│  │    manifests/        │          │
│  │  - pod1.yaml         │          │
│  │  - pod2.yaml         │          │
│  └──────────────────────┘          │
│         │                           │
│         ▼ creates                   │
│  ┌──────────────┐                  │
│  │  Static Pods │                  │
│  └──────────────┘                  │
└─────────────────────────────────────┘
```

**Process**:

1. Place pod YAML files in the configured directory (e.g., `/etc/kubernetes/manifests`)
2. Kubelet monitors this directory
3. Kubelet creates pods from the YAML files
4. Kubelet ensures pods keep running
5. If a YAML is deleted, kubelet deletes the pod

---

## Configuring Static Pods

### Method 1: Using --pod-manifest-path

Configure kubelet to monitor a specific directory:

```bash
# In kubelet service file: /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStart=/usr/local/bin/kubelet \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --network-plugin=cni \
  --register-node=true \
  --v=2
```

### Method 2: Using --config (Recommended)

Use a separate configuration file:

```bash
# In kubelet service file
ExecStart=/usr/local/bin/kubelet \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --config=/var/lib/kubelet/config.yaml \
  --kubeconfig=/var/lib/kubelet/kubeconfig
```

**Configuration file (config.yaml):**

```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
staticPodPath: /etc/kubernetes/manifests
```

### Finding the Static Pod Path

```bash
# Method 1: Check kubelet service file
cat /var/lib/kubelet/config.yaml | grep staticPodPath

# Method 2: Check kubelet process
ps aux | grep kubelet | grep pod-manifest-path

# Method 3: Check kubelet config
cat /var/lib/kubelet/config.yaml | grep staticPodPath

# Common locations:
# - /etc/kubernetes/manifests (kubeadm)
# - /etc/kubelet.d
# - Custom directory
```

---

## Creating Static Pods

### Example 1: Simple Nginx Static Pod

**Create pod manifest file:**

```bash
# Create directory if it doesn't exist
sudo mkdir -p /etc/kubernetes/manifests

# Create static pod YAML
sudo cat <<EOF > /etc/kubernetes/manifests/static-nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
EOF
```

**Result**: Kubelet automatically creates the pod within seconds

---

### Example 2: Static Pod with Multiple Containers

```yaml
# /etc/kubernetes/manifests/static-app.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-app
  labels:
    app: myapp
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - containerPort: 80
    - name: sidecar
      image: busybox
      command: ["sh", "-c", 'while true; do echo "Logging..."; sleep 10; done']
```

---

### Example 3: Static Pod with Resource Limits

```yaml
# /etc/kubernetes/manifests/static-resource-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-resource-pod
spec:
  containers:
    - name: app
      image: nginx
      resources:
        requests:
          memory: "128Mi"
          cpu: "250m"
        limits:
          memory: "256Mi"
          cpu: "500m"
```

---

### Example 4: Static Pod with Volume Mount

```yaml
# /etc/kubernetes/manifests/static-volume-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-volume-pod
spec:
  containers:
    - name: web
      image: nginx
      volumeMounts:
        - name: web-content
          mountPath: /usr/share/nginx/html
  volumes:
    - name: web-content
      hostPath:
        path: /data/web
        type: DirectoryOrCreate
```

---

## Static Pods in a Cluster

When kubelet is part of a Kubernetes cluster:

```
┌─────────────────────────────────────────────────────┐
│               Control Plane                          │
│  ┌──────────────┐       ┌──────────────┐           │
│  │ API Server   │◄──────┤  ETCD        │           │
│  └──────┬───────┘       └──────────────┘           │
│         │                                            │
└─────────┼────────────────────────────────────────────┘
          │ creates mirror object
          │ (read-only)
┌─────────▼────────────────────────────────────────────┐
│         Worker Node                                   │
│  ┌──────────────┐                                    │
│  │   kubelet    │                                    │
│  └──────┬───────┘                                    │
│         │ reads                                       │
│         ▼                                             │
│  ┌─────────────────────┐                             │
│  │ /etc/kubernetes/    │                             │
│  │    manifests/       │                             │
│  │  - pod.yaml         │                             │
│  └─────────────────────┘                             │
│         │                                             │
│         ▼ creates                                     │
│  ┌──────────────┐                                    │
│  │  Static Pod  │                                    │
│  └──────────────┘                                    │
└───────────────────────────────────────────────────────┘
```

### Mirror Objects

When kubelet creates a static pod in a cluster:

1. Kubelet creates the actual pod
2. Kubelet creates a **mirror object** in the API server
3. Mirror object is **read-only** via kubectl
4. Pod name includes node name: `<pod-name>-<node-name>`

**Example:**

```bash
# Static pod on node01
kubectl get pods
# NAME                   READY   STATUS    RESTARTS   AGE
# static-nginx-node01    1/1     Running   0          5m
```

### Viewing Static Pods

```bash
# List all pods (includes static pods)
kubectl get pods -A

# Static pods in kube-system (control plane components)
kubectl get pods -n kube-system

# Example output:
# NAME                           READY   STATUS    RESTARTS   AGE
# etcd-master                    1/1     Running   0          10d
# kube-apiserver-master          1/1     Running   0          10d
# kube-controller-manager-master 1/1     Running   0          10d
# kube-scheduler-master          1/1     Running   0          10d
```

**Notice**: Control plane components are static pods (note the `-master` suffix)

---

## Control Plane Components as Static Pods

In clusters created with **kubeadm**, control plane components run as static pods:

```bash
# List control plane static pods
ls -l /etc/kubernetes/manifests/

# Output:
# etcd.yaml
# kube-apiserver.yaml
# kube-controller-manager.yaml
# kube-scheduler.yaml
```

**Example: API Server Static Pod**

```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
    - name: kube-apiserver
      image: k8s.gcr.io/kube-apiserver:v1.28.0
      command:
        - kube-apiserver
        - --advertise-address=192.168.1.10
        - --etcd-servers=https://127.0.0.1:2379
      # ... many more flags
```

**Benefits**:

- Self-healing: kubelet restarts control plane if it crashes
- No dependency on control plane to start control plane
- Simple to manage and update

---

## Managing Static Pods

### Create Static Pod

```bash
# Option 1: Direct file creation
sudo vi /etc/kubernetes/manifests/my-pod.yaml

# Option 2: Generate and copy
kubectl run static-pod --image=nginx --dry-run=client -o yaml > pod.yaml
sudo cp pod.yaml /etc/kubernetes/manifests/
```

### Update Static Pod

```bash
# Edit the manifest file
sudo vi /etc/kubernetes/manifests/my-pod.yaml

# Kubelet automatically detects changes and recreates the pod
```

### Delete Static Pod

```bash
# Remove the manifest file
sudo rm /etc/kubernetes/manifests/my-pod.yaml

# Kubelet automatically deletes the pod
```

### View Static Pod Status

```bash
# Using kubectl (shows mirror object)
kubectl get pods -o wide

# Using docker/containerd (shows actual container)
docker ps | grep static
crictl ps | grep static

# Check kubelet logs
journalctl -u kubelet -f
```

---

## Static Pods vs DaemonSets

Both ensure pods run on nodes, but they're different:

| Feature            | Static Pods                                    | DaemonSets                                         |
| ------------------ | ---------------------------------------------- | -------------------------------------------------- |
| **Created by**     | kubelet                                        | DaemonSet controller (via API server)              |
| **Control Plane**  | Not required                                   | Required (API server, scheduler)                   |
| **Management**     | Edit manifest files on node                    | kubectl commands                                   |
| **Scheduling**     | Ignored by scheduler                           | Ignored by scheduler                               |
| **Node Targeting** | One pod per node (where manifest exists)       | One pod per node (all nodes by default)            |
| **Use Case**       | Control plane components, critical system pods | Monitoring agents, log collectors, network plugins |
| **Modification**   | Edit file on node                              | kubectl edit/patch                                 |
| **Visibility**     | Visible via kubectl (mirror)                   | Managed via kubectl                                |
| **Restart Policy** | Managed by kubelet                             | Managed by DaemonSet controller                    |

### When to Use Each

**Use Static Pods for:**

- Control plane components (API server, etcd, scheduler)
- Bootstrap scenarios
- Critical system components that must run before cluster is operational

**Use DaemonSets for:**

- Monitoring agents (Prometheus node exporter)
- Log collectors (Fluentd, Filebeat)
- Network plugins (Calico, Weave)
- Storage plugins (Ceph)

---

## Practical Examples

### Example 1: Identify Static Pods

```bash
# List all pods with node name in their name
kubectl get pods -A | grep -E '\-node|\-master'

# Output:
# kube-system   etcd-master                      1/1     Running
# kube-system   kube-apiserver-master            1/1     Running
# kube-system   kube-controller-manager-master   1/1     Running
# default       static-nginx-node01              1/1     Running

# These are static pods (note the node/master suffix)
```

### Example 2: Find Static Pod Manifest Location

```bash
# Check kubelet config
ps aux | grep kubelet | grep config

# Output might show:
# --config=/var/lib/kubelet/config.yaml

# Check the config file
grep staticPodPath /var/lib/kubelet/config.yaml
# Output: staticPodPath: /etc/kubernetes/manifests
```

### Example 3: Create Static Pod on Specific Node

```bash
# SSH to the target node
ssh node01

# Create static pod manifest
sudo cat <<EOF > /etc/kubernetes/manifests/custom-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-pod
spec:
  containers:
  - name: nginx
    image: nginx
EOF

# Exit and verify from master
exit
kubectl get pods
# NAME                 READY   STATUS    RESTARTS   AGE
# custom-pod-node01    1/1     Running   0          10s
```

### Example 4: Modify Static Pod

```bash
# SSH to node
ssh node01

# Edit manifest
sudo vi /etc/kubernetes/manifests/custom-pod.yaml
# Change image from nginx to nginx:alpine

# Kubelet detects change and recreates pod
# Check pod status
kubectl get pods custom-pod-node01 -w
# Watch as old pod terminates and new one starts
```

### Example 5: Delete Static Pod

```bash
# Attempt 1: Using kubectl (FAILS - mirror is read-only)
kubectl delete pod static-nginx-node01
# Pod deleted, but immediately recreated!

# Correct method: Remove manifest file
ssh node01
sudo rm /etc/kubernetes/manifests/static-nginx.yaml
exit

# Verify pod is gone
kubectl get pods
# No static-nginx-node01 pod
```

---

## Important Behaviors

### 1. Automatic Restart

Static pods are automatically restarted if they fail:

```bash
# Kill the container
docker stop <container-id>

# Kubelet immediately restarts it
kubectl get pods -w
# Watch pod go from Running → Terminating → Running
```

### 2. Name Pattern

Static pods always have the node name appended:

```
<pod-name>-<node-name>

Examples:
- static-web-node01
- etcd-master
- kube-apiserver-controlplane
```

### 3. Cannot Be Moved

Static pods are tied to the node where their manifest exists:

```bash
# Cannot do this:
kubectl drain node01  # Static pods won't move!

# To "move" a static pod:
# 1. Remove manifest from node01
# 2. Add manifest to node02
```

### 4. Cannot Be Created via kubectl

```bash
# This does NOT create a static pod:
kubectl run my-pod --image=nginx

# Must place manifest in static pod directory
```

---

## Troubleshooting

### Static Pod Not Starting

**Check 1: Verify manifest directory**

```bash
# Find configured directory
grep staticPodPath /var/lib/kubelet/config.yaml

# Check if manifest exists
ls -l /etc/kubernetes/manifests/
```

**Check 2: Validate YAML syntax**

```bash
# Test YAML validity
kubectl apply --dry-run=client -f /etc/kubernetes/manifests/my-pod.yaml
```

**Check 3: Check kubelet logs**

```bash
# View kubelet logs
journalctl -u kubelet -n 50

# Look for errors like:
# "unable to decode manifest"
# "failed to create pod"
```

**Check 4: Verify file permissions**

```bash
# Kubelet must be able to read the file
ls -l /etc/kubernetes/manifests/my-pod.yaml
# Should be readable by root or kubelet user
```

---

### Cannot Delete Static Pod via kubectl

**Problem:**

```bash
kubectl delete pod static-nginx-node01
# pod "static-nginx-node01" deleted
# But it comes back immediately!
```

**Solution:**

```bash
# SSH to node and remove manifest
ssh node01
sudo rm /etc/kubernetes/manifests/static-nginx.yaml
```

---

### Static Pod Shows in kubectl but Not Running

**Check container runtime:**

```bash
# For docker
docker ps -a | grep static-nginx

# For containerd
crictl ps -a | grep static-nginx

# Check logs
docker logs <container-id>
crictl logs <container-id>
```

---

## Commands Reference

### Configuration

```bash
# Find static pod path
ps aux | grep kubelet | grep -E "pod-manifest-path|config"
grep staticPodPath /var/lib/kubelet/config.yaml

# Check kubelet service
systemctl status kubelet
systemctl cat kubelet

# View kubelet logs
journalctl -u kubelet -f
```

### Managing Static Pods

```bash
# Create static pod (on specific node)
ssh <node-name>
sudo vi /etc/kubernetes/manifests/my-pod.yaml

# List static pod manifests
ls -l /etc/kubernetes/manifests/

# Edit static pod
sudo vi /etc/kubernetes/manifests/my-pod.yaml

# Delete static pod
sudo rm /etc/kubernetes/manifests/my-pod.yaml

# View via kubectl
kubectl get pods -A
kubectl describe pod <pod-name>-<node-name>
```

### Identifying Static Pods

```bash
# List pods with node suffix
kubectl get pods -A -o wide | grep -E '\-node|\-master'

# Check pod owner
kubectl get pod <pod-name> -o yaml | grep ownerReferences
# Static pods have no ownerReferences

# Check annotations
kubectl get pod <pod-name> -o yaml | grep "kubernetes.io/config"
# Static pods have config.source and config.mirror annotations
```

---

## CKA Exam Tips and Scenarios

### What to Expect in CKA Exam

Static pods are commonly tested in these scenarios:

#### Scenario 1: **Identify Static Pods**

**Typical Question:**

> How many static pods exist in the cluster?

**Solution:**

```bash
# Method 1: Look for pods with node suffix
kubectl get pods -A -o wide

# Count pods with pattern: <name>-<node>
# Examples: etcd-master, kube-apiserver-master, static-web-node01

# Method 2: Check for pods without owner
kubectl get pods -A -o json | jq '.items[] | select(.metadata.ownerReferences == null) | .metadata.name'

# Method 3: Check specific namespace
kubectl get pods -n kube-system
# Control plane components are static pods
```

**Answer format**: Count pods like `etcd-master`, `kube-apiserver-master`, etc.

---

#### Scenario 2: **Find Static Pod Path**

**Typical Question:**

> What is the path of the directory holding static pod definition files?

**Solution:**

```bash
# Method 1: Check kubelet config
ps aux | grep kubelet | grep config
# Look for: --config=/var/lib/kubelet/config.yaml

grep staticPodPath /var/lib/kubelet/config.yaml
# Output: staticPodPath: /etc/kubernetes/manifests

# Method 2: Check for --pod-manifest-path flag
ps aux | grep kubelet | grep pod-manifest-path

# Method 3: Check common locations
ls -l /etc/kubernetes/manifests/
ls -l /etc/kubelet.d/
```

**Answer**: `/etc/kubernetes/manifests` (most common with kubeadm)

---

#### Scenario 3: **Create Static Pod**

**Typical Question:**

> Create a static pod named `static-busybox` on node01 with image `busybox` that runs command `sleep 1000`.

**Solution:**

```bash
# Step 1: Generate pod YAML
kubectl run static-busybox --image=busybox --dry-run=client -o yaml --command -- sleep 1000 > static-busybox.yaml

# Step 2: Find static pod path (if not given)
ssh node01
grep staticPodPath /var/lib/kubelet/config.yaml

# Step 3: Copy manifest to static pod directory
sudo cp static-busybox.yaml /etc/kubernetes/manifests/

# Or create directly:
sudo cat <<EOF > /etc/kubernetes/manifests/static-busybox.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-busybox
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sleep', '1000']
EOF

# Step 4: Verify (from master or control plane)
exit
kubectl get pods
# NAME                      READY   STATUS    RESTARTS   AGE
# static-busybox-node01     1/1     Running   0          10s
```

---

#### Scenario 4: **Delete Static Pod**

**Typical Question:**

> Delete the static pod named `static-nginx` on node01.

**Solution:**

```bash
# Step 1: Identify the node
kubectl get pod static-nginx-node01 -o wide
# Note the node name (node01)

# Step 2: SSH to the node
ssh node01

# Step 3: Find manifest file
ls /etc/kubernetes/manifests/ | grep static-nginx
# Output: static-nginx.yaml

# Step 4: Remove manifest file
sudo rm /etc/kubernetes/manifests/static-nginx.yaml

# Step 5: Verify deletion
exit
kubectl get pods
# static-nginx-node01 should be gone
```

**Important**: Using `kubectl delete pod` will NOT work - pod will be recreated!

---

#### Scenario 5: **Modify Static Pod**

**Typical Question:**

> Update the static pod `static-web` on node01 to use image `nginx:alpine` instead of `nginx`.

**Solution:**

```bash
# Step 1: SSH to node
ssh node01

# Step 2: Find and edit manifest
sudo vi /etc/kubernetes/manifests/static-web.yaml

# Change:
# image: nginx
# To:
# image: nginx:alpine

# Save and exit

# Step 3: Kubelet auto-detects change and recreates pod
# Verify from master
exit
kubectl get pods static-web-node01
kubectl describe pod static-web-node01 | grep Image
```

---

#### Scenario 6: **Troubleshoot Static Pod**

**Typical Question:**

> A static pod named `critical-app` is not running. Investigate and fix the issue.

**Solution:**

```bash
# Step 1: Check pod status
kubectl get pods -A | grep critical-app
kubectl describe pod critical-app-node01

# Step 2: SSH to node
ssh node01

# Step 3: Check manifest exists
ls -l /etc/kubernetes/manifests/critical-app.yaml

# Step 4: Validate YAML
kubectl apply --dry-run=client -f /etc/kubernetes/manifests/critical-app.yaml
# Look for syntax errors

# Step 5: Check kubelet logs
journalctl -u kubelet -n 50 | grep critical-app

# Step 6: Fix issue in manifest
sudo vi /etc/kubernetes/manifests/critical-app.yaml

# Common issues:
# - YAML syntax errors
# - Invalid image name
# - Wrong indentation
```

---

### Exam Time-Saving Tips

1. **Know the default path**: `/etc/kubernetes/manifests` (kubeadm clusters)

2. **Quick static pod creation**:

   ```bash
   kubectl run NAME --image=IMAGE --dry-run=client -o yaml > pod.yaml
   scp pod.yaml node01:/etc/kubernetes/manifests/
   ```

3. **Identify static pods quickly**:

   ```bash
   kubectl get pods -A | grep -E '\-node[0-9]|\-master|\-controlplane'
   ```

4. **Remember kubectl commands don't work**:

   - `kubectl delete` → Pod recreates
   - `kubectl edit` → Changes ignored
   - Must edit manifest file directly

5. **SSH shortcuts**:

   ```bash
   # Set up alias
   alias n1='ssh node01'
   alias m='ssh master'
   ```

6. **Common mistake**: Forgetting node name in pod name

   - Static pod: `my-pod` on node01 → Shows as `my-pod-node01`

7. **Verification is key**:
   ```bash
   kubectl get pods -w  # Watch for pod to appear/change
   ```

---

### Practice Scenarios

1. **Count static pods** in kube-system namespace
2. **Create static pod** with specific command
3. **Identify node** running a specific static pod
4. **Delete and recreate** static pod on different node
5. **Update image** of existing static pod
6. **Find manifest path** on worker node
7. **Fix broken** static pod YAML

---

## Best Practices

### 1. Use for Critical System Components Only

✅ **Good use cases:**

- Control plane components (API server, etcd)
- Essential monitoring agents
- Critical system daemons

❌ **Bad use cases:**

- Application workloads (use Deployments)
- Services that need multiple replicas (use Deployments/ReplicaSets)
- Pods that need cluster-wide scheduling (use DaemonSets)

### 2. Keep Manifests Version Controlled

```bash
# Store manifests in git
/etc/kubernetes/manifests/ → Git repository
```

### 3. Use Descriptive Names

```yaml
metadata:
  name: monitoring-agent # Clear purpose
  # Not: pod1, test, app
```

### 4. Document Static Pods

Add labels and annotations:

```yaml
metadata:
  name: my-static-pod
  labels:
    type: static
    component: system
  annotations:
    description: "Critical monitoring agent"
```

### 5. Regular Validation

```bash
# Periodically validate all manifests
for f in /etc/kubernetes/manifests/*.yaml; do
  kubectl apply --dry-run=client -f "$f"
done
```

---

## Additional Resources

- [Official Kubernetes Documentation: Static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)
- [Kubelet Configuration](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/)
- [Create static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)
