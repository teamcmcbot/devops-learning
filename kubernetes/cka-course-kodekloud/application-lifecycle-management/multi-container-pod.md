# Multi-Container Pods - CKA Cheatsheet

## Executive Summary

Multi-container pods allow multiple containers to run together in a single pod, sharing the same **lifecycle**, **network namespace** (localhost communication), and **storage volumes**. This pattern is used when containers are tightly coupled and need to work together as a single unit.

**Key Points:**

- All containers in a pod start and stop together
- Containers share the same IP address and can communicate via `localhost`
- Containers can share volumes for data exchange
- Common patterns: **Sidecar**, **Ambassador**, **Adapter**

---

## Multi-Container Design Patterns

| Pattern        | Description                                        | Example                                    |
| -------------- | -------------------------------------------------- | ------------------------------------------ |
| **Sidecar**    | Enhances/extends main container functionality      | Log collector, file sync, monitoring agent |
| **Ambassador** | Proxies network connections to/from main container | Proxy to database, API gateway             |
| **Adapter**    | Transforms output of main container                | Log format converter, metrics standardizer |

---

## Real-World Usage Example

**Scenario:** A web application needs centralized logging. Each web server pod has a sidecar container that:

- Reads logs from a shared volume
- Processes and forwards them to a central logging system (e.g., Elasticsearch)

**Benefits:**

- Web server code stays simple (no logging logic)
- Logging agent scales automatically with web servers
- Both containers share the same lifecycle

---

## Common Commands

```bash
# Create a multi-container pod
kubectl apply -f multi-container-pod.yaml

# List all containers in a pod
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'

# View logs from a specific container
kubectl logs <pod-name> -c <container-name>

# Execute command in a specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

# Describe pod (shows all container statuses)
kubectl describe pod <pod-name>
```

---

## YAML Configurations

### Basic Multi-Container Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
    - name: app
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

    - name: sidecar
      image: busybox
      command: ["sh", "-c", "tail -f /var/log/nginx/access.log"]
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

  volumes:
    - name: shared-logs
      emptyDir: {}
```

### Sidecar Pattern - Log Agent

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-with-logging
spec:
  containers:
    - name: webapp
      image: simple-webapp
      ports:
        - containerPort: 8080
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/webapp

    - name: log-agent
      image: log-agent
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/webapp

  volumes:
    - name: log-volume
      emptyDir: {}
```

### Ambassador Pattern - Database Proxy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-ambassador
spec:
  containers:
    - name: app
      image: myapp
      env:
        - name: DB_HOST
          value: "localhost" # Connects to ambassador on localhost
        - name: DB_PORT
          value: "5432"

    - name: ambassador
      image: ambassador-proxy
      ports:
        - containerPort: 5432
```

### Adapter Pattern - Log Format Converter

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-adapter
spec:
  containers:
    - name: app
      image: legacy-app # Outputs logs in custom format
      volumeMounts:
        - name: app-logs
          mountPath: /var/log/app

    - name: adapter
      image: log-adapter # Converts to standard format
      volumeMounts:
        - name: app-logs
          mountPath: /var/log/app

  volumes:
    - name: app-logs
      emptyDir: {}
```

---

## Init Containers (Related Concept)

Init containers run **before** app containers start. Useful for setup tasks.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-init
spec:
  initContainers:
    - name: init-service
      image: busybox
      command: ["sh", "-c", "until nslookup myservice; do sleep 2; done"]

  containers:
    - name: app
      image: myapp
```

**Key Differences:**
| Feature | Init Containers | Sidecar Containers |
|---------|-----------------|-------------------|
| Run timing | Before app containers | Same time as app |
| Run once? | Yes, then terminate | No, runs continuously |
| Must succeed? | Yes, all must complete | N/A |

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Add a sidecar container** to an existing pod definition
- **View logs** from a specific container in a multi-container pod
- **Exec into** a specific container
- **Create a pod** with shared volumes between containers
- **Troubleshoot** why one container in a pod is failing

### Key Things to Remember:

| Item               | Detail                                            |
| ------------------ | ------------------------------------------------- |
| `containers` field | Array - can have multiple entries                 |
| Specify container  | `-c <container-name>` for logs/exec               |
| Shared storage     | Use `emptyDir` volume for container communication |
| Network            | All containers share same IP, use `localhost`     |
| Lifecycle          | All containers start/stop together                |

### Quick Reference Commands:

```bash
# MUST know for exam
kubectl logs <pod> -c <container>         # Logs from specific container
kubectl exec -it <pod> -c <container> --  # Exec into specific container

# Check container statuses
kubectl get pod <pod> -o jsonpath='{range .status.containerStatuses[*]}{.name}: {.ready}{"\n"}{end}'
```

### Common Exam Mistakes:

- Forgetting `-c <container-name>` when pod has multiple containers
- Not creating shared volume for containers that need to exchange data
- Incorrect indentation in YAML (containers is an array!)

---

## Official Documentation Links

- [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Multi-Container Pods](https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers)
- [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Sidecar Containers](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)
- [Communicate Between Containers in Same Pod](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/)
