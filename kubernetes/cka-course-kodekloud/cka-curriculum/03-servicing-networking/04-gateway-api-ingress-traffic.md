# Gateway API and Ingress Traffic Management

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Understand Gateway API concepts
- Create Gateway and HTTPRoute resources
- Configure traffic routing rules
- Understand Gateway API vs Ingress differences
- Use Gateway API for advanced routing
- Configure TLS termination
- Implement traffic splitting

## Sample Questions

1. **Create a Gateway resource for HTTP traffic**
2. **Create an HTTPRoute to route traffic based on path**
3. **Configure multiple backends with traffic splitting**
4. **Set up TLS termination using Gateway API**
5. **Compare Gateway API with traditional Ingress**

## Official Documentation

- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Gateway API Concepts](https://gateway-api.sigs.k8s.io/concepts/api-overview/)
- [Gateway API vs Ingress](https://gateway-api.sigs.k8s.io/concepts/migrating-from-ingress/)

## Key Concepts

### Gateway API vs Ingress

| Aspect | Ingress | Gateway API |
|--------|---------|-------------|
| **Role separation** | Combined | Infrastructure (Gateway) + Routes (HTTPRoute) |
| **Expressiveness** | Limited | Extensive (header matching, traffic splitting) |
| **Protocol support** | HTTP/HTTPS | HTTP, HTTPS, TCP, UDP, TLS, gRPC |
| **Status** | Stable | Beta (v1beta1) |
| **Portability** | Implementation-specific | Vendor-neutral |

### Gateway API Resources

```
GatewayClass → Gateway → HTTPRoute → Service → Pods
     ↓            ↓          ↓
Infrastructure  Listener  Routing Rules
```

| Resource | Purpose | Managed By |
|----------|---------|------------|
| **GatewayClass** | Type of gateway (controller) | Cluster admin |
| **Gateway** | Load balancer configuration | Cluster operator |
| **HTTPRoute** | HTTP routing rules | App developer |
| **TCPRoute** | TCP routing rules | App developer |
| **TLSRoute** | TLS routing rules | App developer |

## Prerequisites

```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Verify installation
kubectl get crd | grep gateway

# Expected output:
# gatewayclasses.gateway.networking.k8s.io
# gateways.gateway.networking.k8s.io
# httproutes.gateway.networking.k8s.io
```

## Imperative Commands

```bash
# No direct imperative commands for Gateway API
# Must use YAML

# List Gateway resources
kubectl get gatewayclasses
kubectl get gateways
kubectl get httproutes

# Describe resources
kubectl describe gateway my-gateway
kubectl describe httproute my-route

# Get resource YAML
kubectl get gateway my-gateway -o yaml
kubectl get httproute my-route -o yaml

# Delete resources
kubectl delete httproute my-route
kubectl delete gateway my-gateway
```

## YAML Examples

### GatewayClass
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
```

### Basic Gateway
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
```

### Gateway with HTTPS
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: https-gateway
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate
      certificateRefs:
      - name: example-tls-cert
        kind: Secret
```

### Basic HTTPRoute
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example-route
  namespace: default
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: example-service
      port: 80
```

### HTTPRoute with Path-Based Routing
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: path-based-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: api-service
      port: 8080
  - matches:
    - path:
        type: PathPrefix
        value: /web
    backendRefs:
    - name: web-service
      port: 80
```

### HTTPRoute with Header-Based Routing
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
      - name: x-user-type
        value: premium
    backendRefs:
    - name: premium-service
      port: 80
  - matches:
    - headers:
      - name: x-user-type
        value: standard
    backendRefs:
    - name: standard-service
      port: 80
```

### HTTPRoute with Traffic Splitting
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-split-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: v1-service
      port: 80
      weight: 90
    - name: v2-service
      port: 80
      weight: 10
```

### HTTPRoute with Request Redirect
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: redirect-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "old-domain.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    filters:
    - type: RequestRedirect
      requestRedirect:
        scheme: https
        hostname: new-domain.com
        statusCode: 301
```

### HTTPRoute with Request Header Modification
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-modifier-route
spec:
  parentRefs:
  - name: example-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: x-custom-header
          value: custom-value
        remove:
        - x-legacy-header
    backendRefs:
    - name: api-service
      port: 8080
```

### Complete Example: Multi-Service Application
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: app-gateway
  namespace: production
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate
      certificateRefs:
      - name: app-tls-cert
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-routes
  namespace: production
spec:
  parentRefs:
  - name: app-gateway
  hostnames:
  - "myapp.example.com"
  rules:
  # API routes
  - matches:
    - path:
        type: PathPrefix
        value: /api/v1
    backendRefs:
    - name: api-v1-service
      port: 8080
  - matches:
    - path:
        type: PathPrefix
        value: /api/v2
    backendRefs:
    - name: api-v2-service
      port: 8080
  # Web UI
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-service
      port: 80
```

## Troubleshooting Tips

### Gateway Not Ready

```bash
# Check Gateway status
kubectl get gateway example-gateway

# Describe for events
kubectl describe gateway example-gateway

# Check GatewayClass exists
kubectl get gatewayclass

# Check controller is running
kubectl get pods -n <controller-namespace>

# View Gateway status conditions
kubectl get gateway example-gateway -o yaml | grep -A10 conditions
```

### HTTPRoute Not Working

```bash
# Check HTTPRoute status
kubectl get httproute example-route

# Describe for parent refs
kubectl describe httproute example-route

# Verify Gateway reference
kubectl get httproute example-route -o yaml | grep -A5 parentRefs

# Check backend service exists
kubectl get svc <backend-service>

# Check service endpoints
kubectl get endpoints <backend-service>

# Test from within cluster
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- curl http://<gateway-ip>
```

### Traffic Not Reaching Backends

```bash
# Check HTTPRoute matches
kubectl get httproute example-route -o yaml | grep -A10 matches

# Verify hostname matches
curl -H "Host: example.com" http://<gateway-ip>

# Check path matches
curl http://<gateway-ip>/api

# Check backend service ports
kubectl get svc <backend-service> -o yaml | grep -A3 ports

# Check pods are ready
kubectl get pods -l app=<backend-app>
```

### TLS Not Working

```bash
# Check Gateway TLS configuration
kubectl get gateway https-gateway -o yaml | grep -A10 tls

# Verify certificate secret exists
kubectl get secret example-tls-cert

# Check secret contains correct keys
kubectl get secret example-tls-cert -o yaml | grep -E "tls.crt|tls.key"

# Test TLS connection
curl -k https://<gateway-ip>

# Check certificate details
openssl s_client -connect <gateway-ip>:443 -servername example.com
```

## Key Concepts

### Route Attachment

**Allowed Routes:**
Gateway controls which routes can attach
```yaml
listeners:
- name: http
  allowedRoutes:
    namespaces:
      from: Same  # Only same namespace
```

**Options:**
- `Same` - Same namespace as Gateway
- `All` - All namespaces
- `Selector` - Label selector

### Path Matching Types

| Type | Behavior | Example |
|------|----------|---------|
| **Exact** | Exact match | `/api` matches only `/api` |
| **PathPrefix** | Prefix match | `/api` matches `/api`, `/api/users` |
| **RegularExpression** | Regex match | `/api/.*` matches `/api/anything` |

### Traffic Splitting

```yaml
backendRefs:
- name: v1-service
  weight: 80  # 80% traffic
- name: v2-service
  weight: 20  # 20% traffic
```

## Exam Tips

1. **Gateway API is newer** - might not be heavily tested yet
2. **CRDs must be installed** - check with `kubectl get crd | grep gateway`
3. **Role separation** - Gateway (infra) vs HTTPRoute (app)
4. **parentRefs** links route to gateway
5. **Weight-based splitting** useful for canary deployments
6. **Multiple matches** act as OR (any match routes traffic)
7. **Filters modify requests** - headers, redirects, URL rewrites
8. **Check status** - resources have status conditions
9. **Namespace matters** - routes must be allowed by gateway
10. **Test with curl** - use `-H "Host: ..."` for hostname matching

## Common Mistakes

- ❌ Forgetting to install Gateway API CRDs
- ❌ Wrong GatewayClass reference in Gateway
- ❌ HTTPRoute parentRefs doesn't match Gateway name
- ❌ Hostname mismatch between request and HTTPRoute
- ❌ Backend service doesn't exist
- ❌ Wrong port in backendRefs
- ❌ Namespace not allowed by Gateway
- ❌ TLS secret missing or wrong format

## Quick Reference

```bash
# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Verify installation
kubectl get crd | grep gateway

# Create basic setup
kubectl apply -f gateway.yaml
kubectl apply -f httproute.yaml

# Check status
kubectl get gateway,httproute

# Test routing
GATEWAY_IP=$(kubectl get gateway example-gateway -o jsonpath='{.status.addresses[0].value}')
curl -H "Host: example.com" http://$GATEWAY_IP/api

# Cleanup
kubectl delete httproute example-route
kubectl delete gateway example-gateway
```

## Gateway API Benefits

### Over Ingress

1. **Role-oriented** - Infrastructure vs Application config
2. **Portable** - Works across implementations
3. **Expressive** - Header routing, traffic splitting, etc.
4. **Extensible** - Custom resources and policies
5. **Type-safe** - Strongly typed API
6. **Protocol-rich** - TCP, UDP, gRPC, not just HTTP

### Advanced Features

- **Traffic splitting** (canary, blue-green)
- **Header-based routing**
- **Query parameter routing**
- **Request/response modification**
- **Timeouts and retries**
- **Mirror traffic**
- **Cross-namespace routing** (with RBAC)

## Status Conditions

Check route status:
```bash
kubectl get httproute example-route -o jsonpath='{.status.parents[0].conditions}' | jq
```

Common conditions:
- `Accepted` - Route accepted by Gateway
- `ResolvedRefs` - Backend refs resolved
- `PartiallyInvalid` - Some rules invalid

## Migration from Ingress

**Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: example-svc
            port: 80
```

**Gateway API:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - example.com
  rules:
  - matches:
    - path:
        value: /
    backendRefs:
    - name: example-svc
      port: 80
```
