# Question 14 | Check how long certificates are valid

**Solve this question on:** `ssh cka9412`

## Task

Perform the following tasks on cluster certificates:

1. Check how long the **kube-apiserver server certificate** is valid using `openssl` or `cfssl`
2. Write the **expiration date** into:
   - `/opt/course/14/expiration`
3. Run the `kubeadm` command to list the certificate expiration dates and confirm both methods show the same value
4. Write the `kubeadm` command that would renew the kube-apiserver certificate into:
   - `/opt/course/14/kubeadm-renew-certs.sh`

---

## Solution

SSH into the target node first:

```bash
ssh cka9412
sudo -i
```

### Step 1: Locate the kube-apiserver certificate

Find the certificate files:

```bash
find /etc/kubernetes/pki | grep apiserver
```

Expected relevant output:

```text
/etc/kubernetes/pki/apiserver.crt
/etc/kubernetes/pki/apiserver.key
```

The server certificate we need is:

```text
/etc/kubernetes/pki/apiserver.crt
```

---

### Step 2: Check the expiration date using openssl

Run:

```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
```

Example output:

```text
notAfter=Dec 28 13:11:26 2027 GMT
```

Write just the expiration value into the required file:

```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate | cut -d= -f2 > /opt/course/14/expiration
```

Verify:

```bash
cat /opt/course/14/expiration
```

Example content:

```text
Dec 28 13:11:26 2027 GMT
```

---

### Step 3: Confirm using kubeadm

Run:

```bash
kubeadm certs check-expiration
```

This lists all kubeadm-managed certificates and their expiration dates.

Look for the `apiserver` entry. Example relevant output:

```text
CERTIFICATE                EXPIRES                   RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
apiserver                  Dec 28, 2027 13:11 UTC   729d            ca                      no
```

This confirms the same expiration date as the `openssl` output.

> `openssl` shows the exact certificate `notAfter` value, while `kubeadm certs check-expiration` formats it slightly differently.

---

### Step 4: Write the kubeadm renewal command into the script file

The command to renew only the kube-apiserver certificate is:

```bash
kubeadm certs renew apiserver
```

Write it into the required file:

```bash
echo 'kubeadm certs renew apiserver' > /opt/course/14/kubeadm-renew-certs.sh
chmod +x /opt/course/14/kubeadm-renew-certs.sh
```

Verify:

```bash
cat /opt/course/14/kubeadm-renew-certs.sh
```

Expected content:

```bash
kubeadm certs renew apiserver
```

---

## Optional cfssl method

If `cfssl` is installed, you can also inspect the certificate like this:

```bash
cfssl certinfo -cert /etc/kubernetes/pki/apiserver.crt
```

But `openssl` is usually the fastest method.

---

## Final Commands Summary

```bash
ssh cka9412
sudo -i

find /etc/kubernetes/pki | grep apiserver

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate | cut -d= -f2 > /opt/course/14/expiration

kubeadm certs check-expiration

echo 'kubeadm certs renew apiserver' > /opt/course/14/kubeadm-renew-certs.sh
chmod +x /opt/course/14/kubeadm-renew-certs.sh
```