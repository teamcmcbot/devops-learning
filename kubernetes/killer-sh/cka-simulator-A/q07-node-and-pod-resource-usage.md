# Question 7 | Node and Pod Resource Usage

**Solve this question on:** `ssh cka5774`

## Task

The metrics-server has been installed in the cluster.

Write two bash scripts which use `kubectl`:

- Script `/opt/course/7/node.sh` should show resource usage of nodes
- Script `/opt/course/7/pod.sh` should show resource usage of Pods and their containers

---

## Solution

SSH into the target node first:

```bash
ssh cka5774
```

Check the available `kubectl top` commands:

```bash
kubectl top -h
```

You will see that `top` can display resource usage for both nodes and pods.

Example:

```bash
kubectl top node
```

Possible output:

```text
NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
cka5774   104m         10%    1121Mi          60%
```

---

### Step 1: Create `/opt/course/7/node.sh`

This script should show resource usage of nodes.

Create the file:

```bash
vim /opt/course/7/node.sh
```

Put this inside:

```bash
kubectl top node
```

Make it executable:

```bash
chmod +x /opt/course/7/node.sh
```

---

### Step 2: Create `/opt/course/7/pod.sh`

Check the help for pods:

```bash
kubectl top pod -h
```

Relevant option:

```text
--containers=false: If present, print usage of containers within a pod
```

Create the file:

```bash
vim /opt/course/7/pod.sh
```

Put this inside:

```bash
kubectl top pod --containers=true
```

Make it executable:

```bash
chmod +x /opt/course/7/pod.sh
```

---

### Step 3: Verify the scripts

Run:

```bash
/opt/course/7/node.sh
/opt/course/7/pod.sh
```

---

## Notes

- Use full `kubectl` commands, not aliases like `k`
- `kubectl top node` shows node resource usage
- `kubectl top pod --containers=true` shows pod and container resource usage

---

## Final Commands Summary

```bash
ssh cka5774

echo 'kubectl top node' > /opt/course/7/node.sh
chmod +x /opt/course/7/node.sh

echo 'kubectl top pod --containers=true' > /opt/course/7/pod.sh
chmod +x /opt/course/7/pod.sh

/opt/course/7/node.sh
/opt/course/7/pod.sh
```