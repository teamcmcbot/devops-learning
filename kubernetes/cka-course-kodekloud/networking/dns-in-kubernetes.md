# DNS in Kubernetes (CoreDNS)

## Executive Summary

Kubernetes provides built-in DNS for service discovery. CoreDNS (since v1.12) runs as pods in the cluster and automatically creates DNS records for Services and Pods. This enables pods to communicate using service names instead of IP addresses.

**Key Concepts:**

- CoreDNS runs as a Deployment in `kube-system` namespace
- Every Service automatically gets a DNS record
- Pod DNS records are optional (IP with dashes as hostname)
- Pods are auto-configured to use CoreDNS via `/etc/resolv.conf`

---

## DNS Record Formats

### Service DNS Names

| Format                                       | Example                                 |
| -------------------------------------------- | --------------------------------------- |
| `<service>`                                  | `web-service` (same namespace)          |
| `<service>.<namespace>`                      | `web-service.default`                   |
| `<service>.<namespace>.svc`                  | `web-service.default.svc`               |
| `<service>.<namespace>.svc.<cluster-domain>` | `web-service.default.svc.cluster.local` |

### Pod DNS Names (when enabled)

| Format                                             | Example                                |
| -------------------------------------------------- | -------------------------------------- |
| `<pod-ip-dashed>.<namespace>.pod.<cluster-domain>` | `10-244-1-5.default.pod.cluster.local` |

> **Note:** Pod IPs use dashes instead of dots (e.g., `10.244.1.5` → `10-244-1-5`)

---

## Real-World Usage Example

### Service Discovery Between Pods

```yaml
# Database Service
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: database
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
---
# Application can access MySQL using:
# - mysql.database (short form)
# - mysql.database.svc.cluster.local (FQDN)
```

**In application pod:**

```bash
# All these work:
curl http://mysql.database:3306
curl http://mysql.database.svc:3306
curl http://mysql.database.svc.cluster.local:3306

# DNS lookup
nslookup mysql.database
host mysql.database.svc.cluster.local
```

---

## CoreDNS Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                 │
│                                                      │
│   ┌─────────────────────────────────────────────┐   │
│   │              kube-system namespace           │   │
│   │                                              │   │
│   │   ┌──────────────┐    ┌──────────────┐      │   │
│   │   │  CoreDNS     │    │  CoreDNS     │      │   │
│   │   │  Pod (1)     │    │  Pod (2)     │      │   │
│   │   └──────────────┘    └──────────────┘      │   │
│   │           │                   │              │   │
│   │           └─────────┬─────────┘              │   │
│   │                     │                        │   │
│   │            ┌────────┴────────┐               │   │
│   │            │   kube-dns      │               │   │
│   │            │   Service       │               │   │
│   │            │  10.96.0.10     │               │   │
│   │            └─────────────────┘               │   │
│   └─────────────────────────────────────────────┘   │
│                          │                           │
│            All pods use 10.96.0.10 as nameserver    │
└─────────────────────────────────────────────────────┘
```

---

## CoreDNS Configuration

### Corefile (ConfigMap)

```bash
kubectl get configmap coredns -n kube-system -o yaml
```

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
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```

**Key Plugins:**
| Plugin | Purpose |
|--------|---------|
| `kubernetes` | Handles cluster DNS queries |
| `forward` | Forwards external queries to upstream DNS |
| `cache` | Caches DNS responses |
| `health` | Health check endpoint |
| `prometheus` | Metrics endpoint |

### Pod DNS Configuration

```bash
# Check pod's DNS configuration
kubectl exec <pod-name> -- cat /etc/resolv.conf
```

**Output:**

```
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

- `nameserver`: CoreDNS service IP
- `search`: Domains to append for short names
- `ndots:5`: Number of dots before treating as FQDN

### Kubelet DNS Configuration

```bash
cat /var/lib/kubelet/config.yaml | grep -A2 clusterDNS
```

```yaml
clusterDNS:
  - 10.96.0.10
clusterDomain: cluster.local
```

---

## Common Commands

```bash
# View CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# View CoreDNS service
kubectl get svc -n kube-system kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# View CoreDNS ConfigMap
kubectl get configmap coredns -n kube-system -o yaml

# DNS lookup from a pod
kubectl exec <pod> -- nslookup <service-name>
kubectl exec <pod> -- nslookup <service-name>.<namespace>

# Test DNS resolution
kubectl run dnsutils --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 --rm -it -- nslookup kubernetes

# Check pod's resolv.conf
kubectl exec <pod> -- cat /etc/resolv.conf
```

---

## DNS Resolution Examples

### Same Namespace

```bash
# From a pod in 'default' namespace, accessing service in 'default'
curl http://web-service
curl http://web-service.default
curl http://web-service.default.svc.cluster.local
```

### Cross Namespace

```bash
# From 'default' namespace, accessing service in 'apps' namespace
curl http://web-service.apps
curl http://web-service.apps.svc.cluster.local
```

### Pod DNS (if enabled)

```bash
# Pod with IP 10.244.2.5 in 'default' namespace
nslookup 10-244-2-5.default.pod.cluster.local
```

---

## CKA Exam Tips

### How This Topic is Tested

1. **Troubleshoot DNS resolution issues**
2. **Query DNS records** from pods
3. **Understand FQDN format** for services
4. **Check CoreDNS configuration**

### Key Points to Remember

| Item                   | Value/Location             |
| ---------------------- | -------------------------- |
| CoreDNS namespace      | `kube-system`              |
| Service name           | `kube-dns`                 |
| Default cluster domain | `cluster.local`            |
| ConfigMap              | `coredns` in `kube-system` |
| DNS IP (typical)       | `10.96.0.10`               |

### DNS Name Resolution Quick Reference

```
Service: my-svc in namespace: my-ns

Short names (same namespace only):
  my-svc

Cross-namespace names:
  my-svc.my-ns
  my-svc.my-ns.svc
  my-svc.my-ns.svc.cluster.local  (FQDN)
```

### Troubleshooting Checklist

- [ ] CoreDNS pods running? `kubectl get pods -n kube-system -l k8s-app=kube-dns`
- [ ] kube-dns service exists? `kubectl get svc -n kube-system kube-dns`
- [ ] Pod has correct resolv.conf? `kubectl exec <pod> -- cat /etc/resolv.conf`
- [ ] Service exists? `kubectl get svc <service-name>`
- [ ] Can resolve externally? `kubectl exec <pod> -- nslookup google.com`

### Quick Debug Commands

```bash
# Full DNS test
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default

# Check if DNS is working
kubectl exec -it <pod> -- nslookup kubernetes
```

---

## Official Documentation

- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Customizing DNS Service](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
- [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [CoreDNS](https://coredns.io/manual/toc/)
