# Kubernetes Secrets

## Executive Summary

**Secrets** are Kubernetes objects used to store and manage sensitive information such as passwords, tokens, API keys, and certificates. Unlike ConfigMaps (which store non-sensitive data), Secrets are designed for confidential data.

**Key Points:**

- Secrets store data in **Base64 encoded** format (NOT encrypted by default)
- Similar to ConfigMaps but for sensitive data
- Can be injected into pods as environment variables or mounted as files
- Should be combined with RBAC and encryption at rest for production security

| Secrets vs ConfigMaps |                                          |
| --------------------- | ---------------------------------------- |
| Secrets               | Sensitive data (passwords, keys, tokens) |
| ConfigMaps            | Non-sensitive configuration data         |

⚠️ **Warning:** Base64 encoding is NOT encryption. Anyone with access can decode the values.

---

## Real-World Usage Examples

### Scenario 1: Database Credentials

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_Host: bXlzcWw= # mysql
  DB_User: cm9vdA== # root
  DB_Password: cGFzd3Jk # paswrd
---
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
    - name: webapp
      image: webapp
      envFrom:
        - secretRef:
            name: db-secret
```

### Scenario 2: TLS Certificate for Ingress

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

### Scenario 3: Docker Registry Credentials

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

---

## Common Commands

### Create Secret (Imperative)

```bash
# From literal values
kubectl create secret generic app-secret --from-literal=DB_Host=mysql --from-literal=DB_User=root --from-literal=DB_Password=paswrd

# From file
kubectl create secret generic app-secret --from-file=ssh-privatekey=~/.ssh/id_rsa

# From file (auto key name = filename)
kubectl create secret generic app-secret --from-file=app_secret.properties

# TLS secret from cert files
kubectl create secret tls tls-secret --cert=path/to/tls.crt --key=path/to/tls.key

# Docker registry secret
kubectl create secret docker-registry regcred --docker-server=<registry> --docker-username=<user> --docker-password=<pass> --docker-email=<email>

# Dry-run to generate YAML
kubectl create secret generic app-secret --from-literal=password=mysecret --dry-run=client -o yaml > secret.yaml
```

### Base64 Encoding/Decoding

```bash
# Encode plaintext to Base64
echo -n 'mysql' | base64
# Output: bXlzcWw=

echo -n 'root' | base64
# Output: cm9vdA==

echo -n 'paswrd' | base64
# Output: cGFzd3Jk

# Decode Base64 to plaintext
echo -n 'bXlzcWw=' | base64 --decode
echo -n 'bXlzcWw=' | base64 -d
# Output: mysql
```

### View Secrets

```bash
# List all secrets
kubectl get secrets

# Describe secret (hides values)
kubectl describe secret app-secret

# View secret with encoded values
kubectl get secret app-secret -o yaml

# Decode a specific key value
kubectl get secret app-secret -o jsonpath='{.data.DB_Password}' | base64 --decode
```

### Edit/Delete Secrets

```bash
# Edit secret
kubectl edit secret app-secret

# Delete secret
kubectl delete secret app-secret
```

---

## YAML Configuration Reference

### Secret Definition (with Base64 encoded data)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_Host: bXlzcWw= # base64 encoded
  DB_User: cm9vdA== # base64 encoded
  DB_Password: cGFzd3Jk # base64 encoded
```

### Secret Definition (with plain text - using stringData)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData: # Kubernetes encodes automatically
  DB_Host: mysql
  DB_User: root
  DB_Password: paswrd
```

### Three Ways to Inject Secrets into Pods

#### 1. Inject ALL keys as environment variables (`envFrom`)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      envFrom:
        - secretRef:
            name: app-secret
```

#### 2. Inject SINGLE key as environment variable (`valueFrom`)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_Password
```

#### 3. Mount as Volume (files)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: app-secret
```

Each key becomes a file:

```bash
ls /etc/secrets
# DB_Host  DB_User  DB_Password

cat /etc/secrets/DB_Password
# paswrd
```

---

## Secret Types

