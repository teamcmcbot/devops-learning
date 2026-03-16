# Question 14 | Find out Cluster Information

**Solve this question on:** `ssh cka8448`

## Task

Find out the following information about the cluster:

1. How many controlplane nodes are available?
2. How many worker nodes (non-controlplane nodes) are available?
3. What is the Service CIDR?
4. Which Networking (or CNI Plugin) is configured and where is its config file?
5. Which suffix will static Pods have that run on `cka8448`?

Write your answers into:

```text
/opt/course/14/cluster-info
```

Structured like this:

```text
1: [ANSWER]
2: [ANSWER]
3: [ANSWER]
4: [ANSWER]
5: [ANSWER]
```

---

## Solution

SSH into the node first:

```bash
ssh cka8448
```

### Step 1: Find controlplane and worker node count

```bash
kubectl get node
```

Example output:

```text
NAME      STATUS   ROLES           AGE   VERSION
cka8448   Ready    control-plane   71m   v1.33.1
```

This shows:

- controlplane nodes: `1`
- worker nodes: `0`

---

### Step 2: Find the Service CIDR

Become root:

```bash
sudo -i
```

Inspect the kube-apiserver static Pod manifest:

```bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
```

Expected relevant output:

```text
- --service-cluster-ip-range=10.96.0.0/12
```

So the Service CIDR is:

```text
10.96.0.0/12
```

---

### Step 3: Find the Networking / CNI plugin and config file

Check running Pods in `kube-system`:

```bash
kubectl -n kube-system get pod
```

Example relevant output:

```text
coredns-6f8b9d9f4b-8z7rb
coredns-6f8b9d9f4b-fg7bt
etcd-cka8448
kube-apiserver-cka8448
kube-controller-manager-cka8448
kube-proxy-dvv7m
kube-scheduler-cka8448
weave-net-gjrxh
```

This indicates the CNI plugin is:

```text
weave
```

Check the CNI config directory:

```bash
ls /etc/cni/net.d/
```

Expected relevant output:

```text
10-weave.conflist
```

So the CNI config file is:

```text
/etc/cni/net.d/10-weave.conflist
```

---

### Step 4: Find the suffix of static Pods on cka8448

Static Pods created from the controlplane manifests are shown with the node name appended.

Check them:

```bash
kubectl -n kube-system get pod
```

Example relevant output:

```text
etcd-cka8448
kube-apiserver-cka8448
kube-controller-manager-cka8448
kube-scheduler-cka8448
```

This shows the suffix is:

```text
-cka8448
```

---

### Step 5: Write the answers into the file

Create the required file:

```bash
cat <<EOF > /opt/course/14/cluster-info
1: 1
2: 0
3: 10.96.0.0/12
4: weave /etc/cni/net.d/10-weave.conflist
5: -cka8448
EOF
```

---

## Final Commands Summary

```bash
ssh cka8448

kubectl get node

sudo -i
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range

kubectl -n kube-system get pod
ls /etc/cni/net.d/

cat <<EOF > /opt/course/14/cluster-info
1: 1
2: 0
3: 10.96.0.0/12
4: weave /etc/cni/net.d/10-weave.conflist
5: -cka8448
EOF
```

---

## Note

The question text is visible in the page, but the killer.sh answer is cut off in the attached content after the beginning of Step 2.  
The solution above follows the visible question and the standard investigation steps for this cluster setup.