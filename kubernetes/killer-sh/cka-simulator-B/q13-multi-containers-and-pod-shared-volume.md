# Question 13 | Multi Containers and Pod shared Volume

**Solve this question on:** `ssh cka3200`

## Task

Create a Pod with multiple containers named `multi-container-playground` in Namespace `default`:

- It should have a volume attached and mounted into each container
- The volume shouldn't be persisted or shared with other Pods

Containers:

1. `c1`
   - image: `nginx:1-alpine`
   - should have the name of the node where its Pod is running available as environment variable:
     - `MY_NODE_NAME`

2. `c2`
   - image: `busybox:1`
   - should write the output of the `date` command every second into the shared volume file `date.log`
   - you can use:
   ```bash
   while true; do date >> /your/vol/path/date.log; sleep 1; done
   ```

3. `c3`
   - image: `busybox:1`
   - should constantly write the content of `date.log` from the shared volume to stdout
   - you can use:
   ```bash
   tail -f /your/vol/path/date.log
   ```

> Check the logs of container `c3` to confirm correct setup.

---

## Solution

SSH into the target node first:

```bash
ssh cka3200
```

### Step 1: Create a Pod template

Generate a starter Pod manifest:

```bash
kubectl run multi-container-playground --image=nginx:1-alpine --dry-run=client -o yaml > 13.yaml
```

Edit the file:

```bash
vim 13.yaml
```

Use:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: multi-container-playground
  name: multi-container-playground
  namespace: default
spec:
  volumes:
    - name: shared-volume
      emptyDir: {}
  containers:
    - image: nginx:1-alpine
      name: c1
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
      volumeMounts:
        - name: shared-volume
          mountPath: /pod-data
    - image: busybox:1
      name: c2
      command:
        - sh
        - -c
        - 'while true; do date >> /pod-data/date.log; sleep 1; done'
      volumeMounts:
        - name: shared-volume
          mountPath: /pod-data
    - image: busybox:1
      name: c3
      command:
        - sh
        - -c
        - 'tail -f /pod-data/date.log'
      volumeMounts:
        - name: shared-volume
          mountPath: /pod-data
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

### Why this works

- `emptyDir: {}` creates a volume that is:
  - shared by all containers in the Pod
  - not persisted after the Pod is deleted
  - not shared with other Pods
- `fieldRef.fieldPath: spec.nodeName` exposes the node name into env var `MY_NODE_NAME`
- `c2` keeps appending timestamps into `/pod-data/date.log`
- `c3` tails the same file and prints it to stdout

---

### Step 2: Create the Pod

```bash
kubectl create -f 13.yaml
```

Expected output:

```text
pod/multi-container-playground created
```

---

### Step 3: Verify the Pod is running

```bash
kubectl get pod multi-container-playground
```

Expected output:

```text
NAME                        READY   STATUS    RESTARTS   AGE
multi-container-playground  3/3     Running   0          ...
```

---

### Step 4: Verify container `c3` logs

Check the logs of container `c3`:

```bash
kubectl logs multi-container-playground -c c3
```

Expected output will show repeating timestamps such as:

```text
Mon Dec 30 18:05:01 UTC 2024
Mon Dec 30 18:05:02 UTC 2024
Mon Dec 30 18:05:03 UTC 2024
```

This confirms:

- `c2` is writing to the shared file
- `c3` is reading the same file from the shared volume

---

### Step 5: Optional verification of `MY_NODE_NAME`

Check the environment variable inside container `c1`:

```bash
kubectl exec multi-container-playground -c c1 -- env | grep MY_NODE_NAME
```

Expected output:

```text
MY_NODE_NAME=cka3200
```

The exact node name may differ depending on scheduling.

---

## Final Commands Summary

```bash
ssh cka3200

kubectl run multi-container-playground --image=nginx:1-alpine --dry-run=client -o yaml > 13.yaml
vim 13.yaml

kubectl create -f 13.yaml

kubectl get pod multi-container-playground
kubectl logs multi-container-playground -c c3
kubectl exec multi-container-playground -c c1 -- env | grep MY_NODE_NAME
```