# Question 9 | Contact K8s Api from inside Pod

**Solve this question on:** `ssh cka9412`

## Task

There is ServiceAccount `secret-reader` in Namespace `project-swan`.

Create a Pod of image `nginx:1-alpine` named `api-contact` which uses this ServiceAccount.

Exec into the Pod and use `curl` to manually query all Secrets from the Kubernetes Api.

Write the result into file:

`/opt/course/9/result.json`

---

## Solution

SSH into the target node first:

```bash
ssh cka9412
```

### Step 1: Create the Pod using the ServiceAccount

Generate a Pod manifest:

```bash
kubectl run api-contact --image=nginx:1-alpine --dry-run=client -o yaml > 9.yaml
```

Edit the file and add the Namespace and ServiceAccount name:

```bash
vim 9.yaml
```

Use:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: api-contact
  name: api-contact
  namespace: project-swan
spec:
  serviceAccountName: secret-reader
  containers:
    - image: nginx:1-alpine
      name: api-contact
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

Create it:

```bash
kubectl apply -f 9.yaml
```

---

### Step 2: Exec into the Pod and test API access

Open a shell inside the Pod:

```bash
kubectl -n project-swan exec -it api-contact -- sh
```

Try accessing the Kubernetes API:

```bash
curl https://kubernetes.default
```

This will fail because the server certificate is not trusted by default.

Try again with insecure TLS:

```bash
curl -k https://kubernetes.default
```

Expected output:

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}
```

This shows the request reached the API server, but it is unauthenticated.

---

### Step 3: Use the ServiceAccount token for authentication

Inside the Pod, read the token mounted automatically for the ServiceAccount:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```

Now query the Secrets API with the Bearer token:

```bash
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"
```

This should return a JSON `SecretList`.

You can also verify the RBAC permission from outside the Pod:

```bash
kubectl auth can-i get secret --as system:serviceaccount:project-swan:secret-reader -n project-swan
```

Expected output:

```text
yes
```

---

### Step 4: Save the result into the required file

Simplest way inside the Pod:

```bash
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}" > result.json
exit
```

Then copy the content out into the required location:

```bash
kubectl -n project-swan exec api-contact -- cat result.json > /opt/course/9/result.json
```

---

## Optional Better TLS Method

Instead of using `-k`, use the cluster CA certificate mounted into the Pod:

```bash
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl --cacert ${CACERT} https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"
```

This is cleaner and avoids insecure TLS.

---

## Final Commands Summary

```bash
ssh cka9412

kubectl run api-contact --image=nginx:1-alpine --dry-run=client -o yaml > 9.yaml
vim 9.yaml
kubectl apply -f 9.yaml

kubectl -n project-swan exec -it api-contact -- sh

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}" > result.json
exit

kubectl -n project-swan exec api-contact -- cat result.json > /opt/course/9/result.json
```