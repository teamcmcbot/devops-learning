# Question 8 | Update Kubernetes Version and join cluster

**Solve this question on:** `ssh cka3962`

## Task

Your coworker notified you that node `cka3962-node1` is running an older Kubernetes version and is not even part of the cluster yet.

Do the following:

1. Update the node's Kubernetes version to the **exact same version** as the control plane
2. Add the node to the cluster using `kubeadm`

> You can connect to the worker node using `ssh cka3962-node1` from `cka3962`

---

## Solution

SSH into the control plane first and check its Kubernetes version:

```bash
ssh cka3962
kubectl get nodes
```

Example output:

```text
NAME      STATUS   ROLES           AGE   VERSION
cka3962   Ready    control-plane   ...   v1.35.2
```

So the control plane is running:

```text
v1.35.2
```

---

### Step 1: Check the worker node version

SSH into the worker node:

```bash
ssh cka3962-node1
sudo -i
```

Check the installed versions:

```bash
kubectl version --client
kubelet --version
kubeadm version
```

Example relevant output:

```text
kubectl: v1.34.5
kubelet: v1.34.5
kubeadm: v1.35.2
```

This means:

- `kubeadm` is already at the correct version
- `kubectl` and `kubelet` still need to be upgraded to `v1.35.2`

Because the node is **not yet joined to the cluster**, running:

```bash
kubeadm upgrade node
```

will fail, which is expected.

---

### Step 2: Upgrade `kubectl` and `kubelet`

Update package metadata:

```bash
apt update
```

Check available versions if needed:

```bash
apt show kubectl -a | grep 1.35
```

Install the exact required versions:

```bash
apt install -y kubectl=1.35.2-1.1 kubelet=1.35.2-1.1
```

Verify:

```bash
kubectl version --client
kubelet --version
```

Expected relevant output:

```text
Client Version: v1.35.2
Kubernetes v1.35.2
```

Restart kubelet:

```bash
service kubelet restart
service kubelet status
```

At this point kubelet may still fail or keep restarting because the node has not joined the cluster yet. That is normal.

---

### Step 3: Generate the join command on the control plane

Exit back to the control plane node:

```bash
exit
sudo -i
```

Generate a new join token and print the full join command:

```bash
kubeadm token create --print-join-command
```

Example output:

```bash
kubeadm join 192.168.100.31:6443 --token xpexct.yefojay1ejbq8akx --discovery-token-ca-cert-hash sha256:e2e45842688b5057af4e6431f04cc0d6aa3c0a1a11769a69fd28b6972b886e77
```

You can also list tokens if needed:

```bash
kubeadm token list
```

---

### Step 4: Join the worker node to the cluster

SSH back into the worker node:

```bash
ssh cka3962-node1
```

Run the join command printed earlier:

```bash
kubeadm join 192.168.100.31:6443 --token xpexct.yefojay1ejbq8akx --discovery-token-ca-cert-hash sha256:e2e45842688b5057af4e6431f04cc0d6aa3c0a1a11769a69fd28b6972b886e77
```

Example successful output:

```text
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

Check kubelet status:

```bash
service kubelet status
```

Expected:

```text
Active: active (running)
```

> If `kubeadm join` has problems because of prior failed attempts, run `kubeadm reset` first and retry.

---

### Step 5: Verify from the control plane

Go back to the control plane and check node status:

```bash
exit
kubectl get nodes
```

At first you may see:

```text
cka3962-node1   NotReady
```

Wait a short while and check again:

```bash
kubectl get nodes
```

Expected final output:

```text
NAME            STATUS   ROLES           AGE   VERSION
cka3962         Ready    control-plane   ...   v1.35.2
cka3962-node1   Ready    <none>          ...   v1.35.2
```

---

## Final Commands Summary

```bash
ssh cka3962
kubectl get nodes

ssh cka3962-node1
sudo -i
apt update
apt install -y kubectl=1.35.2-1.1 kubelet=1.35.2-1.1
service kubelet restart

exit
sudo -i
kubeadm token create --print-join-command

ssh cka3962-node1
kubeadm join 192.168.100.31:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

exit
kubectl get nodes
```