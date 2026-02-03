# Robust, Self-Healing Application Deployments

## Exam Weight
Part of **15% - Workloads and Scheduling**

## What Can Be Tested

- Configure liveness probes
- Configure readiness probes
- Configure startup probes
- Understand probe types (HTTP, TCP, Exec)
- Set appropriate probe timing parameters
- Use ReplicaSets and Deployments for self-healing
- Configure pod restart policies
- Implement Jobs and CronJobs

## Sample Questions

1. **Add a liveness probe to check HTTP endpoint /healthz on port 8080**
2. **Configure readiness probe with exec command**
3. **Fix a pod that's in CrashLoopBackOff due to incorrect probe**
4. **Create a Job that runs a batch process to completion**
5. **Create a CronJob that runs daily at midnight**

## Official Documentation

- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Key Concepts

### Probe Types

| Probe | Purpose | When Pod is Ready | Failure Action |
|-------|---------|------------------|----------------|
| **Liveness** | Is app alive/healthy? | N/A | Restart container |
| **Readiness** | Can app serve traffic? | When probe succeeds | Remove from service |
| **Startup** | Has app finished starting? | N/A | Gives more time before liveness |

### Probe Mechanisms

| Type | Use Case | Example |
|------|----------|---------|
| **HTTP GET** | Web applications | GET /healthz returns 200-399 |
| **TCP Socket** | Check port is open | TCP connection to port 8080 |
| **Exec** | Run command | Exit code 0 = success |
| **gRPC** | gRPC health check | gRPC health checking protocol |

### Probe Timing Parameters

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15  # Wait before first probe
  periodSeconds: 10        # How often to probe
  timeoutSeconds: 1        # Timeout for each probe
  successThreshold: 1      # Consecutive successes needed (liveness/startup only)
  failureThreshold: 3      # Consecutive failures before action
```

### Restart Policies

| Policy | Behavior | Use Case |
|--------|----------|----------|
| **Always** | Always restart on exit | Deployments, long-running services |
| **OnFailure** | Restart only if exit code != 0 | Jobs, batch processes |
| **Never** | Never restart | One-time tasks |

## Imperative Commands

```bash
# No direct imperative command for probes
# Must edit deployment or create YAML

# Create deployment (then edit to add probes)
kubectl create deployment webapp --image=webapp:v1 --replicas=3

# Edit to add probes
kubectl edit deployment webapp

# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# View pod events (shows probe failures)
kubectl get events --sort-by='.lastTimestamp' | grep <pod-name>

# Check logs for application issues
kubectl logs <pod-name>

# Create Job
kubectl create job test-job --image=busybox -- echo "Hello World"

# Create CronJob
kubectl create cronjob test-cron --image=busybox --schedule="*/5 * * * *" -- echo "Hello"

# Get Jobs
kubectl get jobs

# Get CronJobs
kubectl get cronjobs
kubectl get cj

# Delete completed Jobs
kubectl delete job <job-name>
```

## YAML Examples

### Liveness Probe - HTTP GET
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-http
spec:
  containers:
  - name: webapp
    image: webapp:v1
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 15
      periodSeconds: 10
      timeoutSeconds: 1
      failureThreshold: 3
```

### Readiness Probe - TCP Socket
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-tcp
spec:
  containers:
  - name: database
    image: postgres:12
    ports:
    - containerPort: 5432
    readinessProbe:
      tcpSocket:
        port: 5432
      initialDelaySeconds: 10
      periodSeconds: 5
```

### Liveness and Readiness - Exec Command
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "touch /tmp/healthy; sleep 30; rm /tmp/healthy; sleep 600"]
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Startup Probe (for Slow-Starting Apps)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-probe
spec:
  containers:
  - name: slow-app
    image: myapp:v1
    ports:
    - containerPort: 8080
    startupProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 30  # Allow 5 minutes to start (30 * 10s)
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 3
```

### Complete Deployment with Probes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:v1
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 2
          successThreshold: 1
          failureThreshold: 3
```

### Job - Run to Completion
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3         # Run 3 times successfully
  parallelism: 2         # Run 2 pods in parallel
  backoffLimit: 4        # Retry up to 4 times on failure
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: processor
        image: busybox
        command: ["/bin/sh", "-c", "echo Processing data; sleep 10"]
```

### CronJob - Scheduled Task
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"  # Every day at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: backup-tool:v1
            command: ["/bin/sh", "-c", "echo Backing up data; date"]
```

### CronJob Schedule Examples
```yaml
# Every minute
schedule: "*/1 * * * *"

# Every hour
schedule: "0 * * * *"

# Every day at midnight
schedule: "0 0 * * *"

# Every Monday at 9 AM
schedule: "0 9 * * 1"

# Every 15 minutes
schedule: "*/15 * * * *"
```

## Troubleshooting Tips

### Pod in CrashLoopBackOff - Liveness Probe Failing
```bash
# Check pod events
kubectl describe pod <pod-name>

# Look for:
# "Liveness probe failed: HTTP probe failed"
# "Back-off restarting failed container"

# Check logs before restart
kubectl logs <pod-name> --previous

# Common causes:
# 1. Probe path incorrect
# 2. initialDelaySeconds too short
# 3. App actually unhealthy

# Fix: Increase initialDelaySeconds or fix probe path
kubectl edit deployment <deployment-name>
```

### Pod Not Receiving Traffic - Readiness Probe Failing
```bash
# Check pod status
kubectl get pods -o wide

# STATUS shows "Running" but pod not in service endpoints
kubectl get endpoints <service-name>

