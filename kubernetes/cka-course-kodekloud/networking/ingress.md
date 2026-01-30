# Ingress

## Executive Summary

Ingress provides HTTP/HTTPS routing to services within a Kubernetes cluster. It acts as a layer 7 load balancer, enabling URL-based routing, SSL termination, and virtual hosting. Unlike NodePort/LoadBalancer services that expose at layer 4, Ingress provides intelligent routing at the application layer.

**Key Components:**
| Component | Purpose | Managed By |
|-----------|---------|------------|
| **Ingress Controller** | Implements the routing rules (NGINX, Traefik, etc.) | Cluster Admin |
| **Ingress Resource** | Defines routing rules | Developer |

**Why Use Ingress?**

- Single entry point for multiple services
- Path-based and host-based routing
- SSL/TLS termination
- Reduces need for multiple LoadBalancers (cost savings)

---

## Ingress vs Services

| Feature                         | NodePort | LoadBalancer        | Ingress             |
| ------------------------------- | -------- | ------------------- | ------------------- |
| Layer                           | L4       | L4                  | L7                  |
| URL routing                     | ❌       | ❌                  | ✅                  |
| SSL termination                 | ❌       | ❌                  | ✅                  |
| Single IP for multiple services | ❌       | ❌                  | ✅                  |
| Cost                            | Free     | Per-service LB cost | Single LB + Ingress |

---

## Ingress Controller

> **Important:** Kubernetes does NOT include an Ingress Controller by default. You must deploy one!

### Popular Ingress Controllers

- **NGINX Ingress Controller** (most common)
- **Traefik**
- **HAProxy**
- **Contour**
- **Istio Gateway**

### Deploy NGINX Ingress Controller

```bash
# Using kubectl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/cloud/deploy.yaml

# Verify deployment
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

---

## Ingress Resource YAML

### Basic Ingress (Single Backend)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-ingress
spec:
  defaultBackend:
    service:
      name: my-service
      port:
        number: 80
```

### Path-Based Routing

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - path: /wear
            pathType: Prefix
            backend:
              service:
                name: wear-service
                port:
                  number: 80
          - path: /watch
            pathType: Prefix
            backend:
              service:
                name: watch-service
                port:
                  number: 80
```

### Host-Based Routing (Virtual Hosting)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-ingress
spec:
  rules:
    - host: wear.mystore.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: wear-service
                port:
                  number: 80
    - host: watch.mystore.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: watch-service
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
  tls:
    - hosts:
        - mystore.com
      secretName: tls-secret
  rules:
    - host: mystore.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

**Create TLS Secret:**

```bash
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
```

---

## Path Types

| PathType                 | Behavior                                                                   |
| ------------------------ | -------------------------------------------------------------------------- |
| `Prefix`                 | Matches URL path prefix (e.g., `/foo` matches `/foo`, `/foo/`, `/foo/bar`) |
| `Exact`                  | Exact URL path match only                                                  |
| `ImplementationSpecific` | Matching depends on IngressClass                                           |

---

## Real-World Example

### E-commerce Application

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
    - host: shop.example.com
      http:
        paths:
          - path: /api(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /(.*)
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

---

## Common Commands

```bash
# List ingress resources
kubectl get ingress
kubectl get ing

# Describe ingress
kubectl describe ingress <ingress-name>

# Create ingress imperatively
kubectl create ingress simple --rule="host/path=service:port"

# Example: Create path-based ingress
kubectl create ingress myingress \
  --rule="/wear=wear-service:80" \
  --rule="/watch=watch-service:80"

# Example: Create host-based ingress
kubectl create ingress myingress \
  --rule="wear.store.com/*=wear-service:80" \
  --rule="watch.store.com/*=watch-service:80"

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Get ingress controller service (external IP)
kubectl get svc -n ingress-nginx
```

---

## Common Annotations (NGINX)

```yaml
metadata:
  annotations:
    # Rewrite target URL
    nginx.ingress.kubernetes.io/rewrite-target: /

    # SSL redirect
    nginx.ingress.kubernetes.io/ssl-redirect: "true"

    # Backend protocol
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

    # Proxy body size
    nginx.ingress.kubernetes.io/proxy-body-size: "8m"

    # Connection timeout
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Create Ingress resources** with path/host rules
2. **Expose services** via Ingress
3. **Configure TLS** for Ingress
4. **Troubleshoot** Ingress routing issues

### Key Points to Remember

| Item               | Details                                     |
| ------------------ | ------------------------------------------- |
| API version        | `networking.k8s.io/v1`                      |
| Ingress Controller | Must be deployed separately                 |
| Path types         | `Prefix`, `Exact`, `ImplementationSpecific` |
| Default backend    | Handles unmatched requests                  |
| IngressClass       | Specifies which controller to use           |

### Quick YAML Template

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.com # Optional: omit for all hosts
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

### Imperative Commands

```bash
# Simple ingress
kubectl create ingress myingress --rule="myapp.com/=my-service:80"

# With path
kubectl create ingress myingress --rule="myapp.com/api=api-service:8080"

# Multiple rules
kubectl create ingress myingress \
  --rule="myapp.com/api=api-svc:8080" \
  --rule="myapp.com/web=web-svc:80"
```

### Troubleshooting Checklist

- [ ] Ingress Controller deployed? `kubectl get pods -n ingress-nginx`
- [ ] Ingress resource created? `kubectl get ingress`
- [ ] Backend services exist? `kubectl get svc`
- [ ] Services have endpoints? `kubectl get endpoints`
- [ ] Check Ingress events: `kubectl describe ingress <name>`
- [ ] Check controller logs for errors

---

## Official Documentation

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Ingress TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)
