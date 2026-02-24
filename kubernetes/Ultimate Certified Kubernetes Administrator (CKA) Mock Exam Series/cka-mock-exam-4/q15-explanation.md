# CKA Mock Exam 4 - Question 15: Detailed Explanation

## What Is This Question About?

This question is about **migrating from Ingress to Gateway API** — the newer, more flexible way to route **inbound traffic** (from outside the cluster to services inside the cluster).

> ⚠️ **Don't be confused by the naming!** The namespace is called `external` and the app is called `external-app`, but they are **inside the cluster**. The name is just a label — it does NOT mean "external to the cluster."

---

## The Big Picture Analogy

| Concept | Real-World Analogy |
|---------|--------------------|
| **GatewayClass** | The type of road system (highways vs local roads) |
| **Gateway** | A specific highway entrance / toll booth |
| **HTTPRoute** | GPS directions from the toll booth to the restaurant |
| **Service** | The restaurant itself |
| **Pod** | The kitchen inside the restaurant that actually serves food |

---

## What Was Pre-Installed vs What We Created

| Resource | Who Set It Up | Namespace |
|----------|--------------|-----------|
| `GatewayClass: nginx` | Pre-installed | cluster-scoped |
| `Deployment: nginx-gateway` | Pre-installed (via Helm) | `nginx-gateway` |
| `Service: nginx-gateway` (NodePort 30080) | Pre-installed | `nginx-gateway` |
| `ServiceAccount: nginx-gateway` | Pre-installed | `nginx-gateway` |
| `Deployment: external-app` | Pre-installed | `external` |
| `Service: external-service` | Pre-installed | `external` |
| `Ingress: external-ingress` | Pre-installed (we deleted it) | `external` |
| **Gateway: web-gateway** | **We created** | `nginx-gateway` |
| **HTTPRoute: external-route** | **We created** | `external` |

The exam pre-installed the **infrastructure** (the NGINX Gateway Fabric controller, its deployment, its service). That's like the highway system already existing.

Our job was to:
1. **Open a door** on that highway (Gateway)
2. **Add road signs** pointing to the destination (HTTPRoute)
3. **Remove the old signs** (delete Ingress)

---

## Each Component Explained

### Component 1: GatewayClass (pre-installed, we did NOT create this)

```
GatewayClass: nginx
```

This was already installed via NGINX Gateway Fabric. It tells Kubernetes:
> "I have an NGINX-based gateway controller available for use."

Think of it as: **"NGINX is available as a traffic management system."**

---

### Component 2: Gateway (Part 1 — we created this)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx        # Use the NGINX gateway system
  listeners:
  - name: http
    port: 80                     # Listen on port 80
    protocol: HTTP               # For HTTP traffic
    allowedRoutes:
      namespaces:
        from: All                # Accept routes from ANY namespace
```

**What this does:** Creates a "front door" that listens for HTTP traffic on port 80. The `from: All` is critical — without it, only routes in the `nginx-gateway` namespace could attach to this Gateway. Our HTTPRoute is in the `external` namespace, so we need this.

Think of it as: **"Open a door on port 80 and allow anyone from any namespace to give me routing directions."**

---

### Component 3: HTTPRoute (Part 2 — we created this)

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: external-route
  namespace: external            # Lives in the 'external' namespace
spec:
  parentRefs:
  - name: web-gateway            # Attach to this Gateway...
    namespace: nginx-gateway     # ...in this namespace
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /                 # Match ALL paths (everything starting with /)
    backendRefs:
    - name: external-service     # Send traffic to this Service
      port: 80
```

**What this does:** Tells the Gateway: "Any request matching `/` (i.e., everything) should go to `external-service` on port 80."

Think of it as: **"GPS directions: from the front door, send everyone to the external-service."**

---

### Component 4: Delete the old Ingress (Part 3)

```bash
kubectl delete -n external ingress external-ingress
```

We remove the old Ingress because the HTTPRoute now does the same job.

---

## Ingress vs Gateway API — Key Difference

```
INGRESS (old way):
  Ingress Resource → defines both the "door" and the "directions" in one object

GATEWAY API (new way):
  Gateway    → defines the "door" (who can enter, what port, what protocol)
  HTTPRoute  → defines the "directions" (where to send traffic)
```

