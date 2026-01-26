# TLS Certificates in Kubernetes

## Executive Summary

TLS (Transport Layer Security) certificates secure communication between all Kubernetes cluster components. Every component (API Server, etcd, kubelet, etc.) requires certificates for encrypted communication and authentication. Understanding TLS is critical for cluster security and troubleshooting.

## Key Concepts

### Certificate Types

| Type                    | Purpose                            | Examples                                         |
| ----------------------- | ---------------------------------- | ------------------------------------------------ |
| **Server Certificates** | Secure server endpoints            | api-server.crt, etcd-server.crt, kubelet.crt     |
| **Client Certificates** | Authenticate clients to servers    | admin.crt, scheduler.crt, controller-manager.crt |
| **CA Certificate**      | Sign and verify other certificates | ca.crt, ca.key                                   |

### Kubernetes Components and Their Certificates

**Server Components:**

- **Kube API Server**: `api-server.crt`, `api-server.key`
- **ETCD Server**: `etcd-server.crt`, `etcd-server.key`
- **Kubelet**: `kubelet.crt`, `kubelet.key`

**Client Components:**

- **Admin/kubectl**: `admin.crt`, `admin.key`
- **Scheduler**: `scheduler.crt`, `scheduler.key`
- **Controller Manager**: `controller-manager.crt`, `controller-manager.key`
- **Kube Proxy**: `kube-proxy.crt`, `kube-proxy.key`

### Naming Conventions

| Extension           | Type                   |
| ------------------- | ---------------------- |
| `.crt`, `.pem`      | Public key/certificate |
| `.key`, `*-key.pem` | Private key            |

## Real-World Usage

- Securing all internal cluster communications
- Authenticating administrators and services
- Enabling HTTPS for API server access
- Mutual TLS (mTLS) between cluster components

## Common Commands

### Generate CA Certificate

```bash
# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=kubernetes-ca"
```

### Generate Admin User Certificate

```bash
# Generate private key
openssl genrsa -out admin.key 2048

# Generate CSR
openssl req -new -key admin.key -out admin.csr -subj "/CN=kube-admin/O=system:masters"

# Sign certificate with CA
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 365
```

### View Certificate Details

```bash
# View certificate content
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout

# Check certificate expiry
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate

# Check certificate issuer and subject
openssl x509 -in cert.crt -noout -issuer -subject
```

### Certificate Locations (kubeadm clusters)

```bash
# All certificates typically located in
/etc/kubernetes/pki/

# View API server certificate configuration
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -A 2 "tls-cert-file"
```

## Certificates API

Kubernetes provides a built-in API for managing certificate signing requests.

### Create CSR Object

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  request: <base64-encoded-csr>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400 # 24 hours
  usages:
    - digital signature
    - key encipherment
    - client auth
```

### CSR Commands

```bash
# Create CSR from file
kubectl create -f csr.yaml

# List pending CSRs
kubectl get csr

# Approve CSR
kubectl certificate approve jane

# Deny CSR
kubectl certificate deny jane

# Delete CSR
kubectl delete csr jane

# View approved certificate (base64 encoded)
kubectl get csr jane -o yaml

# Encode CSR for YAML
cat jane.csr | base64 -w 0
```

### Controller Manager Configuration

The Controller Manager handles CSR approval and signing:

```yaml
# /etc/kubernetes/manifests/kube-controller-manager.yaml
spec:
  containers:
    - command:
        - kube-controller-manager
        - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
        - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
```

## CKA Exam Tips

### What to Expect

- View and decode certificate details
- Troubleshoot certificate-related issues
- Create and approve CertificateSigningRequests
- Identify certificate paths in kubeadm clusters

### Quick Reference

```bash
# Decode base64 certificate
echo "<base64-string>" | base64 --decode

# Check if certificate is valid for specific hostname
openssl verify -CAfile ca.crt server.crt

# View certificate in PEM format
cat cert.crt
```

## Official Documentation

- [PKI Certificates and Requirements](https://kubernetes.io/docs/setup/best-practices/certificates/)
- [Certificate Signing Requests](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)
- [Manage TLS Certificates in a Cluster](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/)
