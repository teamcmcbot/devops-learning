# Question 8 | Get Controlplane Information

**Solve this question on:** `ssh cka8448`

## Task

Check how the controlplane components `kubelet`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` and `etcd` are started/installed on the controlplane node.

Also find out the name of the DNS application and how it's started/installed in the cluster.

Write your findings into:

`/opt/course/8/controlplane-components.txt`

The file should be structured like:

```text
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]
```

Choices of `[TYPE]` are:

- `not-installed`
- `process`
- `static-pod`
- `pod`

---

## Solution

SSH into the target node first:

```bash
ssh cka8448
sudo -i
```

### Step 1: Check kubelet

Look for kubelet as a running process:

```bash
ps aux | grep kubelet
```

Check systemd units related to kubelet:

```bash
find /usr/lib/systemd | grep kube
```

Example relevant output:

```text
/usr/lib/systemd/system/kubelet.service
/usr/lib/systemd/system/kubelet.service.d
/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```

Check service status:

```bash
service kubelet status
```

Example relevant output:

```text
Active: active (running)
Main PID: 7355 (kubelet)
```

This shows:

```text
kubelet: process
```

---

### Step 2: Check kube-apiserver, kube-scheduler, kube-controller-manager and etcd

Check for systemd services related to etcd:

```bash
find /usr/lib/systemd | grep etcd
```

No relevant service is found.

Now inspect the static pod manifest directory:

```bash
find /etc/kubernetes/manifests/
```

Expected output:

```text
/etc/kubernetes/manifests/
/etc/kubernetes/manifests/kube-controller-manager.yaml
/etc/kubernetes/manifests/etcd.yaml
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/manifests/kube-scheduler.yaml
```

This shows these components are started as **static Pods** by kubelet:

```text
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
```

You can also confirm by checking Pods in `kube-system`:

```bash
kubectl -n kube-system get pod -o wide
```

Example relevant output:

```text
etcd-cka8448
kube-apiserver-cka8448
kube-controller-manager-cka8448
kube-scheduler-cka8448
```

---

### Step 3: Identify the DNS application

Check DaemonSets:

```bash
kubectl -n kube-system get ds
```

Example output:

```text
NAME         DESIRED   ...
kube-proxy   1         ...
weave-net    1         ...
```

Check Deployments:

```bash
kubectl -n kube-system get deploy
```

Example output:

```text
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   2/2     2            2           68m
```

This shows the DNS application is:

```text
dns: pod coredns
```

Because CoreDNS is running as Pods managed by a Deployment.

---

### Step 4: Write the result into the required file

Create the output file:

```bash
cat <<EOF > /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF
```

---

## Final Commands Summary

```bash
ssh cka8448
sudo -i

ps aux | grep kubelet
find /usr/lib/systemd | grep kube
service kubelet status

find /usr/lib/systemd | grep etcd
find /etc/kubernetes/manifests/

kubectl -n kube-system get pod -o wide
kubectl -n kube-system get ds
kubectl -n kube-system get deploy

cat <<EOF > /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF
```