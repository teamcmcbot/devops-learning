# Scheduler Profiles - CKA Cheatsheet

## Executive Summary

**Scheduler Profiles** allow you to run multiple scheduling behaviors within a **single scheduler binary** (introduced in Kubernetes 1.18). Instead of deploying separate scheduler processes, you define multiple profiles with different plugin configurations in one config file.

**Key Points:**

- One scheduler binary, multiple profiles
- Each profile acts like an independent scheduler
- Customize plugins per profile (enable/disable)
- Pods select profile via `schedulerName` field
- Avoids race conditions from multiple scheduler processes

---

## Scheduling Phases & Extension Points

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        SCHEDULING PIPELINE                               │
├─────────────────┬──────────────────┬─────────────────┬───────────────────┤
│   1. QUEUE      │   2. FILTER      │   3. SCORE      │   4. BIND         │
│   (queueSort)   │   (preFilter,    │   (preScore,    │   (preBind,       │
│                 │    filter,       │    score,       │    bind,          │
│                 │    postFilter)   │    normalize)   │    postBind)      │
├─────────────────┼──────────────────┼─────────────────┼───────────────────┤
│ PrioritySort    │ NodeResourcesFit │ NodeResourcesFit│ DefaultBinder     │
│                 │ NodeName         │ ImageLocality   │                   │
│                 │ NodeUnschedulable│ TaintToleration │                   │
│                 │ TaintToleration  │                 │                   │
└─────────────────┴──────────────────┴─────────────────┴───────────────────┘
```

| Phase      | Purpose                    | Key Plugins                                                            |
| ---------- | -------------------------- | ---------------------------------------------------------------------- |
| **Queue**  | Sort pods by priority      | `PrioritySort`                                                         |
| **Filter** | Eliminate unsuitable nodes | `NodeResourcesFit`, `NodeName`, `NodeUnschedulable`, `TaintToleration` |
| **Score**  | Rank remaining nodes       | `NodeResourcesFit`, `ImageLocality`, `TaintToleration`                 |
| **Bind**   | Assign pod to best node    | `DefaultBinder`                                                        |

---

## Real-World Use Cases

| Use Case               | Profile Configuration                        |
| ---------------------- | -------------------------------------------- |
| **Default Scheduling** | All plugins enabled (standard behavior)      |
| **Ignore Taints**      | Disable `TaintToleration` plugin             |
| **Fast Scheduling**    | Disable scoring plugins for speed            |
| **Custom Logic**       | Enable custom plugins for specific workloads |

---

## Quick Reference

### Single Profile (Default)

```yaml
# scheduler-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: default-scheduler
```

---

### Multiple Profiles in One Config

```yaml
# multi-profile-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: default-scheduler
  - schedulerName: no-scoring-scheduler
    plugins:
      preScore:
        disabled:
          - name: "*"
      score:
        disabled:
          - name: "*"
  - schedulerName: no-taint-scheduler
    plugins:
      filter:
        disabled:
          - name: TaintToleration
      score:
        disabled:
          - name: TaintToleration
```

---

### Disable Specific Plugin

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: my-scheduler
    plugins:
      score:
        disabled:
          - name: TaintToleration
```

---

### Enable Custom Plugins

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: my-scheduler
    plugins:
      score:
        disabled:
          - name: TaintToleration
        enabled:
          - name: MyCustomPluginA
          - name: MyCustomPluginB
```

---

### Disable All Plugins at Extension Point

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: fast-scheduler
    plugins:
      preScore:
        disabled:
          - name: "*" # Wildcard disables all
      score:
        disabled:
          - name: "*"
```

---

### Use Profile in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  schedulerName: no-scoring-scheduler # Use specific profile
  containers:
    - name: nginx
      image: nginx
```

---

## Key Scheduler Plugins

| Plugin              | Phase        | Purpose                         |
| ------------------- | ------------ | ------------------------------- |
| `PrioritySort`      | Queue        | Sort by pod priority            |
| `NodeResourcesFit`  | Filter/Score | Check/score based on CPU/memory |
| `NodeName`          | Filter       | Match specific node name        |
| `NodeUnschedulable` | Filter       | Skip cordoned/drained nodes     |
| `TaintToleration`   | Filter/Score | Handle taints and tolerations   |
| `ImageLocality`     | Score        | Prefer nodes with image cached  |
| `NodeAffinity`      | Filter/Score | Handle node affinity rules      |
| `PodTopologySpread` | Filter/Score | Spread pods across topology     |
| `DefaultBinder`     | Bind         | Bind pod to node                |

---

## Common Commands

```bash
# View scheduler config (if static pod)
cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Check scheduler config file location
ps aux | grep kube-scheduler | grep config

# View scheduler logs
kubectl logs kube-scheduler-controlplane -n kube-system

# Check which scheduler scheduled a pod
kubectl get events -o wide | grep Scheduled

# Describe pod to see schedulerName
kubectl get pod <pod-name> -o yaml | grep schedulerName
```

---

## Profiles vs Multiple Schedulers

| Aspect              | Multiple Schedulers         | Scheduler Profiles  |
| ------------------- | --------------------------- | ------------------- |
| **Binaries**        | Multiple processes          | Single process      |
| **Race Conditions** | Possible                    | Avoided             |
| **Resource Usage**  | Higher (multiple processes) | Lower (one process) |
| **Configuration**   | Separate config files       | Single config file  |
| **Introduced**      | Always available            | Kubernetes 1.18+    |

---

## CKA Exam Scenarios

### Scenario 1: Identify Scheduler Profile

**Question:** Which scheduler profile was used for pod `nginx`?

```bash
# Check events
kubectl get events --field-selector involvedObject.name=nginx | grep Scheduled

# Or check pod spec
kubectl get pod nginx -o yaml | grep schedulerName
```

---

### Scenario 2: Create Pod with Specific Profile

**Question:** Create pod `test-pod` using scheduler profile `no-scoring-scheduler`.

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml > pod.yaml
```

Edit to add `schedulerName`:

```yaml
spec:
  schedulerName: no-scoring-scheduler
  containers:
    - name: test-pod
      image: nginx
```

```bash
kubectl apply -f pod.yaml
```

---

### Scenario 3: Understand Scheduling Phases

**Question:** In which phase does the `TaintToleration` plugin operate?

**Answer:** Both **Filter** and **Score** phases.

---

### Scenario 4: Interpret Scheduler Config

**Question:** Given a scheduler config, identify which plugins are disabled for a profile.

```yaml
profiles:
  - schedulerName: fast-scheduler
    plugins:
      score:
        disabled:
          - name: "*"
```

**Answer:** All scoring plugins are disabled for `fast-scheduler`.

---

## Exam Tips

1. **Extension Points**: Know the 4 phases (Queue → Filter → Score → Bind)
2. **Wildcard**: `name: '*'` disables all plugins at that extension point
3. **schedulerName**: Pods specify which profile to use via `spec.schedulerName`
4. **Single binary**: Profiles run in ONE scheduler process (not multiple)
5. **Default plugins**: Know key plugins like `NodeResourcesFit`, `TaintToleration`, `PrioritySort`
6. **Config location**: Usually `/etc/kubernetes/scheduler-config.yaml` or mounted via ConfigMap

---

## Official Documentation

- [Scheduler Configuration](https://kubernetes.io/docs/reference/scheduling/config/)
- [Scheduling Plugins](https://kubernetes.io/docs/reference/scheduling/config/#scheduling-plugins)
- [Scheduling Framework](https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/)
- [Scheduler Profiles](https://kubernetes.io/docs/reference/scheduling/config/#profiles)
