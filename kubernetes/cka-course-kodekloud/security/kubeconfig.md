# KubeConfig

## Executive Summary

The kubeconfig file stores cluster access configuration including cluster details, user credentials, and contexts. It eliminates the need to specify certificates and server addresses with every kubectl command. Default location is `~/.kube/config`.

## Key Concepts

### Three Main Sections

| Section      | Purpose                                       |
| ------------ | --------------------------------------------- |
| **Clusters** | Define cluster endpoints and CA certificates  |
| **Users**    | Store user credentials (certificates, tokens) |
| **Contexts** | Map users to clusters (user@cluster)          |

## Real-World Usage

- Managing access to multiple Kubernetes clusters
- Switching between development, staging, and production environments
- Setting default namespaces per context
- Team access management with different credentials

## Kubeconfig Structure

```yaml
apiVersion: v1
kind: Config
current-context: dev-user@development

clusters:
  - name: development
    cluster:
      certificate-authority: /path/to/ca.crt
      # OR embed certificate data directly:
      # certificate-authority-data: <base64-encoded-ca>
      server: https://development-cluster:6443

  - name: production
    cluster:
      certificate-authority-data: LS0tLS1CRUdJTi...
      server: https://production-cluster:6443

users:
  - name: dev-user
    user:
      client-certificate: /path/to/dev-user.crt
      client-key: /path/to/dev-user.key

  - name: admin
    user:
      client-certificate-data: LS0tLS1CRUdJTi...
      client-key-data: LS0tLS1CRUdJTi...

contexts:
  - name: dev-user@development
    context:
      cluster: development
      user: dev-user
      namespace: dev # Optional default namespace

  - name: admin@production
    context:
      cluster: production
      user: admin
      namespace: production
```

## Common Commands

### View Configuration

```bash
# View current kubeconfig
kubectl config view

# View specific kubeconfig file
kubectl config view --kubeconfig=/path/to/custom-config

# View current context
kubectl config current-context

# View merged kubeconfig (when using multiple files)
kubectl config view --flatten
```

### Manage Contexts

```bash
# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context admin@production

# Set default namespace for current context
kubectl config set-context --current --namespace=my-namespace
```

### Manage Clusters, Users, and Contexts

```bash
# Add new cluster
kubectl config set-cluster my-cluster \
  --server=https://cluster-endpoint:6443 \
  --certificate-authority=/path/to/ca.crt

# Add new user credentials
kubectl config set-credentials my-user \
  --client-certificate=/path/to/user.crt \
  --client-key=/path/to/user.key

# Create new context
kubectl config set-context my-context \
  --cluster=my-cluster \
  --user=my-user \
  --namespace=default

# Delete context
kubectl config delete-context my-context

# Delete cluster
kubectl config delete-cluster my-cluster

# Delete user
kubectl config delete-user my-user
```

### Using Custom Kubeconfig

```bash
# Specify custom kubeconfig file
kubectl get pods --kubeconfig=/path/to/custom-config

# Set KUBECONFIG environment variable
export KUBECONFIG=/path/to/custom-config

# Merge multiple kubeconfig files
export KUBECONFIG=~/.kube/config:/path/to/other-config
```

## Certificate Management in Kubeconfig

### Using File Paths (Recommended for local files)

```yaml
clusters:
  - name: my-cluster
    cluster:
      certificate-authority: /etc/kubernetes/pki/ca.crt
      server: https://192.168.1.100:6443
users:
  - name: admin
    user:
      client-certificate: /etc/kubernetes/pki/admin.crt
      client-key: /etc/kubernetes/pki/admin.key
```

### Using Embedded Data (Portable)

```yaml
clusters:
  - name: my-cluster
    cluster:
      certificate-authority-data: LS0tLS1CRUdJTi...
      server: https://192.168.1.100:6443
users:
  - name: admin
    user:
      client-certificate-data: LS0tLS1CRUdJTi...
      client-key-data: LS0tLS1CRUdJTi...
```

### Encode/Decode Certificates

```bash
# Encode certificate to base64
cat admin.crt | base64 -w 0

# Decode base64 certificate
echo "LS0tLS1CRUdJTi..." | base64 --decode
```

## CKA Exam Tips

### What to Expect

- Modify kubeconfig to access different clusters
- Fix broken kubeconfig files
- Switch between contexts
- Set default namespaces

### Quick Troubleshooting

```bash
# Verify cluster connectivity
kubectl cluster-info

# Test with specific context
kubectl get nodes --context=my-context

# Debug kubeconfig issues
kubectl config view --raw
```

## Official Documentation

- [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
- [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
