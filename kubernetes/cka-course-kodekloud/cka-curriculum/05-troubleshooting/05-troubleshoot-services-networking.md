# Troubleshoot Services and Networking

## Exam Weight
Part of **30% - Troubleshooting**

## What Can Be Tested

- Debug Service connectivity issues
- Troubleshoot DNS resolution problems
- Fix Network Policy blocking traffic
- Diagnose ClusterIP/NodePort/LoadBalancer issues
- Troubleshoot Ingress routing
- Fix CNI plugin problems
- Debug pod-to-pod communication
- Resolve kube-proxy issues

## Sample Questions

1. **Service not routing traffic to pods - diagnose and fix**
2. **Pods can't resolve service names via DNS**
3. **Network Policy blocking legitimate traffic**
4. **NodePort service not accessible from outside**
5. **Ingress not routing to correct backend service**

## Official Documentation

- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Troubleshooting Networking](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)
- [Debug DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

## Key Concepts

### Networking Architecture

```
External Traffic
      │
      ▼
┌──────────────┐
│   Ingress    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Service    │  (ClusterIP/NodePort/LoadBalancer)
│  (kube-proxy)│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Pods     │
│  (via CNI)   │
└──────────────┘
       │
       ▼
┌──────────────┐
│  CoreDNS     │
└──────────────┘
```

### Components Involved

| Component | Role | Common Issues |
|-----------|------|---------------|
| **Service** | Load balancing to pods | Wrong selector, no endpoints |
| **kube-proxy** | Implements Service routing | Not running, wrong mode |
| **CoreDNS** | DNS resolution | Pod not running, wrong config |
| **CNI Plugin** | Pod networking | Not installed, misconfigured |
| **NetworkPolicy** | Traffic filtering | Too restrictive rules |
| **Ingress** | HTTP/HTTPS routing | Wrong rules, controller issues |

## Troubleshoot Services

### Check Service Configuration

```bash
# List services
kubectl get svc
kubectl get services --all-namespaces

# Describe service
kubectl describe svc <service-name>

# Check service YAML
kubectl get svc <service-name> -o yaml

# Key things to check:
# 1. Selector matches pod labels
# 2. Port and targetPort are correct
# 3. Service has endpoints
# 4. ClusterIP is allocated
```

### Verify Service Endpoints

```bash
# Check endpoints
kubectl get endpoints <service-name>
kubectl get ep <service-name>

# Describe endpoints
kubectl describe ep <service-name>

# If no endpoints, service selector doesn't match any pods
# Check pod labels
kubectl get pods --show-labels

# Check service selector
kubectl get svc <service-name> -o jsonpath='{.spec.selector}'

# Find pods matching selector
kubectl get pods -l <key>=<value>
```

### Test Service Connectivity

```bash
# Create test pod
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600

# Test service by name (DNS)
kubectl exec test-pod -- nslookup <service-name>
kubectl exec test-pod -- wget -O- <service-name>:<port>

# Test service by ClusterIP
kubectl exec test-pod -- wget -O- <cluster-ip>:<port>

# Test from specific namespace
kubectl exec test-pod -- wget -O- <service-name>.<namespace>.svc.cluster.local

# Test NodePort from outside
curl http://<node-ip>:<nodeport>

# Clean up
kubectl delete pod test-pod
```

### Common Service Issues

#### Issue 1: Service Has No Endpoints

```bash
# Check endpoints
kubectl get ep <service-name>

# If ENDPOINTS column is empty/none:

# 1. Check service selector
kubectl get svc <service-name> -o jsonpath='{.spec.selector}'

# 2. Check pod labels
kubectl get pods --show-labels

# 3. Ensure pods are ready
kubectl get pods

# Fix: Update service selector or pod labels
kubectl label pod <pod-name> <key>=<value>

# Or edit service
kubectl edit svc <service-name>
# Update selector to match pod labels

# Verify endpoints created
kubectl get ep <service-name>
```

#### Issue 2: Wrong Port Configuration

```bash
# Service not accessible

# Check service ports
kubectl get svc <service-name>

# Verify:
# - port: The port service listens on
# - targetPort: The port on the pod
# - nodePort: External port (for NodePort services)

# Check pod's container port
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].ports[*].containerPort}'

# Test connectivity on pod directly
kubectl exec test-pod -- wget -O- <pod-ip>:<container-port>

# Fix: Update service targetPort
kubectl edit svc <service-name>
# Change targetPort to match container port
```

#### Issue 3: NodePort Not Accessible

```bash
# Can't access service via NodePort

# 1. Verify NodePort assigned
kubectl get svc <service-name>
# Should show type=NodePort and port like 30080

# 2. Check node IP
kubectl get nodes -o wide

# 3. Test from outside cluster
curl http://<node-ip>:<nodeport>

# 4. Check firewall
ssh <node>
sudo ufw status
sudo iptables -L -n | grep <nodeport>

# 5. Verify kube-proxy is running
kubectl get pods -n kube-system | grep kube-proxy

# 6. Check kube-proxy logs
kubectl logs -n kube-system kube-proxy-<id>

# Fix: Open firewall port
sudo ufw allow <nodeport>/tcp
```

## Troubleshoot DNS

### Test DNS Resolution

```bash
# Create test pod
kubectl run test-dns --image=busybox --restart=Never -- sleep 3600

# Test basic DNS
kubectl exec test-dns -- nslookup kubernetes.default

# Expected output:
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
# Name:      kubernetes.default
# Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local

# Test service DNS
kubectl exec test-dns -- nslookup <service-name>

# Test FQDN
kubectl exec test-dns -- nslookup <service-name>.<namespace>.svc.cluster.local

# Test external DNS
kubectl exec test-dns -- nslookup google.com

# Clean up
kubectl delete pod test-dns
```

### Check CoreDNS

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS deployment
kubectl get deployment -n kube-system coredns

# Describe CoreDNS pods
kubectl describe pod -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check CoreDNS service
kubectl get svc -n kube-system kube-dns
kubectl describe svc -n kube-system kube-dns

# Check CoreDNS ConfigMap
kubectl get configmap -n kube-system coredns -o yaml
```

### Common DNS Issues

#### Issue 1: CoreDNS Pods Not Running

```bash
# Check CoreDNS status
kubectl get pods -n kube-system | grep coredns

# If pods are pending/failed:

# Check events
kubectl describe pod -n kube-system -l k8s-app=kube-dns | grep -A 10 Events

# Check node resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# Scale up if needed
kubectl scale deployment -n kube-system coredns --replicas=2

# Restart CoreDNS
kubectl rollout restart deployment -n kube-system coredns
```

#### Issue 2: DNS Resolution Fails

```bash
# Create debug pod
kubectl run test-dns --image=busybox --restart=Never -- sleep 3600

# Check if pod can reach CoreDNS
kubectl exec test-dns -- nslookup kubernetes.default

# If fails, check DNS configuration in pod
kubectl exec test-dns -- cat /etc/resolv.conf

# Should show:
# nameserver 10.96.0.10  (CoreDNS service ClusterIP)
# search default.svc.cluster.local svc.cluster.local cluster.local
# options ndots:5

# If wrong, check kubelet DNS settings
ssh <node>
ps aux | grep kubelet | grep cluster-dns

# Should show: --cluster-dns=10.96.0.10

# Verify CoreDNS service ClusterIP
kubectl get svc -n kube-system kube-dns
# ClusterIP should match --cluster-dns value

# Test connectivity to CoreDNS
kubectl exec test-dns -- wget -O- 10.96.0.10:53
```

#### Issue 3: Slow DNS Resolution

```bash
# Check CoreDNS logs for errors
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check CoreDNS resource usage
kubectl top pods -n kube-system | grep coredns

# Check CoreDNS endpoints
kubectl get ep -n kube-system kube-dns

# Scale CoreDNS if needed
kubectl scale deployment -n kube-system coredns --replicas=3

# Check CoreDNS ConfigMap for issues
kubectl get configmap -n kube-system coredns -o yaml
```

## Troubleshoot Pod Networking

### Test Pod-to-Pod Communication

```bash
# Create two test pods
kubectl run pod1 --image=nginx
kubectl run pod2 --image=busybox --restart=Never -- sleep 3600

# Get pod IPs
kubectl get pods -o wide

# Test connectivity from pod2 to pod1
kubectl exec pod2 -- wget -O- <pod1-ip>

# If fails, check:
# 1. CNI plugin installed
# 2. NetworkPolicy not blocking
# 3. Node network connectivity

# Clean up
kubectl delete pod pod1 pod2
```

### Check CNI Plugin

```bash
# Check CNI configuration on node
ssh <node>
ls -la /etc/cni/net.d/
cat /etc/cni/net.d/*.conf*

# Check CNI binaries
ls -la /opt/cni/bin/

# Check CNI pods
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# Check CNI pod logs
kubectl logs -n kube-system <cni-pod-name>

# For Calico
kubectl logs -n kube-system -l k8s-app=calico-node -c calico-node

# Verify IP allocation
kubectl get pods -o wide
# All pods should have IPs from pod CIDR range
```

### Common Pod Networking Issues

#### Issue 1: Pods Stuck in ContainerCreating

```bash
# Check pod status
kubectl describe pod <pod-name>

# Look for network errors:
# "network plugin is not ready: cni config uninitialized"
# "failed to find plugin"

# Check CNI plugin installed
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# If not installed, install CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verify on node
ssh <node>
ls /etc/cni/net.d/
ls /opt/cni/bin/
```

#### Issue 2: Pods Can't Communicate

```bash
# Test pod-to-pod connectivity
kubectl run test1 --image=nginx
kubectl run test2 --image=busybox --restart=Never -- sleep 3600

kubectl get pods -o wide

kubectl exec test2 -- wget -O- <test1-ip>

# If fails:

# 1. Check NetworkPolicy
kubectl get networkpolicy

# 2. Check CNI logs
kubectl logs -n kube-system <cni-pod>

# 3. Check node firewall
ssh <node>
sudo iptables -L -n

# 4. Check routes
ip route

# 5. Verify CNI is working
kubectl get pods -o wide
# IPs should be from pod network CIDR
```

## Troubleshoot Network Policies

### Check Network Policies

```bash
# List Network Policies
kubectl get networkpolicy
kubectl get netpol

# Describe Network Policy
kubectl describe networkpolicy <policy-name>

# Get NetworkPolicy YAML
kubectl get netpol <policy-name> -o yaml

# Check which pods are affected
kubectl get netpol <policy-name> -o jsonpath='{.spec.podSelector}'
```

### Test Network Policy

```bash
# Create test pods
kubectl run source --image=busybox --labels=app=client --restart=Never -- sleep 3600
kubectl run target --image=nginx --labels=app=server

# Get target pod IP
TARGET_IP=$(kubectl get pod target -o jsonpath='{.status.podIP}')

# Test connectivity (should work without NetworkPolicy)
kubectl exec source -- wget -O- $TARGET_IP

# Apply NetworkPolicy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-policy
spec:
  podSelector:
    matchLabels:
      app: server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: allowed
EOF

# Test connectivity (should fail now)
kubectl exec source -- wget -O- --timeout=5 $TARGET_IP

# Add required label to source pod
kubectl label pod source app=allowed

# Test connectivity (should work now)
kubectl exec source -- wget -O- $TARGET_IP

# Clean up
kubectl delete pod source target
kubectl delete netpol test-policy
```

### Common NetworkPolicy Issues

#### Issue 1: NetworkPolicy Blocking Traffic

```bash
# Traffic unexpectedly blocked

# 1. List NetworkPolicies in namespace
kubectl get netpol

# 2. Check which pods are selected
kubectl describe netpol <policy-name>

# 3. Verify pod labels match
kubectl get pods --show-labels

# 4. Check ingress/egress rules
kubectl get netpol <policy-name> -o yaml

# 5. Temporarily delete NetworkPolicy to test
kubectl delete netpol <policy-name>

# Test connectivity
kubectl exec <source-pod> -- wget -O- <target-ip>

# If works without NetworkPolicy, update policy rules
kubectl apply -f updated-netpol.yaml
```

#### Issue 2: NetworkPolicy Not Working

```bash
# Traffic not being blocked as expected

# 1. Verify CNI supports NetworkPolicy
# Calico, Weave, Cilium support it
# Flannel does NOT support NetworkPolicy

# Check CNI
kubectl get pods -n kube-system

# 2. Verify NetworkPolicy is applied
kubectl get netpol <policy-name>

# 3. Check pod selector
kubectl get netpol <policy-name> -o jsonpath='{.spec.podSelector}'

# 4. Verify labels on target pods
kubectl get pods --show-labels | grep <pod-name>

# 5. Check policyTypes
kubectl get netpol <policy-name> -o jsonpath='{.spec.policyTypes}'
# Should include Ingress and/or Egress
```

## Troubleshoot kube-proxy

### Check kube-proxy

```bash
# Check kube-proxy pods
kubectl get pods -n kube-system | grep kube-proxy

# Check kube-proxy DaemonSet
kubectl get daemonset -n kube-system kube-proxy

# Describe kube-proxy pod
kubectl describe pod -n kube-system <kube-proxy-pod>

# Check kube-proxy logs
kubectl logs -n kube-system <kube-proxy-pod>

# Check kube-proxy mode
kubectl logs -n kube-system <kube-proxy-pod> | grep "Using"
# Should show: "Using iptables Proxier" or "Using ipvs Proxier"

# Check kube-proxy ConfigMap
kubectl get configmap -n kube-system kube-proxy -o yaml
```

### Common kube-proxy Issues

#### Issue 1: kube-proxy Not Running

```bash
# Check kube-proxy DaemonSet
kubectl get ds -n kube-system kube-proxy

# Should have pods on all nodes

# Check pods
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# Check logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Restart kube-proxy
kubectl rollout restart daemonset -n kube-system kube-proxy

# Verify
kubectl get pods -n kube-system | grep kube-proxy
```

#### Issue 2: iptables Rules Missing

```bash
# On node, check iptables
ssh <node>
sudo iptables -t nat -L -n | grep <service-name>

# Should see KUBE-SVC-* chains

# If missing, check kube-proxy
kubectl logs -n kube-system <kube-proxy-pod> | grep -i error

# Restart kube-proxy
kubectl delete pod -n kube-system <kube-proxy-pod>

# Verify new pod creates rules
kubectl get pods -n kube-system | grep kube-proxy
```

## Troubleshoot Ingress

### Check Ingress

```bash
# List Ingress resources
kubectl get ingress
kubectl get ing

# Describe Ingress
kubectl describe ingress <ingress-name>

# Check Ingress YAML
kubectl get ingress <ingress-name> -o yaml

# Verify:
# 1. Rules are correct
# 2. Backend service exists
# 3. Service has endpoints
# 4. Ingress controller is running
```

### Check Ingress Controller

```bash
# Check Ingress controller pods (common controllers)
kubectl get pods -n ingress-nginx
kubectl get pods -n kube-system | grep ingress

# Check controller logs
kubectl logs -n ingress-nginx <controller-pod>

# Check controller service
kubectl get svc -n ingress-nginx

# Verify controller is watching Ingress resources
kubectl logs -n ingress-nginx <controller-pod> | grep -i ingress
```

### Common Ingress Issues

#### Issue 1: Ingress Not Routing

```bash
# Check Ingress exists
kubectl get ingress <ingress-name>

# Check Address is assigned
kubectl get ingress <ingress-name> -o wide

# Check backend service
kubectl get svc <backend-service>

# Check service endpoints
kubectl get ep <backend-service>

# Test backend service directly
kubectl run test --image=busybox --restart=Never -- sleep 3600
kubectl exec test -- wget -O- <service-name>

# Check Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

#### Issue 2: Wrong Backend

```bash
# Check Ingress rules
kubectl get ingress <ingress-name> -o yaml

# Verify:
# - host matches request
# - path matches request
# - serviceName is correct
# - servicePort matches service

# Update Ingress if needed
kubectl edit ingress <ingress-name>

# Test with curl
curl -H "Host: example.com" http://<ingress-ip>/path
```

## Debugging Workflow

### Complete Troubleshooting Steps

```bash
# 1. Check Service
kubectl get svc <service-name>
kubectl describe svc <service-name>
kubectl get ep <service-name>

# 2. Check Pods
kubectl get pods -l <selector>
kubectl describe pod <pod-name>

# 3. Test Pod Directly
kubectl exec test-pod -- wget -O- <pod-ip>:<port>

# 4. Test Service
kubectl exec test-pod -- wget -O- <service-name>:<port>

# 5. Test DNS
kubectl exec test-pod -- nslookup <service-name>

# 6. Check CoreDNS
kubectl get pods -n kube-system | grep coredns
kubectl logs -n kube-system -l k8s-app=kube-dns

# 7. Check kube-proxy
kubectl get pods -n kube-system | grep kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-proxy

# 8. Check CNI
kubectl get pods -n kube-system | grep -E "calico|flannel|weave"

# 9. Check NetworkPolicy
kubectl get netpol

# 10. Check node networking
ssh <node>
ping <other-node-ip>
sudo iptables -L -t nat | grep <service>
```

## Key Files and Locations

| Location | Purpose |
|----------|---------|
| `/etc/cni/net.d/` | CNI configuration |
| `/opt/cni/bin/` | CNI binaries |
| `/run/xtables.lock` | iptables lock file |
| `/etc/resolv.conf` | DNS configuration (in pods) |

## Exam Tips

1. **Start with service endpoints** - No endpoints = wrong selector
2. **Test with busybox pod** - wget and nslookup are essential
3. **Check labels match** - Service selector vs pod labels
4. **Verify DNS first** - nslookup kubernetes.default
5. **CoreDNS must be running** - Check kube-system namespace
6. **CNI required** - Pods won't start without it
7. **NetworkPolicy needs compatible CNI** - Flannel doesn't support it
8. **Test pod directly** - Bypass service to isolate issue
9. **kube-proxy creates iptables rules** - Check logs if service broken
10. **Time management** - Follow systematic debugging workflow

## Common Mistakes

- ❌ Not checking service endpoints
- ❌ Wrong service selector labels
- ❌ Testing wrong service port
- ❌ Forgetting CoreDNS needs to be running
- ❌ Not testing pod-to-pod directly
- ❌ Assuming CNI is installed
- ❌ NetworkPolicy blocking without realizing
- ❌ Not checking kube-proxy logs
- ❌ Wrong targetPort in service
- ❌ Testing from wrong namespace

## Quick Reference

### Service Debugging

```bash
# Check service and endpoints
kubectl get svc <svc>
kubectl get ep <svc>

# Test service
kubectl run test --image=busybox --restart=Never -- sleep 3600
kubectl exec test -- wget -O- <svc-name>

# Fix: Update selector
kubectl edit svc <svc>
```

### DNS Debugging

```bash
# Test DNS
kubectl exec test -- nslookup kubernetes.default
kubectl exec test -- nslookup <svc>

# Check CoreDNS
kubectl get pods -n kube-system | grep coredns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### NetworkPolicy Debugging

```bash
# List policies
kubectl get netpol

# Check which pods selected
kubectl describe netpol <policy>

# Temporarily remove to test
kubectl delete netpol <policy>
```

### Quick Test Script

```bash
# Complete connectivity test
kubectl run test --image=busybox --restart=Never -- sleep 3600
kubectl exec test -- nslookup kubernetes.default
kubectl exec test -- wget -O- <service-name>
kubectl exec test -- wget -O- <pod-ip>
kubectl delete pod test
```
