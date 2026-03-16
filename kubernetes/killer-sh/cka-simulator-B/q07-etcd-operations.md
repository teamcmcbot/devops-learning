# Question 7 | Etcd Operations

**Solve this question on:** `ssh cka2560`

## Task

You have been tasked to perform the following etcd operations:

1. Run `etcd --version` and store the output at:
   - `/opt/course/7/etcd-version`
2. Make a snapshot of etcd and save it at:
   - `/opt/course/7/etcd-snapshot.db`

---

## Solution

SSH into the target node first:

```bash
ssh cka2560
sudo -i
```

---

## Step 1: Store the etcd version

Trying to run `etcd --version` directly on the node shows that `etcd` is not installed as a host binary:

```bash
etcd --version
```

Example output:

```text
Command 'etcd' not found, but can be installed with:
apt install etcd-server
```

In this cluster, etcd runs as a Pod, so execute the command inside the etcd Pod.

Check the etcd Pod:

```bash
kubectl -n kube-system get pod
```

Example relevant output:

```text
etcd-cka2560   1/1   Running   0   13m
```

Run the version command inside the Pod:

```bash
kubectl -n kube-system exec etcd-cka2560 -- etcd --version
```

Example output:

```text
etcd Version: 3.6.4
Git SHA: 5400cdc
Go Version: go1.23.11
Go OS/Arch: linux/amd64
```

Store it in the required file:

```bash
kubectl -n kube-system exec etcd-cka2560 -- etcd --version > /opt/course/7/etcd-version
```

---

## Step 2: Create the etcd snapshot

A first attempt without authentication will fail or hang:

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db
```

This is because etcd requires TLS authentication.

To get the required certificate and endpoint details, inspect the etcd static Pod manifest:

```bash
vim /etc/kubernetes/manifests/etcd.yaml
```

Relevant values from the manifest:

```yaml
- --cert-file=/etc/kubernetes/pki/etcd/server.crt
- --key-file=/etc/kubernetes/pki/etcd/server.key
- --listen-client-urls=https://127.0.0.1:2379,https://192.168.100.31:2379
- --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

You can also confirm the API server’s etcd client settings:

```bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd
```

Example relevant output:

```text
- --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
- --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
- --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
- --etcd-servers=https://127.0.0.1:2379
```

Now create the snapshot using TLS certificates:

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db \
  --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --cert /etc/kubernetes/pki/etcd/server.crt \
  --key /etc/kubernetes/pki/etcd/server.key
```

Expected output:

```text
{"level":"info","ts":"2025-03-02T13:35:48.806437Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/opt/course/7/etcd-snapshot.db.part"}
{"level":"info","ts":"2025-03-02T13:35:48.929550Z","logger":"client","caller":"v3@v3.5.16/maintenance.go:212","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2025-03-02T13:35:48.929975Z","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":"2025-03-02T13:35:49.110620Z","logger":"client","caller":"v3@v3.5.16/maintenance.go:220","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2025-03-02T13:35:49.155626Z","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"2.4 MB","took":"now"}
{"level":"info","ts":"2025-03-02T13:35:49.155886Z","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/opt/course/7/etcd-snapshot.db"}

Snapshot saved at /opt/course/7/etcd-snapshot.db
```

---

## Final Commands Summary

```bash
ssh cka2560
sudo -i

kubectl -n kube-system get pod
kubectl -n kube-system exec etcd-cka2560 -- etcd --version > /opt/course/7/etcd-version

ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db \
  --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --cert /etc/kubernetes/pki/etcd/server.crt \
  --key /etc/kubernetes/pki/etcd/server.key
```