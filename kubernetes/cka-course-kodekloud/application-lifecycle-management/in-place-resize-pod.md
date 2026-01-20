# In-Place Resize of Pods - CKA Cheatsheet

## Executive Summary

**In-Place Pod Vertical Scaling** allows you to change CPU and memory resources of a running pod **without restarting or recreating it**. By default, Kubernetes recreates pods when resource specs change, causing potential downtime. This feature enables live resource adjustments.

**Key Points:**

- Feature gate: `InPlacePodVerticalScaling` (alpha since K8s 1.27)
- Only supports **CPU** and **memory** resources
- Uses `resizePolicy` to control restart behavior per resource
- Reduces downtime for stateful workloads
- Works with Deployments, StatefulSets, and standalone Pods

---

## Default Behavior vs In-Place Resize

| Aspect                 | Default Behavior       | In-Place Resize              |
| ---------------------- | ---------------------- | ---------------------------- |
| Pod on resource change | Terminated & recreated | Updated while running        |
| Downtime               | Yes (brief)            | No (for supported resources) |
| State preserved        | No                     | Yes                          |
| Feature gate required  | No                     | Yes                          |

---

## Real-World Usage Example

**Scenario:** A database pod running in production needs more CPU during peak hours but you cannot afford downtime for pod recreation.

**Solution:**

- Enable in-place resize feature
- Update CPU requests/limits on the running pod
- Pod continues running with new resources - no restart needed

**Benefits:**

- Zero downtime for resource adjustments
- Preserves in-memory state and connections
- Ideal for stateful applications (databases, caches)

---

## Enabling the Feature

### Feature Gate (must be enabled on API server and kubelet)

```bash
# Check if feature is enabled
kubectl get --raw /metrics | grep inplace

# Enable via feature gate (in kube-apiserver and kubelet configs)
--feature-gates=InPlacePodVerticalScaling=true
```

### Environment Variable (for testing)

```bash
FEATURE_GATES=InPlacePodVerticalScaling=true
```

---

## Common Commands

```bash
# Apply updated resource configuration
kubectl apply -f deployment.yaml

# Check pod resource status
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[*].resources}'

# Describe pod to see resize status
kubectl describe pod <pod-name>

# Patch pod resources directly (if supported)
kubectl patch pod <pod-name> --patch '{"spec":{"containers":[{"name":"my-app","resources":{"requests":{"cpu":"500m"}}}]}}'

# Check allocated resources vs spec
kubectl get pod <pod-name> -o yaml | grep -A 10 resources
```

---

## YAML Configurations

### Deployment with Resize Policy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: nginx
          resizePolicy: # NEW: Controls restart behavior
            - resourceName: cpu
              restartPolicy: NotRequired # CPU change = no restart
            - resourceName: memory
              restartPolicy: RestartContainer # Memory change = restart
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

### Resize Policy Options

| `restartPolicy`    | Behavior                                   |
| ------------------ | ------------------------------------------ |
| `NotRequired`      | Resource updated without container restart |
| `RestartContainer` | Container restarted when resource changes  |

### Pod Spec for In-Place Resize

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resize-demo
spec:
  containers:
    - name: app
      image: nginx
      resizePolicy:
        - resourceName: cpu
          restartPolicy: NotRequired
        - resourceName: memory
          restartPolicy: NotRequired
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "200m"
          memory: "256Mi"
```

---

## Pod Status Fields (New with In-Place Resize)

When in-place resize is enabled, pods have additional status fields:

```yaml
status:
  containerStatuses:
    - name: my-app
      resources: # Actual allocated resources
        requests:
          cpu: "250m"
        limits:
          cpu: "500m"
  resize: InProgress # or "Proposed", "Deferred", ""
```

| `resize` Status | Meaning                                                    |
| --------------- | ---------------------------------------------------------- |
| `""` (empty)    | No resize in progress                                      |
| `Proposed`      | Resize requested, waiting for approval                     |
| `InProgress`    | Resize is being applied                                    |
| `Deferred`      | Resize waiting (e.g., memory can't be reduced below usage) |

---

## Limitations

⚠️ **Important constraints to remember:**

| Limitation           | Details                                             |
| -------------------- | --------------------------------------------------- |
| Resources supported  | Only **CPU** and **memory**                         |
| QoS class changes    | Not supported (can't change Guaranteed ↔ Burstable) |
| Init containers      | Cannot be resized in-place                          |
| Ephemeral containers | Cannot be resized                                   |
| Memory reduction     | Cannot reduce below current usage                   |
| Windows pods         | Not supported                                       |
| Cross-container      | Can't move resources between containers             |

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Enable in-place resize** by configuring feature gates
- **Add `resizePolicy`** to a container spec
- **Understand limitations** - what CAN and CANNOT be resized
- **Troubleshoot** why a resize is stuck (e.g., memory below usage)
- **Identify** the correct `restartPolicy` values

### Key Things to Remember:

| Item                | Value                             |
| ------------------- | --------------------------------- |
| Feature gate        | `InPlacePodVerticalScaling`       |
| Spec field          | `spec.containers[].resizePolicy`  |
| Restart policies    | `NotRequired`, `RestartContainer` |
| Supported resources | CPU and memory only               |
| Status field        | `status.resize` shows progress    |

### Quick YAML Snippet:

```yaml
resizePolicy:
  - resourceName: cpu
    restartPolicy: NotRequired
  - resourceName: memory
    restartPolicy: NotRequired
```

### Common Exam Mistakes:

- Forgetting that this requires a **feature gate** to be enabled
- Trying to resize resources other than CPU/memory
- Not understanding that memory cannot be reduced below current usage
- Confusing in-place resize with VPA (Vertical Pod Autoscaler)

---

## Related Concepts

| Concept             | Description                                             |
| ------------------- | ------------------------------------------------------- |
| **HPA**             | Horizontal scaling - adds/removes pods                  |
| **VPA**             | Vertical scaling - auto-adjusts resources (may restart) |
| **In-Place Resize** | Manual vertical scaling without restart                 |

---

## Official Documentation Links

- [Resize CPU and Memory Resources](https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/)
- [In-Place Update of Pod Resources (KEP)](https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/1287-in-place-update-pod-resources)
- [Feature Gates](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)
- [Resource Management for Pods](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
