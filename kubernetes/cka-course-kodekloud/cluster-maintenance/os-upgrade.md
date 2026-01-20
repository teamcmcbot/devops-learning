# OS Upgrades (Node Maintenance) - CKA Cheatsheet

## Executive Summary

**OS Upgrades** in Kubernetes involves safely taking nodes offline for maintenance (OS patches, security updates, hardware fixes) while minimizing service disruption. The key operations are **drain**, **cordon**, and **uncordon**.

**Key Points:**

- Nodes can be taken offline for maintenance without losing workloads
- **Drain** = evict pods + mark node unschedulable
- **Cordon** = mark node unschedulable only (pods stay)
- **Uncordon** = allow scheduling again
- Pod eviction timeout: **5 minutes** by default (node marked dead after)
- ReplicaSet pods are rescheduled; standalone pods are lost

---

## Key Concepts

### What Happens When a Node Goes Down?

| Scenario                       | Behavior                                                   |
| ------------------------------ | ---------------------------------------------------------- |
| Node down < 5 min              | Pods restart when node recovers                            |
| Node down > 5 min              | Pods marked as dead, ReplicaSet creates new pods elsewhere |
| Standalone pod (no controller) | **Lost** - not recreated anywhere                          |
| Pod with ReplicaSet/Deployment | Recreated on another node                                  |

### Pod Eviction Timeout

- Default: **5 minutes** (`--pod-eviction-timeout=5m0s` on controller-manager)
- After timeout, pods are considered dead and evicted

---

## Drain vs Cordon vs Uncordon

| Command    | What It Does                    | Pods Evicted? | Node Schedulable? |
| ---------- | ------------------------------- | ------------- | ----------------- |
| `drain`    | Evict pods + mark unschedulable | ✅ Yes        | ❌ No             |
| `cordon`   | Mark unschedulable only         | ❌ No         | ❌ No             |
| `uncordon` | Allow scheduling again          | N/A           | ✅ Yes            |

---

## Real-World Usage Example

**Scenario:** You need to apply a critical security patch to a worker node's OS.

**Steps:**

1. **Drain** the node - safely move all pods to other nodes
2. **Perform maintenance** - apply patches, reboot
3. **Uncordon** the node - allow pods to be scheduled again

```bash
# Step 1: Drain the node
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data

# Step 2: Perform OS maintenance on node-1
# (SSH to node, apply patches, reboot)

# Step 3: Once node is back, uncordon it
kubectl uncordon node-1
```

---

## Common Commands

### Drain a Node

```bash
# Basic drain (may fail if there are standalone pods or DaemonSets)
kubectl drain <node-name>

# Drain with common flags (recommended)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Drain with force (for standalone pods - they will be DELETED, not moved)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force

# Drain with grace period
kubectl drain <node-name> --ignore-daemonsets --grace-period=60
```

### Cordon a Node (No Eviction)

```bash
# Mark node as unschedulable (existing pods remain)
kubectl cordon <node-name>
```

### Uncordon a Node

```bash
# Allow scheduling on node again
kubectl uncordon <node-name>
```

### Check Node Status

```bash
# View node status (look for SchedulingDisabled)
kubectl get nodes

# Detailed node info
kubectl describe node <node-name>
```

---

## Important Drain Flags

| Flag                       | Description                                              |
| -------------------------- | -------------------------------------------------------- |
| `--ignore-daemonsets`      | Ignore DaemonSet pods (they auto-recreate)               |
| `--delete-emptydir-data`   | Delete pods using emptyDir volumes (data lost!)          |
| `--force`                  | Force delete standalone pods (not managed by controller) |
| `--grace-period=<seconds>` | Grace period for pod termination                         |
| `--timeout=<duration>`     | Timeout for drain operation                              |
| `--dry-run=client`         | Preview what would be evicted                            |

---

## Node Status After Operations

```bash
$ kubectl get nodes
NAME     STATUS                     ROLES    AGE   VERSION
node-1   Ready,SchedulingDisabled   <none>   10d   v1.30.0   # Cordoned/Drained
node-2   Ready                      <none>   10d   v1.30.0   # Normal
node-3   Ready                      <none>   10d   v1.30.0   # Normal
```

**`SchedulingDisabled`** = node is cordoned (no new pods scheduled)

---

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Node Maintenance Workflow                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   kubectl drain node-1          kubectl uncordon node-1         │
│         │                              │                        │
│         ▼                              ▼                        │
│   ┌───────────┐    Maintenance    ┌───────────┐                │
│   │  Pods     │ ──────────────▶  │   Node    │                 │
│   │  Evicted  │    (Reboot,      │  Ready    │                 │
│   │  Node     │     Patches)     │   for     │                 │
│   │ Cordoned  │                  │  Workloads│                 │
│   └───────────┘                  └───────────┘                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Common Drain Errors & Solutions

| Error                                   | Cause                           | Solution                             |
| --------------------------------------- | ------------------------------- | ------------------------------------ |
| `cannot delete DaemonSet-managed Pods`  | DaemonSet pods on node          | Add `--ignore-daemonsets`            |
| `cannot delete Pods with local storage` | Pods using emptyDir             | Add `--delete-emptydir-data`         |
| `cannot delete Pods not managed by...`  | Standalone pods (no controller) | Add `--force` (pod will be deleted!) |
| `pod has a PodDisruptionBudget`         | PDB prevents eviction           | Wait or adjust PDB                   |

---

## Important Notes

⚠️ **Critical Points to Remember:**

1. **Drained pods don't return automatically**
   - After uncordon, pods stay where they were rescheduled
   - Original node only gets NEW pods

2. **Standalone pods are DELETED with `--force`**
   - No controller to recreate them
   - Data is lost!

3. **DaemonSets auto-recreate**
   - Use `--ignore-daemonsets` since they'll restart anyway

4. **emptyDir data is lost**
   - `--delete-emptydir-data` removes pods using emptyDir
   - Any data in emptyDir volumes is gone

5. **PodDisruptionBudgets (PDBs)**
   - May block drain if evicting would violate PDB
   - Check PDBs before draining

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Drain a node** for maintenance
- **Cordon a node** to prevent new pods
- **Uncordon a node** after maintenance
- **Troubleshoot** drain failures (DaemonSets, local storage, standalone pods)
- **Understand** what happens to pods during node failure

### Key Commands to Memorize:

```bash
# Most common exam pattern
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <node>
kubectl cordon <node>
```

### Quick Reference Table:

| Task                         | Command                                                           |
| ---------------------------- | ----------------------------------------------------------------- |
| Prepare node for maintenance | `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data` |
| Mark node unschedulable only | `kubectl cordon <node>`                                           |
| Re-enable scheduling         | `kubectl uncordon <node>`                                         |
| Check node status            | `kubectl get nodes`                                               |

### Common Exam Mistakes:

- Forgetting `--ignore-daemonsets` (drain fails)
- Forgetting `--delete-emptydir-data` (drain fails if pods use emptyDir)
- Using `--force` without understanding standalone pods will be deleted
- Expecting pods to return to original node after uncordon

---

## Official Documentation Links

- [Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)
- [Cluster Management - Node Maintenance](https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/#maintenance-on-a-node)
- [kubectl drain](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_drain/)
- [kubectl cordon](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cordon/)
- [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)
