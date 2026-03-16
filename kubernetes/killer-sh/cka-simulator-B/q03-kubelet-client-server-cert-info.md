# Question 3 | Kubelet client/server cert info

**Solve this question on:** `ssh cka5248`

## Task

Node `cka5248-node1` has been added to the cluster using `kubeadm` and TLS bootstrapping.

Find the **Issuer** and **Extended Key Usage** values on `cka5248-node1` for:

- **Kubelet Client Certificate**
  - the one used for outgoing connections to the kube-apiserver
- **Kubelet Server Certificate**
  - the one used for incoming connections from the kube-apiserver

Write the information into:

`/opt/course/3/certificate-info.txt`

> You can connect to the worker node using `ssh cka5248-node1` from `cka5248`.

---

## Solution

SSH into the target node first:

```bash
ssh cka5248
ssh cka5248-node1
sudo -i
```

### Step 1: Find the kubelet certificate files

```bash
find /var/lib/kubelet/pki
```

Expected output:

```text
/var/lib/kubelet/pki
/var/lib/kubelet/pki/kubelet-client-2024-10-29-14-24-14.pem
/var/lib/kubelet/pki/kubelet.crt
/var/lib/kubelet/pki/kubelet.key
/var/lib/kubelet/pki/kubelet-client-current.pem
```

Relevant files:

- **Kubelet client certificate**: `/var/lib/kubelet/pki/kubelet-client-current.pem`
- **Kubelet server certificate**: `/var/lib/kubelet/pki/kubelet.crt`

---

### Step 2: Check the kubelet client certificate

Get the Issuer:

```bash
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer
```

Expected output:

```text
Issuer: CN = kubernetes
```

Get the Extended Key Usage:

```bash
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1
```

Expected output:

```text
X509v3 Extended Key Usage:
    TLS Web Client Authentication
```

---

### Step 3: Check the kubelet server certificate

Get the Issuer:

```bash
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer
```

Expected output:

```text
Issuer: CN = cka5248-node1-ca@1730211854
```

Get the Extended Key Usage:

```bash
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1
```

Expected output:

```text
X509v3 Extended Key Usage:
    TLS Web Server Authentication
```

---

### Step 4: Write the results into the required file

Create the output file:

```bash
cat <<EOF > /opt/course/3/certificate-info.txt
Issuer: CN = kubernetes
X509v3 Extended Key Usage: TLS Web Client Authentication
Issuer: CN = cka5248-node1-ca@1730211854
X509v3 Extended Key Usage: TLS Web Server Authentication
EOF
```

---

## Notes

- The **client certificate** is used by kubelet when connecting **outbound** to the kube-apiserver.
- The **server certificate** is used for **incoming** connections to kubelet from the kube-apiserver.
- The Extended Key Usage confirms whether the certificate is for client or server authentication.

---

## Final Commands Summary

```bash
ssh cka5248
ssh cka5248-node1
sudo -i

find /var/lib/kubelet/pki

openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1

openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1

cat <<EOF > /opt/course/3/certificate-info.txt
Issuer: CN = kubernetes
X509v3 Extended Key Usage: TLS Web Client Authentication
Issuer: CN = cka5248-node1-ca@1730211854
X509v3 Extended Key Usage: TLS Web Server Authentication
EOF
```