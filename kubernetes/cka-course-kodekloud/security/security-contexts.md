# Security Contexts

## Executive Summary

Security Contexts define privilege and access control settings for pods and containers. They allow you to run containers as specific users, add/drop Linux capabilities, and set various security parameters. Security contexts can be set at pod level (applies to all containers) or container level (overrides pod level).

## Key Concepts

| Setting                  | Pod Level | Container Level    |
| ------------------------ | --------- | ------------------ |
| `runAsUser`              | ✓         | ✓ (overrides pod)  |
| `runAsGroup`             | ✓         | ✓                  |
| `fsGroup`                | ✓         | ✗                  |
| `runAsNonRoot`           | ✓         | ✓                  |
| `capabilities`           | ✗         | ✓ (container only) |
| `privileged`             | ✗         | ✓                  |
| `readOnlyRootFilesystem` | ✗         | ✓                  |

> **Note**: Container-level settings override pod-level settings when both are specified.

## Real-World Usage

- Running containers as non-root for security
- Adding network capabilities to containers
- Restricting file system access
- Meeting compliance requirements (PCI-DSS, SOC2)

## YAML Configurations

### Pod-Level Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000 # Run all containers as user ID 1000
    runAsGroup: 3000 # Run as group ID 3000
    fsGroup: 2000 # Volumes owned by group ID 2000
  containers:
    - name: my-container
      image: nginx
```

### Container-Level Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  containers:
    - name: my-container
      image: nginx
      securityContext:
        runAsUser: 1000
        capabilities:
          add: ["NET_ADMIN", "SYS_TIME"]
          drop: ["ALL"]
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
```

### Combined Pod and Container Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  securityContext:
    runAsUser: 1000 # Default for all containers
    fsGroup: 2000
  containers:
    - name: container1
      image: nginx
      # Uses pod-level runAsUser: 1000
    - name: container2
      image: redis
      securityContext:
        runAsUser: 2000 # Overrides pod-level, runs as 2000
        capabilities:
          add: ["NET_BIND_SERVICE"]
```

### Run as Non-Root

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: non-root-pod
spec:
  securityContext:
    runAsNonRoot: true # Fails if image tries to run as root
  containers:
    - name: my-container
      image: my-non-root-image
```

### Privileged Container (Use with Caution)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
    - name: privileged-container
      image: nginx
      securityContext:
        privileged: true # Full host access - dangerous!
```

## Common Linux Capabilities

| Capability          | Description                   |
| ------------------- | ----------------------------- |
| `NET_ADMIN`         | Network administration        |
| `NET_BIND_SERVICE`  | Bind to ports < 1024          |
| `SYS_TIME`          | Modify system clock           |
| `SYS_PTRACE`        | Trace processes               |
| `MAC_ADMIN`         | MAC configuration             |
| `CHOWN`             | Change file ownership         |
| `DAC_OVERRIDE`      | Bypass file permission checks |
| `SETUID` / `SETGID` | Set user/group IDs            |

## Common Commands

### Check Current User in Container

```bash
# Check user ID inside container
kubectl exec my-pod -- whoami
kubectl exec my-pod -- id

# View process user
kubectl exec my-pod -- ps aux
```

### Debug Security Context Issues

```bash
# Check pod security context
kubectl get pod my-pod -o yaml | grep -A 10 securityContext

# Describe pod for events
kubectl describe pod my-pod

# Check container capabilities
kubectl exec my-pod -- cat /proc/1/status | grep Cap
```

### Decode Capabilities

```bash
# Inside container, get capability hex value
cat /proc/1/status | grep CapEff
# Output: CapEff: 00000000a80425fb

# Decode capabilities (on Linux host)
capsh --decode=00000000a80425fb
```

## CKA Exam Tips

### What to Expect

- Configure pods to run as specific users
- Add or drop capabilities from containers
- Troubleshoot security context issues
- Understand pod vs container level settings

### Quick Reference

```yaml
# Most common security context settings
securityContext:
  runAsUser: 1000 # Run as specific UID
  runAsNonRoot: true # Must run as non-root
  readOnlyRootFilesystem: true # Immutable root fs
  capabilities:
    drop: ["ALL"] # Drop all capabilities
    add: ["NET_BIND_SERVICE"] # Add only what's needed
```

### Common Exam Scenarios

```bash
# Find user ID a pod is running as
kubectl exec pod-name -- id

# Change user ID
# Edit pod spec: securityContext.runAsUser: 1000

# Add capability (must be at container level)
# Edit container spec: securityContext.capabilities.add: ["SYS_TIME"]
```

## Official Documentation

- [Configure a Security Context for a Pod or Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
