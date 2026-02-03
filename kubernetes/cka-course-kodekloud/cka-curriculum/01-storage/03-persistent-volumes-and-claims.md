# Persistent Volumes and Persistent Volume Claims

## Exam Weight
Part of **10% - Storage**

## What Can Be Tested

- Create PersistentVolume (PV) manually
- Create PersistentVolumeClaim (PVC)
- Bind PVC to specific PV using labels and selectors
- Mount PVC in pods
- Resize PVC (volume expansion)
- Troubleshoot PVC binding issues
- Delete PVC and understand reclaim behavior

## Sample Questions

1. **Create a PV named `pv-demo` with 2Gi capacity using hostPath `/mnt/data`**
2. **Create a PVC requesting 1Gi storage and mount it in an nginx pod at `/data`**
3. **Create a PV with label `type=ssd` and a PVC that selects only that PV**
4. **Expand an existing PVC from 5Gi to 10Gi**
5. **Troubleshoot why a PVC is stuck in Pending state**

## Official Documentation

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Configure Pod to Use PVC](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)
- [Expanding Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims)

## Key Concepts

### PV vs PVC

| Aspect | PersistentVolume (PV) | PersistentVolumeClaim (PVC) |
|--------|----------------------|----------------------------|
| **Created by** | Cluster admin | User/developer |
| **Scope** | Cluster-wide resource | Namespace-scoped |
| **Purpose** | Provision storage | Request storage |
| **Analogy** | Storage pool | Storage request |

### PVC to PV Binding Process

```
1. User creates PVC
2. Kubernetes finds matching PV:
   - Sufficient capacity
   - Matching access modes
   - Matching StorageClass
   - Matching selector (if specified)
3. PVC binds to PV (1:1 relationship)
4. Pod uses PVC to mount storage
```

## Imperative Commands

```bash
# List PVs and PVCs
kubectl get pv
kubectl get pvc
kubectl get pv,pvc

# Describe to see details and events
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>

# Check which PV a PVC is bound to
kubectl get pvc <pvc-name> -o yaml | grep volumeName

# Delete PVC
kubectl delete pvc <pvc-name>

# Delete PV
kubectl delete pv <pv-name>

# Watch PVC status changes
kubectl get pvc -w

# Show custom columns
kubectl get pvc -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,VOLUME:.spec.volumeName,CAPACITY:.spec.resources.requests.storage

kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,ACCESS:.spec.accessModes,RECLAIM:.spec.persistentVolumeReclaimPolicy,STATUS:.status.phase
```

## YAML Examples

### Basic PV with hostPath
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
    type: DirectoryOrCreate
```

### PV with Labels
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-ssd
  labels:
    type: ssd
    environment: production
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/ssd-data
```

### Basic PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-basic
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

### PVC with Selector (Binds to Specific PV)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-ssd
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  selector:
    matchLabels:
      type: ssd
      environment: production
```

### PVC with StorageClass
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-storage
  resources:
    requests:
      storage: 5Gi
```

### Pod Using PVC
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: data-volume
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: pvc-basic
```

### Complete Example: PV + PVC + Pod
```yaml
# PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/task-data
---
# PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
# Pod
apiVersion: v1
kind: Pod
metadata:
  name: task-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: task-pvc
```

### NFS PV
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.example.com
    path: /exported/path
  persistentVolumeReclaimPolicy: Retain
```

## Troubleshooting Tips

### PVC Stuck in Pending

```bash
# Check PVC status and events
kubectl describe pvc <pvc-name>

# Common reasons:
# 1. No PV matches requirements (capacity, access mode, StorageClass)
# 2. All matching PVs are already bound
# 3. StorageClass doesn't exist
# 4. Selector doesn't match any PV labels

# Check available PVs
kubectl get pv

# Look for PVs in "Available" state
kubectl get pv | grep Available

# Check PVC requested vs PV capacity
kubectl get pvc <pvc-name> -o yaml | grep storage
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,STATUS:.status.phase
```

### PVC Requesting More Than PV Offers
```bash
# PVC requests 10Gi but only 5Gi PV available
# Solution: Create larger PV or reduce PVC request

# Check what PVC is requesting
kubectl get pvc <pvc-name> -o yaml | grep -A3 "resources:"

# Create PV with sufficient capacity
kubectl apply -f larger-pv.yaml
```

