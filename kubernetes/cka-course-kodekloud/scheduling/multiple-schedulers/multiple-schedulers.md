# Multiple Schedulers - CKA Cheatsheet

## Executive Summary

**Multiple Schedulers** allow you to run custom schedulers alongside the default Kubernetes scheduler. Each scheduler can have its own scheduling logic, and pods can specify which scheduler should handle their placement.

**Key Points:**

- Default scheduler: `default-scheduler`
- Custom schedulers must have **unique names**
- Pods specify scheduler via `schedulerName` field
- Useful for specialized scheduling requirements (GPU workloads, compliance checks, custom placement logic)

---

## Real-World Use Cases

| Use Case              | Description                                              |
| --------------------- | -------------------------------------------------------- |
| **GPU Workloads**     | Custom scheduler for optimal GPU node placement          |
| **Compliance**        | Extra verification before placing pods on specific nodes |
| **Cost Optimization** | Scheduler that prefers spot/preemptible instances        |
| **Data Locality**     | Schedule pods close to their data sources                |
| **Multi-Tenant**      | Different scheduling policies per tenant                 |

---

## Quick Reference

### Scheduler Configuration File

```yaml
# my-scheduler-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: my-scheduler
leaderElection:
  leaderElect: false # Set true for HA with multiple replicas
```

---

### Deploy Custom Scheduler as Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-custom-scheduler
  namespace: kube-system
spec:
  containers:
    - name: kube-scheduler
      image: registry.k8s.io/kube-scheduler:v1.28.0
      command:
        - kube-scheduler
        - --kubeconfig=/etc/kubernetes/scheduler.conf
        - --config=/etc/kubernetes/my-scheduler-config.yaml
      volumeMounts:
        - name: kubeconfig
          mountPath: /etc/kubernetes/scheduler.conf
          readOnly: true
        - name: config
          mountPath: /etc/kubernetes/my-scheduler-config.yaml
          readOnly: true
  volumes:
    - name: kubeconfig
      hostPath:
        path: /etc/kubernetes/scheduler.conf
    - name: config
      hostPath:
        path: /etc/kubernetes/my-scheduler-config.yaml
```

---

### ConfigMap for Scheduler Config

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-scheduler-config
  namespace: kube-system
data:
  my-scheduler-config.yaml: |
    apiVersion: kubescheduler.config.k8s.io/v1
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: my-scheduler
    leaderElection:
      leaderElect: false
```

---

### Use Custom Scheduler in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  schedulerName: my-scheduler # Use custom scheduler
  containers:
    - name: nginx
      image: nginx
```

---

### ServiceAccount & RBAC (for Deployment)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-scheduler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-scheduler-as-kube-scheduler
subjects:
  - kind: ServiceAccount
    name: my-scheduler
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: system:kube-scheduler
  apiGroup: rbac.authorization.k8s.io
```

### Why ServiceAccount & RBAC Are Required

A scheduler needs to **interact with the Kubernetes API** to function:

| Permission Needed          | Why                         |
| -------------------------- | --------------------------- |
| `pods` - get, list, watch  | Find unscheduled pods       |
| `pods/binding` - create    | Assign pods to nodes        |
| `nodes` - get, list, watch | Know node capacity/status   |
| `events` - create, patch   | Report scheduling decisions |

**Without proper RBAC, the scheduler cannot schedule pods!**

```
┌─────────────────────┐
│  Custom Scheduler   │  Uses ServiceAccount
│        Pod          │─────────────────────┐
└─────────────────────┘                     │
                                            ▼
                               ┌────────────────────────┐
                               │ ClusterRoleBinding     │
                               │ (links SA to Role)     │
                               └───────────┬────────────┘
                                           │
                                           ▼
                               ┌────────────────────────┐
                               │ ClusterRole            │
                               │ system:kube-scheduler  │
                               └────────────────────────┘
```

### Verify RBAC Setup

