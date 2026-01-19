# Encrypting Secret Data at Rest - CKA Cheatsheet

## Executive Summary

By default, Kubernetes Secrets are stored **base64-encoded (NOT encrypted)** in etcd. Anyone with access to etcd can decode and read secret values. **Encryption at rest** encrypts secret data before it's written to etcd, adding a critical security layer.

**Key Points:**

- Base64 encoding ≠ encryption (easily decoded)
- Encryption at rest uses `EncryptionConfiguration` with the kube-apiserver
- Common providers: `aescbc`, `aesgcm`, `secretbox`, `identity` (no encryption)
- Only new/updated secrets are encrypted after enabling; existing secrets need re-encryption

---

## Real-World Usage Example

**Scenario:** A financial services company stores database credentials and API keys as Kubernetes Secrets. Compliance requires all sensitive data to be encrypted at rest to meet PCI-DSS requirements.

**Solution:** Enable encryption at rest using AES-CBC encryption to ensure that even if an attacker gains access to etcd backups, they cannot read the secret values without the encryption key.

---

## Common Commands

### Create Secrets

```bash
# From literal values
kubectl create secret generic my-secret --from-literal=key1=supersecret

# From file
kubectl create secret generic my-secret --from-file=path/to/file

# View secret (base64 encoded)
kubectl get secret my-secret -o yaml

# Decode base64 value
echo "c3VwZXJzZWNyZXQ=" | base64 --decode
```

### Check if Encryption is Enabled

```bash
ps -aux | grep kube-api | grep "encryption-provider-config"
```

### Generate Encryption Key

```bash
head -c 32 /dev/urandom | base64
```

### Inspect Secret in etcd (Before/After Encryption)

```bash
# Install etcd client
apt-get install etcd-client

# Query secret from etcd
ETCDCTL_API=3 etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/secrets/default/my-secret | hexdump -C
```

### Re-encrypt Existing Secrets

```bash
kubectl get secret --all-namespaces -o json | kubectl replace -f -
```

---

## YAML Configurations

### EncryptionConfiguration (`/etc/kubernetes/enc/enc.yaml`)

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <base64-encoded-32-byte-key> # Generate with: head -c 32 /dev/urandom | base64
      - identity: {} # Fallback for reading unencrypted secrets
```

### kube-apiserver Manifest Changes (`/etc/kubernetes/manifests/kube-apiserver.yaml`)

```yaml
spec:
  containers:
    - command:
        - kube-apiserver
        # ... other flags ...
        - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml # ADD THIS
      volumeMounts:
        # ... other mounts ...
        - name: enc # ADD THIS
          mountPath: /etc/kubernetes/enc
          readOnly: true
  volumes:
    # ... other volumes ...
    - name: enc # ADD THIS
      hostPath:
        path: /etc/kubernetes/enc
        type: DirectoryOrCreate
```

---

## Step-by-Step: Enable Encryption at Rest

1. **Generate encryption key:**

   ```bash
   head -c 32 /dev/urandom | base64
   ```

2. **Create encryption config file:**

   ```bash
   mkdir -p /etc/kubernetes/enc
   vi /etc/kubernetes/enc/enc.yaml
   # Add EncryptionConfiguration YAML (see above)
   ```

3. **Modify kube-apiserver manifest:**

   ```bash
   vi /etc/kubernetes/manifests/kube-apiserver.yaml
   # Add --encryption-provider-config flag, volume, and volumeMount
   ```

4. **Wait for API server restart** (it's a static pod, restarts automatically)

5. **Verify encryption works:**

   ```bash
   kubectl create secret generic test-secret --from-literal=mykey=mydata
   # Check etcd - data should be encrypted (not readable in hexdump)
   ```

6. **Re-encrypt existing secrets:**
   ```bash
   kubectl get secret --all-namespaces -o json | kubectl replace -f -
   ```

---

## CKA Exam Tips

### How This Topic May Be Tested:

- **Enable encryption at rest** for secrets in a cluster
- **Verify** that secrets are encrypted in etcd
- **Troubleshoot** why encryption isn't working (missing flags, incorrect paths)
- **Create** the EncryptionConfiguration file with correct syntax

### Key Things to Remember:

| Item                       | Value/Path                                                               |
| -------------------------- | ------------------------------------------------------------------------ |
| Encryption config location | `/etc/kubernetes/enc/enc.yaml`                                           |
| API server manifest        | `/etc/kubernetes/manifests/kube-apiserver.yaml`                          |
| Flag to add                | `--encryption-provider-config=/etc/kubernetes/enc/enc.yaml`              |
| etcd certs location        | `/etc/kubernetes/pki/etcd/`                                              |
| Provider order matters     | First provider is used for encryption; all providers used for decryption |

### Common Mistakes:

- Forgetting to add volumeMount AND volume to API server manifest
- Not waiting for API server to restart after changes
- Forgetting `identity: {}` provider (needed to read unencrypted secrets)
- Not re-encrypting existing secrets after enabling encryption

---

## Official Documentation Links

- [Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [kube-apiserver Configuration](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
- [Using a KMS provider for data encryption](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/)
