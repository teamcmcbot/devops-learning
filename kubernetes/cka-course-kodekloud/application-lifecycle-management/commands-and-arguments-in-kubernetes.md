# Commands and Arguments in Kubernetes

## Executive Summary

Commands and arguments in Kubernetes allow you to override the default behavior of container images. This directly maps to Docker's `ENTRYPOINT` and `CMD` instructions:

| Kubernetes Field | Docker Equivalent | Purpose                                     |
| ---------------- | ----------------- | ------------------------------------------- |
| `command`        | `ENTRYPOINT`      | The executable to run when container starts |
| `args`           | `CMD`             | Default parameters passed to the command    |

**Key Point:** Specifying `command` in a pod definition **completely replaces** the Dockerfile's ENTRYPOINT, while `args` **overrides** the default CMD parameters.

---

## Real-World Usage Examples

### Scenario 1: Override Sleep Duration

A container image defaults to sleeping 5 seconds, but you need it to sleep 10 seconds.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
spec:
  containers:
    - name: ubuntu-sleeper
      image: ubuntu-sleeper
      args: ["10"] # Overrides CMD, sleeps for 10 seconds
```

### Scenario 2: Override Both Command and Arguments

Change the command entirely (e.g., from `sleep` to `sleep2.0`).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
spec:
  containers:
    - name: ubuntu-sleeper
      image: ubuntu-sleeper
      command: ["sleep2.0"] # Overrides ENTRYPOINT
      args: ["10"] # Overrides CMD
```

### Scenario 3: Run a Custom Script

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: command-demo
spec:
  containers:
    - name: command-demo-container
      image: debian
      command: ["/bin/sh"]
      args: ["-c", "echo Hello Kubernetes! && sleep 3600"]
```

---

## Common Commands

```bash
# Create pod from YAML
kubectl create -f pod-definition.yml

# Create pod imperatively with command override
kubectl run nginx --image=nginx --command -- <cmd> <arg1> <arg2>

# Create pod imperatively with args only
kubectl run nginx --image=nginx -- <arg1> <arg2>

# Generate YAML with command/args (dry-run)
kubectl run ubuntu-sleeper --image=ubuntu-sleeper --dry-run=client -o yaml --command -- sleep 10 > pod.yaml

# Edit existing pod (will recreate)
kubectl edit pod <pod-name>

# Check pod's command and args
kubectl describe pod <pod-name> | grep -A5 "Command\|Args"
```

---

## YAML Configuration Reference

### Basic Structure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: <pod-name>
spec:
  containers:
    - name: <container-name>
      image: <image-name>
      command: ["<executable>"] # Optional: overrides ENTRYPOINT
      args: ["<arg1>", "<arg2>"] # Optional: overrides CMD
```

### Alternative Syntax (Multi-line)

```yaml
spec:
  containers:
    - name: ubuntu-sleeper
      image: ubuntu-sleeper
      command:
        - "sleep"
      args:
        - "10"
```

### With Environment Variables in Args

```yaml
spec:
  containers:
    - name: demo
      image: busybox
      command: ["/bin/sh"]
      args: ["-c", "echo $(MY_VAR) && sleep 3600"]
      env:
        - name: MY_VAR
          value: "Hello World"
```

---

## Docker to Kubernetes Mapping

| Docker                                               | Kubernetes                               |
| ---------------------------------------------------- | ---------------------------------------- |
| `docker run ubuntu-sleeper 10`                       | `args: ["10"]`                           |
| `docker run --entrypoint sleep2.0 ubuntu-sleeper 10` | `command: ["sleep2.0"]` + `args: ["10"]` |

**Dockerfile Example:**

```dockerfile
FROM Ubuntu
ENTRYPOINT ["sleep"]   # → command in K8s
CMD ["5"]              # → args in K8s
```

---

## CKA Exam Relevance

### How This Topic is Tested:

1. **Modify existing pods** - Change sleep duration or command in a running pod
2. **Create pods with custom commands** - Use imperative or declarative approach
3. **Troubleshooting** - Identify why a pod is not behaving as expected due to incorrect command/args
4. **Edit YAML** - Correct `command` vs `args` placement

### Exam Tips:

- Remember: `command` = ENTRYPOINT, `args` = CMD
- Use `kubectl run --command --` for command override
- Use `kubectl run --` (without `--command`) for args only
- Arrays can use `["item1", "item2"]` or multi-line YAML format
- You cannot edit command/args of a running pod directly - delete and recreate

### Sample Exam Task:

> _Create a pod named `time-check` in namespace `dvl1987` using image `busybox`. The container should run the command `while true; do date; sleep $TIME_FREQ; done`. Set TIME_FREQ to 10 seconds._

---

## Official Documentation Links

- [Define a Command and Arguments for a Container](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/)
- [Pod Spec - Container](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container)
- [Docker ENTRYPOINT vs CMD](https://docs.docker.com/reference/dockerfile/#understand-how-cmd-and-entrypoint-interact)

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│  Docker                    →  Kubernetes               │
├─────────────────────────────────────────────────────────┤
│  ENTRYPOINT ["sleep"]      →  command: ["sleep"]       │
│  CMD ["5"]                 →  args: ["5"]              │
│  --entrypoint sleep2.0     →  command: ["sleep2.0"]    │
│  docker run image 10       →  args: ["10"]             │
└─────────────────────────────────────────────────────────┘
```