The Gateway API **separates concerns** — cluster admins manage Gateways, app developers manage HTTPRoutes. This is why they can live in different namespaces.

---

## The `deployment.apps/nginx-gateway` — Where the Magic Happens

The nginx-gateway pod has **2 containers** sharing EmptyDir volumes:

| Container | Role |
|-----------|------|
| `nginx-gateway` | The **controller** — watches the Kubernetes API for Gateway and HTTPRoute resources, then generates NGINX config |
| `nginx` | The **proxy** — runs NGINX with the generated config, actually handles the traffic |

### How It "Automatically Knows"

The controller's startup args tell it what to watch:

```
Args:
  static-mode
  --gateway-ctlr-name=gateway.nginx.org/nginx-gateway-controller
  --gatewayclass=nginx
  --service=nginx-gateway
```

This means:
1. **I manage the GatewayClass named `nginx`** → so watch for any Gateway that uses `gatewayClassName: nginx`
2. **I'm associated with the service `nginx-gateway`** → so that's where traffic enters

The controller is constantly **watching the Kubernetes API** for:
- Any **Gateway** referencing `gatewayClassName: nginx` → found `web-gateway`
- Any **HTTPRoute** with `parentRefs` pointing to that Gateway → found `external-route`

### The Shared Volume Mechanism

```
nginx-gateway container                nginx container
    (controller)                         (proxy)
         │                                  │
         │  writes nginx.conf               │  reads nginx.conf
         │                                  │
         └──────────► /etc/nginx/conf.d ◄───┘
                      (EmptyDir volume)
```

The controller **translates** declarative Gateway API resources into **imperative NGINX configuration**, and the proxy **uses** that configuration to route traffic. This happens dynamically — if you add/change/delete a Gateway or HTTPRoute, the controller regenerates the config and NGINX picks it up.

---

## Detailed Traffic Flow — Every Hop Explained

```
curl localhost:30080  (from cluster1-controlplane, IP: 10.244.196.190)
  │
  │ Step 1: localhost:30080 hits the NodePort on the control plane node
  │
  ▼
NodePort Service: nginx-gateway (nginx-gateway namespace)
  │  Type: NodePort
  │  ClusterIP: 172.20.237.248:80
  │  NodePort: 30080 → TargetPort: 80
  │  Endpoint: 172.17.1.4:80
  │
  │ Step 2: NodePort forwards to the single endpoint (the nginx-gateway pod)
  │
  ▼
Pod: nginx-gateway-96f76cdcf-dzjtd (IP: 172.17.1.4, on cluster1-node01)
  │
  │  This pod has 2 containers sharing volumes:
  │
  │  ┌─────────────────────────────────────────────────────┐
  │  │ Container 1: nginx-gateway (the controller)         │
  │  │                                                     │
  │  │ • Watches K8s API for Gateway & HTTPRoute resources  │
  │  │ • Sees: Gateway "web-gateway" (gatewayClass: nginx) │
  │  │ • Sees: HTTPRoute "external-route"                  │
  │  │   - parentRef → web-gateway                         │
  │  │   - match: PathPrefix "/"                           │
  │  │   - backendRef → external-service:80                │
  │  │ • Generates nginx.conf and writes to shared volume  │
  │  │   /etc/nginx/conf.d (EmptyDir)                      │
  │  │                                                     │
  │  │ Step 3: Controller translates Gateway API resources  │
  │  │         into NGINX config                           │
  │  └─────────────────────────────────────────────────────┘
  │
  │  ┌─────────────────────────────────────────────────────┐
  │  │ Container 2: nginx (the proxy)                      │
  │  │                                                     │
  │  │ • Listens on port 80 (this is the TargetPort)       │
  │  │ • Reads nginx.conf from shared volume               │
  │  │   /etc/nginx/conf.d                                 │
  │  │ • Config says: path "/" → proxy_pass to             │
  │  │   external-service.external.svc.cluster.local:80    │
  │  │ • Adds headers: X-Forwarded-For, X-Real-Ip, etc.   │
  │  │                                                     │
  │  │ Step 4: NGINX proxies the request to the backend    │
  │  └─────────────────────────────────────────────────────┘
  │
  │ Step 5: NGINX resolves external-service.external.svc.cluster.local
  │         via CoreDNS → gets ClusterIP of external-service
  │
  ▼
Service: external-service (external namespace)
  │  Type: ClusterIP
  │  Port: 80
  │  Selector: matches external-app pods
  │
  │ Step 6: Service load-balances to pod endpoint(s)
  │
  ▼
Pod: external-app-6f9cc8cbb9-zldq7 (IP: 172.17.2.10, on cluster1-node02)
  │
  │ Step 7: The echo server processes the request and returns info
  │
  ▼
Response travels back the same path (reverse)
  Pod → Service → nginx proxy → NodePort → curl output
```

