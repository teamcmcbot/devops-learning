# Question 13 | Gateway API Ingress

**Solve this question on:** `ssh cka7968`

## Task

The team from Project `r500` wants to replace their Ingress (`networking.k8s.io`) with a Gateway API (`gateway.networking.k8s.io`) solution.

The old Ingress is available at:

```
/opt/course/13/ingress.yaml
```

Perform the following in Namespace `project-r500` and for the **already existing Gateway**:

1. Create a new `HTTPRoute` named **traffic-director** which replicates the routes from the old Ingress.
2. Extend the new HTTPRoute with path `/auto` which:
   - forwards to **mobile** backend if the `User-Agent` is exactly `mobile`
   - forwards to **desktop** backend otherwise.

The existing Gateway is reachable at:

```
http://r500.gateway:30080
```

Your implementation should work for:

```bash
curl r500.gateway:30080/desktop
curl r500.gateway:30080/mobile
curl r500.gateway:30080/auto -H "User-Agent: mobile"
curl r500.gateway:30080/auto
```

---

# Solution

## Step 1 — Connect to the node

```bash
ssh cka7968
```

---

# Step 2 — Inspect the existing Gateway

Check the existing Gateway resource.

```bash
kubectl -n project-r500 get gateway
```

Example output:

```
NAME          CLASS   ADDRESS   PORTS
r500-gateway  nginx   ...       80
```

Inspect it:

```bash
kubectl -n project-r500 describe gateway
```

Take note of the **gateway name**, which will be referenced in the HTTPRoute.

---

# Step 3 — Inspect the old Ingress

Open the original ingress definition:

```bash
cat /opt/course/13/ingress.yaml
```

Example structure:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: r500-ingress
spec:
  rules:
  - http:
      paths:
      - path: /desktop
        backend:
          service:
            name: desktop
            port:
              number: 80
      - path: /mobile
        backend:
          service:
            name: mobile
            port:
              number: 80
```

This means we need equivalent **HTTPRoute rules**.

---

# Step 4 — Create HTTPRoute

Create the route manifest:

```bash
vim 13.yaml
```

````yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  parentRefs:
  - name: r500-gateway

  rules:

  - matches:
    - path:
        type: PathPrefix
        value: /desktop
    backendRefs:
    - name: desktop
      port: 80

  - matches:
    - path:
        type: PathPrefix
        value: /mobile
    backendRefs:
    - name: mobile
      port: 80

  - matches:
    - path:
        type: PathPrefix
        value: /auto
      headers:
      - name: User-Agent
        value: mobile
    backendRefs:
    - name: mobile
      port: 80

  - matches:
    - path:
        type: PathPrefix
        value: /auto
    backendRefs:
    - name: desktop
      port: 80