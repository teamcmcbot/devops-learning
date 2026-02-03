# CoreDNS

## Exam Weight
Part of **20% - Servicing and Networking**

## What Can Be Tested

- Understand CoreDNS architecture and role
- Troubleshoot DNS resolution issues
- Configure CoreDNS
- Check DNS records for services and pods
- Modify CoreDNS ConfigMap
- Debug DNS-related pod failures

## Sample Questions

1. **Troubleshoot why pods cannot resolve service names**
2. **Check CoreDNS logs for DNS resolution failures**
3. **Verify DNS service is running and accessible**
4. **Add custom DNS entries to CoreDNS**
5. **Debug DNS timeout issues**

## Official Documentation

- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [CoreDNS](https://coredns.io/)
- [Customizing DNS Service](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
- [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

## Key Concepts

### CoreDNS Architecture

```
Pod → /etc/resolv.conf → kube-dns Service (ClusterIP)
                              ↓
                         CoreDNS Pods
                              ↓
                         DNS Resolution
```

### DNS Records in Kubernetes

| Resource | DNS Name Format | Example |
|----------|----------------|---------|
| **Service** | `<service>.<namespace>.svc.cluster.local` | `nginx.default.svc.cluster.local` |
| **Headless Service** | `<pod-ip>.<service>.<namespace>.svc.cluster.local` | `10-244-1-5.nginx.default.svc.cluster.local` |
| **Pod** | `<pod-ip>.<namespace>.pod.cluster.local` | `10-244-1-5.default.pod.cluster.local` |

### Search Domains

Pods get automatic search domains:
```
<namespace>.svc.cluster.local
svc.cluster.local
cluster.local
```

**Example:** From pod in `default` namespace:
- `nginx` → resolves to `nginx.default.svc.cluster.local`
- `nginx.kube-system` → resolves to `nginx.kube-system.svc.cluster.local`

## Imperative Commands

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check DNS service
kubectl get svc -n kube-system kube-dns

# CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Follow CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns -f

# Describe CoreDNS deployment
kubectl describe deployment coredns -n kube-system

# Get CoreDNS ConfigMap
kubectl get configmap coredns -n kube-system -o yaml

# Edit CoreDNS ConfigMap
kubectl edit configmap coredns -n kube-system

# Restart CoreDNS pods (to apply config changes)
kubectl rollout restart deployment coredns -n kube-system

# Test DNS from debug pod
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check pod DNS configuration
kubectl exec <pod-name> -- cat /etc/resolv.conf
```

## DNS Testing

### Test DNS Resolution

```bash
# Create test pod
kubectl run dnstest --image=busybox --rm -it --restart=Never -- /bin/sh

# Inside pod, test DNS:
nslookup kubernetes.default
nslookup google.com
nslookup nginx.default.svc.cluster.local

# Expected output for service:
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
#
# Name:      kubernetes.default
# Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

### Check Pod DNS Config

```bash
# View resolv.conf
kubectl exec <pod-name> -- cat /etc/resolv.conf

# Expected output:
# nameserver 10.96.0.10
# search default.svc.cluster.local svc.cluster.local cluster.local
# options ndots:5
```

## YAML Examples

### CoreDNS ConfigMap Structure

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

### Custom DNS Entries

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        hosts {
          192.168.1.100 custom.example.com
          fallthrough
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```

### Custom Upstream DNS

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 8.8.8.8 8.8.4.4 {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

### Pod with Custom DNS Config

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns-pod
spec:
  containers:
  - name: nginx
    image: nginx
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
    - 8.8.8.8
    searches:
    - custom.local
    options:
    - name: ndots
      value: "2"
```

### Pod with Custom DNS Policy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dnstest
spec:
  containers:
  - name: test
    image: busybox
    command: ["sleep", "3600"]
  dnsPolicy: ClusterFirst  # Default, uses CoreDNS
  # Other options:
  # ClusterFirstWithHostNet - for hostNetwork pods
  # Default - inherits from node
  # None - must specify dnsConfig
```

## Troubleshooting Tips

### Pods Cannot Resolve DNS

```bash
# Step 1: Check CoreDNS is running
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Step 2: Check DNS service exists
kubectl get svc -n kube-system kube-dns

# Expected: ClusterIP (usually 10.96.0.10)

# Step 3: Test DNS from pod
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# If "server can't find kubernetes.default":
# 4. Check pod's resolv.conf
kubectl exec <pod-name> -- cat /etc/resolv.conf

# Should show: nameserver 10.96.0.10

# 5. Test direct connection to CoreDNS
kubectl exec <pod-name> -- nslookup kubernetes.default 10.96.0.10

# 6. Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# 7. Check CoreDNS endpoints
kubectl get endpoints -n kube-system kube-dns
```

### CoreDNS Pods CrashLoopBackOff

```bash
# Check pod status
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check logs
kubectl logs -n kube-system <coredns-pod-name>

# Common issues:
# 1. ConfigMap syntax error
kubectl get configmap coredns -n kube-system -o yaml

# 2. Port conflict
# Check if another pod is using port 53

# 3. Resource constraints
kubectl describe pod -n kube-system <coredns-pod-name>

# Fix: Edit ConfigMap
kubectl edit configmap coredns -n kube-system

# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system
```

### DNS Timeouts / Slow Resolution

```bash
# Check CoreDNS logs for errors
kubectl logs -n kube-system -l k8s-app=kube-dns | grep -i error

# Check CoreDNS resource usage
kubectl top pods -n kube-system -l k8s-app=kube-dns

# Increase cache TTL in ConfigMap
kubectl edit configmap coredns -n kube-system
# Change: cache 30 → cache 300

# Scale CoreDNS replicas
kubectl scale deployment coredns -n kube-system --replicas=3

# Check forward nameservers
kubectl exec <pod-name> -- cat /etc/resolv.conf
```

### Service Not Resolving

```bash
# Check service exists
kubectl get svc <service-name>

# Test with FQDN
kubectl exec <pod-name> -- nslookup <service-name>.default.svc.cluster.local

# Check service has endpoints
kubectl get endpoints <service-name>

# If no endpoints, service won't resolve
# Fix: Ensure pods with matching labels exist

# Test from CoreDNS directly
kubectl exec -n kube-system <coredns-pod> -- nslookup <service-name>.default.svc.cluster.local 127.0.0.1
```

### External DNS Not Resolving

```bash
# Test external DNS
kubectl exec <pod-name> -- nslookup google.com

# If fails:
# Check forward configuration in CoreDNS
kubectl get configmap coredns -n kube-system -o yaml | grep forward

# Should be: forward . /etc/resolv.conf
# Or: forward . 8.8.8.8 8.8.4.4

# Check node's /etc/resolv.conf
ssh <node>
cat /etc/resolv.conf

# Verify network connectivity
kubectl exec <pod-name> -- ping 8.8.8.8
```

### Search Domain Issues

```bash
# Check pod's search domains
kubectl exec <pod-name> -- cat /etc/resolv.conf | grep search

# Should include:
# search <namespace>.svc.cluster.local svc.cluster.local cluster.local

# If missing, check DNS policy
kubectl get pod <pod-name> -o yaml | grep dnsPolicy

# Test with different search paths
kubectl exec <pod-name> -- nslookup nginx              # Uses search
kubectl exec <pod-name> -- nslookup nginx.default      # Partial FQDN
kubectl exec <pod-name> -- nslookup nginx.default.svc.cluster.local  # Full FQDN
```

## Key Files and Locations

### CoreDNS
- **Namespace**: `kube-system`
- **Deployment**: `coredns`
- **Service**: `kube-dns` (yes, service name is kube-dns, not coredns!)
- **ConfigMap**: `coredns`
- **Default Port**: 53 (DNS), 9153 (metrics)

### Pod DNS Configuration
- **File**: `/etc/resolv.conf` (inside pod)
- **Managed by**: kubelet based on dnsPolicy

### Check DNS Service IP
```bash
# Get DNS service cluster IP
kubectl get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}'

# This IP should match nameserver in pod's resolv.conf
```

## Exam Tips

1. **Service name is `kube-dns`** not `coredns`
2. **Check logs first** - `kubectl logs -n kube-system -l k8s-app=kube-dns`
3. **Test with `nslookup`** from inside a pod
4. **Use FQDN** if short name doesn't work
5. **CoreDNS ConfigMap** controls DNS behavior
6. **Restart after config changes** - `kubectl rollout restart`
7. **Check `/etc/resolv.conf`** in pod for DNS config
8. **Default DNS IP: 10.96.0.10** (may vary)
9. **ndots:5** means 5+ dots → query as-is, else use search domains
10. **External DNS** goes through forward directive

## Common Mistakes

- ❌ Looking for `coredns` service (it's `kube-dns`)
- ❌ Forgetting to restart CoreDNS after config changes
- ❌ Not using FQDN when search domains aren't working
- ❌ Testing DNS from local machine (test from inside pod)
- ❌ Syntax errors in CoreDNS ConfigMap
- ❌ Not checking if CoreDNS pods are running
- ❌ Expecting instant DNS propagation (cache delay)

## Quick Reference

```bash
# Check CoreDNS health
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get svc -n kube-system kube-dns

# Test DNS resolution
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check pod DNS config
kubectl run test --image=busybox --rm -it --restart=Never -- cat /etc/resolv.conf

# View CoreDNS config
kubectl get configmap coredns -n kube-system -o yaml

# CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system

# Scale CoreDNS
kubectl scale deployment coredns -n kube-system --replicas=3
```

## CoreDNS Plugins

Common plugins in Corefile:

| Plugin | Purpose |
|--------|---------|
| **errors** | Log errors |
| **health** | Health check endpoint |
| **ready** | Readiness check endpoint |
| **kubernetes** | Kubernetes service/pod DNS |
| **prometheus** | Metrics endpoint |
| **forward** | Forward to upstream DNS |
| **cache** | DNS response caching |
| **loop** | Loop detection |
| **reload** | Auto-reload on config change |
| **loadbalance** | Round-robin load balancing |

## DNS Query Flow

```
1. Pod queries "nginx"
   ↓
2. Check /etc/resolv.conf
   ↓
3. Try search domains:
   - nginx.default.svc.cluster.local
   - nginx.svc.cluster.local
   - nginx.cluster.local
   ↓
4. Send to nameserver (10.96.0.10)
   ↓
5. CoreDNS receives query
   ↓
6. Check cache
   ↓
7. If not cached, query Kubernetes API
   ↓
8. Return service ClusterIP
   ↓
9. Pod connects to ClusterIP
   ↓
10. kube-proxy routes to pod
```

## ndots Option

```
options ndots:5
```

**Meaning:** If query has < 5 dots, try search domains first

**Example with ndots:5:**
- `google.com` (1 dot) → tries search domains first
- `api.google.com` (2 dots) → tries search domains first
- `one.two.three.four.five.com` (5 dots) → queries as-is first

**Override in pod:**
```yaml
dnsConfig:
  options:
  - name: ndots
    value: "2"
```
