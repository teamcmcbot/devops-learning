# Storage Classes and Dynamic Volume Provisioning

## Exam Weight
Part of **10% - Storage**

## What Can Be Tested

- Create a StorageClass for dynamic provisioning
- Configure StorageClass with specific provisioner (AWS EBS, GCE PD, etc.)
- Set volume binding modes (Immediate vs WaitForFirstConsumer)
- Configure reclaim policies in StorageClass
- Set a default StorageClass
- Create PVCs that use StorageClasses for dynamic provisioning
- Troubleshoot dynamic provisioning failures

## Sample Questions

1. **Create a StorageClass named `fast-storage` using local storage provisioner with WaitForFirstConsumer binding mode**
2. **Create a StorageClass for AWS EBS with gp3 type and mark it as default**
3. **Create a PVC that uses dynamic provisioning with the `fast-storage` StorageClass**

## Official Documentation

- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)
- [Change Default StorageClass](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/)

## Key Concepts

### StorageClass Components

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"  # Set as default
provisioner: kubernetes.io/no-provisioner  # or cloud provider
parameters:
  type: pd-ssd  # Provisioner-specific parameters
volumeBindingMode: WaitForFirstConsumer  # or Immediate
reclaimPolicy: Delete  # or Retain
allowVolumeExpansion: true
```

### Volume Binding Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| **Immediate** | PV created immediately when PVC is created | General use |
| **WaitForFirstConsumer** | PV created when pod using PVC is scheduled | Topology-aware, local storage |

### Common Provisioners

| Provisioner | Storage Type |
|-------------|--------------|
| `kubernetes.io/aws-ebs` | AWS EBS (legacy) |
| `ebs.csi.aws.com` | AWS EBS (CSI driver) |
| `kubernetes.io/gce-pd` | Google Persistent Disk |
| `kubernetes.io/azure-disk` | Azure Disk |
| `kubernetes.io/no-provisioner` | Local/manual provisioning |

## Imperative Commands

```bash
# List StorageClasses
kubectl get storageclass
kubectl get sc

# Describe StorageClass
kubectl describe sc <storage-class-name>

# Get StorageClass YAML
kubectl get sc <storage-class-name> -o yaml

# Check which StorageClass is default
kubectl get sc | grep "(default)"

# Create PVC using specific StorageClass (imperative)
kubectl create -f pvc.yaml
```

## YAML Examples

### Local Storage StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

### AWS EBS StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-fast
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### GCE PD StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gold-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

### PVC Using StorageClass
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-storage  # References StorageClass
  resources:
    requests:
      storage: 5Gi
```

## Troubleshooting Tips

### Check StorageClass Availability
```bash
# List all StorageClasses
kubectl get sc

# If no StorageClasses exist and you're on cloud provider
# Check if CSI driver is installed
kubectl get pods -n kube-system | grep csi
```

### PVC Stuck in Pending
```bash
# Check PVC status
kubectl describe pvc <pvc-name>

# Common issues:
# 1. No matching StorageClass exists
# 2. StorageClass provisioner not available
# 3. Insufficient resources in cloud provider
# 4. WaitForFirstConsumer mode but no pod scheduled yet

# Check events
kubectl get events --sort-by='.lastTimestamp' | grep <pvc-name>
```

### Dynamic Provisioning Not Working
```bash
# Check if provisioner pods are running
kubectl get pods -n kube-system | grep provisioner

# Check StorageClass exists
kubectl get sc <storage-class-name>

# Check PVC references correct StorageClass
kubectl get pvc <pvc-name> -o yaml | grep storageClassName
```

### Set Default StorageClass
```bash
# Remove default annotation from current default
kubectl patch storageclass <old-default> \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Set new default
kubectl patch storageclass <new-default> \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Verify
kubectl get sc
```

## Key Files and Locations

- **Cloud Provider CSI Drivers**: `/etc/kubernetes/manifests/` or deployed as DaemonSets
- **Storage Plugin Config**: Varies by CSI driver
- **PVC/PV Binding**: Managed by kube-controller-manager

## Exam Tips

1. **Check existing StorageClasses first**: `kubectl get sc`
2. **Use WaitForFirstConsumer for local storage** to ensure topology awareness
3. **Remember to set storageClassName in PVC** - if omitted, default StorageClass is used
4. **Dynamic provisioning creates PVs automatically** - you only create PVC
5. **For on-prem/kubeadm clusters**, use `kubernetes.io/no-provisioner` and manual PV creation
6. **Cloud clusters (GKE, EKS, AKS)** have pre-configured StorageClasses
7. **Check provisioner availability** if dynamic provisioning fails

## Common Mistakes

- ❌ Creating PV manually when using dynamic provisioning
- ❌ Forgetting to specify `storageClassName` in PVC
- ❌ Using `Immediate` binding mode for local storage (use `WaitForFirstConsumer`)
- ❌ Not checking if StorageClass exists before creating PVC
- ❌ Misspelling provisioner name

## Quick Reference

```bash
# Create StorageClass from file
kubectl apply -f storageclass.yaml

# Create PVC with dynamic provisioning
kubectl apply -f pvc.yaml

# Check PV was created automatically
kubectl get pv

# Check PVC is bound
kubectl get pvc

# Verify pod can mount the volume
kubectl describe pod <pod-name>
```