# Check readiness probe
kubectl describe pod <pod-name> | grep -A10 "Readiness"

# Check probe failures
kubectl describe pod <pod-name> | grep "Warning"

# Test probe endpoint manually
kubectl exec <pod-name> -- curl localhost:8080/ready

# Common fixes:
# - App not listening on expected port
# - Readiness path incorrect
# - App dependencies not ready (database, etc.)
```

### Slow-Starting App - Killed by Liveness Probe
```bash
# Symptoms: Pod keeps restarting during startup

# Check restart count
kubectl get pods

# Solution 1: Increase initialDelaySeconds
# Solution 2: Add startup probe (better)

kubectl edit deployment <name>
# Add startupProbe with higher failureThreshold
```

### Probe Timeout Issues
```bash
# Check events
kubectl describe pod <pod-name>

# "Liveness probe failed: Get http://...: context deadline exceeded"

# Increase timeoutSeconds
kubectl edit deployment <name>
# Change timeoutSeconds from 1 to 5
```

### Job Not Completing
```bash
# Check job status
kubectl get jobs

# Describe job
kubectl describe job <job-name>

# Check pods
kubectl get pods -l job-name=<job-name>

# Check logs
kubectl logs -l job-name=<job-name>

# Check backoffLimit not exceeded
kubectl describe job <job-name> | grep "Pods Status Failed"
```

### CronJob Not Running
```bash
# Check cronjob
kubectl get cronjob

# Check schedule syntax
kubectl describe cronjob <cronjob-name>

# Check for suspended status
kubectl get cronjob <cronjob-name> -o yaml | grep suspend

# Check job history
kubectl get jobs -l job-name=<cronjob-name>

# Manually trigger cronjob
kubectl create job test-run --from=cronjob/<cronjob-name>
```

## Key Concepts

### Probe Success/Failure Calculation

**Liveness Probe Example:**
```
failureThreshold: 3
periodSeconds: 10

If probe fails 3 times consecutively (30 seconds), container restarts
```

**Readiness Probe Example:**
```
successThreshold: 1
failureThreshold: 3
periodSeconds: 5

- 1 success → Pod marked Ready, added to Service
- 3 failures → Pod marked NotReady, removed from Service
```

### When to Use Each Probe

| Scenario | Liveness | Readiness | Startup |
|----------|----------|-----------|---------|
| **Long startup time** | ✅ | ✅ | ✅ |
| **Temporary unavailability** | ❌ | ✅ | ❌ |
| **Permanent failure** | ✅ | ✅ | ❌ |
| **Dependency unavailable** | ❌ | ✅ | ❌ |
| **Memory leak** | ✅ | ❌ | ❌ |

## Exam Tips

1. **Liveness = restart**, **Readiness = traffic**
2. **Always set initialDelaySeconds** - give app time to start
3. **Readiness more forgiving** - doesn't restart, just stops traffic
4. **Use startup probe** for slow-starting apps (legacy apps, JVM)
5. **Exec probes are expensive** - prefer HTTP or TCP
6. **failureThreshold: 3** is common (allow temporary issues)
7. **Check `kubectl describe pod`** - shows probe failures
8. **Jobs need `restartPolicy: OnFailure` or `Never`**
9. **CronJob schedule** uses cron syntax (minute hour day month weekday)
10. **Test probes** by exec into pod and running probe command

## Common Mistakes

- ❌ No initialDelaySeconds (app not ready when first probe runs)
- ❌ Liveness and readiness point to same endpoint (should be different)
- ❌ Probe timeout too short (1s often not enough)
- ❌ Using liveness for temporary issues (use readiness instead)
- ❌ Probes checking external dependencies (makes system fragile)
- ❌ Jobs with `restartPolicy: Always` (should be OnFailure/Never)
- ❌ CronJob schedule syntax errors
- ❌ Not considering timezone for CronJobs (uses controller manager timezone)

## Quick Reference

```bash
# Create deployment with probes (must use YAML)
kubectl apply -f deployment-with-probes.yaml

# Check pod readiness
kubectl get pods

# See why pod not ready
kubectl describe pod <pod-name> | grep -A5 "Conditions:"

# Test HTTP probe manually
kubectl exec <pod-name> -- curl -f localhost:8080/healthz

# Create Job
kubectl create job test --image=busybox -- echo "done"

# Create CronJob
kubectl create cronjob backup --image=backup:v1 --schedule="0 2 * * *" -- /backup.sh

# Watch job completion
kubectl get jobs -w

# Check cronjob schedule
kubectl get cronjob

# Manually trigger cronjob
kubectl create job manual-trigger --from=cronjob/backup

# Delete completed jobs
kubectl delete job --field-selector=status.successful=1
```

## Health Check Best Practices

### Liveness Probe
```yaml
# Should check:
# - Application is responsive
# - No deadlocks
# - Core functionality works

# Should NOT check:
# - External dependencies
# - Database connectivity
# - Network issues

# Example: Simple HTTP endpoint
GET /healthz
→ Returns 200 if app can handle requests
→ Returns 500 if app deadlocked
```

### Readiness Probe
```yaml
# Should check:
# - App ready to serve traffic
# - Dependencies available (database, cache)
# - Warmup completed

# Example: More comprehensive check
GET /ready
→ Returns 200 if app + dependencies ready
→ Returns 503 if database unavailable
```

### Startup Probe
```yaml
# For apps with slow initialization:
# - JVM warmup
# - Data loading
# - Cache population

# Gives app time before liveness checks start
```
