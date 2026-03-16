# Question 1 | DNS / FQDN / Headless Service

**Solve this question on:** `ssh cka6016`

## Task

The Deployment controller in Namespace `lima-control` communicates with various cluster internal endpoints by using their DNS FQDN values.

Update the ConfigMap used by the Deployment with the correct FQDN values for:

- `DNS_1`: Service `kubernetes` in Namespace `default`
- `DNS_2`: Headless Service `department` in Namespace `lima-workload`
- `DNS_3`: Pod `section100` in Namespace `lima-workload`  
  It should work even if the Pod IP changes
- `DNS_4`: A Pod with IP `1.2.3.4` in Namespace `kube-system`

Ensure the Deployment works with the updated values.

> You can use `nslookup` or `dig` inside a Pod of the controller Deployment.

---

## Solution

For this question we need to understand how cluster internal DNS works in Kubernetes.

The most common pattern is:

```text
SERVICE.NAMESPACE.svc.cluster.local
```

This resolves to the IP address of the Kubernetes Service.

Because the task explicitly asks for **FQDN values**, short names like `SERVICE.NAMESPACE` are not enough.

---

### Step 1: Exec into a controller Pod and test DNS

```bash
ssh cka6016
kubectl -n lima-control get pod
```

Example output:

```text
NAME                        READY   STATUS    RESTARTS   AGE
controller-586d6657-gdmch   1/1     Running   0          11m
controller-586d6657-lvdtd   1/1     Running   0          11m
```

Exec into one of the Pods:

```bash
kubectl -n lima-control exec -it controller-586d6657-gdmch -- sh
```

Check that DNS resolution works:

```bash
nslookup google.com
nslookup non-exist.some.google.com
```

---

### Step 2: Find the FQDN for DNS_1

The default Kubernetes API Service is:

```bash
nslookup kubernetes.default.svc.cluster.local
```

Expected result:

```text
Name:    kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

So:

```text
DNS_1=kubernetes.default.svc.cluster.local
```

---

### Step 3: Find the FQDN for DNS_2

The headless Service is `department` in Namespace `lima-workload`.

Test it:

```bash
nslookup department.lima-workload.svc.cluster.local
```

Expected result:

```text
Name:    department.lima-workload.svc.cluster.local
Address: 10.32.0.2
Name:    department.lima-workload.svc.cluster.local
Address: 10.32.0.9
```

Because it is a **headless Service**, it returns the IPs of the backing Pods instead of a single ClusterIP.

You can confirm this:

```bash
kubectl -n lima-workload get svc
kubectl -n lima-workload get endpointslice
```

Example:

```text
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
department   ClusterIP   None         <none>        80/TCP    ...
section      ClusterIP   10.99.121.17 <none>        80/TCP    ...
```

So:

```text
DNS_2=department.lima-workload.svc.cluster.local
```

---

### Step 4: Find the FQDN for DNS_3

We need the Pod `section100` in Namespace `lima-workload`, and it should still work even if the Pod IP changes.

Try:

```bash
nslookup section100.section.lima-workload.svc.cluster.local
nslookup section200.section.lima-workload.svc.cluster.local
```

Expected result:

```text
Name:    section100.section.lima-workload.svc.cluster.local
Address: 10.32.0.10

Name:    section200.section.lima-workload.svc.cluster.local
Address: 10.32.0.3
```

So the correct FQDN is:

```text
DNS_3=section100.section.lima-workload.svc.cluster.local
```

This works because the Pods behind the Service specify `hostname` and `subdomain`, for example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: section100
  namespace: lima-workload
  labels:
    name: section
spec:
  hostname: section100
  subdomain: section
  containers:
    - image: httpd:2-alpine
      name: pod
```

---

### Step 5: Find the FQDN for DNS_4

Kubernetes can resolve Pod-style DNS names in this format:

```text
IP-WITH-DASHES.NAMESPACE.pod.cluster.local
```

So for Pod IP `1.2.3.4` in Namespace `kube-system`, test:

```bash
nslookup 1-2-3-4.kube-system.pod.cluster.local
```

Expected result:

```text
Name:    1-2-3-4.kube-system.pod.cluster.local
Address: 1.2.3.4
```

So:

```text
DNS_4=1-2-3-4.kube-system.pod.cluster.local
```

---

### Step 6: Update the ConfigMap

Check the ConfigMap:

```bash
kubectl -n lima-control get cm
```

Example output:

```text
NAME             DATA   AGE
control-config   4      10m
```

Edit it:

```bash
kubectl -n lima-control edit cm control-config
```

Update it to:

```yaml
apiVersion: v1
data:
  DNS_1: kubernetes.default.svc.cluster.local
  DNS_2: department.lima-workload.svc.cluster.local
  DNS_3: section100.section.lima-workload.svc.cluster.local
  DNS_4: 1-2-3-4.kube-system.pod.cluster.local
kind: ConfigMap
metadata:
  name: control-config
  namespace: lima-control
```

---

### Step 7: Restart the Deployment

```bash
kubectl -n lima-control rollout restart deploy controller
```

Expected output:

```text
deployment.apps/controller restarted
```

---

### Step 8: Verify the Deployment works

Check the logs of one of the new controller Pods:

```bash
kubectl -n lima-control logs -f <controller-pod-name>
```

Example successful output:

```text
+ nslookup kubernetes.default.svc.cluster.local
Name:    kubernetes.default.svc.cluster.local
Address: 10.96.0.1

+ nslookup department.lima-workload.svc.cluster.local
Name:    department.lima-workload.svc.cluster.local
Address: 10.32.0.2
Name:    department.lima-workload.svc.cluster.local
Address: 10.32.0.9

+ nslookup section100.section.lima-workload.svc.cluster.local
Name:    section100.section.lima-workload.svc.cluster.local
Address: 10.32.0.10

+ nslookup 1-2-3-4.kube-system.pod.cluster.local
Name:    1-2-3-4.kube-system.pod.cluster.local
Address: 1.2.3.4
```

---

## Final Values

```text
DNS_1=kubernetes.default.svc.cluster.local
DNS_2=department.lima-workload.svc.cluster.local
DNS_3=section100.section.lima-workload.svc.cluster.local
DNS_4=1-2-3-4.kube-system.pod.cluster.local
```

---

## Final Commands Summary

```bash
ssh cka6016

kubectl -n lima-control get pod
kubectl -n lima-control exec -it controller-586d6657-gdmch -- sh

nslookup kubernetes.default.svc.cluster.local
nslookup department.lima-workload.svc.cluster.local
nslookup section100.section.lima-workload.svc.cluster.local
nslookup 1-2-3-4.kube-system.pod.cluster.local

kubectl -n lima-control edit cm control-config

kubectl -n lima-control rollout restart deploy controller
kubectl -n lima-control logs -f <controller-pod-name>
```