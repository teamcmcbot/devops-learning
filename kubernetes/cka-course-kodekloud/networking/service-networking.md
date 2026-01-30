# Service Networking

## Executive Summary

Kubernetes Services provide stable networking endpoints for pods. Unlike pods which are ephemeral and get new IPs, Services provide a consistent IP address and DNS name. The `kube-proxy` component running on each node manages Service networking using iptables rules (or IPVS).

**Key Concepts:**

- Services are cluster-wide virtual constructs (not tied to a node)
- Services get IPs from a separate range than pods
- `kube-proxy` creates forwarding rules to route traffic to pods
- Three main types: ClusterIP, NodePort, LoadBalancer

---

## Service Types

| Type             | Scope                  | Use Case                                |
| ---------------- | ---------------------- | --------------------------------------- |
| **ClusterIP**    | Internal only          | Default; internal service communication |
| **NodePort**     | External via node port | Expose service on each node's IP        |
| **LoadBalancer** | External via cloud LB  | Cloud provider load balancer            |
| **ExternalName** | DNS CNAME              | Map service to external DNS name        |

### ClusterIP (Default)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

### NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nodeport-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080 # Range: 30000-32767
```

### LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

---

## How Service Networking Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐          │
│  │  Node 1  │    │  Node 2  │    │  Node 3  │          │
│  │          │    │          │    │          │          │
│  │ kubelet  │    │ kubelet  │    │ kubelet  │          │
│  │kube-proxy│    │kube-proxy│    │kube-proxy│          │
│  │          │    │          │    │          │          │
│  │ Pod(s)   │    │ Pod(s)   │    │ Pod(s)   │          │
│  └──────────┘    └──────────┘    └──────────┘          │
│        │              │               │                 │
│        └──────────────┼───────────────┘                 │
│                       │                                  │
│              Service: 10.96.0.100:80                    │
│              (Virtual IP - kube-proxy rules)            │
└─────────────────────────────────────────────────────────┘
```

### kube-proxy Modes

| Mode          | Description                                 |
| ------------- | ------------------------------------------- |
| **iptables**  | Default; uses iptables rules for routing    |
| **ipvs**      | Uses IPVS kernel module; better performance |
| **userspace** | Legacy; routes through kube-proxy process   |

```bash
# Check kube-proxy mode
kubectl logs -n kube-system <kube-proxy-pod> | grep "Using"

# Or check kube-proxy config
kubectl get configmap kube-proxy -n kube-system -o yaml
```

---

## IP Address Ranges

**Important:** Pod and Service IP ranges must NOT overlap!

| Range                    | Configured By | Example         |
| ------------------------ | ------------- | --------------- |
| Pod Network CIDR         | CNI plugin    | `10.244.0.0/16` |
| Service Cluster IP Range | API Server    | `10.96.0.0/12`  |
| Node Port Range          | API Server    | `30000-32767`   |

```bash
# Check service cluster IP range
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
# --service-cluster-ip-range=10.96.0.0/12

# Check pod network CIDR
kubectl cluster-info dump | grep -m 1 cluster-cidr
```

---

## Real-World Usage Example

### Exposing a Database Internally

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:5.7
          ports:
            - containerPort: 3306
---
# ClusterIP Service (internal only)
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
```

### Exposing a Web App Externally

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080
```

Access via: `http://<any-node-ip>:30080`

---

## Common Commands

```bash
# List all services
kubectl get svc
kubectl get services --all-namespaces

# Get service details
kubectl describe svc <service-name>

# Get service endpoints
kubectl get endpoints <service-name>

# Create service imperatively
kubectl expose deployment <deployment-name> --port=80 --target-port=8080 --type=NodePort

# Check iptables rules for a service
sudo iptables -L -t nat | grep <service-name>

# View kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Check service cluster IP range
ps aux | grep kube-apiserver | grep service-cluster-ip-range
```

---

## Debugging Service Networking

```bash
# Check if service has endpoints
kubectl get endpoints <service-name>
# Empty endpoints = no matching pods or selector mismatch

# Test service from within cluster
kubectl run test --image=busybox --rm -it --restart=Never -- wget -qO- <service-name>:<port>

# Check kube-proxy is running
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# View iptables DNAT rules
sudo iptables -L -t nat | grep DNAT
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Create Services** (ClusterIP, NodePort)
2. **Expose deployments** as services
3. **Troubleshoot service connectivity**
4. **Understand service-to-pod routing**

### Key Points to Remember

| Item           | Details                                   |
| -------------- | ----------------------------------------- |
| Default type   | ClusterIP                                 |
| NodePort range | 30000-32767                               |
| kube-proxy     | Creates iptables/ipvs rules on every node |
| Endpoints      | Auto-populated based on selector matching |
| Service DNS    | `<service>.<namespace>.svc.cluster.local` |

### Quick YAML Templates

**Minimal ClusterIP Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

**Expose Command:**

```bash
kubectl expose deployment <name> --port=80 --target-port=8080 --type=NodePort --name=my-svc
```

### Troubleshooting Checklist

- [ ] Service exists? `kubectl get svc`
- [ ] Endpoints populated? `kubectl get endpoints <svc>`
- [ ] Selector matches pod labels?
- [ ] Target port matches container port?
- [ ] kube-proxy running on all nodes?

---

## Official Documentation

- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Connecting Applications with Services](https://kubernetes.io/docs/tutorials/services/connect-applications-service/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
