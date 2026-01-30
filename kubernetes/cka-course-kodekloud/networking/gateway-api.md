# Gateway API (2025 Updates)

## Executive Summary

Gateway API is the next generation of Kubernetes Ingress, providing more expressive, extensible, and role-oriented routing. It addresses the limitations of Ingress by supporting multiple protocols (HTTP, TCP, gRPC), offering standardized advanced features, and enabling better multi-tenancy.

**Key Differences from Ingress:**
| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| Protocol support | HTTP/HTTPS only | HTTP, HTTPS, TCP, UDP, gRPC |
| Advanced features | Controller-specific annotations | Native, standardized |
| Multi-tenancy | Single resource for all | Separated by role |
| Traffic splitting | Annotations | Native support |
| TLS configuration | Basic | Advanced, structured |

---

## Gateway API Components

The Gateway API separates concerns across three main resources:

| Resource                   | Managed By              | Purpose                                |
| -------------------------- | ----------------------- | -------------------------------------- |
| **GatewayClass**           | Infrastructure Provider | Defines the controller implementation  |
| **Gateway**                | Cluster Operator        | Configures the actual gateway instance |
| **HTTPRoute** (and others) | Application Developer   | Defines routing rules                  |

```
┌─────────────────────────────────────────────────────────┐
│                    GatewayClass                         │
│        (Infrastructure Provider - e.g., NGINX)          │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       Gateway                            │
│            (Cluster Operator - Ports, TLS)              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      HTTPRoute                           │
│         (Developer - Path, Host, Backend routing)        │
└─────────────────────────────────────────────────────────┘
```

---

## YAML Configuration Examples

### GatewayClass

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
```

### Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example-gateway
  namespace: default
spec:
  gatewayClassName: example-gateway-class
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
```

### Gateway with TLS

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: secure-gateway
spec:
  gatewayClassName: example-gateway-class
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      tls:
        mode: Terminate
        certificateRefs:
          - kind: Secret
            name: tls-secret
      allowedRoutes:
        kinds:
          - kind: HTTPRoute
```

### HTTPRoute (Basic)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example-httproute
spec:
  parentRefs:
    - name: example-gateway
  hostnames:
    - "www.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      backendRefs:
        - name: api-service
          port: 8080
```

### HTTPRoute with Path-Based Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: store-route
spec:
  parentRefs:
    - name: store-gateway
  hostnames:
    - "store.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /products
      backendRefs:
        - name: products-service
          port: 80
    - matches:
        - path:
            type: PathPrefix
            value: /cart
      backendRefs:
        - name: cart-service
          port: 80
```

---

## Traffic Splitting (Canary Deployments)

**With Ingress (annotation-based):**

```yaml
# Requires controller-specific annotations
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-weight: "20"
```

**With Gateway API (native support):**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
    - name: app-gateway
  rules:
    - backendRefs:
        - name: app-v1
          port: 80
          weight: 80 # 80% traffic
        - name: app-v2
          port: 80
          weight: 20 # 20% traffic (canary)
```

---

## Header-Based Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-route
spec:
  parentRefs:
    - name: example-gateway
  rules:
    - matches:
        - headers:
            - name: "X-Version"
              value: "v2"
      backendRefs:
        - name: app-v2
          port: 80
    - backendRefs:
        - name: app-v1
          port: 80
```

---

## Response Header Modification

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: cors-route
spec:
  parentRefs:
    - name: my-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      filters:
        - type: ResponseHeaderModifier
          responseHeaderModifier:
            add:
              - name: Access-Control-Allow-Origin
                value: "*"
              - name: Access-Control-Allow-Methods
                value: "GET, POST, PUT, DELETE"
      backendRefs:
        - name: api-service
          port: 8080
```

---

## Supported Controllers

| Controller                 | Status |
| -------------------------- | ------ |
| NGINX Gateway Fabric       | GA     |
| Istio                      | GA     |
| Contour                    | GA     |
| Traefik                    | GA     |
| Kong                       | GA     |
| HAProxy                    | GA     |
| AWS Gateway API Controller | GA     |
| Azure Application Gateway  | GA     |
| Google Kubernetes Engine   | GA     |

---

## Gateway API vs Ingress Comparison

### Same Use Case - Different Approaches

**Ingress (with annotations):**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: myapp.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-svc
                port:
                  number: 80
```

**Gateway API (declarative):**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      backendRefs:
        - name: api-svc
          port: 80
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Understand Gateway API concepts** (GatewayClass, Gateway, HTTPRoute)
2. **Know the differences** between Ingress and Gateway API
3. **Configure basic HTTPRoutes** for traffic routing
4. **Traffic splitting** for canary deployments

### Key Points to Remember

| Item                  | Details                               |
| --------------------- | ------------------------------------- |
| API Group             | `gateway.networking.k8s.io/v1`        |
| Three main resources  | GatewayClass, Gateway, HTTPRoute      |
| Role separation       | Infra provider → Operator → Developer |
| Multi-protocol        | HTTP, HTTPS, TCP, UDP, gRPC           |
| No annotations needed | Features are native and standardized  |

### Quick Reference

**Resource Hierarchy:**

```
GatewayClass (who provides it)
    └── Gateway (how to expose)
           └── HTTPRoute (where to route)
```

**Route Types:**

- `HTTPRoute` - HTTP/HTTPS traffic
- `TCPRoute` - TCP traffic
- `UDPRoute` - UDP traffic
- `TLSRoute` - TLS passthrough
- `GRPCRoute` - gRPC traffic

### When to Use Gateway API vs Ingress

| Use Ingress When...    | Use Gateway API When...     |
| ---------------------- | --------------------------- |
| Simple HTTP routing    | Multi-protocol needed       |
| Basic TLS termination  | Advanced traffic management |
| Single team/namespace  | Multi-tenant environment    |
| Existing Ingress setup | New deployments             |

---

## Official Documentation

- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Gateway API Concepts](https://gateway-api.sigs.k8s.io/concepts/api-overview/)
- [HTTPRoute](https://gateway-api.sigs.k8s.io/api-types/httproute/)
- [Getting Started](https://gateway-api.sigs.k8s.io/guides/)
- [Implementations](https://gateway-api.sigs.k8s.io/implementations/)
