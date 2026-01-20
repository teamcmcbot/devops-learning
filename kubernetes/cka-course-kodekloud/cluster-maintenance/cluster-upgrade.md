# Kubernetes Cluster Upgrade - CKA Cheatsheet

## Executive Summary

**Cluster upgrade** is the process of updating Kubernetes components (kube-apiserver, controller-manager, scheduler, kubelet, kubectl) to a newer version. Upgrades are performed using `kubeadm` and must be done **one minor version at a time** (e.g., 1.28 → 1.29 → 1.30).

**Key Points:**

- Upgrade **one minor version at a time** (no skipping!)
- Upgrade **control plane first**, then worker nodes
- Kubernetes supports only **3 most recent minor versions**
- `kubeadm` upgrades control plane components but **NOT kubelet**
- kubelet must be upgraded **manually** on each node

---

## Version Skew Policy

Components can run at different versions, but with limits:

| Component          | Allowed Version (relative to kube-apiserver) |
| ------------------ | -------------------------------------------- |
| kube-apiserver     | X (baseline)                                 |
| controller-manager | X or X-1                                     |
| kube-scheduler     | X or X-1                                     |
| kubelet            | X, X-1, or X-2                               |
| kube-proxy         | X, X-1, or X-2                               |
| kubectl            | X+1, X, or X-1                               |

**Example:** If API server is v1.29:

- controller-manager can be v1.29 or v1.28
- kubelet can be v1.29, v1.28, or v1.27

---

## Upgrade Strategies for Worker Nodes

| Strategy        | Description                                  | Downtime? |
| --------------- | -------------------------------------------- | --------- |
| **All at once** | Upgrade all workers simultaneously           | Yes ⚠️    |
| **Rolling**     | Upgrade one node at a time                   | No ✅     |
| **Blue-Green**  | Add new nodes, migrate workloads, remove old | No ✅     |

---

## Real-World Usage Example

**Scenario:** Upgrade a cluster from v1.28.0 to v1.29.3

**Order of operations:**

1. Upgrade control plane node(s)
2. Upgrade worker nodes one at a time (rolling)

**Why rolling?** Ensures zero downtime - workloads shift to other nodes during each upgrade.

---

## Upgrade Process Overview

```
┌────────────────────────────────────────────────────────────────┐
│                    CLUSTER UPGRADE WORKFLOW                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   CONTROL PLANE                     WORKER NODES               │
│   ─────────────                     ────────────               │
│   1. Upgrade kubeadm                1. Upgrade kubeadm         │
│   2. kubeadm upgrade plan           2. kubeadm upgrade node    │
│   3. kubeadm upgrade apply          3. Drain node              │
│   4. Drain node                     4. Upgrade kubelet/kubectl │
│   5. Upgrade kubelet/kubectl        5. Restart kubelet         │
│   6. Restart kubelet                6. Uncordon node           │
│   7. Uncordon node                  7. Repeat for each node    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Common Commands

### Pre-Upgrade: Check Versions

```bash
# Check current node versions
kubectl get nodes

# Check kubeadm version
kubeadm version

# Check available versions
sudo apt-cache madison kubeadm
```

### Upgrade Control Plane

#### Step 0: Update Package Repository (Required for Minor Version Upgrades)

When upgrading to a **new minor version** (e.g., 1.28 → 1.29), you must update the Kubernetes package repository first. Each minor version has its own repository URL.

```bash
# Check current OS (CKA exam typically uses Ubuntu)
cat /etc/os-release

# Update repository to target version (e.g., v1.29)
# This points apt to the new version's package repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list
sudo apt-get update

# Verify new version is available
sudo apt-cache madison kubeadm | head -5
```

> **Note:** For patch upgrades within the same minor version (e.g., 1.29.0 → 1.29.3), you do NOT need to change the repository.

#### Step 1: Upgrade kubeadm

```bash
# Unhold, upgrade, and hold kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt-get install -y kubeadm='1.29.3-1.1' && \
sudo apt-mark hold kubeadm

# Verify kubeadm version
kubeadm version
```

#### Step 2: Plan the Upgrade

```bash
# See upgrade plan (dry run)
sudo kubeadm upgrade plan
```

#### Step 3: Apply Upgrade

```bash
# Apply upgrade to control plane
sudo kubeadm upgrade apply v1.29.3
```

#### Step 4: Upgrade kubelet & kubectl on Control Plane

```bash
# Drain control plane node
kubectl drain controlplane --ignore-daemonsets

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt-get install -y kubelet='1.29.3-1.1' kubectl='1.29.3-1.1' && \
sudo apt-mark hold kubelet kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Uncordon control plane
kubectl uncordon controlplane
```

### Upgrade Worker Nodes

```bash
# On WORKER NODE: Upgrade kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && \
sudo apt-get install -y kubeadm='1.29.3-1.1' && \
sudo apt-mark hold kubeadm

# On WORKER NODE: Upgrade node config
sudo kubeadm upgrade node

# On CONTROL PLANE: Drain worker node
kubectl drain node01 --ignore-daemonsets

# On WORKER NODE: Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && \
sudo apt-get install -y kubelet='1.29.3-1.1' kubectl='1.29.3-1.1' && \
sudo apt-mark hold kubelet kubectl

