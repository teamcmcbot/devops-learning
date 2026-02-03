# Network Policies

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Create network policies to allow/deny traffic
- Understand ingress and egress rules
- Use pod selectors and namespace selectors
- Configure port-specific rules
- Implement default deny policies
- Troubleshoot network policy issues
- Verify network policy enforcement

## Sample Questions

1. **Create a network policy that denies all ingress traffic to pods with label `app=db`**
2. **Allow traffic only from pods with label `app=frontend` to `app=backend`**
3. **Create a default deny-all policy for a namespace**
4. **Allow egress traffic only to specific IP ranges**
5. **Debug why traffic is blocked after applying network policy**

## Official Documentation

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Declare Network Policy](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)

## Key Concepts

### Network Policy Basics

**Default Behavior (no NetworkPolicy):**
- All pods can communicate with all pods
- All pods can communicate with all services
- No restrictions

**With NetworkPolicy:**
- Traffic is **denied by default** for selected pods
- Only explicitly allowed traffic is permitted
- Policies are **additive** (multiple policies combine with OR logic)

### Policy Types

| Type | Controls | Default if Not Specified |
|------|----------|-------------------------|
| **Ingress** | Incoming traffic to pods | Allow all |
| **Egress** | Outgoing traffic from pods | Allow all |

### Selectors

| Selector | Matches | Scope |
|----------|---------|-------|
| **podSelector** | Pods by labels | Current namespace |
| **namespaceSelector** | Namespaces by labels | Cluster-wide |
| **ipBlock** | IP ranges (CIDR) | External IPs |

## Prerequisites

**Network Policy requires CNI plugin support:**
- ✅ Calico
- ✅ Cilium
- ✅ Weave Net
- ✅ Kube-router
- ❌ Flannel (basic version)

```bash
# Check if NetworkPolicy is supported
kubectl get networkpolicies
# If command works, NetworkPolicy is supported
```

## Imperative Commands

```bash
# No direct imperative command for NetworkPolicy
# Must use YAML

# List network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe networkpolicy <policy-name>

# Get network policy YAML
kubectl get networkpolicy <policy-name> -o yaml

# Delete network policy
kubectl delete networkpolicy <policy-name>

# Get network policies in all namespaces
kubectl get networkpolicies --all-namespaces

# Test connectivity (before and after policy)
kubectl exec <pod-name> -- curl http://<target-ip>
```

## YAML Examples

### Default Deny All Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress
```

### Default Deny All Egress
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### Default Deny All (Ingress and Egress)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Allow from Specific Pods
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Allow from Specific Namespace
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-dev-namespace
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: dev
```

### Allow from Specific Namespace AND Specific Pods
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific-namespace-and-pods
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: production
      podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Allow from External IPs (ipBlock)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-ips
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 203.0.113.0/24
        except:
        - 203.0.113.5/32
    ports:
    - protocol: TCP
      port: 80
```

### Egress to Specific Pods
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-to-db
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

### Allow DNS (Common Requirement)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
```

### Complete Example: Multi-tier App
```yaml
# Deny all by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow frontend to backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
---
# Allow backend to database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
---
# Allow DNS for all pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-access
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
```

## Troubleshooting Tips

### Test Network Policy Enforcement

```bash
# Step 1: Label test pods
kubectl run frontend --image=nginx --labels="app=frontend"
kubectl run backend --image=nginx --labels="app=backend"

# Step 2: Test connectivity before policy
BACKEND_IP=$(kubectl get pod backend -o jsonpath='{.status.podIP}')
kubectl exec frontend -- curl -m 3 http://$BACKEND_IP

# Expected: Success (no policies applied)

# Step 3: Apply deny-all policy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Step 4: Test again
kubectl exec frontend -- curl -m 3 http://$BACKEND_IP

# Expected: Timeout (traffic blocked)
```

### Traffic Still Allowed After Deny Policy

```bash
# Check if NetworkPolicy is applied
kubectl get networkpolicy

# Describe policy
kubectl describe networkpolicy <policy-name>

# Check pod labels match selector
kubectl get pods --show-labels

# Verify CNI supports NetworkPolicy
kubectl get pods -n kube-system | grep -E "calico|cilium|weave"

# Check policy applies to correct namespace
kubectl get networkpolicy -n <namespace>

# Test from correct source pod
kubectl exec <pod-name> -- curl http://<target-ip>
```

### Traffic Blocked Unexpectedly

