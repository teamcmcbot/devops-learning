# Question 17 | Find Container of Pod and check info

**Solve this question on:** `ssh cka2556`

## Task

In Namespace `project-tiger`, create a Pod named `tigers-reunite` using image `httpd:2-alpine` with labels:

- `pod=container`
- `container=pod`

Find out on which node the Pod is scheduled. SSH into that node and find the `containerd` container belonging to that Pod.

Using command `crictl`:

1. Write the **container ID** and the **info.runtimeType** into:
   - `/opt/course/17/pod-container.txt`
2. Write the **logs of the container** into:
   - `/opt/course/17/pod-container.log`

> You can connect to a worker node using `ssh cka2556-node1` or `ssh cka2556-node2` from `cka2556`

---

## Solution

SSH into the control plane first:

```bash
ssh cka2556
```

### Step 1: Create the Pod

```bash
kubectl -n project-tiger run tigers-reunite --image=httpd:2-alpine --labels="pod=container,container=pod"
```

Expected output:

```text
pod/tigers-reunite created
```

---

### Step 2: Find which node the Pod is running on

```bash
kubectl -n project-tiger get pod -o wide
```

Example output:

```text
NAME                                  READY   STATUS    ...   NODE
tigers-for-rent-web-57558cfbf8-4tldr  1/1     Running   ...   cka2556-node1
tigers-for-rent-web-57558cfbf8-5pz4z  1/1     Running   ...   cka2556-node2
tigers-reunite                        1/1     Running   ...   cka2556-node1
```

In this example, the Pod is running on:

```text
cka2556-node1
```

---

### Step 3: SSH into that node and find the container

```bash
ssh cka2556-node1
sudo -i
```

Use `crictl` to find the container for the Pod:

```bash
crictl ps | grep tigers-reunite
```

Example output:

```text
ba62e5d465ff0   a7ccaadd632cf   2 minutes ago   Running   tigers-reunite   ...
```

The container ID is:

```text
ba62e5d465ff0
```

---

### Step 4: Get the runtime type

Inspect the container:

```bash
crictl inspect ba62e5d465ff0 | grep runtimeType
```

Example output:

```text
"runtimeType": "io.containerd.runc.v2",
```

So the runtime type is:

```text
io.containerd.runc.v2
```

---

### Step 5: Write the required info file

Write the container ID and runtime type into the required file:

```bash
echo 'ba62e5d465ff0 io.containerd.runc.v2' > /opt/course/17/pod-container.txt
```

Expected file content:

```text
ba62e5d465ff0 io.containerd.runc.v2
```

---

### Step 6: Write the container logs

Get the logs:

```bash
crictl logs ba62e5d465ff0
```

Example output:

```text
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.29. Set the 'ServerName' directive globally to suppress this message

AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.44.0.29. Set the 'ServerName' directive globally to suppress this message
```

Write them into the required file:

```bash
crictl logs ba62e5d465ff0 > /opt/course/17/pod-container.log
```

---

## Final Commands Summary

```bash
ssh cka2556

kubectl -n project-tiger run tigers-reunite --image=httpd:2-alpine --labels="pod=container,container=pod"

kubectl -n project-tiger get pod -o wide

ssh cka2556-node1
sudo -i

crictl ps | grep tigers-reunite
crictl inspect <container-id> | grep runtimeType

echo '<container-id> <runtime-type>' > /opt/course/17/pod-container.txt
crictl logs <container-id> > /opt/course/17/pod-container.log
```