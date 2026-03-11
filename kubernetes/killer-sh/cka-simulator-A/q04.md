# Question 4 | Find Pods first to be terminated

**Solve this question on:** `ssh cka2556`

## Task

Check all available Pods in Namespace `project-c13` and find the names of those that would probably be terminated first if the nodes run out of resources (CPU or memory).

Write the Pod names into:

`/opt/course/4/pods-terminated-first.txt`

---

## Key Idea

When node resources run low, Kubernetes is more likely to evict Pods that are using more resources than requested.

Pods with no resource requests defined are treated as the weakest candidates and usually fall into the **BestEffort** QoS class, which makes them the most likely to be terminated first.

So for this task, we need to find the Pods with:

- no CPU requests
- no memory requests

---

## Solution

SSH into the target node first:

```bash
ssh cka2556
```

A manual way is to inspect the Pod descriptions and look for missing resource requests:

```bash
kubectl -n project-c13 describe pod | less -p Requests
```

Or filter the output:

```bash
kubectl -n project-c13 describe pod | grep -A 3 -E 'Requests|^Name:'
```

From the output, the Pods from Deployment `c13-3cc-runner-heavy` do not have resource requests specified.

The Pods are:

```text
c13-3cc-runner-heavy-65588d7d6-djtv9
c13-3cc-runner-heavy-65588d7d6-v8kf5
c13-3cc-runner-heavy-65588d7d6-wwpb4
```

Write them into the required file:

```bash
cat <<EOF > /opt/course/4/pods-terminated-first.txt
c13-3cc-runner-heavy-65588d7d6-djtv9
c13-3cc-runner-heavy-65588d7d6-v8kf5
c13-3cc-runner-heavy-65588d7d6-wwpb4
EOF
```

---

## Optional Faster Verification

You can also check resource definitions using jsonpath:

```bash
kubectl -n project-c13 get pod -o jsonpath="{range .items[*]}{.metadata.name}{.spec.containers[*].resources}{'\n'}"
```

Example relevant output:

```text
c13-3cc-runner-heavy-8687d66dbb-gnxjh{}
c13-3cc-runner-heavy-8687d66dbb-przdh{}
c13-3cc-runner-heavy-8687d66dbb-wqwfz{}
```

The `{}` means no resources were defined.

You can also check the QoS class directly:

```bash
kubectl get pods -n project-c13 -o jsonpath="{range .items[*]}{.metadata.name} {.status.qosClass}{'\n'}"
```

Relevant output:

```text
c13-3cc-runner-heavy-8687d66dbb-gnxjh BestEffort
c13-3cc-runner-heavy-8687d66dbb-przdh BestEffort
c13-3cc-runner-heavy-8687d66dbb-wqwfz BestEffort
```

Those BestEffort Pods are the ones most likely to be terminated first.

---

## Final Commands Summary

```bash
ssh cka2556

kubectl -n project-c13 describe pod | grep -A 3 -E 'Requests|^Name:'

cat <<EOF > /opt/course/4/pods-terminated-first.txt
c13-3cc-runner-heavy-65588d7d6-djtv9
c13-3cc-runner-heavy-65588d7d6-v8kf5
c13-3cc-runner-heavy-65588d7d6-wwpb4
EOF
```