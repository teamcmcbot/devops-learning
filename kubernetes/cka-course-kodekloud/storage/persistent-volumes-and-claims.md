# Persistent Volumes, Claims & Storage Classes

## Executive Summary

This guide covers three interconnected Kubernetes storage concepts:

| Concept                         | Purpose                           | Created By     |
| ------------------------------- | --------------------------------- | -------------- |
| **PersistentVolume (PV)**       | Cluster-wide storage resource     | Administrator  |
| **PersistentVolumeClaim (PVC)** | Request for storage by user       | User/Developer |
| **StorageClass (SC)**           | Template for dynamic provisioning | Administrator  |

**Key Workflow:**

1. Admin creates PV (static) OR StorageClass (dynamic)
2. User creates PVC to request storage
3. Kubernetes binds PVC to matching PV
4. Pod references PVC to use storage

---

## Container Storage Interface (CSI)

CSI is a standard interface that enables Kubernetes to work with any storage vendor without modifying core code.

**Key Points:**

- Universal standard (works with Kubernetes, Cloud Foundry, Mesos)
- Storage vendors create CSI drivers (Portworx, AWS EBS, Azure Disk, etc.)
- CSI defines RPCs: `CreateVolume`, `DeleteVolume`, `ControllerPublishVolume`, etc.

> **Note:** You typically don't interact with CSI directly - it works behind the scenes with StorageClasses.

---

## Persistent Volumes (PV)

### What is a PV?

A cluster-wide storage resource provisioned by an administrator. Think of it as a "pool" of available storage.

### Access Modes

| Mode            | Abbreviation | Description               |
| --------------- | ------------ | ------------------------- |
| `ReadWriteOnce` | RWO          | Read-write by single node |
| `ReadOnlyMany`  | ROX          | Read-only by many nodes   |
| `ReadWriteMany` | RWX          | Read-write by many nodes  |

### Reclaim Policies

| Policy    | Behavior                                           |
| --------- | -------------------------------------------------- |
| `Retain`  | PV kept after PVC deleted; manual cleanup required |
| `Delete`  | PV deleted automatically with PVC                  |
| `Recycle` | Data scrubbed, PV reused (deprecated)              |

### PV YAML Example

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-vol1
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/data
```

### PV with AWS EBS

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-aws
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```

---

## Persistent Volume Claims (PVC)

### What is a PVC?

A request for storage by a user. Kubernetes automatically binds PVC to a matching PV based on:

- Capacity
- Access modes
- Storage class
- Labels/Selectors (optional)

### PVC YAML Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

### PVC with Storage Class

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: google-storage
  resources:
    requests:
      storage: 500Mi
```

### Using PVC in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /data
          name: data-volume
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: myclaim
```

---

## Storage Classes

### What is a Storage Class?

Enables **dynamic provisioning** - automatically creates PVs when PVCs are created, eliminating manual PV management.

### Static vs Dynamic Provisioning

| Static Provisioning            | Dynamic Provisioning          |
| ------------------------------ | ----------------------------- |
| Admin creates storage manually | Storage created automatically |
| Admin creates PV manually      | PV created automatically      |
| More control                   | Less management overhead      |
| Time-consuming                 | Faster, scalable              |

### Storage Class YAML Examples

#### Basic Storage Class (GCE)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
```

#### Storage Class with Parameters

```yaml
# Silver tier - Standard disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: silver
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: none
```

```yaml
# Gold tier - SSD disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gold
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
```

```yaml
# Platinum tier - Regional SSD
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: platinum
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

#### AWS EBS Storage Class

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-sc
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
```

---

## Common Commands

```bash
# Persistent Volumes
kubectl create -f pv-definition.yaml
kubectl get pv
kubectl get persistentvolume
kubectl describe pv <pv-name>
kubectl delete pv <pv-name>

# Persistent Volume Claims
kubectl create -f pvc-definition.yaml
kubectl get pvc
kubectl get persistentvolumeclaim
kubectl describe pvc <pvc-name>
kubectl delete pvc <pvc-name>

# Storage Classes
kubectl create -f sc-definition.yaml
kubectl get sc
kubectl get storageclass
kubectl describe sc <sc-name>

# Check binding status
kubectl get pv,pvc
```

---

## Complete Workflow Example

### Step 1: Create Storage Class

```yaml
# sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

### Step 2: Create PVC (referencing StorageClass)

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-storage
  resources:
    requests:
      storage: 10Gi
```

### Step 3: Create Pod using PVC

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /var/www/html
          name: web-storage
  volumes:
    - name: web-storage
      persistentVolumeClaim:
        claimName: my-pvc
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Create PV and PVC from scratch**
2. **Configure pods to use PVCs**
3. **Troubleshoot PVC binding issues**
4. **Work with Storage Classes**

### Key Points to Remember

| Item           | Remember                                                     |
| -------------- | ------------------------------------------------------------ |
| PV/PVC binding | Automatic based on capacity, access modes, storage class     |
| PVC Pending    | No matching PV available                                     |
| Access modes   | Must match between PV and PVC                                |
| Storage Class  | Set `storageClassName` in PVC for dynamic provisioning       |
| Reclaim Policy | Default is usually `Delete` for dynamic, `Retain` for static |

### Quick YAML Templates

**Minimal PV:**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-name
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data
```

**Minimal PVC:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-name
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

**Minimal StorageClass:**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc-name
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

### Troubleshooting Checklist

- [ ] PVC stuck in `Pending`? Check if matching PV exists
- [ ] Access modes match between PV and PVC?
- [ ] Capacity request ≤ PV capacity?
- [ ] StorageClass name matches (or both empty)?
- [ ] PV status is `Available` (not `Bound` or `Released`)?

---

## Official Documentation

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Configure PVC](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)
- [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)
- [CSI Specification](https://github.com/container-storage-interface/spec)
