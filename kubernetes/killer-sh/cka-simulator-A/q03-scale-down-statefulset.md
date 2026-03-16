# Question 3 | Scale down StatefulSet

**Solve this question on:** `ssh cka3962`

## Task

There are two Pods named `o3db-*` in Namespace `project-h800`.

The Project H800 management asked you to scale these down to one replica to save resources.

---

## Solution

SSH into the target node first:

```bash
ssh cka3962
```

Check the Pods:

```bash
kubectl -n project-h800 get pods | grep o3db
```

Example output:

```text
o3db-0   1/1   Running   0   6d19h
o3db-1   1/1   Running   0   6d19h
```

From the Pod names, these appear to be managed by a StatefulSet.

To confirm:

```bash
kubectl -n project-h800 get deploy,ds,sts | grep o3db
```

Example output:

```text
statefulset.apps/o3db   2/2   6d19h
```

You can also confirm from Pod labels:

```bash
kubectl -n project-h800 get pods --show-labels | grep o3db
```

Example output:

```text
o3db-0   1/1   Running   0   6d19h   app=nginx,apps.kubernetes.io/pod-index=0,controller-revision-hash=o3db-5fbd4bb9cc,statefulset.kubernetes.io/pod-name=o3db-0
o3db-1   1/1   Running   0   6d19h   app=nginx,apps.kubernetes.io/pod-index=1,controller-revision-hash=o3db-5fbd4bb9cc,statefulset.kubernetes.io/pod-name=o3db-1
```

Scale the StatefulSet down to 1 replica:

```bash
kubectl -n project-h800 scale statefulset o3db --replicas=1
```

Verify:

```bash
kubectl -n project-h800 get statefulset o3db
```

Expected output:

```text
NAME   READY   AGE
o3db   1/1     6d19h
```

---

## Final Commands Summary

```bash
ssh cka3962

kubectl -n project-h800 get pods | grep o3db
kubectl -n project-h800 get deploy,ds,sts | grep o3db

kubectl -n project-h800 scale statefulset o3db --replicas=1

kubectl -n project-h800 get statefulset o3db
```