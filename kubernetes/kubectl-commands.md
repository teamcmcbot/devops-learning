# Kubectl Commands Reference

## Table of Contents

- [Basic kubectl Commands](#basic-kubectl-commands)
- [Cluster Information](#cluster-information)
- [Pod Management](#pod-management)
- [Deployment Management](#deployment-management)
- [Service Management](#service-management)
- [ConfigMap and Secret Management](#configmap-and-secret-management)
- [Namespace Management](#namespace-management)
- [Resource Management](#resource-management)
- [Scaling and Updates](#scaling-and-updates)
- [Debugging and Troubleshooting](#debugging-and-troubleshooting)
- [Logs and Monitoring](#logs-and-monitoring)
- [Storage Management](#storage-management)
- [Networking](#networking)
- [Security and RBAC](#security-and-rbac)
- [Helm Integration](#helm-integration)

## Basic kubectl Commands

### Configuration and Context

```bash
# Check kubectl version
kubectl version
kubectl version --client

# Display cluster information
kubectl cluster-info

# Get current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>

# View kubectl configuration
kubectl config view
```

## Cluster Information

### Cluster Status

```bash
# Get cluster information
kubectl cluster-info

# Check cluster nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe node details
kubectl describe node <node-name>

# Get node resource usage
kubectl top nodes

# Check cluster components
kubectl get componentstatuses
kubectl get cs
```

### API Resources

```bash
# List all API resources
kubectl api-resources

# List API versions
kubectl api-versions

# Explain resource fields
kubectl explain <resource>
kubectl explain pod.spec.containers
```

## Pod Management

### Creating and Managing Pods

```bash
# Create pod from YAML file
kubectl apply -f <pod.yaml>

# Create pod from image (imperative)
kubectl run <pod-name> --image=<image-name>

# List all pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces

# List pods with labels
kubectl get pods --show-labels
kubectl get pods -l <label-selector>

# Describe pod details
kubectl describe pod <pod-name>

# Delete pod
kubectl delete pod <pod-name>
kubectl delete -f <pod.yaml>
```

### Pod Operations

```bash
# Execute command in pod
kubectl exec <pod-name> -- <command>

# Interactive shell in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- sh

# Execute command in specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash

# Port forwarding to pod
kubectl port-forward <pod-name> <local-port>:<pod-port>

# Copy files to/from pod
kubectl cp <local-file> <pod-name>:<remote-file>
kubectl cp <pod-name>:<remote-file> <local-file>
```

## Deployment Management

### Creating and Managing Deployments

```bash
# Create deployment
kubectl create deployment <deployment-name> --image=<image-name>

# Apply deployment from YAML
kubectl apply -f <deployment.yaml>

# List deployments
kubectl get deployments
kubectl get deploy

# Describe deployment
kubectl describe deployment <deployment-name>

# Update deployment image
kubectl set image deployment/<deployment-name> <container-name>=<new-image>

# Delete deployment
kubectl delete deployment <deployment-name>
```

### Deployment Rollouts

```bash
# Check rollout status
kubectl rollout status deployment/<deployment-name>

# View rollout history
kubectl rollout history deployment/<deployment-name>

# Rollback to previous version
kubectl rollout undo deployment/<deployment-name>

# Rollback to specific revision
kubectl rollout undo deployment/<deployment-name> --to-revision=<revision-number>

# Restart deployment
kubectl rollout restart deployment/<deployment-name>
```

## Service Management

### Creating and Managing Services

```bash
# Create service (ClusterIP)
kubectl create service clusterip <service-name> --tcp=<port>:<target-port>

# Create NodePort service
kubectl create service nodeport <service-name> --tcp=<port>:<target-port>

# Create LoadBalancer service
kubectl create service loadbalancer <service-name> --tcp=<port>:<target-port>

# Expose deployment as service
kubectl expose deployment <deployment-name> --port=<port> --target-port=<target-port>

# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service <service-name>

# Delete service
kubectl delete service <service-name>
```

### Service Operations

```bash
# Get service endpoints
kubectl get endpoints <service-name>

# Port forward to service
kubectl port-forward service/<service-name> <local-port>:<service-port>
```

## ConfigMap and Secret Management

### ConfigMap Operations

```bash
# Create ConfigMap from literal values
kubectl create configmap <configmap-name> --from-literal=<key>=<value>

# Create ConfigMap from file
kubectl create configmap <configmap-name> --from-file=<file-path>

# Create ConfigMap from directory
kubectl create configmap <configmap-name> --from-file=<directory-path>

# List ConfigMaps
kubectl get configmaps
kubectl get cm

# Describe ConfigMap
kubectl describe configmap <configmap-name>

# Edit ConfigMap
kubectl edit configmap <configmap-name>

# Delete ConfigMap
kubectl delete configmap <configmap-name>
```

### Secret Operations

```bash
# Create generic secret
kubectl create secret generic <secret-name> --from-literal=<key>=<value>

# Create secret from file
kubectl create secret generic <secret-name> --from-file=<file-path>

# Create TLS secret
kubectl create secret tls <secret-name> --cert=<cert-file> --key=<key-file>

# Create Docker registry secret
kubectl create secret docker-registry <secret-name> \
  --docker-server=<server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>

# List secrets
kubectl get secrets

# Describe secret (values are base64 encoded)
kubectl describe secret <secret-name>

# Get secret value
kubectl get secret <secret-name> -o jsonpath='{.data.<key>}' | base64 --decode

# Delete secret
kubectl delete secret <secret-name>
```

## Namespace Management

### Namespace Operations

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace <namespace-name>

# Delete namespace
kubectl delete namespace <namespace-name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>

# Get resources in specific namespace
kubectl get pods -n <namespace>

# Get resources in all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A
```

## Resource Management

### General Resource Operations

```bash
# Get all resources in namespace
kubectl get all

# Get specific resource types
kubectl get pods,services,deployments

# Output in different formats
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o wide
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Watch resources in real-time
kubectl get pods -w

# Sort resources
kubectl get pods --sort-by=.metadata.creationTimestamp

# Filter by field selector
kubectl get pods --field-selector=status.phase=Running

# Filter by label selector
kubectl get pods -l app=nginx
kubectl get pods -l 'app in (nginx,apache)'
```

### Resource Creation and Updates

```bash
# Apply configuration
kubectl apply -f <file.yaml>
kubectl apply -f <directory>/

# Create resource (fails if exists)
kubectl create -f <file.yaml>

# Replace resource
kubectl replace -f <file.yaml>

# Delete resources
kubectl delete -f <file.yaml>
kubectl delete <resource-type> <resource-name>
kubectl delete <resource-type> --all

# Edit resource in place
kubectl edit <resource-type> <resource-name>

# Patch resource
kubectl patch <resource-type> <resource-name> -p '<patch-data>'
```

## Scaling and Updates

### Scaling Resources

```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=<count>

# Scale ReplicaSet
kubectl scale replicaset <replicaset-name> --replicas=<count>

# Autoscale deployment
kubectl autoscale deployment <deployment-name> --min=<min> --max=<max> --cpu-percent=<percent>

# Check HPA status
kubectl get hpa
```

### Resource Updates

```bash
# Update image
kubectl set image deployment/<deployment-name> <container>=<image>

# Update environment variables
kubectl set env deployment/<deployment-name> <key>=<value>

# Update resource limits
kubectl set resources deployment <deployment-name> --limits=cpu=200m,memory=256Mi
```

## Debugging and Troubleshooting

### Pod Debugging

```bash
# Get pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs <pod-name> --previous

# Follow logs
kubectl logs -f <pod-name>

# Get logs from all containers in pod
kubectl logs <pod-name> --all-containers

# Debug pod with temporary container
kubectl debug <pod-name> -it --image=busybox

# Create debug session
kubectl run debug --image=busybox -it --rm -- sh

# Check pod events
kubectl get events --field-selector involvedObject.name=<pod-name>
```

### Resource Troubleshooting

```bash
# Describe resource for events and details
kubectl describe <resource-type> <resource-name>

# Get events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource usage
kubectl top pods
kubectl top nodes

# Validate YAML files
kubectl apply --dry-run=client -f <file.yaml>
kubectl apply --dry-run=server -f <file.yaml>

# Explain resource specifications
kubectl explain pod.spec
kubectl explain deployment.spec.template.spec.containers
```

## Logs and Monitoring

### Log Management

```bash
# View logs with timestamps
kubectl logs <pod-name> --timestamps

# View logs from last N lines
kubectl logs <pod-name> --tail=<number>

# View logs since specific time
kubectl logs <pod-name> --since=1h
kubectl logs <pod-name> --since=2023-01-01T10:00:00Z

# Export logs to file
kubectl logs <pod-name> > pod-logs.txt

# View logs from multiple pods
kubectl logs -l app=<label-value>
```

### Resource Monitoring

```bash
# Monitor resource usage
kubectl top pods
kubectl top pods --containers
kubectl top nodes

# Monitor specific pod
kubectl top pod <pod-name>

# Get resource usage with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.status.containerStatuses[0].resources.requests.cpu
```

## Storage Management

### Persistent Volume Operations

```bash
# List Persistent Volumes
kubectl get pv

# List Persistent Volume Claims
kubectl get pvc

# Describe PV/PVC
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>

# Create PVC from YAML
kubectl apply -f <pvc.yaml>

# Delete PVC
kubectl delete pvc <pvc-name>
```

### Storage Class Operations

```bash
# List Storage Classes
kubectl get storageclass
kubectl get sc

# Describe Storage Class
kubectl describe storageclass <sc-name>

# Set default Storage Class
kubectl patch storageclass <sc-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Networking

### Network Policies

```bash
# List Network Policies
kubectl get networkpolicy
kubectl get netpol

# Describe Network Policy
kubectl describe networkpolicy <policy-name>

# Apply Network Policy
kubectl apply -f <network-policy.yaml>
```

### Ingress Management

```bash
# List Ingress resources
kubectl get ingress
kubectl get ing

# Describe Ingress
kubectl describe ingress <ingress-name>

# Create Ingress
kubectl apply -f <ingress.yaml>

# Get Ingress with external IP
kubectl get ingress -o wide
```

## Security and RBAC

### Role-Based Access Control

```bash
# List Roles and ClusterRoles
kubectl get roles
kubectl get clusterroles

# List RoleBindings and ClusterRoleBindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Describe RBAC resources
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>

# Check permissions
kubectl auth can-i <verb> <resource>
kubectl auth can-i create pods
kubectl auth can-i "*" "*"

# Check permissions for specific user
kubectl auth can-i create pods --as=<username>
```

### Service Accounts

```bash
# List Service Accounts
kubectl get serviceaccounts
kubectl get sa

# Create Service Account
kubectl create serviceaccount <sa-name>

# Describe Service Account
kubectl describe serviceaccount <sa-name>

# Get Service Account token
kubectl get secret $(kubectl get sa <sa-name> -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode
```

## Helm Integration

### Helm with kubectl

```bash
# List Helm releases using kubectl
kubectl get secret -l owner=helm

# Get Helm release information
kubectl get secret <release-name> -o yaml

# Check Helm-deployed resources
kubectl get all -l app.kubernetes.io/managed-by=Helm
```

## Advanced kubectl Commands

### Custom Resource Definitions (CRDs)

```bash
# List CRDs
kubectl get crd

# Describe CRD
kubectl describe crd <crd-name>

# Get custom resources
kubectl get <custom-resource-type>
```

### Finalizers and Annotations

```bash
# Remove finalizers (use with caution)
kubectl patch <resource-type> <resource-name> -p '{"metadata":{"finalizers":null}}'

# Add annotation
kubectl annotate <resource-type> <resource-name> <key>=<value>

# Remove annotation
kubectl annotate <resource-type> <resource-name> <key>-
```

### JSON Path Queries

```bash
# Get specific fields using JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# Complex JSONPath with conditions
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

## kubectl Aliases and Shortcuts

### Common Aliases (Add to ~/.bashrc or ~/.zshrc)

```bash
# kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdl='kubectl delete'
alias kdf='kubectl delete -f'
alias kex='kubectl exec -it'
alias klogs='kubectl logs'
alias kpf='kubectl port-forward'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# Namespace shortcuts
alias kgpn='kubectl get pods -n'
alias kgsn='kubectl get services -n'
alias kgdn='kubectl get deployments -n'
```

### Useful One-liners

```bash
# Get all pod names
kubectl get pods -o name | cut -d/ -f2

# Get pods not in Running state
kubectl get pods --field-selector=status.phase!=Running

# Delete all pods in Evicted state
kubectl get pods | grep Evicted | awk '{print $1}' | xargs kubectl delete pod

# Get resource requests and limits
kubectl describe nodes | grep -A 5 "Allocated resources"

# Find pods using most CPU
kubectl top pods --sort-by=cpu

# Get pod restart counts
kubectl get pods -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount
```

## Tips and Best Practices

1. **Use namespaces** to organize resources and avoid conflicts
2. **Always specify resource limits** to prevent resource exhaustion
3. **Use labels and selectors** for better resource organization
4. **Implement health checks** (liveness and readiness probes)
5. **Use ConfigMaps and Secrets** instead of hardcoding configuration
6. **Apply the principle of least privilege** with RBAC
7. **Monitor resource usage** regularly with `kubectl top`
8. **Use dry-run** to validate configurations before applying
9. **Keep your kubectl version** compatible with your cluster version
10. **Use context and namespace** management to avoid mistakes
11. **Implement proper backup strategies** for persistent data
12. **Use network policies** to secure pod-to-pod communication
13. **Regularly update** your cluster and node versions
14. **Use Helm** for complex application deployments
15. **Implement logging and monitoring** solutions for production clusters
