# Service Types and Endpoints

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Create ClusterIP services
- Create NodePort services
- Create LoadBalancer services
- Expose deployments and pods as services
- Understand service endpoints
- Troubleshoot service connectivity
- Use headless services
- Configure session affinity

## Sample Questions

1. **Create a ClusterIP service for deployment exposing port 80**
2. **Create a NodePort service accessible on port 30080**
3. **Expose a deployment as a LoadBalancer service**
4. **Troubleshoot why service has no endpoints**
5. **Create a headless service for StatefulSet**

## Official Documentation

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [Connecting Applications with Services](https://kubernetes.io/docs/tutorials/services/connect-applications-service/)

## Key Concepts

### Service Types

| Type | Accessibility | Use Case | IP Assignment |
|------|--------------|----------|---------------|
| **ClusterIP** | Internal only | Default, internal communication | Cluster IP |
| **NodePort** | External via Node IP:Port | Development, simple external access | Cluster IP + Node Port |
| **LoadBalancer** | External via cloud LB | Production external access | Cluster IP + Node Port + External IP |
| **ExternalName** | DNS CNAME mapping | External service proxy | None |

### Service Architecture

```
Client
  ↓
LoadBalancer (External IP: 1.2.3.4)
  ↓
NodePort (Node IP:30080)
  ↓
ClusterIP (10.96.100.50:80)
  ↓
Endpoints → Pod IPs (10.244.1.5:8080, 10.244.2.10:8080)
```

### Service Components

1. **Service** - Virtual IP and port
2. **Selector** - Matches pod labels
3. **Endpoints** - Actual pod IP:port combinations
4. **Kube-proxy** - Routes traffic to endpoints

## Imperative Commands

```bash
# Create ClusterIP service
kubectl create service clusterip my-service --tcp=80:8080

# Expose deployment as ClusterIP
kubectl expose deployment nginx --port=80 --target-port=8080 --name=nginx-service

# Expose deployment as NodePort
kubectl expose deployment nginx --type=NodePort --port=80 --name=nginx-nodeport

# Expose deployment as LoadBalancer
kubectl expose deployment nginx --type=LoadBalancer --port=80 --name=nginx-lb

# Expose pod
kubectl expose pod nginx --port=80 --name=nginx-pod-service

# Get services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service nginx-service

# Get service with endpoints
kubectl get svc,ep

# Get endpoints
kubectl get endpoints
kubectl get ep

# Get service details
kubectl get svc nginx-service -o yaml

# Delete service
kubectl delete service nginx-service

# Check service from inside cluster
kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -O- http://nginx-service
```

## YAML Examples

### ClusterIP Service (Default)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
  - name: http
    protocol: TCP
    port: 80          # Service port
    targetPort: 8080  # Container port
```

### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nodeport-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
    nodePort: 30080  # Optional: 30000-32767
```

### LoadBalancer Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
```

### Multi-Port Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
```

### Headless Service (No ClusterIP)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-service
spec:
  clusterIP: None  # Headless service
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

### Service with Session Affinity
```yaml
apiVersion: v1
kind: Service
metadata:
  name: sticky-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
  ports:
  - port: 80
    targetPort: 8080
```

### Service Without Selector (Manual Endpoints)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-service  # Must match service name
subsets:
- addresses:
  - ip: 192.168.1.100
  - ip: 192.168.1.101
  ports:
  - port: 8080
```

### ExternalName Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-database
spec:
  type: ExternalName
  externalName: database.example.com
```

### Complete Example: Deployment + Service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
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
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

## Troubleshooting Tips

### Service Has No Endpoints

```bash
# Check service and endpoints
kubectl get svc,ep my-service

# If no endpoints listed:
# 1. Check service selector
kubectl get svc my-service -o yaml | grep -A3 selector

# 2. Check pod labels
kubectl get pods --show-labels

# 3. Verify pods are running
kubectl get pods -l app=my-app

# 4. Check pod ready status
kubectl get pods -l app=my-app -o wide

# 5. Verify targetPort matches container port
kubectl get svc my-service -o yaml | grep targetPort
kubectl get pod <pod-name> -o yaml | grep containerPort

# Fix: Update service selector or pod labels
kubectl label pods <pod-name> app=my-app
```

### Cannot Access Service

```bash
# Test from within cluster
kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -O- http://my-service

# If fails:
# 1. Check service exists
kubectl get svc my-service

# 2. Check endpoints
kubectl get endpoints my-service

# 3. Check pods are ready
kubectl get pods -l app=my-app

# 4. Test direct pod connection
POD_IP=$(kubectl get pod <pod-name> -o jsonpath='{.status.podIP}')
kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -O- http://$POD_IP

# 5. Check kube-proxy
kubectl get pods -n kube-system | grep kube-proxy
kubectl logs -n kube-system kube-proxy-<node>
```

### NodePort Not Accessible

```bash
# Get NodePort
kubectl get svc my-service

# Get node IP
kubectl get nodes -o wide

# Test from outside
curl http://<node-ip>:<node-port>

# If fails:
# 1. Check firewall rules
# 2. Verify service type is NodePort
kubectl get svc my-service -o yaml | grep type

# 3. Check nodePort range (30000-32767)
kubectl get svc my-service -o yaml | grep nodePort

# 4. Test from another node
ssh <another-node>
curl http://<node-ip>:<node-port>
```

### LoadBalancer Stuck in Pending

```bash
# Check service status
kubectl get svc my-lb-service

# EXTERNAL-IP shows <pending>

# Common causes:
# 1. Not on cloud provider (minikube, bare metal)
# 2. Cloud controller not configured
# 3. No cloud provider integration

# Check events
kubectl describe svc my-lb-service

# For minikube, use tunnel
minikube tunnel

# For testing, use NodePort instead
kubectl patch svc my-lb-service -p '{"spec":{"type":"NodePort"}}'
```

### Service DNS Not Resolving

```bash
# Test DNS from pod
kubectl exec <pod-name> -- nslookup my-service

# Expected: my-service.default.svc.cluster.local

# If fails:
# 1. Check CoreDNS
kubectl get pods -n kube-system | grep coredns

# 2. Check DNS service
kubectl get svc -n kube-system kube-dns

# 3. Test with FQDN
kubectl exec <pod-name> -- nslookup my-service.default.svc.cluster.local

# 4. Check pod DNS config
kubectl exec <pod-name> -- cat /etc/resolv.conf
```

### Endpoints Not Updating

```bash
# Delete pod and check if endpoint updates
kubectl delete pod <pod-name>
kubectl get endpoints my-service -w

# If not updating:
# 1. Check endpoints controller
kubectl logs -n kube-system kube-controller-manager-<node> | grep endpoints

# 2. Verify service selector matches new pods
kubectl get svc my-service -o yaml | grep -A3 selector
kubectl get pods --show-labels
```

## Key Files and Locations

### Kube-proxy
- **Component**: Runs on each node
- **Mode**: iptables (default) or IPVS
- **Config**: `/var/lib/kube-proxy/config.conf`
- **Logs**: `kubectl logs -n kube-system kube-proxy-<node>`

### Check Kube-proxy Mode
```bash
kubectl logs -n kube-system kube-proxy-<pod> | grep "Using"
# Output: "Using iptables Proxier"
```

### Service IP Range
```bash
# Check API server config
ps aux | grep kube-apiserver | grep service-cluster-ip-range

# Common: --service-cluster-ip-range=10.96.0.0/12
```

## Exam Tips

1. **Use `kubectl expose`** for quick service creation
2. **Labels must match** between service selector and pods
3. **targetPort = container port** not service port
4. **NodePort range: 30000-32767** (default)
5. **ClusterIP only accessible within cluster**
6. **Check endpoints** - if empty, service won't work
7. **Service DNS**: `<service-name>.<namespace>.svc.cluster.local`
8. **Headless service** for StatefulSets (clusterIP: None)
9. **LoadBalancer** needs cloud provider
10. **Test with busybox** - simple and has network tools

## Common Mistakes

- ❌ Service selector doesn't match pod labels
- ❌ targetPort doesn't match container port
- ❌ Pods not ready (readiness probe failing)
- ❌ Trying to access ClusterIP from outside cluster
- ❌ Expecting LoadBalancer on non-cloud cluster
- ❌ Wrong protocol (TCP vs UDP)
- ❌ Port vs targetPort confusion
- ❌ Not checking endpoints

## Quick Reference

```bash
# Create deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Expose as ClusterIP
kubectl expose deployment nginx --port=80 --target-port=80 --name=nginx-svc

# Check service and endpoints
kubectl get svc,ep nginx-svc

# Test from within cluster
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- http://nginx-svc

# Expose as NodePort
kubectl expose deployment nginx --type=NodePort --port=80 --name=nginx-np

# Get NodePort
kubectl get svc nginx-np

# Test NodePort (from node or external)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
NODE_PORT=$(kubectl get svc nginx-np -o jsonpath='{.spec.ports[0].nodePort}')
curl http://$NODE_IP:$NODE_PORT

# Cleanup
kubectl delete deployment nginx
kubectl delete svc nginx-svc nginx-np
```

## Service DNS Names

| Service Location | DNS Name |
|-----------------|----------|
| Same namespace | `service-name` |
| Different namespace | `service-name.namespace` |
| Fully qualified | `service-name.namespace.svc.cluster.local` |

## Port Terminology

```yaml
spec:
  ports:
  - port: 80          # Service port (what clients connect to)
    targetPort: 8080  # Pod port (where container listens)
    nodePort: 30080   # Node port (external access)
```

## Session Affinity

**Default**: Round-robin to endpoints
**ClientIP**: Same client → same pod

```yaml
sessionAffinity: ClientIP
sessionAffinityConfig:
  clientIP:
    timeoutSeconds: 10800  # 3 hours
```

## Service Discovery

**Environment Variables:**
```bash
# Kubernetes injects for each service
<SERVICE_NAME>_SERVICE_HOST=10.96.100.50
<SERVICE_NAME>_SERVICE_PORT=80
```

**DNS** (Preferred):
```bash
# Use service DNS name
curl http://my-service
curl http://my-service.default
curl http://my-service.default.svc.cluster.local
```
