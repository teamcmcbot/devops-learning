# Backup and Restore Methods - CKA Cheatsheet

## Executive Summary

Kubernetes backup involves protecting **three key areas**: declarative configuration files, imperatively-created resources, and the **etcd cluster** (the most critical). etcd stores all cluster state - losing it means losing your entire cluster. The primary backup method is **etcd snapshots** using `etcdctl`.

**Key Points:**

- etcd is the **single source of truth** for cluster state
- Use `etcdctl snapshot save` to backup etcd
- Use `etcdctl snapshot restore` to restore from backup
- Always include certificates when running etcdctl commands
- Store config files in version control (GitOps)

---

## What to Back Up

| Component                | What It Contains                           | Backup Method                |
| ------------------------ | ------------------------------------------ | ---------------------------- |
| **Declarative configs**  | YAML files (Deployments, Services, etc.)   | Git/version control          |
| **Imperative resources** | Resources created via `kubectl create/run` | `kubectl get all -A -o yaml` |
| **etcd cluster**         | ALL cluster state and data                 | `etcdctl snapshot save`      |

---

## Backup Approaches

### 1. Resource Configuration Backup

```bash
# Export all resources from all namespaces
kubectl get all --all-namespaces -o yaml > all-resources-backup.yaml

# Backup specific resource types
kubectl get deployments -A -o yaml > deployments-backup.yaml
kubectl get services -A -o yaml > services-backup.yaml
kubectl get configmaps -A -o yaml > configmaps-backup.yaml
kubectl get secrets -A -o yaml > secrets-backup.yaml
kubectl get pv,pvc -A -o yaml > storage-backup.yaml
```

> **Note:** This method doesn't capture everything (e.g., etcd metadata). Use etcd backup for complete cluster recovery.

### 2. etcd Snapshot Backup (Primary Method)

```bash
# Create etcd snapshot
ETCDCTL_API=3 etcdctl snapshot save /opt/snapshot-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify snapshot
ETCDCTL_API=3 etcdctl snapshot status /opt/snapshot-backup.db --write-out=table
```

---

## Real-World Usage Example

**Scenario:** Before performing a risky cluster upgrade, you want to backup etcd so you can restore if things go wrong.

**Steps:**

1. Take etcd snapshot before upgrade
2. Perform cluster upgrade
3. If upgrade fails → restore from snapshot
4. If upgrade succeeds → keep snapshot as historical backup

---

## etcd Key Information

### Find etcd Configuration

```bash
# If etcd runs as a static pod (kubeadm clusters)
cat /etc/kubernetes/manifests/etcd.yaml

# Key paths to look for:
# --data-dir=/var/lib/etcd                    (etcd data directory)
# --cert-file=/etc/kubernetes/pki/etcd/server.crt
# --key-file=/etc/kubernetes/pki/etcd/server.key
# --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
# --listen-client-urls=https://127.0.0.1:2379

# Check etcd pod
kubectl get pods -n kube-system | grep etcd
kubectl describe pod etcd-controlplane -n kube-system
```

### Common etcd Paths (kubeadm clusters)

| Item                | Path                                  |
| ------------------- | ------------------------------------- |
| etcd manifest       | `/etc/kubernetes/manifests/etcd.yaml` |
| etcd data directory | `/var/lib/etcd`                       |
| CA certificate      | `/etc/kubernetes/pki/etcd/ca.crt`     |
| Server certificate  | `/etc/kubernetes/pki/etcd/server.crt` |
| Server key          | `/etc/kubernetes/pki/etcd/server.key` |

---

## Common Commands

### Backup etcd

```bash
# Set API version (required!)
export ETCDCTL_API=3

# Simple snapshot (if certs not required)
etcdctl snapshot save snapshot.db

# Full command with certificates (most common in exams)
ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Check snapshot status
ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup.db --write-out=table
```

### Restore etcd

```bash
# Step 1: Stop kube-apiserver (if not using static pods, it auto-restarts)
# For static pod setup, the restore process handles this

# Step 2: Restore snapshot to a NEW data directory
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-from-backup

# Step 3: Update etcd manifest to use new data directory
# Edit /etc/kubernetes/manifests/etcd.yaml
# Change: --data-dir=/var/lib/etcd-from-backup
# Change: volumes hostPath to /var/lib/etcd-from-backup

# Step 4: Wait for etcd to restart (static pod auto-restarts)
# Verify
kubectl get pods -n kube-system | grep etcd
```

### Restore Steps in Detail

