# Question 2 | Create a Static Pod and Service

**Solve this question on:** `ssh cka2560`

## Task

Create a Static Pod named `my-static-pod` in Namespace `default` on the controlplane node.

Requirements:

- image: `nginx:1-alpine`
- resource requests:
  - CPU: `10m`
  - memory: `20Mi`

Then create a NodePort Service named `static-pod-service` which exposes that static Pod on port `80`.

> For verification, check if the new Service has one Endpoint.  
> It should also be possible to access the Pod via the `cka2560` internal IP address, for example:
>
> ```bash
> curl 192.168.100.31:NODE_PORT
> ```

---

## Solution

SSH into the target node first:

```bash
ssh cka2560
sudo -i
```

### Step 1: Create the Static Pod manifest

Go to the static pod manifest directory:

```bash
cd /etc/kubernetes/manifests/
```

Generate a Pod manifest:

```bash
kubectl run my-static-pod --image=nginx:1-alpine -o yaml --dry-run=client > my-static-pod.yaml
```

Edit the manifest and add the required resource requests.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-static-pod
  name: my-static-pod
spec:
  containers:
    - image: nginx:1-alpine
      name: my-static-pod
      resources:
        requests:
          cpu: 10m
          memory: 20Mi
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Because the manifest is placed under `/etc/kubernetes/manifests/`, kubelet will automatically create it as a Static Pod.

Verify it is running:

```bash
kubectl get pod -A | grep my-static
```

Expected output:

```text
default   my-static-pod-cka2560   1/1   Running   0   20s
```

---

### Step 2: Create the NodePort Service

Expose the static Pod:

```bash
kubectl expose pod my-static-pod-cka2560 --name static-pod-service --type=NodePort --port 80
```

This creates a Service similar to:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: my-static-pod
  name: static-pod-service
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 80
  selector:
    run: my-static-pod
  type: NodePort
status:
  loadBalancer: {}
```

---

### Step 3: Verify the Service and Endpoint

Check the Service and EndpointSlice:

```bash
kubectl get svc,endpointslice -l run=my-static-pod
```

Expected output:

```text
NAME                         TYPE       CLUSTER-IP       ...   PORT(S)        AGE
service/static-pod-service   NodePort   10.98.249.240   ...   80:32699/TCP   34s

NAME                         ADDRESSTYPE   PORTS   ENDPOINTS   AGE
static-pod-service-2h7cf     IPv4          80      10.32.0.4   34s
```

This shows the Service has one Endpoint.

---

### Step 4: Test access via NodePort

Get the internal IP of the node:

```bash
kubectl get node -o wide
```

Example output:

```text
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP      ...
cka2560   Ready    control-plane   8d    v1.33.1   192.168.100.31   ...
```

Then curl the NodePort:

```bash
curl 192.168.100.31:32699
```

Expected output will be the default nginx welcome page.

---

## Final Commands Summary

```bash
ssh cka2560
sudo -i

cd /etc/kubernetes/manifests/
kubectl run my-static-pod --image=nginx:1-alpine -o yaml --dry-run=client > my-static-pod.yaml

kubectl get pod -A | grep my-static

kubectl expose pod my-static-pod-cka2560 --name static-pod-service --type=NodePort --port 80

kubectl get svc,endpointslice -l run=my-static-pod
kubectl get node -o wide

curl 192.168.100.31:<node-port>
```