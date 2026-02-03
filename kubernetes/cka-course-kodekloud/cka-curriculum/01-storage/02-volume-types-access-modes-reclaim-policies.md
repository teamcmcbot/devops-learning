# Volume Types, Access Modes and Reclaim Policies

## Exam Weight
Part of **10% - Storage**

## What Can Be Tested

- Understand different volume types (hostPath, emptyDir, PV, PVC, ConfigMap, Secret, NFS, cloud volumes)
- Configure access modes (ReadWriteOnce, ReadOnlyMany, ReadWriteMany)
- Set and understand reclaim policies (Retain, Delete, Recycle)
- Match PVC to PV based on access modes and capacity
- Troubleshoot access mode mismatches

## Sample Questions

1. **Create a PV with ReadWriteMany access mode using NFS**
2. **Create a pod using emptyDir volume shared between two containers**
3. **Configure a PV with Retain reclaim policy and verify PV is retained after PVC deletion**
4. **Fix a pod that fails to mount due to access mode mismatch**

## Official Documentation

- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Access Modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
- [Reclaim Policies](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming)

## Volume Types

### Ephemeral Volumes (Pod Lifetime)

| Type | Use Case | Persists After Pod Deletion |
|------|----------|----------------------------|
| **emptyDir** | Temporary storage, shared between containers | ❌ No |
| **configMap** | Configuration files | ❌ No |
| **secret** | Sensitive data | ❌ No |
| **downwardAPI** | Pod metadata | ❌ No |

### Persistent Volumes (Beyond Pod Lifetime)

| Type | Use Case | Node-Specific |
|------|----------|---------------|
| **hostPath** | Single-node testing only | ✅ Yes |
| **local** | Local SSD, high performance | ✅ Yes |
| **nfs** | Shared network storage | ❌ No |
| **awsElasticBlockStore** | AWS EBS | ❌ No |
| **gcePersistentDisk** | GCP Persistent Disk | ❌ No |
| **azureDisk** | Azure Disk | ❌ No |

## Access Modes

| Mode | Abbreviation | Description | Use Case |
|------|--------------|-------------|----------|
| **ReadWriteOnce** | RWO | Read-write by **single node** | Most common, databases |
| **ReadOnlyMany** | ROX | Read-only by **many nodes** | Static content |
| **ReadWriteMany** | RWX | Read-write by **many nodes** | Shared file systems (NFS) |

### Important Notes
- Access modes are **node-level**, not pod-level
- Multiple pods on the **same node** can use RWO
- **Not all volume types support all access modes**

### Volume Type Support Matrix

| Volume Type | RWO | ROX | RWX |
|-------------|-----|-----|-----|
| **AWS EBS** | ✅ | ✅ | ❌ |
| **GCE PD** | ✅ | ✅ | ❌ |
| **Azure Disk** | ✅ | ❌ | ❌ |
| **NFS** | ✅ | ✅ | ✅ |
| **hostPath** | ✅ | ✅ | ❌ |
| **local** | ✅ | ❌ | ❌ |

## Reclaim Policies

| Policy | Behavior | When to Use |
|--------|----------|-------------|
| **Retain** | PV kept after PVC deleted, manual cleanup | Production, data safety |
| **Delete** | PV and backing storage deleted with PVC | Development, automatic cleanup |
| **Recycle** | Data scrubbed, PV reused | ⚠️ Deprecated, use dynamic provisioning |

### Default Reclaim Policies
- **Manually created PVs**: `Retain` (default)
- **Dynamically provisioned PVs**: `Delete` (default, from StorageClass)

## Imperative Commands

```bash
# List PVs with access modes
kubectl get pv

# Describe PV to see access modes and reclaim policy
kubectl describe pv <pv-name>

# List PVCs
kubectl get pvc

# Check PVC access modes and storage
kubectl describe pvc <pvc-name>

# Get PV/PVC as YAML
kubectl get pv <pv-name> -o yaml
kubectl get pvc <pvc-name> -o yaml

# Change reclaim policy of existing PV
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## YAML Examples

### emptyDir Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-storage-pod
spec:
  containers:
  - name: writer
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo $(date) >> /data/log.txt; sleep 5; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    command: ["/bin/sh", "-c", "tail -f /data/log.txt"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

### hostPath Volume (Testing Only)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    hostPath:
      path: /tmp/data
      type: DirectoryOrCreate
```