### Access Mode Mismatch
```bash
# PVC requests RWX but only RWO PVs available
kubectl describe pvc <pvc-name> | grep "Access Modes"
kubectl get pv -o custom-columns=NAME:.metadata.name,ACCESS:.spec.accessModes

# Solution: Either change PVC access mode or create appropriate PV
```

### StorageClass Mismatch
```bash
# Check PVC StorageClass
kubectl get pvc <pvc-name> -o yaml | grep storageClassName

# Check available StorageClasses
kubectl get sc

# List PVs by StorageClass
kubectl get pv -o custom-columns=NAME:.metadata.name,STORAGECLASS:.spec.storageClassName

# Fix: Update PVC to use correct StorageClass or create matching PV
```

### PVC/PV Stuck in Terminating
```bash
# Check if pod is still using PVC
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\n"}{end}' | grep <pvc-name>

# Delete pod first
kubectl delete pod <pod-name>

# Then delete PVC
kubectl delete pvc <pvc-name>

# Force delete if needed (caution!)
kubectl patch pvc <pvc-name> -p '{"metadata":{"finalizers":null}}'
```

### Pod Cannot Mount PVC
```bash
# Check pod events
kubectl describe pod <pod-name>

# Common errors:
# "Volume is already attached by pod X"
# "Multi-Attach error"
# "Failed to mount device"

# Check if volume is already in use
kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\n"}{end}' | grep <pvc-name>
```

### Expand PVC (Volume Expansion)
```bash
# Check if StorageClass allows expansion
kubectl get sc <storage-class-name> -o yaml | grep allowVolumeExpansion

# Edit PVC to increase size
kubectl edit pvc <pvc-name>
# Change spec.resources.requests.storage to larger value

# Or use patch
kubectl patch pvc <pvc-name> -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'

# Restart pod to apply expansion (for some volume types)
kubectl delete pod <pod-name>

# Check expansion status
kubectl get pvc <pvc-name> -w
kubectl describe pvc <pvc-name> | grep -i "condition\|message"
```

## Key Files and Locations

### Volume Plugin Configuration
- **Kubelet config**: `/var/lib/kubelet/config.yaml`
- **Volume plugins**: `/usr/libexec/kubernetes/kubelet-plugins/volume/`

### PV/PVC Controller
- **Component**: `kube-controller-manager`
- **Logs**: `kubectl logs -n kube-system kube-controller-manager-<node>`
- **Check for binding issues**: `kubectl logs -n kube-system kube-controller-manager-<node> | grep persistentvolume`

### Node Volume Mounts
```bash
# SSH to node
ssh node01

# Check mounted volumes
mount | grep /var/lib/kubelet/pods

# Volume paths on node
ls /var/lib/kubelet/pods/<pod-uid>/volumes/
```

## Exam Tips

1. **Start with `kubectl get pv,pvc`** - see what's available
2. **Use `kubectl describe pvc`** - events show why binding fails
3. **PV capacity must be ≥ PVC request** - can't bind 5Gi PV to 10Gi PVC
4. **1:1 relationship** - one PV binds to one PVC
5. **PVC is namespaced, PV is cluster-wide**
6. **Pod references PVC name, not PV name**
7. **Delete pod before deleting PVC** to avoid stuck states
8. **Use labels/selectors** for specific PV selection
9. **Check StorageClass** - empty/manual vs dynamic provisioning
10. **Volume expansion** - requires `allowVolumeExpansion: true` in StorageClass

## Common Mistakes

- ❌ Pod references PV directly (should reference PVC)
- ❌ Creating PVC before PV exists (with manual provisioning)
- ❌ Requesting more storage than any available PV
- ❌ Mismatched access modes between PV and PVC
- ❌ Deleting PV while PVC still bound
- ❌ Forgetting namespace for PVC
- ❌ Using wrong claimName in pod spec

## Quick Reference

```bash
# Create PV and PVC
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

# Verify binding
kubectl get pv,pvc

# Check which pod uses which PVC
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\n"}{end}'

# Test by creating pod with PVC
kubectl run test-pod --image=nginx --dry-run=client -o yaml > pod.yaml
# Edit to add PVC volume
kubectl apply -f pod.yaml

# Verify mount in pod
kubectl exec test-pod -- df -h | grep /data

# Cleanup
kubectl delete pod test-pod
kubectl delete pvc <pvc-name>
kubectl delete pv <pv-name>
```
