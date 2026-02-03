# ConfigMaps and Secrets

## Exam Weight
Part of **15% - Workloads and Scheduling**

## What Can Be Tested

- Create ConfigMaps from literals, files, and directories
- Create Secrets from literals, files, and images
- Mount ConfigMaps/Secrets as volumes
- Use ConfigMaps/Secrets as environment variables
- Update ConfigMaps/Secrets and understand pod refresh behavior
- Decode base64 encoded secrets
- Understand different secret types

## Sample Questions

1. **Create a ConfigMap from a file and mount it in a pod**
2. **Create a Secret with username/password and use as environment variables**
3. **Create a ConfigMap from literal values and inject specific keys as env vars**
4. **Decode a base64 encoded secret value**
5. **Update a ConfigMap and verify pod behavior**

## Official Documentation

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Configure Pod ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [Distribute Credentials Securely Using Secrets](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/)

## Key Concepts

### ConfigMap vs Secret

| Aspect | ConfigMap | Secret |
|--------|-----------|--------|
| **Purpose** | Non-sensitive configuration | Sensitive data (passwords, tokens, keys) |
| **Storage** | Plain text | Base64 encoded (not encrypted by default!) |
| **Size Limit** | 1 MB | 1 MB |
| **Use Cases** | Config files, env vars, command-line args | Passwords, API keys, TLS certs |

### Ways to Consume ConfigMaps/Secrets

1. **Environment Variables** - Individual keys as env vars
2. **Volume Mounts** - All keys as files in a directory
3. **Command Arguments** - Via env vars in command

## Imperative Commands

### ConfigMap Commands
```bash
# Create ConfigMap from literals
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2

# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.properties

# Create ConfigMap from directory (all files)
kubectl create configmap dir-config --from-file=./configs/

# Create ConfigMap with specific key name
kubectl create configmap special-config --from-file=special-key=config.txt

# Get ConfigMaps
kubectl get configmap
kubectl get cm

# Describe ConfigMap
kubectl describe configmap my-config

# View ConfigMap data
kubectl get configmap my-config -o yaml

# Edit ConfigMap
kubectl edit configmap my-config

# Delete ConfigMap
kubectl delete configmap my-config
```

### Secret Commands
```bash
# Create generic Secret from literals
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=secret123

# Create Secret from file
kubectl create secret generic db-secret --from-file=username.txt --from-file=password.txt

# Create TLS Secret
kubectl create secret tls tls-secret --cert=path/to/tls.cert --key=path/to/tls.key

# Create Docker registry Secret
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=user@example.com

# Get Secrets
kubectl get secrets

# Describe Secret (data is hidden)
kubectl describe secret my-secret

# View Secret (base64 encoded)
kubectl get secret my-secret -o yaml

# Decode Secret value
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode

# Edit Secret
kubectl edit secret my-secret

# Delete Secret
kubectl delete secret my-secret
```

## YAML Examples

### ConfigMap from Literals
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "mysql://db-server:3306"
  log_level: "info"
  max_connections: "100"
```

### ConfigMap with File Content
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    server {
      listen 80;
      server_name example.com;
      location / {
        proxy_pass http://backend:8080;
      }
    }
```

### Secret - Generic Type
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=        # base64 encoded "admin"
  password: cGFzc3dvcmQxMjM= # base64 encoded "password123"
```

### Secret - TLS Type
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

### Pod Using ConfigMap as Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-env-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "env; sleep 3600"]
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
```

### Pod Using ConfigMap as Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### Pod Using All ConfigMap Keys as Env Vars
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-envfrom-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "env; sleep 3600"]
    envFrom:
    - configMapRef:
        name: app-config
```

### Pod Using Secret as Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "env | grep -E '(USERNAME|PASSWORD)'; sleep 3600"]
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### Pod Using Secret as Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "ls -la /etc/secret; cat /etc/secret/*; sleep 3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
```

### Pod with Specific ConfigMap Keys as Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: selective-configmap-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
  volumes:
  - name: config
    configMap:
      name: nginx-config
      items:
      - key: nginx.conf
        path: nginx.conf
```

## Troubleshooting Tips

### Pod Fails to Start - ConfigMap/Secret Not Found
```bash
# Check pod events
kubectl describe pod <pod-name>

# Common error: "configmaps \"my-config\" not found"

# Verify ConfigMap/Secret exists
kubectl get configmap my-config
kubectl get secret my-secret

# Check namespace
kubectl get configmap my-config -n <namespace>

# Create missing ConfigMap/Secret
kubectl create configmap my-config --from-literal=key=value
```

### Environment Variable Not Set
```bash
# Exec into pod and check env vars
kubectl exec <pod-name> -- env

# Check for the specific variable
kubectl exec <pod-name> -- env | grep MY_VAR

# Verify ConfigMap key exists
kubectl get configmap <name> -o yaml