### PV with ReadWriteOnce (RWO)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-rwo
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
```

### PV with ReadWriteMany (RWX) - NFS
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-rwx-nfs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: nfs-server.example.com
    path: /exported/path
```

### PVC Requesting Specific Access Mode
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-rwx
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 8Gi
  storageClassName: nfs-storage
```

### AWS EBS PV
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: aws-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  awsElasticBlockStore:
    volumeID: vol-0123456789abcdef0
    fsType: ext4
```

## Troubleshooting Tips

### PVC Stuck in Pending - Access Mode Mismatch
```bash
# Check PVC requested access modes
kubectl get pvc <pvc-name> -o yaml | grep accessModes -A2

# Check available PV access modes
kubectl get pv -o custom-columns=NAME:.metadata.name,ACCESS:.spec.accessModes

# Events often show mismatch
kubectl describe pvc <pvc-name>
```

### Pod Cannot Mount Volume - Access Mode Issue
```bash
# Check pod events
kubectl describe pod <pod-name>

# Common error: "Multi-Attach error for volume"
# Cause: Trying to mount RWO volume on different node

# Solution: Either:
# 1. Use RWX volume type (NFS)
# 2. Ensure pod schedules on same node
# 3. Use node affinity or nodeSelector
```

### PV Not Released After PVC Deletion
```bash
# Check PV status
kubectl get pv

# If status is "Released" (not "Available")
# This happens with "Retain" policy

# To make it available again:
# 1. Remove claimRef from PV
kubectl patch pv <pv-name> -p '{"spec":{"claimRef": null}}'

# 2. Or delete and recreate PV
kubectl delete pv <pv-name>
kubectl apply -f pv.yaml
```

### Check What Volume Type Supports
```bash
# Check documentation for volume type capabilities
kubectl explain pv.spec --recursive | grep -A 20 "awsElasticBlockStore"
```

## Key Concepts

### PVC to PV Binding Rules
Kubernetes binds PVC to PV when:
1. **Capacity**: PV size ≥ PVC requested size
2. **Access Mode**: PV access modes include at least one PVC requested mode
3. **StorageClass**: Matches (or both empty)
4. **Selector**: PVC selector matches PV labels (if specified)

### Volume Lifecycle
```
Provisioning → Binding → Using → Reclaiming
     ↓            ↓        ↓          ↓
   PV Created  PVC Bound  Pod Uses  Policy Applied
```

## Exam Tips

1. **RWO = Single Node** (not single pod) - multiple pods on same node can use it
2. **RWX requires network storage** (NFS, CephFS) - most block storage doesn't support it
3. **hostPath is for testing only** - never use in production/multi-node clusters
4. **emptyDir deleted with pod** - use for temp/cache data only
5. **Retain = safe for production** - data won't be lost accidentally
6. **Check access modes compatibility** before creating PVCs
7. **Use `kubectl describe`** to see why PVC won't bind

## Common Mistakes

- ❌ Using hostPath in multi-node cluster (data won't follow pod)
- ❌ Requesting RWX for AWS EBS (not supported)
- ❌ Expecting emptyDir to persist after pod deletion
- ❌ Creating PVC with access mode not supported by available PVs
- ❌ Using Recycle policy (deprecated)
- ❌ Forgetting to check reclaim policy before deleting PVC

## Quick Reference Commands

```bash
# Create PV from YAML
kubectl apply -f pv.yaml

# Create PVC from YAML
kubectl apply -f pvc.yaml

# Check binding status
kubectl get pv,pvc

# See which PVC is bound to which PV
kubectl get pvc -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,VOLUME:.spec.volumeName

# Change reclaim policy
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

# Force delete PVC (if stuck)
kubectl patch pvc <pvc-name> -p '{"metadata":{"finalizers":null}}'
kubectl delete pvc <pvc-name> --force --grace-period=0
```
