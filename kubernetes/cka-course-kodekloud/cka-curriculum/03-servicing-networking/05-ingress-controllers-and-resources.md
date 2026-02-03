# Ingress Controllers and Ingress Resources

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Create Ingress resources
- Configure path-based routing
- Configure host-based routing
- Set up TLS/SSL termination
- Use Ingress annotations
- Troubleshoot Ingress issues
- Understand Ingress controller requirements

## Sample Questions

1. **Create an Ingress to route `/app` to app-service and `/api` to api-service**
2. **Configure host-based routing for multiple domains**
3. **Set up TLS termination with a certificate secret**
4. **Troubleshoot why Ingress is not routing traffic**
5. **Configure default backend for unmatched paths**

## Official Documentation

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [Set up Ingress on Minikube](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

## Key Concepts

### Ingress Architecture

```
Client
  ↓
Ingress Controller (nginx, traefik, etc.)
  ↓
Ingress Rules
  ↓
Services
  ↓
Pods
```

### Ingress vs Service

| Aspect | Service (LoadBalancer) | Ingress |
|--------|----------------------|---------|
| **Layer** | L4 (TCP/UDP) | L7 (HTTP/HTTPS) |
| **Cost** | One LB per service | One LB for many services |
| **Routing** | Simple port-based | Path/host-based |
| **SSL/TLS** | Pass-through | Termination |
| **Features** | Basic | Advanced (rewrites, auth, etc.) |

### Popular Ingress Controllers

| Controller | Features | Use Case |
|------------|----------|----------|
| **NGINX** | Most popular, feature-rich | General purpose |
| **Traefik** | Auto-discovery, Let's Encrypt | Cloud-native |
| **HAProxy** | High performance | Enterprise |
| **Contour** | Envoy-based | Service mesh integration |
| **Kong** | API Gateway features | API management |

## Prerequisites

```bash
# Check if Ingress controller is installed
kubectl get pods -n ingress-nginx
# or
kubectl get pods -n kube-system | grep ingress

# For minikube
minikube addons enable ingress

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Verify installation
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## Imperative Commands

```bash
# Create Ingress (limited - better use YAML)
kubectl create ingress simple --rule="example.com/=service:80"

# Create Ingress with TLS
kubectl create ingress tls-example --rule="example.com/=service:80,tls=my-cert"

# Get Ingress resources
kubectl get ingress
kubectl get ing

# Describe Ingress
kubectl describe ingress my-ingress

# Get Ingress YAML
kubectl get ingress my-ingress -o yaml

# Edit Ingress
kubectl edit ingress my-ingress

# Delete Ingress
kubectl delete ingress my-ingress

# Check Ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## YAML Examples

### Basic Ingress - Single Service
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Path-Based Routing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 8080
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Host-Based Routing (Virtual Hosts)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### Ingress with TLS
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Create TLS Secret
```bash
# Create TLS secret from cert files
kubectl create secret tls example-tls \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key

# Or create self-signed for testing
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=example.com"

kubectl create secret tls example-tls \
  --cert=tls.crt \
  --key=tls.key
```

### Ingress with Default Backend
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-with-default
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: default-service
      port:
        number: 80
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 8080
```

### Ingress with Annotations (NGINX-specific)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: annotated-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### Rewrite Target Example
```yaml
# Request: /api/users → Backend: /users
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### Complete Example: Multi-App with TLS
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: complete-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - app1.example.com
    - app2.example.com
    secretName: example-tls
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: app2-api-service
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-web-service
            port:
              number: 80
```

## Troubleshooting Tips

### Ingress Not Working - No Address

```bash
# Check Ingress status
kubectl get ingress

# ADDRESS column empty

# Check Ingress controller is running
kubectl get pods -n ingress-nginx

# Check Ingress controller service
kubectl get svc -n ingress-nginx

# If no LoadBalancer external IP on cloud:
# Use NodePort or port-forward for testing
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80

# Test via localhost
curl -H "Host: example.com" http://localhost:8080
```

### 404 Not Found

```bash
# Check Ingress rules
kubectl describe ingress my-ingress

# Verify host matches request
curl -v -H "Host: example.com" http://<ingress-ip>

# Check path matches
kubectl get ingress my-ingress -o yaml | grep -A5 paths

# Verify backend service exists
kubectl get svc <service-name>

# Check service has endpoints
kubectl get endpoints <service-name>

# Check Ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller | grep "example.com"
```

### 503 Service Unavailable

```bash
# Backend service or pods not ready

# Check service exists
kubectl get svc <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# If no endpoints:
# 1. Check pods are running
kubectl get pods -l app=<app-label>

# 2. Check service selector matches pods
kubectl get svc <service-name> -o yaml | grep -A3 selector
kubectl get pods --show-labels

# 3. Check pods are ready
kubectl describe pod <pod-name> | grep -A5 "Conditions"
```

### TLS Certificate Issues

```bash
# Check secret exists
kubectl get secret example-tls

# Verify secret contains correct keys
kubectl get secret example-tls -o yaml | grep -E "tls.crt|tls.key"

# Check certificate details
kubectl get secret example-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# Test TLS connection
curl -k https://<ingress-ip> -H "Host: example.com"

# Check for certificate errors
openssl s_client -connect <ingress-ip>:443 -servername example.com
```

### Ingress Controller Not Installed

```bash
# Check for controller
kubectl get pods --all-namespaces | grep ingress

# For minikube
minikube addons list | grep ingress
minikube addons enable ingress

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Wait for ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### Path Matching Issues

```bash
# PathType matters!

# Prefix: matches /api, /api/, /api/users
pathType: Prefix

# Exact: matches only /api
pathType: Exact

# ImplementationSpecific: depends on controller
pathType: ImplementationSpecific

# Check what paths are configured
kubectl get ingress my-ingress -o yaml | grep -A3 "path:"
```

## Key Files and Locations

### NGINX Ingress Controller
- **Namespace**: `ingress-nginx`
- **Deployment**: `kubectl get deployment -n ingress-nginx`
- **ConfigMap**: `kubectl get configmap -n ingress-nginx ingress-nginx-controller`
- **Logs**: `kubectl logs -n ingress-nginx deployment/ingress-nginx-controller`

### IngressClass
```bash
# List IngressClasses
kubectl get ingressclass

# Describe IngressClass
kubectl describe ingressclass nginx

# Set default IngressClass
kubectl annotate ingressclass nginx \
  ingressclass.kubernetes.io/is-default-class=true
```

## Exam Tips

1. **Ingress controller must be installed** - check first
2. **ingressClassName required** (or default IngressClass set)
3. **Host header matters** - use `curl -H "Host: example.com"`
4. **pathType: Prefix** most common (matches path and subpaths)
5. **Order matters** for paths - most specific first
6. **TLS secret must exist** before creating Ingress
7. **Check backend service** - Ingress won't work without it
8. **Annotations are controller-specific** - nginx.ingress.kubernetes.io/*
9. **defaultBackend** for catch-all routing
10. **Test with port-forward** if no external IP

## Common Mistakes

- ❌ No Ingress controller installed
- ❌ Wrong ingressClassName (or missing)
- ❌ Host mismatch (request vs Ingress rule)
- ❌ Backend service doesn't exist
- ❌ Service has no endpoints (pods not ready)
- ❌ TLS secret missing or wrong format
- ❌ Path order incorrect (less specific first)
- ❌ Testing without Host header
- ❌ Using wrong pathType

## Quick Reference

```bash
# Install NGINX Ingress Controller (example)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Create deployment and service
kubectl create deployment web --image=nginx --replicas=2
kubectl expose deployment web --port=80

# Create Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
EOF

# Get Ingress address
kubectl get ingress web-ingress

# Test (replace <ingress-ip> with actual IP)
curl -H "Host: web.example.com" http://<ingress-ip>

# Or add to /etc/hosts and test
# <ingress-ip> web.example.com
curl http://web.example.com

# Cleanup
kubectl delete ingress web-ingress
kubectl delete svc web
kubectl delete deployment web
```

## Path Types

| Type | Behavior | Example |
|------|----------|---------|
| **Prefix** | Matches path and subpaths | `/foo` → `/foo`, `/foo/`, `/foo/bar` |
| **Exact** | Exact match only | `/foo` → only `/foo` |
| **ImplementationSpecific** | Controller-dependent | Varies |

## Common Annotations (NGINX)

```yaml
# Rewrite target
nginx.ingress.kubernetes.io/rewrite-target: /

# SSL redirect
nginx.ingress.kubernetes.io/ssl-redirect: "true"

# Backend protocol
nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

# Rate limiting
nginx.ingress.kubernetes.io/rate-limit: "100"

# Proxy buffer size
nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"

# Authentication
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: basic-auth

# Custom timeouts
nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
```

## IngressClass

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
```

Reference in Ingress:
```yaml
spec:
  ingressClassName: nginx
```

Or set as default:
```bash
kubectl annotate ingressclass nginx \
  ingressclass.kubernetes.io/is-default-class=true
```
