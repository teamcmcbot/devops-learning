# CKA Documentation Guide

A guide for efficiently navigating Kubernetes documentation during the CKA exam.

## Key Documentation URLs

Since you cannot use bookmarks in the exam, memorize these important paths:

| Topic                     | URL Path                               |
| ------------------------- | -------------------------------------- |
| **kubectl Cheat Sheet**   | `/docs/reference/kubectl/cheatsheet/`  |
| **Tasks (How-to guides)** | `/docs/tasks/`                         |
| **Concepts**              | `/docs/concepts/`                      |
| **API Reference**         | `/docs/reference/kubernetes-api/`      |
| **kubeadm Reference**     | `/docs/reference/setup-tools/kubeadm/` |

## Quick Search Keywords by Domain

### Storage (10%)

| Topic              | Search Keywords                         |
| ------------------ | --------------------------------------- |
| Persistent Volumes | `persistent volume`, `pv pvc`           |
| Storage Classes    | `storage class`, `dynamic provisioning` |
| Volume Types       | `volumes`, `hostPath`, `emptyDir`       |
| Access Modes       | `access modes ReadWriteOnce`            |

### Troubleshooting (30%)

| Topic                   | Search Keywords                        |
| ----------------------- | -------------------------------------- |
| Cluster Troubleshooting | `troubleshoot cluster`                 |
| Application Debugging   | `debug running pod`, `debug service`   |
| Node Issues             | `troubleshoot node`                    |
| Logging                 | `logging architecture`, `kubectl logs` |

### Workloads and Scheduling (15%)

| Topic              | Search Keywords                        |
| ------------------ | -------------------------------------- |
| Deployments        | `deployment`, `rolling update`         |
| ConfigMaps         | `configmap`, `configure pod configmap` |
| Secrets            | `secret`, `distribute credentials`     |
| Autoscaling        | `horizontal pod autoscaler`, `hpa`     |
| Node Affinity      | `assign pod node`, `node affinity`     |
| Taints/Tolerations | `taints tolerations`                   |
| Resource Limits    | `resource quota`, `limit range`        |

### Cluster Architecture, Installation & Configuration (25%)

| Topic             | Search Keywords                                   |
| ----------------- | ------------------------------------------------- |
| RBAC              | `rbac`, `role binding`, `cluster role`            |
| kubeadm           | `kubeadm init`, `kubeadm join`, `kubeadm upgrade` |
| etcd Backup       | `etcd backup`, `operating etcd`                   |
| Certificates      | `certificate signing request`, `kubeadm certs`    |
| High Availability | `high availability`, `ha topology`                |
| Helm              | Use https://helm.sh/docs                          |
| CRDs              | `custom resource definition`, `extend kubernetes` |

### Services and Networking (20%)

| Topic            | Search Keywords                                    |
| ---------------- | -------------------------------------------------- |
| Services         | `service`, `ClusterIP`, `NodePort`, `LoadBalancer` |
| Network Policies | `network policy`, `network policies`               |
| Ingress          | `ingress`, `ingress controller`                    |
| Gateway API      | Use https://gateway-api.sigs.k8s.io                |
| DNS              | `dns kubernetes`, `coredns`, `debugging dns`       |
| Pod Networking   | `cluster networking`                               |

## Using kubectl Instead of Documentation

### kubectl explain

Get field documentation directly from the cluster:

```bash
# Get pod spec fields
kubectl explain pod.spec

# Get container fields
kubectl explain pod.spec.containers

# Recursive output (all fields)
kubectl explain deployment.spec --recursive

# Specific field details
kubectl explain pv.spec.persistentVolumeReclaimPolicy
```

### kubectl --help

Get command syntax and examples:

```bash
# General help
kubectl --help

# Command-specific help
kubectl run --help
kubectl create --help
kubectl expose --help

# Subcommand help
kubectl create deployment --help
kubectl create secret generic --help
kubectl create configmap --help
```

### kubectl with --dry-run

Generate YAML templates without documentation:

```bash
# Generate Pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Generate Deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml

# Generate Service YAML
kubectl expose pod nginx --port=80 --dry-run=client -o yaml > svc.yaml

# Generate Job YAML
kubectl create job my-job --image=busybox --dry-run=client -o yaml -- /bin/sh -c "echo hello"

# Generate CronJob YAML
kubectl create cronjob my-cron --image=busybox --schedule="*/5 * * * *" --dry-run=client -o yaml -- /bin/sh -c "echo hello"

# Generate ConfigMap YAML
kubectl create configmap my-config --from-literal=key=value --dry-run=client -o yaml

# Generate Secret YAML
kubectl create secret generic my-secret --from-literal=password=secret --dry-run=client -o yaml

# Generate ServiceAccount YAML
kubectl create serviceaccount my-sa --dry-run=client -o yaml

# Generate Role YAML
kubectl create role my-role --verb=get,list --resource=pods --dry-run=client -o yaml

# Generate RoleBinding YAML
kubectl create rolebinding my-rb --role=my-role --user=myuser --dry-run=client -o yaml

# Generate ClusterRole YAML
kubectl create clusterrole my-cr --verb=get,list --resource=nodes --dry-run=client -o yaml

# Generate ClusterRoleBinding YAML
kubectl create clusterrolebinding my-crb --clusterrole=my-cr --user=myuser --dry-run=client -o yaml
```

## Documentation Navigation Tips

### 1. Use the Search Bar Effectively

- Type specific keywords, not sentences
- Use official Kubernetes terms (e.g., "PersistentVolumeClaim" not "storage request")
- Look for results from `/docs/tasks/` for step-by-step guides

### 2. Tasks Section is Your Best Friend

The `/docs/tasks/` section contains practical how-to guides:

- `tasks/configure-pod-container/` - Pod configuration
- `tasks/administer-cluster/` - Cluster administration
- `tasks/access-application-cluster/` - Services, Ingress
- `tasks/run-application/` - Deployments, scaling

### 3. Copy-Paste Ready Examples

Look for pages with YAML examples you can copy:

- Search for the resource type + "example"
- Most task pages have complete YAML manifests
- Modify the examples rather than writing from scratch

### 4. Use the kubectl Cheat Sheet

The cheat sheet (`/docs/reference/kubectl/cheatsheet/`) contains:

- Common command patterns
- Output formatting options
- Resource shortcuts
- Context and namespace switching

## Time-Saving Aliases (Pre-configured in Exam)

These are already set up in the exam environment:

```bash
# kubectl alias
alias k=kubectl

# Use it like this
k get pods
k describe node
k apply -f manifest.yaml
```

## Common Documentation Paths to Memorize

```
kubernetes.io/docs/
├── concepts/
│   ├── workloads/
│   │   ├── pods/
│   │   └── controllers/
│   ├── services-networking/
│   ├── storage/
│   └── security/
├── tasks/
│   ├── configure-pod-container/
│   ├── administer-cluster/
│   ├── access-application-cluster/
│   └── run-application/
└── reference/
    ├── kubectl/
    │   └── cheatsheet/
    ├── kubernetes-api/
    └── setup-tools/
        └── kubeadm/
```

## Practice Strategy

1. **Practice without bookmarks** - Simulate exam conditions
2. **Time yourself** searching for specific topics
3. **Learn to use `kubectl explain`** - Often faster than docs
4. **Memorize YAML structure** for common resources
5. **Use `--dry-run=client -o yaml`** to generate templates