```bash
# 1. Restore to new directory
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-from-backup

# 2. Edit etcd manifest
vi /etc/kubernetes/manifests/etcd.yaml

# Change these lines:
# spec.containers.command:
#   - --data-dir=/var/lib/etcd-from-backup
#
# spec.volumes (find etcd-data volume):
#   - hostPath:
#       path: /var/lib/etcd-from-backup

# 3. Wait for etcd pod to restart (may take 1-2 minutes)
watch "kubectl get pods -n kube-system | grep etcd"

# 4. Verify cluster is working
kubectl get nodes
kubectl get pods -A
```

---

## Diagram: Backup & Restore Flow

```
BACKUP:
┌─────────────────┐    etcdctl snapshot save    ┌─────────────────┐
│   etcd cluster  │ ──────────────────────────▶ │  snapshot.db    │
│ /var/lib/etcd   │                             │ (backup file)   │
└─────────────────┘                             └─────────────────┘

RESTORE:
┌─────────────────┐   etcdctl snapshot restore  ┌─────────────────┐
│  snapshot.db    │ ──────────────────────────▶ │   NEW etcd dir  │
│ (backup file)   │   --data-dir=/new/path      │/var/lib/etcd-   │
└─────────────────┘                             │  from-backup    │
                                                └─────────────────┘
                                                        │
                                                        ▼
                                          Update etcd.yaml manifest
                                          to point to new data-dir
```

---

## CKA Exam Tips

### ⚠️ CKA Exam Environment

- The exam **frequently tests** etcd backup and restore
- You'll need to find certificate paths from etcd pod/manifest
- Always use `ETCDCTL_API=3` (version 2 is deprecated)
- Restore creates a **NEW directory** - don't restore to existing `/var/lib/etcd`

### How This Topic May Be Tested:

- **Take a backup** of etcd and save to a specific location
- **Restore** etcd from a provided snapshot file
- **Find** etcd certificate paths from the cluster
- **Verify** backup was successful

### Key Commands to Memorize:

```bash
# BACKUP - Most important command!
ETCDCTL_API=3 etcdctl snapshot save <backup-path> \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=<ca-cert-path> \
  --cert=<server-cert-path> \
  --key=<server-key-path>

# RESTORE
ETCDCTL_API=3 etcdctl snapshot restore <backup-path> \
  --data-dir=<new-data-directory>

# VERIFY
ETCDCTL_API=3 etcdctl snapshot status <backup-path> --write-out=table
```

### Exam Workflow - Backup:

1. Find etcd pod: `kubectl describe pod etcd-controlplane -n kube-system`
2. Note certificate paths from the `--cert-file`, `--key-file`, `--trusted-ca-file` flags
3. Run `etcdctl snapshot save` with those certificates
4. Verify with `etcdctl snapshot status`

### Exam Workflow - Restore:

1. Restore snapshot to **new directory**: `etcdctl snapshot restore <file> --data-dir=/var/lib/etcd-from-backup`
2. Edit etcd manifest: `vi /etc/kubernetes/manifests/etcd.yaml`
3. Update `--data-dir` and volume `hostPath` to new directory
4. Wait for etcd pod to restart
5. Verify: `kubectl get pods -A`

### Common Exam Mistakes:

- Forgetting `ETCDCTL_API=3` (commands won't work!)
- Wrong certificate paths (check etcd manifest!)
- Restoring to existing `/var/lib/etcd` instead of new directory
- Forgetting to update BOTH `--data-dir` AND `volumes.hostPath` in manifest
- Not waiting long enough for etcd to restart after restore

---

## Quick Reference Card

| Action               | Command                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| Backup etcd          | `ETCDCTL_API=3 etcdctl snapshot save <file> --endpoints=... --cacert=... --cert=... --key=...` |
| Restore etcd         | `ETCDCTL_API=3 etcdctl snapshot restore <file> --data-dir=<new-dir>`                           |
| Verify backup        | `ETCDCTL_API=3 etcdctl snapshot status <file> --write-out=table`                               |
| Find etcd config     | `cat /etc/kubernetes/manifests/etcd.yaml`                                                      |
| Check etcd pod       | `kubectl describe pod etcd-controlplane -n kube-system`                                        |
| Backup all resources | `kubectl get all -A -o yaml > backup.yaml`                                                     |

---

## Official Documentation Links

- [Backing up an etcd cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster)
- [Restoring an etcd cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster)
- [Operating etcd clusters for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
- [etcd Documentation](https://etcd.io/docs/)
- [Velero - Backup and migrate Kubernetes resources](https://velero.io/)
