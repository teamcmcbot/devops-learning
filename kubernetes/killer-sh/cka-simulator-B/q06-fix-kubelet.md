# Question 6 | Fix Kubelet

**Solve this question on:** `ssh cka1024`

## Task

There seems to be an issue with the kubelet on controlplane node `cka1024`, it is not running.

Fix the kubelet and confirm that the node is available in `Ready` state.

Create a Pod called `success` in Namespace `default` using image `nginx:1-alpine`.

> The node has no taints and can schedule Pods without additional tolerations.

---

## Solution

SSH into the target node first:

```bash
ssh cka1024
```

---

## Step 1: Confirm the problem

Trying to query the node shows the API server is not reachable:

```bash
kubectl get node
```

Example output:

```text
The connection to the server 192.168.100.41:6443 was refused - did you specify the right host or port?
```

Check whether kubelet is running:

```bash
sudo -i
ps aux | grep kubelet
```

Example output:

```text
root 12892 ... grep --color=auto kubelet
```

Only the `grep` process appears, so kubelet is not running.

Check the service status:

```bash
service kubelet status
```

Relevant output:

```text
Active: inactive (dead)
```

---

## Step 2: Try starting kubelet

Start the service:

```bash
service kubelet start
service kubelet status
```

Relevant output:

```text
Active: activating (auto-restart) (Result: exit-code)
Process: ... ExecStart=/usr/local/bin/kubelet ...
Main PID: ... (code=exited, status=203/EXEC)
```

This shows systemd is trying to execute:

```text
/usr/local/bin/kubelet
```

Test that path manually:

```bash
/usr/local/bin/kubelet
```

Expected output:

```text
-bash: /usr/local/bin/kubelet: No such file or directory
```

Check where kubelet actually exists:

```bash
whereis kubelet
```

Expected output:

```text
kubelet: /usr/bin/kubelet
```

So the kubelet service is using the wrong binary path.

---

## Step 3: Check logs

Inspect kubelet-related logs:

```bash
cat /var/log/syslog | grep kubelet
```

Relevant recent lines show:

```text
kubelet.service: Main process exited, code=exited, status=203/EXEC
kubelet.service: Failed with result 'exit-code'
```

This matches the wrong binary path problem.

---

## Step 4: Fix the kubelet service config

Edit the kubelet systemd drop-in file:

```bash
vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```

Update the final `ExecStart` line so it uses `/usr/bin/kubelet` instead of `/usr/local/bin/kubelet`.

Correct file:

```ini
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

---

## Step 5: Reload systemd and restart kubelet

```bash
systemctl daemon-reload
service kubelet restart
service kubelet status
```

Expected output:

```text
Active: active (running)
```

You can also confirm the process is now running:

```bash
ps aux | grep kubelet
```

Example output:

```text
/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf ...
```

---

## Step 6: Wait for control plane components and node readiness

It may take a short while for the control plane static Pods to come back.

You can watch container runtime processes:

```bash
watch crictl ps
```

Example components appearing:

```text
kube-controller-manager
kube-scheduler
kube-apiserver
etcd
```

Then confirm the node is Ready:

```bash
kubectl get node
```

Expected output:

```text
NAME      STATUS   ROLES           AGE   VERSION
cka1024   Ready    control-plane   ...   v1.33.1
```

---

## Step 7: Create the success Pod

```bash
kubectl run success --image=nginx:1-alpine
```

Verify:

```bash
kubectl get pod success -o wide
```

Expected output:

```text
NAME      READY   STATUS    ...   NODE
success   1/1     Running   ...   cka1024
```

---

## Final Commands Summary

```bash
ssh cka1024
sudo -i

ps aux | grep kubelet
service kubelet status

service kubelet start
service kubelet status

/usr/local/bin/kubelet
whereis kubelet

vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
service kubelet restart
service kubelet status

kubectl get node

kubectl run success --image=nginx:1-alpine
kubectl get pod success -o wide
```