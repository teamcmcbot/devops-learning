# Kubernetes Troubleshooting Guide

## Executive Summary

Troubleshooting is a critical skill for CKA and involves systematically diagnosing issues at different levels of the Kubernetes stack:

| Level             | Components                                      | Common Issues                            |
| ----------------- | ----------------------------------------------- | ---------------------------------------- |
| **Application**   | Pods, Services, Deployments                     | Crashes, connectivity, misconfigurations |
| **Control Plane** | API Server, etcd, Scheduler, Controller Manager | Component failures, certificate issues   |
| **Worker Node**   | Kubelet, Container Runtime, kube-proxy          | Node NotReady, resource exhaustion       |

**Troubleshooting Approach:**

1. Start from the user-facing issue (top-down)
2. Check component status and health
3. Review logs for errors
4. Verify configurations and connectivity

---

## Application Failure Troubleshooting

### Systematic Approach

```
User Request → Service → Endpoints → Pod → Container → Logs
```

### Step 1: Check Service Accessibility

```bash
# Test service connectivity
curl http://<service-ip>:<port>
curl http://<node-ip>:<node-port>

# Check service exists and has correct configuration
kubectl get svc <service-name>
kubectl describe svc <service-name>
```

### Step 2: Verify Service Endpoints

```bash
# Check if service has endpoints (connected to pods)
kubectl get endpoints <service-name>

# If no endpoints, check selector labels match pod labels
kubectl describe svc <service-name> | grep Selector
kubectl get pods --show-labels
```

**Common Issue:** Selector mismatch between Service and Pod labels

### Step 3: Check Pod Status

```bash
# List pods and their status
kubectl get pods
kubectl get pods -o wide

# Get detailed pod information
kubectl describe pod <pod-name>

# Check pod events for issues
kubectl get events --sort-by=.metadata.creationTimestamp
```

**Pod Status Meanings:**
| Status | Meaning |
|--------|---------|
| `Pending` | Pod scheduled but not running (image pull, resource issues) |
| `Running` | Pod is running |
| `CrashLoopBackOff` | Container crashing repeatedly |
| `ImagePullBackOff` | Cannot pull container image |
| `Error` | Container exited with error |
| `Completed` | Container finished successfully |

### Step 4: Review Application Logs

```bash
# View pod logs
kubectl logs <pod-name>

# View logs for specific container (multi-container pod)
kubectl logs <pod-name> -c <container-name>

# Stream logs in real-time
kubectl logs <pod-name> -f

# View previous container logs (after crash)
kubectl logs <pod-name> --previous
```

### Step 5: Debug Inside Container

```bash
# Execute command in container
kubectl exec -it <pod-name> -- /bin/sh

# Test network connectivity from pod
kubectl exec <pod-name> -- curl http://<service-name>
kubectl exec <pod-name> -- nslookup <service-name>

# Check environment variables
kubectl exec <pod-name> -- env
```

---

## Control Plane Failure Troubleshooting

### Control Plane Components

| Component                 | Purpose                        | Default Port |
| ------------------------- | ------------------------------ | ------------ |
| `kube-apiserver`          | API gateway for all operations | 6443         |
| `etcd`                    | Cluster state storage          | 2379, 2380   |
| `kube-scheduler`          | Pod scheduling                 | 10259        |
| `kube-controller-manager` | Runs controllers               | 10257        |

### Step 1: Check Node Status

```bash
# Verify all nodes are Ready
kubectl get nodes

# Check node details
kubectl describe node <node-name>
```

### Step 2: Check Control Plane Pods (kubeadm setup)

```bash
# List control plane pods
kubectl get pods -n kube-system

# Check specific component
kubectl get pods -n kube-system | grep -E "apiserver|etcd|scheduler|controller"

# Describe component pod
kubectl describe pod kube-apiserver-<master-node> -n kube-system
```

### Step 3: Check Component Status (Native Services)

```bash
# Check service status
sudo systemctl status kube-apiserver
sudo systemctl status kube-controller-manager
sudo systemctl status kube-scheduler
sudo systemctl status etcd

# Restart a service if needed
sudo systemctl restart kubelet
```

### Step 4: Review Control Plane Logs

**For kubeadm deployments (pods):**

```bash
# API Server logs
kubectl logs kube-apiserver-<master-node> -n kube-system

# Controller Manager logs
kubectl logs kube-controller-manager-<master-node> -n kube-system

# Scheduler logs
kubectl logs kube-scheduler-<master-node> -n kube-system

# etcd logs
kubectl logs etcd-<master-node> -n kube-system
```

**For native service deployments:**

```bash
# View logs via journalctl
sudo journalctl -u kube-apiserver
sudo journalctl -u kube-controller-manager
sudo journalctl -u kube-scheduler
sudo journalctl -u etcd

# Follow logs in real-time
sudo journalctl -u kube-apiserver -f
```

### Step 5: Check Static Pod Manifests

```bash
# Static pod manifests location
ls /etc/kubernetes/manifests/

# View API server manifest
cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Check for syntax errors
kubectl apply --dry-run=client -f /etc/kubernetes/manifests/kube-apiserver.yaml
```

**Common Control Plane Issues:**

- Incorrect manifest configuration
- Certificate expiration
- etcd connectivity issues
- Resource exhaustion on master node

---

## Worker Node Failure Troubleshooting

### Step 1: Check Node Status

```bash
# List nodes with status
kubectl get nodes

# Example output showing NotReady node
NAME       STATUS     ROLES    AGE   VERSION
master     Ready      master   10d   v1.28.0
worker-1   Ready      <none>   10d   v1.28.0
worker-2   NotReady   <none>   10d   v1.28.0
```

