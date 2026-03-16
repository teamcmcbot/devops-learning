# Question 1 | Contexts

**Solve this question on:** `ssh cka9412`

## Task

You are asked to extract the following information from the kubeconfig file:

`/opt/course/1/kubeconfig`

Write the results to these files:

1. Write all kubeconfig context names into:
   - `/opt/course/1/contexts`
   - one context name per line

2. Write the name of the current context into:
   - `/opt/course/1/current-context`

3. Write the client certificate of user `account-0027`, base64-decoded, into:
   - `/opt/course/1/cert`

---

## Solution

SSH into the target node first:

```bash
ssh cka9412
```

### Step 1: Get all context names

List all contexts:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts
```

Get only the context names:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name
```

Write them into the required file:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name > /opt/course/1/contexts
```

Expected file content:

```
cluster-admin
cluster-w100
cluster-w200
```

---

### Step 2: Get the current context

Check the current context:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config current-context
```

Write it into the required file:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config current-context > /opt/course/1/current-context
```

Expected file content:

```
cluster-w200
```

---

### Step 3: Extract the client certificate for `account-0027`

View the kubeconfig including raw certificate data:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config view --raw -o yaml
```

Look under the `users` section for user `account-0027@internal` and locate:

```yaml
client-certificate-data: <base64-value>
```

You can manually copy that value and decode it:

```bash
echo '<base64-value>' | base64 -d > /opt/course/1/cert
```

A more automated way is:

```bash
kubectl --kubeconfig /opt/course/1/kubeconfig config view --raw -o jsonpath="{.users[0].user.client-certificate-data}" | base64 -d > /opt/course/1/cert
```

Expected file content will look like:

```
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
```

---

## Final Commands Summary

```bash
ssh cka9412

kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name > /opt/course/1/contexts

kubectl --kubeconfig /opt/course/1/kubeconfig config current-context > /opt/course/1/current-context

kubectl --kubeconfig /opt/course/1/kubeconfig config view --raw -o jsonpath="{.users[0].user.client-certificate-data}" | base64 -d > /opt/course/1/cert
```