# On WORKER NODE: Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# On CONTROL PLANE: Uncordon worker node
kubectl uncordon node01
```

---

## Quick Reference: Control Plane vs Worker Node

| Step                    | Control Plane | Worker Node |
| ----------------------- | ------------- | ----------- |
| Upgrade kubeadm         | ✅            | ✅          |
| `kubeadm upgrade plan`  | ✅            | ❌          |
| `kubeadm upgrade apply` | ✅            | ❌          |
| `kubeadm upgrade node`  | ❌            | ✅          |
| Drain node              | ✅            | ✅          |
| Upgrade kubelet/kubectl | ✅            | ✅          |
| Restart kubelet         | ✅            | ✅          |
| Uncordon node           | ✅            | ✅          |

---

## Key Commands Summary

| Purpose                     | Command                                                |
| --------------------------- | ------------------------------------------------------ |
| Check upgrade plan          | `kubeadm upgrade plan`                                 |
| Apply control plane upgrade | `kubeadm upgrade apply v1.29.3`                        |
| Upgrade worker node config  | `kubeadm upgrade node`                                 |
| Check available versions    | `apt-cache madison kubeadm`                            |
| Hold package version        | `apt-mark hold kubeadm kubelet kubectl`                |
| Unhold package version      | `apt-mark unhold kubeadm kubelet kubectl`              |
| Restart kubelet             | `systemctl daemon-reload && systemctl restart kubelet` |

---

## Important Notes

⚠️ **Critical Points to Remember:**

1. **One minor version at a time**
   - Cannot jump from 1.27 → 1.29
   - Must go 1.27 → 1.28 → 1.29

2. **Control plane first, workers second**
   - Never upgrade workers before control plane

3. **kubeadm doesn't upgrade kubelet**
   - Must manually upgrade kubelet on each node

4. **`kubectl get nodes` shows kubelet version**
   - Not the API server version!

5. **Package repository update (newer K8s)**
   ```bash
   # Update to new pkgs.k8s.io repository for v1.29
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   ```

---

## CKA Exam Tips

### ⚠️ CKA Exam Environment

- The CKA exam typically uses **Ubuntu** (Debian-based)
- Use `apt` commands for package management
- Always check OS first: `cat /etc/os-release`
- For minor version upgrades, you **may need to update the package repository**

### How This Topic May Be Tested:

- **Upgrade a control plane node** from version X to Y
- **Upgrade a worker node** from version X to Y
- **Update package repository** when upgrading to new minor version
- **Check available versions** for kubeadm/kubelet
- **Troubleshoot** upgrade issues
- **Understand** version skew policy

### Key Commands to Memorize:

```bash
# Control plane upgrade
kubeadm upgrade plan
kubeadm upgrade apply v1.X.Y

# Worker node upgrade
kubeadm upgrade node

# Package management
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y kubeadm='1.X.Y-1.1' kubelet='1.X.Y-1.1' kubectl='1.X.Y-1.1'
apt-mark hold kubeadm kubelet kubectl

# Always after kubelet upgrade
systemctl daemon-reload
systemctl restart kubelet
```

### Exam Workflow Checklist:

**Control Plane:**

- [ ] Update repo (if minor version upgrade): `echo "deb [...] https://pkgs.k8s.io/core:/stable:/v1.XX/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
- [ ] `apt-get update`
- [ ] `apt-mark unhold kubeadm`
- [ ] `apt-get install kubeadm=<version>`
- [ ] `apt-mark hold kubeadm`
- [ ] `kubeadm upgrade plan`
- [ ] `kubeadm upgrade apply v<version>`
- [ ] `kubectl drain controlplane --ignore-daemonsets`
- [ ] `apt-mark unhold kubelet kubectl`
- [ ] `apt-get install kubelet=<version> kubectl=<version>`
- [ ] `apt-mark hold kubelet kubectl`
- [ ] `systemctl daemon-reload && systemctl restart kubelet`
- [ ] `kubectl uncordon controlplane`

**Worker Node:**

- [ ] Update repo (if minor version upgrade): `echo "deb [...] https://pkgs.k8s.io/core:/stable:/v1.XX/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
- [ ] `apt-get update`
- [ ] `apt-mark unhold kubeadm`
- [ ] `apt-get install kubeadm=<version>`
- [ ] `apt-mark hold kubeadm`
- [ ] `kubeadm upgrade node`
- [ ] `kubectl drain <node> --ignore-daemonsets` (from control plane)
- [ ] `apt-mark unhold kubelet kubectl`
- [ ] `apt-get install kubelet=<version> kubectl=<version>`
- [ ] `apt-mark hold kubelet kubectl`
- [ ] `systemctl daemon-reload && systemctl restart kubelet`
- [ ] `kubectl uncordon <node>` (from control plane)

### Common Exam Mistakes:

- Forgetting `systemctl daemon-reload` before `systemctl restart kubelet`
- Not draining node before upgrading kubelet
- Running `kubeadm upgrade apply` on worker nodes (should be `kubeadm upgrade node`)
- Forgetting to uncordon after upgrade

---

## Official Documentation Links

- [Upgrading kubeadm clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Changing the Kubernetes Package Repository](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/)
- [Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
- [kubeadm upgrade](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-upgrade/)
- [Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)
- [Kubernetes Release Notes](https://kubernetes.io/releases/)
