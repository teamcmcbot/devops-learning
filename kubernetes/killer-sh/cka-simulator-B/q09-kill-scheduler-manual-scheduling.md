# Question 9 | Kill Scheduler, Manual Scheduling

**Solve this question on:** `ssh cka5248`

## Task

Temporarily stop the kube-scheduler, in a way that you can start it again afterwards.

Create a single Pod named `manual-schedule` of image `httpd:2-alpine`, confirm it is created but not scheduled on any node.

Now manually schedule that Pod onto node `cka5248`. Make sure it is running.

Start the kube-scheduler again and confirm it is running correctly by creating a second Pod named `manual-schedule2` of image `httpd:2-alpine` and checking if it runs on `cka5248-node1`.

---

## Solution

### Step 1: Connect and identify the control plane

```bash
ssh cka5248
kubectl get node
```

Example output:

```text
NAME            STATUS   ROLES           AGE     VERSION
cka5248         Ready    control-plane   6d22h   v1.33.1
cka5248-node1   Ready    <none>          6d22h   v1.33.1
```

The control plane node is:

```text
cka5248
```

Become root and confirm the scheduler Pod is running:

```bash
sudo -i
kubectl -n kube-system get pod | grep schedule
```

Example output:

```text
kube-scheduler-cka5248   1/1   Running   0   6d22h
```

---

### Step 2: Stop the kube-scheduler temporarily

Because kube-scheduler is a static Pod, temporarily stop it by moving its manifest out of the manifests directory:

```bash
cd /etc/kubernetes/manifests/
mv kube-scheduler.yaml ..
```

Wait for it to stop. You can monitor with:

```bash
watch crictl ps
```

Then verify it is gone:

```bash
kubectl -n kube-system get pod | grep schedule
```

Expected result: no output.

---

### Step 3: Create the Pod and confirm it is Pending

```bash
kubectl run manual-schedule --image=httpd:2-alpine
kubectl get pod manual-schedule -o wide
```

Expected output:

```text
NAME              READY   STATUS    RESTARTS   AGE   IP       NODE
manual-schedule   0/1     Pending   0          14s   <none>   <none>
```

This confirms it was created but not scheduled to any node because the scheduler is down.

---

### Step 4: Manually schedule the Pod onto cka5248

Export the Pod YAML:

```bash
kubectl get pod manual-schedule -o yaml > 9.yaml
```

Edit the file and add:

```yaml
spec:
  nodeName: cka5248
```

Example relevant section:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-schedule
  namespace: default
spec:
  nodeName: cka5248
  containers:
    - image: httpd:2-alpine
      imagePullPolicy: IfNotPresent
      name: manual-schedule
```

Because the Pod already exists, replace it:

```bash
kubectl replace --force -f 9.yaml
```

Verify it is now running on `cka5248`:

```bash
kubectl get pod manual-schedule -o wide
```

Expected output:

```text
NAME              READY   STATUS    ...   NODE
manual-schedule   1/1     Running   ...   cka5248
```

---

### Step 5: Start the kube-scheduler again

Move the manifest back:

```bash
cd /etc/kubernetes/manifests/
mv ../kube-scheduler.yaml .
```

Verify the scheduler Pod comes back:

```bash
kubectl -n kube-system get pod | grep schedule
```

Expected output:

```text
kube-scheduler-cka5248   1/1   Running   0   13s
```

---

### Step 6: Confirm the scheduler works again

Create the second Pod:

```bash
kubectl run manual-schedule2 --image=httpd:2-alpine
kubectl get pod -o wide | grep schedule
```

Expected output:

```text
manual-schedule    1/1   Running   0   95s   10.32.0.2   cka5248
manual-schedule2   1/1   Running   0   9s    10.44.0.3   cka5248-node1
```

This confirms the scheduler is working again and scheduled `manual-schedule2` onto `cka5248-node1`.

---

## Final Commands Summary

```bash
ssh cka5248
kubectl get node

sudo -i
kubectl -n kube-system get pod | grep schedule

cd /etc/kubernetes/manifests/
mv kube-scheduler.yaml ..

kubectl run manual-schedule --image=httpd:2-alpine
kubectl get pod manual-schedule -o wide

kubectl get pod manual-schedule -o yaml > 9.yaml
vim 9.yaml
kubectl replace --force -f 9.yaml

kubectl get pod manual-schedule -o wide

cd /etc/kubernetes/manifests/
mv ../kube-scheduler.yaml .

kubectl -n kube-system get pod | grep schedule

kubectl run manual-schedule2 --image=httpd:2-alpine
kubectl get pod -o wide | grep schedule
```