# Check spelling of key in pod spec
kubectl get pod <pod-name> -o yaml | grep -A5 configMapKeyRef
```

### Mounted ConfigMap/Secret Empty or Wrong Content
```bash
# Check mounted files
kubectl exec <pod-name> -- ls -la /etc/config
kubectl exec <pod-name> -- cat /etc/config/<key>

# Verify ConfigMap content
kubectl get configmap <name> -o yaml

# Check mount path and volume name match
kubectl describe pod <pod-name>
```

### Decode Secret Value
```bash
# Get base64 encoded value
kubectl get secret my-secret -o yaml

# Decode specific key
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode

# Decode all keys
kubectl get secret my-secret -o json | jq '.data | map_values(@base64d)'

# On macOS, use base64 -D instead of base64 --decode
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -D
```

### Encode Value for Secret
```bash
# Encode string to base64
echo -n "mypassword" | base64

# On macOS
echo -n "mypassword" | base64

# Use in Secret YAML
# data:
#   password: bXlwYXNzd29yZA==
```

### ConfigMap/Secret Not Updating in Pod
```bash
# ConfigMaps/Secrets mounted as volumes update automatically (may take ~60s)
# Environment variables DO NOT update automatically - need pod restart

# Check if ConfigMap was updated
kubectl get configmap <name> -o yaml

# Restart pod to pick up env var changes
kubectl delete pod <pod-name>

# Or rollout restart deployment
kubectl rollout restart deployment <deployment-name>

# Check update propagation for volume-mounted configs
kubectl exec <pod-name> -- cat /etc/config/<key>
```

## Key Concepts

### ConfigMap/Secret Update Behavior

| Consumption Method | Auto-Update | Notes |
|-------------------|-------------|-------|
| **Volume Mount** | ✅ Yes | Takes ~60 seconds (kubelet sync period) |
| **Environment Variable** | ❌ No | Requires pod restart |
| **subPath Volume** | ❌ No | Immutable once mounted |

### Secret Types

| Type | Use Case | Keys |
|------|----------|------|
| `Opaque` | Generic secret | Custom keys |
| `kubernetes.io/tls` | TLS certificate | `tls.crt`, `tls.key` |
| `kubernetes.io/dockerconfigjson` | Docker registry auth | `.dockerconfigjson` |
| `kubernetes.io/basic-auth` | Basic authentication | `username`, `password` |
| `kubernetes.io/ssh-auth` | SSH authentication | `ssh-privatekey` |
| `kubernetes.io/service-account-token` | Service account token | `token`, `ca.crt`, `namespace` |

## Exam Tips

1. **Use imperative commands** for speed: `kubectl create configmap`
2. **ConfigMap/Secret must exist before pod** - create them first
3. **Names must match exactly** - check spelling
4. **Use `--from-literal`** for quick key-value pairs
5. **Use `--from-file`** when you have config files
6. **Base64 encode/decode** - `echo -n "value" | base64` / `base64 --decode`
7. **Volume mounts auto-update** but env vars don't
8. **Use `subPath`** to mount single file instead of directory
9. **ReadOnly volumes** for security with secrets
10. **Check namespace** - ConfigMaps/Secrets are namespace-scoped

## Common Mistakes

- ❌ Forgetting `-n` flag in echo for base64 encoding (adds newline)
- ❌ Creating pod before ConfigMap/Secret exists
- ❌ Typo in ConfigMap/Secret name or key name
- ❌ Wrong namespace (ConfigMap in default, pod in other namespace)
- ❌ Expecting env vars to update when ConfigMap changes
- ❌ Not using `readOnly: true` for secret volume mounts
- ❌ Storing sensitive data in ConfigMaps instead of Secrets
- ❌ Thinking Secrets are encrypted by default (they're only base64!)

## Quick Reference

```bash
# Create ConfigMap
kubectl create configmap app-config \
  --from-literal=key1=value1 \
  --from-literal=key2=value2

# Create Secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=pass123

# View data
kubectl get configmap app-config -o yaml
kubectl get secret db-secret -o yaml

# Decode secret
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode

# Create pod using ConfigMap as env
kubectl run test --image=busybox --dry-run=client -o yaml -- sleep 3600 > pod.yaml
# Edit to add configMapKeyRef
kubectl apply -f pod.yaml

# Verify in pod
kubectl exec test -- env | grep KEY1

# Cleanup
kubectl delete pod test
kubectl delete configmap app-config
kubectl delete secret db-secret
```

## Testing Example

```bash
# Create ConfigMap
kubectl create configmap test-config --from-literal=env=production --from-literal=version=1.0

# Create Secret
kubectl create secret generic test-secret --from-literal=api-key=abc123

# Create test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "env; sleep 3600"]
    env:
    - name: ENVIRONMENT
      valueFrom:
        configMapKeyRef:
          name: test-config
          key: env
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: test-secret
          key: api-key
EOF

# Verify
kubectl logs test-pod | grep -E "(ENVIRONMENT|API_KEY)"

# Cleanup
kubectl delete pod test-pod
kubectl delete configmap test-config
kubectl delete secret test-secret
```