### How Each Kubernetes Resource Maps to Each Step

| Step | What Happens | Kubernetes Resource | Namespace |
|------|-------------|-------------------|-----------|
| 1 | curl hits port 30080 on the node | **Service/nginx-gateway** (NodePort) | `nginx-gateway` |
| 2 | NodePort forwards to pod endpoint 172.17.1.4:80 | **Service/nginx-gateway** (Endpoints) | `nginx-gateway` |
| 3 | Controller reads Gateway + HTTPRoute, generates nginx config | **Gateway/web-gateway** + **HTTPRoute/external-route** | `nginx-gateway` + `external` |
| 4 | NGINX proxy matches path `/` and proxies to backend | **Pod/nginx-gateway** (nginx container) | `nginx-gateway` |
| 5 | DNS resolves the backend service name | **CoreDNS** | `kube-system` |
| 6 | ClusterIP service routes to pod | **Service/external-service** | `external` |
| 7 | Echo server responds | **Pod/external-app** | `external` |

---

## Mapping the curl Output to Each Step

```bash
curl localhost:30080
```

```
Hostname: external-app-6f9cc8cbb9-zldq7    ← Step 7: this pod answered
IP: 172.17.2.10                             ← the pod's own IP
RemoteAddr: 172.17.1.4:53010                ← Step 4: the nginx proxy pod (172.17.1.4)
                                               forwarded the request (not your original IP)
Host: localhost:30080                        ← Step 1: the original Host header from curl
X-Forwarded-For: 172.17.0.0                 ← your source IP (masqueraded by NodePort)
X-Forwarded-Port: 80                        ← the Gateway listener port
X-Forwarded-Proto: http                     ← the Gateway listener protocol
X-Real-Ip: 172.17.0.0                       ← your original client IP
```

---

## Relevant Outputs Explained

| Output | Relevant? | What It Tells You |
|--------|-----------|-------------------|
| `kubectl get gateway` | ✅ Yes | `PROGRAMMED: True` = Gateway is working |
| `kubectl describe gateway` | ✅ Yes | `Attached Routes: 1` confirms the HTTPRoute connected successfully |
| `kubectl describe httproute` | ✅ Yes | `Accepted: True` + `ResolvedRefs: True` = route is valid and the backend Service was found |
| `kubectl get all -n nginx-gateway` | ✅ Yes | Shows the NodePort service (`80:30080`) — this is **why** `curl localhost:30080` works |
| `kubectl describe service/nginx-gateway` | ✅ Yes | Confirms `NodePort: 30080 → TargetPort: 80` and the endpoint is `172.17.1.4:80` (the gateway pod) |
| `kubectl describe pod/nginx-gateway` | ⚠️ Somewhat | Confirms the NGINX Gateway Fabric pod is running with 2 containers and shared volumes. Useful for understanding architecture but not essential for solving the question |
| `kubectl get nodes` | ❌ Not really | Node info isn't relevant to this question |
| `curl localhost:30080` output | ✅ Yes | **Proves everything works!** The `RemoteAddr: 172.17.1.4` confirms traffic came through the gateway pod |

---

## Key Takeaways

1. **Gateway API is the replacement for Ingress** — it separates the "door" (Gateway) from the "directions" (HTTPRoute)
2. **The nginx-gateway deployment is the brain** — its controller container watches for Gateway/HTTPRoute resources and dynamically generates NGINX config
3. **Cross-namespace routing requires `allowedRoutes.namespaces.from: All`** — without this, routes in other namespaces can't attach to the Gateway
4. **The NodePort service is just the entry point** — it exposes the NGINX proxy to the outside world
5. **This is inbound traffic routing** — from outside the cluster to services inside the cluster (don't be confused by the "external" namespace name)
