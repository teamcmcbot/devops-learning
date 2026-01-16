# Kubectl Commands Reference - CKA Certification Guide

This guide is organized according to the CKA (Certified Kubernetes Administrator) exam curriculum domains. Each section includes essential commands and links to official Kubernetes documentation.

## CKA Exam Domains

The CKA exam tests the following domains:

- **Cluster Architecture, Installation & Configuration** - 25%
- **Workloads & Scheduling** - 15%
- **Services & Networking** - 20%
- **Storage** - 10%
- **Troubleshooting** - 30%

## Table of Contents

### Core Concepts & Cluster Architecture

- [Basic kubectl Commands](#basic-kubectl-commands)
- [Cluster Information & Components](#cluster-information--components)
- [Namespace Management](#namespace-management)
- [Node Management](#node-management)

### Workloads & Scheduling

- [Pod Management](#pod-management)
- [ReplicaSet Management](#replicaset-management)
- [Deployment Management](#deployment-management)
- [DaemonSet Management](#daemonset-management)
- [StatefulSet Management](#statefulset-management)
- [Job and CronJob Management](#job-and-cronjob-management)
- [Scheduling & Resource Management](#scheduling--resource-management)

### Services & Networking

- [Service Management](#service-management)
- [Ingress Management](#ingress-management)
- [Network Policies](#network-policies)
- [DNS and CoreDNS](#dns-and-coredns)

### Storage

- [Storage Management](#storage-management)

### Configuration & Security

- [ConfigMap and Secret Management](#configmap-and-secret-management)
- [Security and RBAC](#security-and-rbac)
- [Service Accounts](#service-accounts)
- [Security Contexts](#security-contexts)

### Troubleshooting & Maintenance

- [Debugging and Troubleshooting](#debugging-and-troubleshooting)
- [Logs and Monitoring](#logs-and-monitoring)
- [Cluster Maintenance](#cluster-maintenance)
- [etcd Backup and Restore](#etcd-backup-and-restore)

### Additional Resources

- [kubectl Aliases and Shortcuts](#kubectl-aliases-and-shortcuts)
- [CKA Exam Tips](#cka-exam-tips)

## Basic kubectl Commands

> **Official Documentation**: [kubectl Overview](https://kubernetes.io/docs/reference/kubectl/) | [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

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

## Cluster Information & Components

> **Official Documentation**: [Cluster Architecture](https://kubernetes.io/docs/concepts/architecture/) | [Cluster Administration](https://kubernetes.io/docs/concepts/cluster-administration/)

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

## Node Management

> **Official Documentation**: [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/) | [Node Management](https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/)

```bash
# Get all nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe node (shows resources, conditions, pods)
kubectl describe node <node-name>

# Get node resource usage
kubectl top nodes

# Label nodes
kubectl label node <node-name> <label-key>=<label-value>

# Remove label from node
kubectl label node <node-name> <label-key>-

# Cordon node (mark as unschedulable)
kubectl cordon <node-name>

# Uncordon node (mark as schedulable)
kubectl uncordon <node-name>

# Drain node (evict pods for maintenance)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Taint nodes
kubectl taint nodes <node-name> <key>=<value>:<effect>

# Effect options:
# - NoSchedule: New pods won't be scheduled on the node (existing pods remain)
# - PreferNoSchedule: Scheduler tries to avoid placing pods on the node (soft constraint)
# - NoExecute: New pods won't be scheduled AND existing pods without tolerations are evicted

# Examples:
kubectl taint nodes node1 key1=value1:NoSchedule
kubectl taint nodes node1 key1=value1:PreferNoSchedule
kubectl taint nodes node1 key1=value1:NoExecute

# Remove taint (multiple options)
kubectl taint nodes <node-name> <key>=<value>:<effect>-   # Remove specific taint
kubectl taint nodes <node-name> <key>-                     # Remove all taints with this key

# Examples:
kubectl taint nodes node1 key1=value1:NoSchedule-
kubectl taint nodes node1 key1-

# Get node conditions
kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}'
```

## Namespace Management

> **Official Documentation**: [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

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

# Create namespace from YAML
kubectl apply -f <namespace.yaml>

# Get resource quotas for namespace
kubectl get resourcequota -n <namespace>

# Describe namespace
kubectl describe namespace <namespace-name>
```

## Pod Management

> **Official Documentation**: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/) | [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

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

## ReplicaSet Management

> **Official Documentation**: [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

### Creating and Managing ReplicaSets

```bash
# Create ReplicaSet from YAML file
kubectl create -f <replicaset-definition.yml>
kubectl apply -f <replicaset-definition.yml>

# List all ReplicaSets
kubectl get replicaset
kubectl get rs
kubectl get rs -o wide

# List ReplicaSets in all namespaces
kubectl get replicaset --all-namespaces
kubectl get rs -A

# List ReplicaSets with labels
kubectl get rs --show-labels
kubectl get rs -l <label-selector>

# Describe ReplicaSet details
kubectl describe replicaset <replicaset-name>
kubectl describe rs <replicaset-name>

# Delete ReplicaSet
kubectl delete replicaset <replicaset-name>
kubectl delete rs <replicaset-name>
kubectl delete -f <replicaset-definition.yml>
```

### Updating ReplicaSets

```bash
# Replace ReplicaSet definition (updates from YAML file)
kubectl replace -f <replicaset-definition.yml>

# Edit ReplicaSet in place
kubectl edit replicaset <replicaset-name>
kubectl edit rs <replicaset-name>

# Update ReplicaSet image (Note: won't update existing pods)
kubectl set image replicaset/<replicaset-name> <container-name>=<new-image>

# Patch ReplicaSet
kubectl patch replicaset <replicaset-name> -p '<patch-data>'
```

### Scaling ReplicaSets

```bash
# Scale ReplicaSet by name
kubectl scale replicaset <replicaset-name> --replicas=<count>
kubectl scale rs <replicaset-name> --replicas=<count>

# Scale ReplicaSet using file definition
kubectl scale --replicas=<count> -f <replicaset-definition.yml>

# Scale multiple ReplicaSets
kubectl scale replicaset <rs1> <rs2> --replicas=<count>

# Conditional scaling (scale only if current replica count matches)
kubectl scale replicaset <replicaset-name> --current-replicas=<current> --replicas=<new>
```

### ReplicaSet Monitoring

```bash
# Watch ReplicaSet status
kubectl get rs -w

# Get ReplicaSet in YAML format
kubectl get replicaset <replicaset-name> -o yaml

# Get ReplicaSet in JSON format
kubectl get replicaset <replicaset-name> -o json

# Get pods managed by a ReplicaSet
kubectl get pods -l <label-selector>

# Check ReplicaSet events
kubectl get events --field-selector involvedObject.name=<replicaset-name>

# Get ReplicaSet with custom columns
kubectl get rs -o custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas,CURRENT:.status.replicas,READY:.status.readyReplicas
```

### ReplicaSet Troubleshooting

```bash
# Describe ReplicaSet for debugging
kubectl describe rs <replicaset-name>

# Check ReplicaSet conditions
kubectl get rs <replicaset-name> -o jsonpath='{.status.conditions}'

# Get pods created by ReplicaSet
kubectl get pods --selector=<label-from-replicaset>

# Delete all pods in ReplicaSet (will be recreated)
kubectl delete pods -l <label-selector>

# Validate ReplicaSet YAML before applying
kubectl apply --dry-run=client -f <replicaset-definition.yml>
kubectl apply --dry-run=server -f <replicaset-definition.yml>
```

## Deployment Management

> **Official Documentation**: [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) | [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

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

## DaemonSet Management

> **Official Documentation**: [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

```bash
# Create DaemonSet from YAML
kubectl apply -f <daemonset.yaml>

# List DaemonSets
kubectl get daemonsets
kubectl get ds

# Describe DaemonSet
kubectl describe daemonset <daemonset-name>

# Delete DaemonSet
kubectl delete daemonset <daemonset-name>

# Get DaemonSet rollout status
kubectl rollout status daemonset/<daemonset-name>

# View DaemonSet rollout history
kubectl rollout history daemonset/<daemonset-name>

# Update DaemonSet image
kubectl set image daemonset/<daemonset-name> <container>=<image>

# Get pods created by DaemonSet
kubectl get pods -l <label-selector>
```

## StatefulSet Management

> **Official Documentation**: [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

```bash
# Create StatefulSet from YAML
kubectl apply -f <statefulset.yaml>

# List StatefulSets
kubectl get statefulsets
kubectl get sts

# Describe StatefulSet
kubectl describe statefulset <statefulset-name>

# Delete StatefulSet
kubectl delete statefulset <statefulset-name>

# Scale StatefulSet
kubectl scale statefulset <statefulset-name> --replicas=<count>

# Update StatefulSet image
kubectl set image statefulset/<statefulset-name> <container>=<image>

# Patch StatefulSet update strategy
kubectl patch statefulset <statefulset-name> -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'

# Delete pod from StatefulSet (will be recreated)
kubectl delete pod <statefulset-pod-name>
```

## Job and CronJob Management

> **Official Documentation**: [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) | [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

```bash
# Create Job from YAML
kubectl apply -f <job.yaml>

# Create Job imperatively
kubectl create job <job-name> --image=<image>

# List Jobs
kubectl get jobs

# Describe Job
kubectl describe job <job-name>

# Delete Job
kubectl delete job <job-name>

# Get logs from Job pods
kubectl logs job/<job-name>

# Create CronJob from YAML
kubectl apply -f <cronjob.yaml>

# Create CronJob imperatively
kubectl create cronjob <cronjob-name> --image=<image> --schedule="<cron-expression>"

# List CronJobs
kubectl get cronjobs
kubectl get cj

# Describe CronJob
kubectl describe cronjob <cronjob-name>

# Delete CronJob
kubectl delete cronjob <cronjob-name>

# Suspend CronJob
kubectl patch cronjob <cronjob-name> -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob <cronjob-name> -p '{"spec":{"suspend":false}}'

# Manually trigger CronJob
kubectl create job <job-name> --from=cronjob/<cronjob-name>
```

## Scheduling & Resource Management

> **Official Documentation**: [Scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/) | [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

```bash
# Assign pod to specific node (nodeName)
kubectl run <pod-name> --image=<image> --overrides='{"spec":{"nodeName":"<node-name>"}}'

# Create pod with node selector
kubectl run <pod-name> --image=<image> --overrides='{"spec":{"nodeSelector":{"<key>":"<value>"}}}'

# Set resource requests and limits
kubectl set resources deployment <deployment-name> --limits=cpu=200m,memory=256Mi --requests=cpu=100m,memory=128Mi

# View resource quotas
kubectl get resourcequota
kubectl describe resourcequota <quota-name>

# Create resource quota
kubectl create quota <quota-name> --hard=pods=10,requests.cpu=4,requests.memory=8Gi

# View limit ranges
kubectl get limitrange
kubectl describe limitrange <limit-name>

# Get pod priority classes
kubectl get priorityclass

# Label nodes for scheduling
kubectl label nodes <node-name> <label-key>=<label-value>

# Check pod scheduling
kubectl get pods -o wide
kubectl describe pod <pod-name> | grep -i node

# Manual scheduling using binding
# Create a binding object and apply it

# View scheduler logs
kubectl logs -n kube-system <scheduler-pod-name>
```

## Service Management

> **Official Documentation**: [Services](https://kubernetes.io/docs/concepts/services-networking/service/) | [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)

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

# Expose pod as service
kubectl expose pod <pod-name> --port=<port> --name=<service-name>

# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service <service-name>

# Delete service
kubectl delete service <service-name>

# Edit service
kubectl edit service <service-name>
```

### Service Operations

```bash
# Get service endpoints
kubectl get endpoints <service-name>
kubectl get ep

# Port forward to service
kubectl port-forward service/<service-name> <local-port>:<service-port>

# Get service external IP
kubectl get svc <service-name> -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test service connectivity from pod
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
# Then: curl <service-name>:<port>
```

## Ingress Management

> **Official Documentation**: [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) | [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

```bash
# Create Ingress from YAML
kubectl apply -f <ingress.yaml>

# List Ingress resources
kubectl get ingress
kubectl get ing

# Describe Ingress
kubectl describe ingress <ingress-name>

# Delete Ingress
kubectl delete ingress <ingress-name>

# Get Ingress with external address
kubectl get ingress -o wide

# Edit Ingress
kubectl edit ingress <ingress-name>

# Get Ingress class
kubectl get ingressclass

# Annotate Ingress
kubectl annotate ingress <ingress-name> <key>=<value>
```

## Network Policies

> **Official Documentation**: [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

```bash
# Create Network Policy from YAML
kubectl apply -f <network-policy.yaml>

# List Network Policies
kubectl get networkpolicy
kubectl get netpol

# Describe Network Policy
kubectl describe networkpolicy <policy-name>

# Delete Network Policy
kubectl delete networkpolicy <policy-name>

# Get Network Policies in all namespaces
kubectl get networkpolicy -A

# Test network connectivity (from a pod)
kubectl exec <pod-name> -- nc -zv <target-service> <port>
kubectl exec <pod-name> -- wget -qO- <url>
```

## DNS and CoreDNS

> **Official Documentation**: [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) | [CoreDNS](https://kubernetes.io/docs/tasks/administer-cluster/coredns/)

```bash
# Get CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# View CoreDNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Test DNS resolution from pod
kubectl run tmp-shell --rm -i --tty --image busybox -- /bin/sh
# Then: nslookup <service-name>
# Or: nslookup <service-name>.<namespace>.svc.cluster.local

# Debug DNS issues
kubectl exec <pod-name> -- cat /etc/resolv.conf
kubectl exec <pod-name> -- nslookup kubernetes.default
```

## Storage Management

> **Official Documentation**: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) | [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

### Persistent Volume Operations

```bash
# List Persistent Volumes
kubectl get pv

# Describe Persistent Volume
kubectl describe pv <pv-name>

# Create PV from YAML
kubectl apply -f <pv.yaml>

# Delete PV
kubectl delete pv <pv-name>

# Get PV status
kubectl get pv -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CLAIM:.spec.claimRef.name
```

### Persistent Volume Claim Operations

```bash
# List Persistent Volume Claims
kubectl get pvc

# Describe PVC
kubectl describe pvc <pvc-name>

# Create PVC from YAML
kubectl apply -f <pvc.yaml>

# Delete PVC
kubectl delete pvc <pvc-name>

# Get PVC status and bound PV
kubectl get pvc <pvc-name> -o jsonpath='{.status.phase}'
kubectl get pvc <pvc-name> -o jsonpath='{.spec.volumeName}'
```

### Storage Class Operations

```bash
# List Storage Classes
kubectl get storageclass
kubectl get sc

# Describe Storage Class
kubectl describe storageclass <sc-name>

# Create Storage Class from YAML
kubectl apply -f <storageclass.yaml>

# Set default Storage Class
kubectl patch storageclass <sc-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Get default Storage Class
kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}'
```

## ConfigMap and Secret Management

> **Official Documentation**: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) | [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

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

# Edit secret
kubectl edit secret <secret-name>

# Create secret from env file
kubectl create secret generic <secret-name> --from-env-file=<env-file>
```

## Security and RBAC

> **Official Documentation**: [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) | [Security Best Practices](https://kubernetes.io/docs/concepts/security/)

### Role-Based Access Control

```bash
# List Roles and ClusterRoles
kubectl get roles
kubectl get clusterroles

# Create Role
kubectl create role <role-name> --verb=<verb> --resource=<resource>

# Create ClusterRole
kubectl create clusterrole <role-name> --verb=<verb> --resource=<resource>

# List RoleBindings and ClusterRoleBindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Create RoleBinding
kubectl create rolebinding <binding-name> --role=<role-name> --user=<username>

# Create ClusterRoleBinding
kubectl create clusterrolebinding <binding-name> --clusterrole=<role-name> --user=<username>

# Describe RBAC resources
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>
kubectl describe rolebinding <binding-name>

# Check permissions (can-i)
kubectl auth can-i <verb> <resource>
kubectl auth can-i create pods
kubectl auth can-i "*" "*"
kubectl auth can-i delete deployments --namespace=<namespace>

# Check permissions for specific user
kubectl auth can-i create pods --as=<username>
kubectl auth can-i list secrets --as=system:serviceaccount:<namespace>:<sa-name>

# List who can perform action
kubectl auth can-i --list --as=<username>
```

## Service Accounts

> **Official Documentation**: [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)

```bash
# List Service Accounts
kubectl get serviceaccounts
kubectl get sa

# Create Service Account
kubectl create serviceaccount <sa-name>

# Describe Service Account
kubectl describe serviceaccount <sa-name>

# Get Service Account token (Kubernetes 1.24+)
kubectl create token <sa-name>
kubectl create token <sa-name> --duration=<duration>

# Delete Service Account
kubectl delete serviceaccount <sa-name>

# Assign ServiceAccount to pod (in pod spec)
# spec:
#   serviceAccountName: <sa-name>

# Get service account for a pod
kubectl get pod <pod-name> -o jsonpath='{.spec.serviceAccountName}'
```

## Security Contexts

> **Official Documentation**: [Security Context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

```bash
# Create pod with security context (example)
kubectl run secure-pod --image=nginx --dry-run=client -o yaml > pod.yaml
# Edit pod.yaml to add securityContext

# Check pod security context
kubectl get pod <pod-name> -o jsonpath='{.spec.securityContext}'

# Check container security context
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].securityContext}'

# Create pod as non-root user (example)
# securityContext:
#   runAsUser: 1000
#   runAsGroup: 3000
#   fsGroup: 2000

# Create pod with read-only root filesystem
# securityContext:
#   readOnlyRootFilesystem: true
```

## Debugging and Troubleshooting

> **Official Documentation**: [Troubleshooting](https://kubernetes.io/docs/tasks/debug/) | [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

### Pod Debugging

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

````

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
````

## Scaling and Updates

### Scaling Resources

```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=<count>

# Scale ReplicaSet (see ReplicaSet Management section for more details)
kubectl scale replicaset <replicaset-name> --replicas=<count>
kubectl scale --replicas=<count> -f <replicaset-definition.yml>

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

> **Official Documentation**: [Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/) | [Monitoring](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

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

## Cluster Maintenance

> **Official Documentation**: [Cluster Administration](https://kubernetes.io/docs/tasks/administer-cluster/) | [Cluster Upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

```bash
# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Cordon node (prevent new pods from scheduling)
kubectl cordon <node-name>

# Uncordon node (allow scheduling)
kubectl uncordon <node-name>

# Check cluster component status
kubectl get componentstatuses
kubectl get cs

# View cluster version
kubectl version --short

# Get all resources in cluster
kubectl get all --all-namespaces

# Check node conditions
kubectl describe node <node-name> | grep -i condition

# View control plane pods
kubectl get pods -n kube-system

# Upgrade cluster with kubeadm (on control plane)
# kubeadm upgrade plan
# kubeadm upgrade apply v1.x.x

# Upgrade kubelet and kubectl (on each node)
# apt-get update && apt-get install -y kubelet=1.x.x-00 kubectl=1.x.x-00
# systemctl daemon-reload
# systemctl restart kubelet
```

## etcd Backup and Restore

> **Official Documentation**: [etcd Backup and Restore](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster)

```bash
# Backup etcd (snapshot)
ETCDCTL_API=3 etcdctl snapshot save <backup-file> \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=<ca-cert> \
  --cert=<server-cert> \
  --key=<server-key>

# Verify etcd snapshot
ETCDCTL_API=3 etcdctl snapshot status <backup-file>

# Restore etcd from snapshot
ETCDCTL_API=3 etcdctl snapshot restore <backup-file> \
  --data-dir=<data-dir-location>

# Get etcd pod in kube-system
kubectl get pods -n kube-system | grep etcd

# Check etcd health
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=<ca-cert> \
  --cert=<server-cert> \
  --key=<server-key>

# List etcd members
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=<ca-cert> \
  --cert=<server-cert> \
  --key=<server-key>

# Common etcd cert locations:
# --cacert=/etc/kubernetes/pki/etcd/ca.crt
# --cert=/etc/kubernetes/pki/etcd/server.crt
# --key=/etc/kubernetes/pki/etcd/server.key
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

## kubectl Aliases and Shortcuts

> **Pro Tip**: Create aliases to speed up your work during the CKA exam

### Common Aliases (Add to ~/.bashrc or ~/.zshrc)

## kubectl Aliases and Shortcuts

> **Pro Tip**: Create aliases to speed up your work during the CKA exam

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

# Enable kubectl autocompletion (highly recommended for CKA)
source <(kubectl completion bash)
# or for zsh:
source <(kubectl completion zsh)

# Add to .bashrc or .zshrc:
# echo 'source <(kubectl completion bash)' >>~/.bashrc
# echo 'alias k=kubectl' >>~/.bashrc
# echo 'complete -F __start_kubectl k' >>~/.bashrc
```

### Useful One-liners for CKA

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

# Find pods using most memory
kubectl top pods --sort-by=memory

# Get pod restart counts
kubectl get pods -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

# Get all images used in a namespace
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}' | tr -s '[[:space:]]' '\n' | sort | uniq

# Get pod count per node
kubectl get pods -o wide --all-namespaces | awk '{print $8}' | sort | uniq -c

# Force delete pod
kubectl delete pod <pod-name> --grace-period=0 --force

# Get events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Show labels for all pods
kubectl get pods --show-labels

# Run temporary pod for debugging
kubectl run tmp-pod --rm -i --tty --image=busybox -- /bin/sh

# Generate YAML template (dry-run)
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > service.yaml
```

## CKA Exam Tips

> **Official CKA Exam**: [CKA Certification](https://www.cncf.io/certification/cka/) | [Exam Curriculum](https://github.com/cncf/curriculum)

### Key Points for CKA Success

#### 1. **Time Management** (2 hours, 15-20 questions)

- Read all questions first and tackle easier ones
- Use kubectl shortcuts and aliases
- Practice imperative commands to save time
- Bookmark important documentation pages

#### 2. **Essential Commands to Master**

```bash
# Imperative commands (faster than YAML)
kubectl run
kubectl create
kubectl expose
kubectl set
kubectl scale
kubectl autoscale

# Dry-run to generate YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml

# Quick edits
kubectl edit
kubectl patch
```

#### 3. **Documentation Access**

During the exam, you can access:

- [kubernetes.io/docs](https://kubernetes.io/docs/)
- [kubernetes.io/blog](https://kubernetes.io/blog/)
- [github.com/kubernetes](https://github.com/kubernetes/)

**Bookmark these pages:**

- kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- JSONPath: https://kubernetes.io/docs/reference/kubectl/jsonpath/
- kubectl Commands: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

#### 4. **Critical Skills to Practice**

**Cluster Management (25%)**

- RBAC configuration (Roles, ClusterRoles, RoleBindings)
- Node management (drain, cordon, uncordon)
- Cluster upgrades with kubeadm
- etcd backup and restore
- Certificate management

**Workloads & Scheduling (15%)**

- Create Deployments, DaemonSets, StatefulSets
- Configure resource requests and limits
- Use nodeSelector, nodeName, affinity, taints, and tolerations
- Understand static pods
- Configure manual scheduling

**Services & Networking (20%)**

- Create Services (ClusterIP, NodePort, LoadBalancer)
- Configure Ingress resources
- Implement Network Policies
- Understand DNS resolution in Kubernetes

**Storage (10%)**

- Create PersistentVolumes and PersistentVolumeClaims
- Configure StorageClasses
- Use volume mounts in pods

**Troubleshooting (30%)**

- Debug application failures
- Debug cluster component failures
- Debug networking issues
- Analyze logs and events
- Understand pod lifecycle and common issues

#### 5. **Common Exam Scenarios**

```bash
# Scenario 1: Create a pod with specific requirements
kubectl run web --image=nginx --port=80 --labels=app=web,tier=frontend --requests='cpu=100m,memory=128Mi' --limits='cpu=200m,memory=256Mi' --dry-run=client -o yaml > pod.yaml

# Scenario 2: Expose a deployment
kubectl expose deployment web --name=web-service --type=NodePort --port=80 --target-port=80

# Scenario 3: Scale deployment
kubectl scale deployment web --replicas=5

# Scenario 4: Create service account and assign to pod
kubectl create serviceaccount app-sa
# Add serviceAccountName: app-sa to pod spec

# Scenario 5: Troubleshoot failing pod
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --field-selector involvedObject.name=<pod-name>

# Scenario 6: Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Scenario 7: etcd backup
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Scenario 8: Create NetworkPolicy
# Allow only specific pods to access a pod
```

#### 6. **Vim Shortcuts for Faster Editing**

```bash
# Set vim options for YAML (add to ~/.vimrc)
set tabstop=2
set shiftwidth=2
set expandtab

# Quick vim commands
:set paste        # Enable paste mode
:set number       # Show line numbers
dd               # Delete line
yy               # Copy line
p                # Paste
u                # Undo
Ctrl+r           # Redo
/search-term     # Search
n                # Next search result
:%s/old/new/g    # Replace all
:wq              # Save and quit
:q!              # Quit without saving
```

#### 7. **Common Mistakes to Avoid**

- Not reading the question carefully (check namespace!)
- Forgetting to switch context/namespace
- Not verifying your work
- Spending too much time on one question
- Not using imperative commands when possible
- Forgetting to check if resources are in correct namespace

#### 8. **Verification Checklist**

After completing a task, always verify:

```bash
# Check if resource was created
kubectl get <resource-type> <resource-name>

# Verify resource is in correct namespace
kubectl get <resource-type> -n <namespace>

# Check pod status
kubectl get pods -o wide

# Verify resource details
kubectl describe <resource-type> <resource-name>

# Check logs if pod is running
kubectl logs <pod-name>
```

#### 9. **Practice Resources**

- **Killer.sh**: Two free CKA simulator sessions (included with exam registration)
- **KodeKloud**: CKA course with hands-on labs
- **GitHub**: Practice questions and scenarios
- **Kubernetes The Hard Way**: Deep understanding of cluster setup

#### 10. **Exam Environment**

- Remote proctored exam via PSI
- Browser-based terminal
- Copy-paste might be different (Ctrl+Shift+C/V or right-click)
- One additional monitor allowed
- Keep workspace clean (no papers, books, phones)
- Valid government ID required

### Quick Reference: Imperative vs Declarative

#### Imperative (Faster for Exam)

```bash
kubectl run nginx --image=nginx
kubectl create deployment web --image=nginx --replicas=3
kubectl expose deployment web --port=80
kubectl scale deployment web --replicas=5
kubectl set image deployment/web nginx=nginx:1.19
```

#### Declarative (Better for Production)

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f .
```

#### Hybrid Approach (Best for Exam)

```bash
# Generate YAML with imperative command
kubectl create deployment web --image=nginx --dry-run=client -o yaml > deployment.yaml

# Edit YAML as needed
vi deployment.yaml

# Apply the YAML
kubectl apply -f deployment.yaml
```

---

## Additional Resources

- **Official Kubernetes Documentation**: https://kubernetes.io/docs/
- **kubectl Reference**: https://kubernetes.io/docs/reference/kubectl/
- **CKA Exam Curriculum**: https://github.com/cncf/curriculum
- **Kubernetes API Reference**: https://kubernetes.io/docs/reference/kubernetes-api/
- **Killer.sh CKA Simulator**: https://killer.sh/cka
- **Practice Exercises**: https://github.com/dgkanatsios/CKAD-exercises