```bash
# List all network policies affecting pod
kubectl get networkpolicies -o yaml | grep -A20 "podSelector:"

# Check if multiple policies are combining
kubectl get networkpolicies

# Remember: Policies are additive (OR logic)
# If ANY policy allows traffic, it's allowed

# Check egress policies (often forgotten)
kubectl describe networkpolicy <policy-name> | grep -A10 "Egress"

# Verify DNS is allowed
kubectl exec <pod-name> -- nslookup kubernetes.default

# Check if ipBlock might be blocking
kubectl describe networkpolicy <policy-name> | grep -A5 "ipBlock"
```

### Find Which Policy Blocks Traffic

```bash
# Get all policies in namespace
kubectl get networkpolicies -n <namespace>

# Check each policy
for policy in $(kubectl get netpol -o name); do
  echo "=== $policy ==="
  kubectl describe $policy
done

# Temporarily delete policies one by one to isolate
kubectl delete networkpolicy <policy-name>
# Test connectivity
# Reapply if needed
```

### Verify Policy Selectors

```bash
# Check if pod labels match policy selector
kubectl get pod <pod-name> --show-labels

# Check policy selector
kubectl get networkpolicy <policy-name> -o yaml | grep -A5 "podSelector"

# List pods matching selector
kubectl get pods -l app=backend

# Check namespace labels (for namespaceSelector)
kubectl get namespace <namespace> --show-labels
```

### DNS Not Working After Egress Policy

```bash
# Common issue: Egress policy blocks DNS

# Add DNS exception
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
EOF

# Test DNS
kubectl exec <pod-name> -- nslookup kubernetes.default
```

## Key Concepts

### Policy Scope

```yaml
# Applies to ALL pods in namespace
podSelector: {}

# Applies to specific pods
podSelector:
  matchLabels:
    app: backend
```

### Ingress Rules Logic

```yaml
# Allow from pods with label "role=db" OR namespace with label "env=prod"
ingress:
- from:
  - podSelector:
      matchLabels:
        role: db
  - namespaceSelector:
      matchLabels:
        env: prod
```

```yaml
# Allow from pods with label "role=db" AND namespace with label "env=prod"
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        env: prod
    podSelector:
      matchLabels:
        role: db
```

### Empty Selectors

| Selector | Meaning |
|----------|---------|
| `podSelector: {}` | All pods in namespace |
| `namespaceSelector: {}` | All namespaces |
| `from: []` or `to: []` | No traffic allowed |
| Missing `from` or `to` | All traffic allowed |

## Exam Tips

1. **No imperative command** - must write YAML
2. **Default deny** is good practice - start with deny-all, then allow specific
3. **Policies are additive** - multiple policies combine with OR
4. **Check CNI support** - Flannel (basic) doesn't support NetworkPolicy
5. **DNS often forgotten** - remember to allow DNS in egress policies
6. **Labels must match** - verify with `kubectl get pods --show-labels`
7. **Namespace matters** - NetworkPolicy is namespace-scoped
8. **Test before and after** - verify policy works as expected
9. **Empty podSelector** (`{}`) means all pods
10. **policyTypes required** - specify Ingress, Egress, or both

## Common Mistakes

- ❌ Forgetting to allow DNS (breaks name resolution)
- ❌ Not specifying policyTypes (default behavior may surprise)
- ❌ Confusing OR vs AND logic in selectors
- ❌ Applying policy without testing connectivity first
- ❌ Not labeling namespaces when using namespaceSelector
- ❌ Assuming policies work without CNI support
- ❌ Blocking health check probes (kubelet traffic)
- ❌ Not allowing egress to external services

## Quick Reference

```bash
# Create test environment
kubectl create namespace test
kubectl run pod1 --image=nginx -n test --labels="app=web"
kubectl run pod2 --image=nginx -n test --labels="app=api"

# Test connectivity
kubectl exec -n test pod1 -- curl -m 3 http://$(kubectl get pod pod2 -n test -o jsonpath='{.status.podIP}')

# Apply deny-all policy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test again (should timeout)
kubectl exec -n test pod1 -- curl -m 3 http://$(kubectl get pod pod2 -n test -o jsonpath='{.status.podIP}')

# Allow specific traffic
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
  namespace: test
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
EOF

# Test again (should work)
kubectl exec -n test pod1 -- curl -m 3 http://$(kubectl get pod pod2 -n test -o jsonpath='{.status.podIP}')

# Cleanup
kubectl delete namespace test
```

## Network Policy Checklist

- [ ] CNI plugin supports NetworkPolicy
- [ ] Pod labels are correct
- [ ] Namespace labels are correct (if using namespaceSelector)
- [ ] policyTypes specified (Ingress, Egress, or both)
- [ ] DNS allowed in egress policies
- [ ] Ports specified correctly
- [ ] Test connectivity before applying policy
- [ ] Test connectivity after applying policy
- [ ] Check multiple policies don't conflict