| Type                                  | Usage                                     |
| ------------------------------------- | ----------------------------------------- |
| `Opaque`                              | Default type for arbitrary key-value data |
| `kubernetes.io/tls`                   | TLS certificates (tls.crt, tls.key)       |
| `kubernetes.io/dockerconfigjson`      | Docker registry credentials               |
| `kubernetes.io/basic-auth`            | Basic authentication (username, password) |
| `kubernetes.io/ssh-auth`              | SSH authentication (ssh-privatekey)       |
| `kubernetes.io/service-account-token` | Service account tokens                    |

---

## Security Best Practices

| Practice                  | Description                                           |
| ------------------------- | ----------------------------------------------------- |
| Enable encryption at rest | Encrypt etcd data with `EncryptionConfiguration`      |
| Use RBAC                  | Restrict who can read/write secrets                   |
| Avoid source control      | Never commit secret YAML files to Git                 |
| Use external providers    | AWS Secrets Manager, HashiCorp Vault, Azure Key Vault |
| Limit secret scope        | Create secrets in specific namespaces                 |

---

## CKA Exam Relevance

### How This Topic is Tested:

1. **Create Secrets** - Imperatively or declaratively
2. **Inject Secrets into Pods** - Using `envFrom`, `valueFrom`, or volumes
3. **Decode Secret values** - Use base64 decode to view actual values
4. **Troubleshooting** - Fix pods not reading secrets correctly
5. **Identify Secret types** - Know when to use TLS, docker-registry, etc.

### Exam Tips:

- Use `--dry-run=client -o yaml` to quickly generate YAML
- Use `stringData` instead of `data` to avoid manual base64 encoding
- Remember: `envFrom: secretRef` vs `valueFrom: secretKeyRef`
- Secrets must exist BEFORE pod references them (unless optional)
- Secrets are namespace-scoped (must be in same namespace as pod)
- Use `-n` with echo to avoid newline: `echo -n 'value' | base64`

### Sample Exam Tasks:

> _Create a secret named `db-secret` with `DB_Host=sql01`, `DB_User=root`, `DB_Password=password123`_

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_Host=sql01 \
  --from-literal=DB_User=root \
  --from-literal=DB_Password=password123
```

> _Configure pod to use secret `db-secret` as environment variables_

---

## Official Documentation Links

- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Managing Secrets using kubectl](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/)
- [Distribute Credentials Securely Using Secrets](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/)
- [Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│  BASE64 ENCODE/DECODE                                           │
├─────────────────────────────────────────────────────────────────┤
│  echo -n 'value' | base64           # Encode                    │
│  echo -n 'encoded' | base64 --decode # Decode                   │
├─────────────────────────────────────────────────────────────────┤
│  CREATE SECRET                                                  │
├─────────────────────────────────────────────────────────────────┤
│  kubectl create secret generic NAME --from-literal=KEY=VALUE    │
│  kubectl create secret generic NAME --from-file=FILE            │
│  kubectl create secret tls NAME --cert=CRT --key=KEY            │
├─────────────────────────────────────────────────────────────────┤
│  INJECT INTO POD                                                │
├─────────────────────────────────────────────────────────────────┤
│  ALL KEYS:    envFrom:                                          │
│                 - secretRef:                                    │
│                     name: app-secret                            │
│                                                                 │
│  ONE KEY:     env:                                              │
│                 - name: DB_PASSWORD                             │
│                   valueFrom:                                    │
│                     secretKeyRef:                               │
│                       name: app-secret                          │
│                       key: DB_Password                          │
│                                                                 │
│  AS FILES:    volumes:                                          │
│                 - name: secret-vol                              │
│                   secret:                                       │
│                     secretName: app-secret                      │
├─────────────────────────────────────────────────────────────────┤
│  VIEW SECRET DATA                                               │
├─────────────────────────────────────────────────────────────────┤
│  kubectl get secret NAME -o yaml                                │
│  kubectl get secret NAME -o jsonpath='{.data.KEY}' | base64 -d  │
└─────────────────────────────────────────────────────────────────┘
```
