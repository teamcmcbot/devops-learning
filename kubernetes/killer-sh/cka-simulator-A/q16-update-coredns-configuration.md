# Question 16 | Update CoreDNS Configuration

**Solve this question on:** `ssh cka5774`

## Task

The CoreDNS configuration in the cluster needs to be updated:

1. Make a backup of the existing configuration YAML and store it at:
   - `/opt/course/16/coredns_backup.yaml`
   - You should be able to fast recover from the backup
2. Update the CoreDNS configuration in the cluster so that DNS resolution for:
   - `SERVICE.NAMESPACE.custom-domain`
   works exactly like and in addition to:
   - `SERVICE.NAMESPACE.cluster.local`
3. Test your configuration, for example from a Pod with image `busybox:1`

These commands should result in an IP address:

```bash
nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc.custom-domain
```

---

## Solution

SSH into the target node first:

```bash
ssh cka5774
```

### Step 1: Inspect CoreDNS and create a backup

Check the CoreDNS Deployment and Pods:

```bash
kubectl -n kube-system get deploy,pod
```

Example relevant output:

```text
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns               2/2     2            2           42h
```

Check the ConfigMap:

```bash
kubectl -n kube-system get cm coredns
```

Create the backup:

```bash
kubectl -n kube-system get cm coredns -o yaml > /opt/course/16/coredns_backup.yaml
```

---

### Step 2: Update the CoreDNS configuration

Edit the CoreDNS ConfigMap:

```bash
kubectl -n kube-system edit cm coredns
```

The current Corefile contains a line similar to:

```text
kubernetes cluster.local in-addr.arpa ip6.arpa {
```

Update it to include `custom-domain` in addition to `cluster.local`:

```text
kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {
```

So the relevant Corefile section becomes:

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30 {
           disable success cluster.local
           disable denial cluster.local
        }
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
```

---

### Step 3: Restart CoreDNS

Restart the Deployment so the updated ConfigMap is picked up:

```bash
kubectl -n kube-system rollout restart deploy coredns
```

Verify the new Pods come up successfully:

```bash
kubectl -n kube-system get pod
```

Example output:

```text
coredns-77d6976b98-jkvqn   1/1   Running   0   13s
coredns-77d6976b98-zdxw8   1/1   Running   0   13s
```

---

### Step 4: Test the new DNS resolution

Create a test Pod:

```bash
kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
```

Exec into it:

```bash
kubectl exec -it bb -- sh
```

Run the test lookups:

```bash
nslookup kubernetes.default.svc.custom-domain
nslookup kubernetes.default.svc.cluster.local
```

Expected output for both should include the same IP, for example:

```text
Server:         10.96.0.10
Address:        10.96.0.10:53

Name:   kubernetes.default.svc.custom-domain
Address: 10.96.0.1
```

```text
Server:         10.96.0.10
Address:        10.96.0.10:53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

Exit the Pod shell when done:

```bash
exit
```

---

### Step 5: Fast recovery from backup

If needed, compare the current ConfigMap with the backup:

```bash
kubectl diff -f /opt/course/16/coredns_backup.yaml
```

To restore from backup:

```bash
kubectl delete -f /opt/course/16/coredns_backup.yaml
kubectl apply -f /opt/course/16/coredns_backup.yaml
kubectl -n kube-system rollout restart deploy coredns
```

---

## Final Commands Summary

```bash
ssh cka5774

kubectl -n kube-system get cm coredns -o yaml > /opt/course/16/coredns_backup.yaml

kubectl -n kube-system edit cm coredns
kubectl -n kube-system rollout restart deploy coredns

kubectl run bb --image=busybox:1 -- sh -c 'sleep 1d'
kubectl exec -it bb -- sh

nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc.custom-domain
```