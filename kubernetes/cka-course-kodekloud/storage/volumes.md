# Volumes in Kubernetes

## Executive Summary

Volumes in Kubernetes provide a way to persist data beyond the lifecycle of a container or pod. Unlike Docker containers where data is lost when the container is destroyed, Kubernetes volumes allow data to be stored and shared between containers in a pod, and can survive pod restarts.

**Key Concepts:**

- Pods are ephemeral - data inside is lost when pod is deleted
- Volumes attach to pods and persist data
- Multiple volume types available (hostPath, NFS, cloud storage, etc.)
- Volumes are defined in pod spec and mounted to containers

---

## Real-World Usage Example

**Scenario:** A logging application that writes logs to a file needs to persist logs even if the pod restarts.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-writer
spec:
  containers:
    - name: logger
      image: busybox
      command:
        [
          "/bin/sh",
          "-c",
          "while true; do echo $(date) >> /var/log/app.log; sleep 5; done",
        ]
      volumeMounts:
        - mountPath: /var/log
          name: log-volume
  volumes:
    - name: log-volume
      hostPath:
        path: /data/logs
        type: DirectoryOrCreate
```

---

## Common Volume Types

| Volume Type             | Use Case                                    | Notes                     |
| ----------------------- | ------------------------------------------- | ------------------------- |
| `hostPath`              | Single-node testing                         | Uses local node directory |
| `emptyDir`              | Temporary storage shared between containers | Deleted when pod removed  |
| `configMap`             | Configuration data                          | Mount config as files     |
| `secret`                | Sensitive data                              | Mount secrets as files    |
| `persistentVolumeClaim` | Production persistent storage               | References PVC            |
| `nfs`                   | Shared storage across nodes                 | NFS server required       |
| `awsElasticBlockStore`  | AWS cloud storage                           | AWS EBS volume            |
| `gcePersistentDisk`     | GCP cloud storage                           | Google Persistent Disk    |
| `azureDisk`             | Azure cloud storage                         | Azure Managed Disk        |

---

## YAML Configuration Examples

### Basic hostPath Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
    - image: alpine
      name: alpine
      command: ["/bin/sh", "-c"]
      args: ["shuf -i 0-100 -n 1 >> /opt/number.out;"]
      volumeMounts:
        - mountPath: /opt
          name: data-volume
  volumes:
    - name: data-volume
      hostPath:
        path: /data
        type: Directory
```

### emptyDir Volume (shared between containers)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
    - name: writer
      image: busybox
      command: ["/bin/sh", "-c", "echo hello > /shared/data.txt; sleep 3600"]
      volumeMounts:
        - mountPath: /shared
          name: shared-data
    - name: reader
      image: busybox
      command: ["/bin/sh", "-c", "cat /shared/data.txt; sleep 3600"]
      volumeMounts:
        - mountPath: /shared
          name: shared-data
  volumes:
    - name: shared-data
      emptyDir: {}
```

### AWS EBS Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: aws-pod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /data
          name: ebs-volume
  volumes:
    - name: ebs-volume
      awsElasticBlockStore:
        volumeID: <volume-id>
        fsType: ext4
```

---

## Common Commands

```bash
# View pod with volume details
kubectl describe pod <pod-name>

# Check volume mounts in running container
kubectl exec <pod-name> -- df -h

# List contents of mounted volume
kubectl exec <pod-name> -- ls -la /path/to/mount
```

---

## CKA Exam Tips

**How this topic is tested:**

- Creating pods with volumes from YAML
- Configuring hostPath volumes
- Understanding volume mount paths
- Troubleshooting volume-related issues

**Key exam points:**

1. Know the difference between `volumes` (pod-level) and `volumeMounts` (container-level)
2. Remember `hostPath` is for single-node only - not suitable for multi-node clusters
3. `emptyDir` is ephemeral - data lost when pod is deleted
4. Volume name must match between `volumes` and `volumeMounts`

**Quick reference structure:**

```yaml
spec:
  containers:
    - volumeMounts: # Container level
        - mountPath: /path # Where to mount in container
          name: volume-name # Must match volume name
  volumes: # Pod level
    - name: volume-name # Volume definition
      <type>: # hostPath, emptyDir, etc.
        <type-specific-config>
```

---

## Official Documentation

- [Kubernetes Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Volume Types](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types)
- [Configure Pod to Use Volume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/)
