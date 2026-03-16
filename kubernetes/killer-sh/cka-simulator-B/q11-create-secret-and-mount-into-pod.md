# Question 11 | Create Secret and mount into Pod

**Solve this question on:** `ssh cka2560`

## Task

Create Namespace `secret` and implement the following in it:

- Create Pod `secret-pod` with image `busybox:1`
  - keep it running by executing `sleep 1d` or something similar
- Create the existing Secret from:
  - `/opt/course/11/secret1.yaml`
  - mount it readonly into the Pod at `/tmp/secret1`
- Create a new Secret called `secret2` which should contain:
  - `user=user1`
  - `pass=1234`
- These entries from `secret2` should be available inside the Pod container as environment variables:
  - `APP_USER`
  - `APP_PASS`

---

## Solution

### Step 1: Connect and create the Namespace

```bash
ssh cka2560
kubectl create ns secret
```

Expected output:

```text
namespace/secret created
```

---

## Step 2: Create Secret `secret1`

The provided Secret YAML needs to be created in Namespace `secret`.

Copy the file and update the Namespace:

```bash
cp /opt/course/11/secret1.yaml 11_secret1.yaml
vim 11_secret1.yaml
```

Use:

```yaml
apiVersion: v1
data:
  halt: IyEgL2Jpbi9zaAo...
kind: Secret
metadata:
  creationTimestamp: null
  name: secret1
  namespace: secret
```

Create it:

```bash
kubectl -f 11_secret1.yaml create
```

Expected output:

```text
secret/secret1 created
```

---

## Step 3: Create Secret `secret2`

Create the second Secret with literal values:

```bash
kubectl -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234
```

Expected output:

```text
secret/secret2 created
```

---

## Step 4: Create the Pod manifest

Generate a Pod template:

```bash
kubectl -n secret run secret-pod --image=busybox:1 --dry-run=client -o yaml -- sh -c "sleep 1d" > 11.yaml
```

Edit it:

```bash
vim 11.yaml
```

Use:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-pod
  name: secret-pod
  namespace: secret
spec:
  containers:
    - args:
        - sh
        - -c
        - sleep 1d
      image: busybox:1
      name: secret-pod
      resources: {}
      env:
        - name: APP_USER
          valueFrom:
            secretKeyRef:
              name: secret2
              key: user
        - name: APP_PASS
          valueFrom:
            secretKeyRef:
              name: secret2
              key: pass
      volumeMounts:
        - name: secret1
          mountPath: /tmp/secret1
          readOnly: true
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
    - name: secret1
      secret:
        secretName: secret1
status: {}
```

Create the Pod:

```bash
kubectl -f 11.yaml create
```

Expected output:

```text
pod/secret-pod created
```

---

## Step 5: Verify the environment variables and mounted secret

Check the env vars:

```bash
kubectl -n secret exec secret-pod -- env | grep APP
```

Expected output:

```text
APP_PASS=1234
APP_USER=user1
```

Check the mounted files:

```bash
kubectl -n secret exec secret-pod -- find /tmp/secret1
```

You should see the files from Secret `secret1` mounted under `/tmp/secret1`.

---

## Final Commands Summary

```bash
ssh cka2560

kubectl create ns secret

cp /opt/course/11/secret1.yaml 11_secret1.yaml
vim 11_secret1.yaml
kubectl -f 11_secret1.yaml create

kubectl -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234

kubectl -n secret run secret-pod --image=busybox:1 --dry-run=client -o yaml -- sh -c "sleep 1d" > 11.yaml
vim 11.yaml
kubectl -f 11.yaml create

kubectl -n secret exec secret-pod -- env | grep APP
kubectl -n secret exec secret-pod -- find /tmp/secret1
```