# Question 15 | Cluster Event Logging

**Solve this question on:** `ssh cka6016`

## Task

Write a kubectl command into:

```text
/opt/course/15/cluster_events.sh
```

which shows the latest events in the whole cluster, ordered by time (`metadata.creationTimestamp`).

Then:

1. Delete the `kube-proxy` Pod and write the events this caused into:
   ```text
   /opt/course/15/pod_kill.log
   ```

2. Manually kill the containerd container of the `kube-proxy` Pod and write the events into:
   ```text
   /opt/course/15/container_kill.log
   ```

---

## Solution

### Step 1: Connect and create the event command script

```bash
ssh cka6016
vim /opt/course/15/cluster_events.sh
```

Put this into the file:

```bash
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

You can test it:

```bash
sh /opt/course/15/cluster_events.sh
```

Example output:

```text
NAMESPACE     LAST SEEN   TYPE     REASON           OBJECT                       MESSAGE
...
default       19m         Normal   Pulled           pod/team-york-board-...      Successfully pulled image "httpd:2-alpine" ...
default       19m         Normal   Created          pod/team-york-board-...      Created container httpd
default       19m         Normal   Started          pod/team-york-board-...      Started container httpd
...
```

---

### Step 2: Delete the kube-proxy Pod and record the events

Find the kube-proxy Pod:

```bash
kubectl -n kube-system get pod -l k8s-app=kube-proxy -o wide
```

Example output:

```text
NAME               READY   ...   NODE
kube-proxy-lf2fs   1/1     ...   cka6016
```

Delete it:

```bash
kubectl -n kube-system delete pod kube-proxy-lf2fs
```

Expected output:

```text
pod "kube-proxy-lf2fs" deleted
```

Now check the events again:

```bash
sh /opt/course/15/cluster_events.sh
```

Write the relevant events into:

```text
/opt/course/15/pod_kill.log
```

Example content:

```text
kube-system   12s   Normal   Killing           pod/kube-proxy-lf2fs     Stopping container kube-proxy
kube-system   12s   Normal   SuccessfulCreate  daemonset/kube-proxy     Created pod: kube-proxy-wb4tb
kube-system   11s   Normal   Scheduled         pod/kube-proxy-wb4tb     Successfully assigned kube-system/kube-proxy-wb4tb to cka6016
kube-system   11s   Normal   Pulled            pod/kube-proxy-wb4tb     Container image "registry.k8s.io/kube-proxy:v1.33.1" already present on machine
kube-system   11s   Normal   Created           pod/kube-proxy-wb4tb     Created container kube-proxy
kube-system   11s   Normal   Started           pod/kube-proxy-wb4tb     Started container kube-proxy
default       10s   Normal   Starting          node/cka6016
```

---

### Step 3: Kill the kube-proxy container and record the events

This cluster has only one node, `cka6016`, and the kube-proxy Pod is running there, so continue on the same node.

Become root:

```bash
sudo -i
```

Find the kube-proxy container:

```bash
crictl ps | grep kube-proxy
```

Example output:

```text
2fd052f1fcf78   505d571f5fd56   57 seconds ago   Running   kube-proxy   0   3455856e0970c   kube-proxy-wb4tb
```

Kill the container manually:

```bash
crictl rm --force 2fd052f1fcf78
```

Example output:

```text
2fd052f1fcf78
2fd052f1fcf78
```

Check again:

```bash
crictl ps | grep kube-proxy
```

Example output:

```text
6bee4f36f8410   505d571f5fd56   5 seconds ago   Running   kube-proxy   0   3455856e0970c   kube-proxy-wb4tb
```

This shows Kubernetes recreated the container.

Now check cluster events again:

```bash
sh /opt/course/15/cluster_events.sh
```

Write the relevant events into:

```text
/opt/course/15/container_kill.log
```

Example content:

```text
kube-system   21s   Normal   Created   pod/kube-proxy-wb4tb   Created container kube-proxy
kube-system   21s   Normal   Started   pod/kube-proxy-wb4tb   Started container kube-proxy
default       90s   Normal   Starting  node/cka6016
default       20s   Normal   Starting  node/cka6016
```

---

## Notes

- Deleting the whole Pod causes more events because the DaemonSet recreates the Pod.
- Killing only the container causes fewer events because the Pod still exists and only the container is recreated.
- In this environment `crictl` is used for container runtime management.

---

## Final Commands Summary

```bash
ssh cka6016

vim /opt/course/15/cluster_events.sh
sh /opt/course/15/cluster_events.sh

kubectl -n kube-system get pod -l k8s-app=kube-proxy -o wide
kubectl -n kube-system delete pod kube-proxy-lf2fs
sh /opt/course/15/cluster_events.sh

sudo -i
crictl ps | grep kube-proxy
crictl rm --force <container-id>
crictl ps | grep kube-proxy

sh /opt/course/15/cluster_events.sh
```