### Step 2: Examine Node Conditions

```bash
# Describe the problematic node
kubectl describe node <node-name>
```

**Node Conditions to Check:**
| Condition | True Means |
|-----------|------------|
| `Ready` | Node is healthy and accepting pods |
| `MemoryPressure` | Node is running low on memory |
| `DiskPressure` | Node is running low on disk space |
| `PIDPressure` | Too many processes on node |
| `NetworkUnavailable` | Network not configured correctly |

**Check LastHeartbeatTime** - indicates when node last communicated with master

### Step 3: SSH to Node and Check Kubelet

```bash
# SSH to the problematic node
ssh <node-name>

# Check kubelet service status
sudo systemctl status kubelet

# If not running, start it
sudo systemctl start kubelet

# Enable kubelet to start on boot
sudo systemctl enable kubelet

# View kubelet logs
sudo journalctl -u kubelet
sudo journalctl -u kubelet -f  # Follow

# Check kubelet configuration
cat /var/lib/kubelet/config.yaml
```

### Step 4: Check Node Resources

```bash
# On the worker node
# Check disk space
df -h

# Check memory
free -m

# Check CPU and processes
top
ps aux | wc -l  # Count processes
```

### Step 5: Verify Kubelet Certificates

```bash
# Check kubelet certificate
openssl x509 -in /var/lib/kubelet/pki/kubelet.crt -text -noout

# Verify certificate validity
openssl x509 -in /var/lib/kubelet/pki/kubelet.crt -noout -dates

# Check if issued by correct CA
openssl x509 -in /var/lib/kubelet/pki/kubelet.crt -noout -issuer
```

### Step 6: Check Container Runtime

```bash
# For containerd
sudo systemctl status containerd
sudo crictl ps
sudo crictl info

# For Docker (older clusters)
sudo systemctl status docker
sudo docker ps
```

---

## Quick Reference Commands

### Essential Troubleshooting Commands

```bash
# Get all resources in namespace
kubectl get all -n <namespace>

# Get events (sorted by time)
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Describe any resource
kubectl describe <resource-type> <resource-name>

# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs <pod-name> --previous

# Execute into container
kubectl exec -it <pod-name> -- /bin/sh

# Check cluster info
kubectl cluster-info
kubectl cluster-info dump

# Check component status
kubectl get componentstatuses  # deprecated but may work

# Node troubleshooting
kubectl get nodes
kubectl describe node <node-name>
kubectl top nodes
kubectl top pods
```

### Log Locations

| Component            | Log Location                                                 |
| -------------------- | ------------------------------------------------------------ |
| Kubelet              | `journalctl -u kubelet`                                      |
| Container Runtime    | `journalctl -u containerd` or `journalctl -u docker`         |
| API Server (kubeadm) | `kubectl logs -n kube-system kube-apiserver-<node>`          |
| API Server (native)  | `journalctl -u kube-apiserver`                               |
| Scheduler            | `kubectl logs -n kube-system kube-scheduler-<node>`          |
| Controller Manager   | `kubectl logs -n kube-system kube-controller-manager-<node>` |
| etcd                 | `kubectl logs -n kube-system etcd-<node>`                    |
| kube-proxy           | `kubectl logs -n kube-system kube-proxy-<pod>`               |

---

## CKA Exam Tips

### How This Topic is Tested

1. **Fix broken applications** - Services not connecting to pods
2. **Diagnose control plane issues** - Components not starting
3. **Troubleshoot worker nodes** - Nodes showing NotReady
4. **Fix configuration errors** - YAML syntax, selectors, ports

### Troubleshooting Checklist

**Application Issues:**

- [ ] Service exists? `kubectl get svc`
- [ ] Endpoints populated? `kubectl get endpoints`
- [ ] Pod running? `kubectl get pods`
- [ ] Pod logs show errors? `kubectl logs`
- [ ] Selector labels match?

**Control Plane Issues:**

- [ ] All control plane pods running? `kubectl get pods -n kube-system`
- [ ] Check logs for errors? `kubectl logs -n kube-system <pod>`
- [ ] Static manifests correct? `/etc/kubernetes/manifests/`

**Worker Node Issues:**

- [ ] Node status Ready? `kubectl get nodes`
- [ ] Kubelet running? `systemctl status kubelet`
- [ ] Kubelet logs? `journalctl -u kubelet`
- [ ] Disk/Memory OK? `df -h`, `free -m`
- [ ] Certificates valid? Check expiry dates

### Common Fixes

| Problem                        | Solution                                     |
| ------------------------------ | -------------------------------------------- |
| Service no endpoints           | Fix selector labels                          |
| Pod CrashLoopBackOff           | Check logs, fix command/args                 |
| ImagePullBackOff               | Fix image name, check registry access        |
| Node NotReady                  | Start/restart kubelet                        |
| Control plane pod not starting | Fix manifest in `/etc/kubernetes/manifests/` |
| kubelet not starting           | Check config, certificates, restart service  |

### Quick Debug Commands

```bash
# Fast pod status check
kubectl get pods -A | grep -v Running

# Check all events for errors
kubectl get events -A --field-selector type=Warning

# Quick service endpoint check
kubectl get endpoints

# Fast node status
kubectl get nodes -o wide
```

---

## Official Documentation

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshoot Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Node Health Monitoring](https://kubernetes.io/docs/tasks/debug/debug-cluster/monitor-node-health/)
