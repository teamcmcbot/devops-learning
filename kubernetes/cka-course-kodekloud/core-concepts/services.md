# Kubernetes Services

## Executive Summary

A **Service** is an abstraction that defines a logical set of Pods and a policy for accessing them. Services enable:

- **Stable networking**: Pods get dynamic IPs; Services provide stable endpoints
- **Load balancing**: Distribute traffic across multiple pods
- **Service discovery**: Access pods by service name (DNS)
- **External access**: Expose applications outside the cluster

---

## Service Types

| Type             | Description                                | Use Case                                |
| ---------------- | ------------------------------------------ | --------------------------------------- |
| **ClusterIP**    | Internal cluster IP (default)              | Internal communication between services |
| **NodePort**     | Exposes on each node's IP at a static port | Development, direct node access         |
| **LoadBalancer** | Cloud provider load balancer               | Production, cloud environments          |
| **ExternalName** | Maps to external DNS name                  | Accessing external services             |

---

## ClusterIP Service

Default type - creates an internal IP for pod-to-pod communication.

### YAML Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: back-end
spec:
  type: ClusterIP # Default, can be omitted
  ports:
    - port: 80 # Service port
      targetPort: 80 # Pod port
  selector:
    app: myapp
    type: back-end
```

### Use Case

- Frontend pods → Backend service
- Backend pods → Database service
- Any internal service communication

---

## NodePort Service

Exposes the service on each node's IP at a static port (30000-32767).

### Port Types

| Port           | Description                     |
| -------------- | ------------------------------- |
| **nodePort**   | Port on the node (30000-32767)  |
| **port**       | Service port (cluster internal) |
| **targetPort** | Pod/container port              |

### YAML Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: NodePort
  ports:
    - targetPort: 80 # Pod port (defaults to port if omitted)
      port: 80 # Service port
      nodePort: 30008 # Node port (auto-assigned if omitted)
  selector:
    app: myapp
    type: front-end
```

### Access Pattern

```
http://<node-ip>:30008
```

---

## LoadBalancer Service

Provisions a cloud load balancer (AWS ELB, GCP LB, Azure LB).

### YAML Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-loadbalancer
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: myapp
```

> **Note**: Only works on supported cloud providers. On bare metal, behaves like NodePort.

---

## Common Commands

### Creating Services

```bash
# Expose deployment as ClusterIP
kubectl expose deployment nginx --port=80 --target-port=80

# Expose as NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Expose pod
kubectl expose pod nginx --port=80 --name=nginx-svc

# Create from YAML
kubectl create -f service-definition.yaml
kubectl apply -f service-definition.yaml
```

### Viewing Services

```bash
# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe svc <service-name>

# Get service endpoints
kubectl get endpoints <service-name>
```

### Managing Services

```bash
# Delete service
kubectl delete svc <service-name>

# Edit service
kubectl edit svc <service-name>
```

---

## YAML Examples

### ClusterIP (Internal)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
spec:
  type: ClusterIP
  ports:
    - port: 3306
      targetPort: 3306
  selector:
    app: mysql
```

### NodePort (External Access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
  selector:
    app: webapp
    tier: frontend
```

### LoadBalancer (Cloud)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-lb
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: frontend
```

---

## Service Discovery

### DNS-based Discovery

Services are automatically registered in cluster DNS:

```
<service-name>.<namespace>.svc.cluster.local
```

### Examples

```bash
# Same namespace - use service name
curl http://db-service

# Different namespace - use FQDN
curl http://db-service.dev.svc.cluster.local

# Or shorter form
curl http://db-service.dev
```

---

## CKA Exam Relevance

### What to Know

- Create services using imperative and declarative methods
- Understand the three main service types
- Know port terminology (nodePort, port, targetPort)
- Troubleshoot service connectivity

### Quick Service Creation (Exam Tip!)

```bash
# Expose deployment (creates ClusterIP)
kubectl expose deployment nginx --port=80

# Expose as NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Generate YAML
kubectl expose deployment nginx --port=80 --type=NodePort --dry-run=client -o yaml > svc.yaml

# Create service for specific pod
kubectl expose pod redis --port=6379 --name=redis-service
```

### Troubleshooting Services

```bash
# Check service exists
kubectl get svc

# Check endpoints (should show pod IPs)
kubectl get endpoints <svc-name>

# If endpoints empty:
# - Check selector matches pod labels
# - Check pods are running
kubectl get pods --show-labels

# Test connectivity from within cluster
kubectl run test --image=busybox -it --rm -- wget -qO- http://<svc-name>
```

### Common Issues

| Problem               | Possible Cause                          |
| --------------------- | --------------------------------------- |
| No endpoints          | Selector doesn't match pod labels       |
| Connection refused    | targetPort doesn't match container port |
| External access fails | Wrong service type, firewall rules      |

---

## Quick Reference

| Command                                                  | Description              |
| -------------------------------------------------------- | ------------------------ |
| `kubectl expose deploy <name> --port=80`                 | Create ClusterIP service |
| `kubectl expose deploy <name> --port=80 --type=NodePort` | Create NodePort service  |
| `kubectl get svc`                                        | List services            |
| `kubectl describe svc <name>`                            | Service details          |
| `kubectl get endpoints`                                  | View service endpoints   |

---

## Official Documentation

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Connecting Applications with Services](https://kubernetes.io/docs/tutorials/services/connect-applications-service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
