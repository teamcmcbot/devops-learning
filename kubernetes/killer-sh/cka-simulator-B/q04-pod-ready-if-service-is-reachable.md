# Question 4 | Pod Ready if Service is reachable

**Solve this question on:** `ssh cka3200`

## Task

Do the following in Namespace `default`:

- Create a Pod named `ready-if-service-ready` of image `nginx:1-alpine`
- Configure a LivenessProbe which simply executes command `true`
- Configure a ReadinessProbe which checks whether `http://service-am-i-ready:80` is reachable  
  You can use:
  ```bash
  wget -T2 -O- http://service-am-i-ready:80
  ```
- Start the Pod and confirm it is **not ready** because of the ReadinessProbe

Then:

- Create a second Pod named `am-i-ready` of image `nginx:1-alpine`
- Add label:
  ```yaml
  id: cross-server-ready
  ```
- The already existing Service `service-am-i-ready` should now have that second Pod as endpoint
- Now the first Pod should become **Ready**

---

## Solution

SSH into the target node first:

```bash
ssh cka3200
```

### Step 1: Create the first Pod manifest

Generate a Pod YAML:

```bash
kubectl run ready-if-service-ready --image=nginx:1-alpine --dry-run=client -o yaml > 4_pod1.yaml
```

Edit it and add the probes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ready-if-service-ready
  name: ready-if-service-ready
spec:
  containers:
    - image: nginx:1-alpine
      name: ready-if-service-ready
      resources: {}
      livenessProbe:
        exec:
          command:
            - "true"
      readinessProbe:
        exec:
          command:
            - sh
            - -c
            - 'wget -T2 -O- http://service-am-i-ready:80'
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Create the Pod:

```bash
kubectl create -f 4_pod1.yaml
```

Expected output:

```text
pod/ready-if-service-ready created
```

---

### Step 2: Confirm the first Pod is not Ready

Check the Pod:

```bash
kubectl get pod ready-if-service-ready
```

Expected output:

```text
NAME                     READY   STATUS    RESTARTS   AGE
ready-if-service-ready   0/1     Running   0          8s
```

Describe it to confirm the readiness failure:

```bash
kubectl describe pod ready-if-service-ready
```

Relevant output:

```text
Warning  Unhealthy  ...  kubelet  Readiness probe failed: command timed out: "sh -c wget -T2 -O- http://service-am-i-ready:80" timed out after 1s
```

This shows the Pod is running but not Ready because the Service is not yet reachable.

---

### Step 3: Create the second Pod

Create the second Pod with the required label:

```bash
kubectl run am-i-ready --image=nginx:1-alpine --labels="id=cross-server-ready"
```

Expected output:

```text
pod/am-i-ready created
```

---

### Step 4: Verify the Service now has an endpoint

Describe the existing Service:

```bash
kubectl describe svc service-am-i-ready
```

Expected relevant output:

```text
Name:              service-am-i-ready
Namespace:         default
Labels:            id=cross-server-ready
Selector:          id=cross-server-ready
Type:              ClusterIP
IP:                10.108.19.168
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.44.0.30:80
```

You can also check the EndpointSlice:

```bash
kubectl get endpointslice
```

Example relevant output:

```text
service-am-i-ready-ch6d6   IPv4   80   10.44.0.30
```

This confirms that `am-i-ready` is now backing the Service.

---

### Step 5: Confirm the first Pod becomes Ready

Wait a short moment for the readiness probe to retry, then check again:

```bash
kubectl get pod ready-if-service-ready
```

Expected output:

```text
NAME                     READY   STATUS    RESTARTS   AGE
ready-if-service-ready   1/1     Running   0          2m10s
```

Now the first Pod is Ready because it can successfully reach `http://service-am-i-ready:80`.

---

## Final Commands Summary

```bash
ssh cka3200

kubectl run ready-if-service-ready --image=nginx:1-alpine --dry-run=client -o yaml > 4_pod1.yaml
vim 4_pod1.yaml
kubectl create -f 4_pod1.yaml

kubectl get pod ready-if-service-ready
kubectl describe pod ready-if-service-ready

kubectl run am-i-ready --image=nginx:1-alpine --labels="id=cross-server-ready"

kubectl describe svc service-am-i-ready
kubectl get pod ready-if-service-ready
```