```bash
# Check ServiceAccount exists
kubectl get serviceaccount -n kube-system | grep scheduler

# Check ClusterRoleBindings for scheduler
kubectl get clusterrolebinding | grep scheduler

# View binding details
kubectl describe clusterrolebinding my-scheduler-as-kube-scheduler

# Check for permission errors in scheduler logs
kubectl logs <scheduler-pod> -n kube-system | grep -i "forbidden\|unauthorized"
```

---

## Common Commands

```bash
# List scheduler pods
kubectl get pods -n kube-system | grep scheduler

# Check which scheduler scheduled a pod
kubectl get events -o wide | grep Scheduled

# View scheduler logs
kubectl logs <scheduler-pod-name> -n kube-system

# Describe pod to see scheduler
kubectl get pod <pod-name> -o yaml | grep schedulerName

# Check if pod is pending (scheduler issue)
kubectl describe pod <pod-name> | grep -A5 Events
```

---

## Verification

### Check Pod Events

```bash
kubectl get events -o wide
```

**Expected output:**

```
LAST SEEN   NAME        KIND   REASON      SOURCE              MESSAGE
9s          nginx.15    Pod    Scheduled   my-scheduler        Successfully assigned default/nginx to node01
```

The **SOURCE** column shows which scheduler placed the pod.

---

## Troubleshooting

| Issue                  | Check                                                     |
| ---------------------- | --------------------------------------------------------- |
| Pod stuck in Pending   | Scheduler config incorrect or scheduler not running       |
| Wrong scheduler used   | Verify `schedulerName` in pod spec                        |
| Scheduler not starting | Check logs: `kubectl logs <scheduler-pod> -n kube-system` |
| Permission denied      | Verify RBAC ClusterRoleBinding exists                     |

---

## CKA Exam Scenarios

### Scenario 1: Identify Custom Scheduler

**Question:** Which scheduler scheduled pod `nginx`?

```bash
kubectl get events --field-selector involvedObject.name=nginx | grep Scheduled
# Or
kubectl describe pod nginx | grep -i "scheduled"
```

---

### Scenario 2: Create Pod with Custom Scheduler

**Question:** Create pod `my-pod` using scheduler `my-scheduler`.

```bash
kubectl run my-pod --image=nginx --dry-run=client -o yaml > pod.yaml
```

Edit to add `schedulerName`:

```yaml
spec:
  schedulerName: my-scheduler
  containers:
    - name: my-pod
      image: nginx
```

```bash
kubectl apply -f pod.yaml
```

---

### Scenario 3: Deploy Custom Scheduler

**Question:** Deploy a custom scheduler named `my-scheduler` as a pod in `kube-system`.

1. Create scheduler config:

```bash
cat <<EOF > /etc/kubernetes/my-scheduler-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: my-scheduler
leaderElection:
  leaderElect: false
EOF
```

2. Create scheduler pod (copy from existing kube-scheduler and modify)

---

### Scenario 4: Fix Pending Pod

**Question:** Pod `app` is Pending. It uses scheduler `custom-scheduler` which doesn't exist. Fix it.

```bash
# Check current scheduler
kubectl get pod app -o yaml | grep schedulerName

# Option 1: Change to default-scheduler
kubectl get pod app -o yaml > app.yaml
# Edit: schedulerName: default-scheduler
kubectl delete pod app
kubectl apply -f app.yaml

# Option 2: Deploy the missing custom-scheduler
```

---

## Exam Tips

1. **Know the schedulerName field location**: `spec.schedulerName`
2. **Default scheduler name**: `default-scheduler`
3. **Check events to identify scheduler**: `kubectl get events -o wide`
4. **Scheduler pods run in**: `kube-system` namespace
5. **Config API version**: `kubescheduler.config.k8s.io/v1`
6. **Leader election**: Set `leaderElect: false` for single replica

---

## Official Documentation

- [Configure Multiple Schedulers](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)
- [Scheduler Configuration](https://kubernetes.io/docs/reference/scheduling/config/)
- [Kubernetes Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)
