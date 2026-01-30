# Kubernetes Cluster Architecture

## Executive Summary

A Kubernetes cluster consists of **Master (Control Plane) Nodes** and **Worker Nodes**. The master nodes manage the cluster state and make scheduling decisions, while worker nodes run the actual containerized applications.

### Control Plane Components (Master Node)

| Component                   | Purpose                                                  |
| --------------------------- | -------------------------------------------------------- |
| **ETCD**                    | Distributed key-value store for cluster state            |
| **kube-apiserver**          | Central management hub, processes all API requests       |
| **kube-controller-manager** | Runs controllers that monitor and maintain cluster state |
| **kube-scheduler**          | Assigns pods to nodes based on resources and constraints |

### Worker Node Components

| Component             | Purpose                                                 |
| --------------------- | ------------------------------------------------------- |
| **kubelet**           | Agent that manages pod lifecycle on each node           |
| **kube-proxy**        | Network proxy that maintains network rules for Services |
| **Container Runtime** | Docker, containerd, or CRI-O to run containers          |

---

## ETCD

Distributed key-value store that holds all cluster data: nodes, pods, configs, secrets, accounts, roles, and bindings.

### Key Points

- Listens on port **2379**
- All cluster changes are recorded in ETCD first
- Data stored under `/registry` directory

### Common Commands

```bash
# View keys in etcd (kubeadm setup)
kubectl exec etcd-master -n kube-system -- etcdctl get / --prefix --keys-only

# Check etcd pod
kubectl get pods -n kube-system | grep etcd

# View etcd configuration
cat /etc/kubernetes/manifests/etcd.yaml
```

---

## Kube API Server

The central hub that processes all API requests, authenticates users, validates requests, and communicates with ETCD.

### Request Lifecycle

1. Authenticate user
2. Validate request
3. Retrieve/Update data in ETCD
4. Scheduler assigns node (for new pods)
5. Kubelet deploys the pod

### Common Commands

```bash
# View API server pod
kubectl get pods -n kube-system | grep apiserver

# View API server configuration (kubeadm)
cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Check running process
ps -aux | grep kube-apiserver
```

---

## Kube Controller Manager

Manages various controllers that continuously monitor and maintain the desired cluster state.

### Key Controllers

- **Node Controller**: Monitors node health (5s intervals, 40s grace period, 5min eviction timeout)
- **Replication Controller**: Maintains desired pod count
- **Deployment Controller**: Manages deployments and rollouts
- **Namespace Controller**: Manages namespace lifecycle

### Common Commands

```bash
# View controller manager pod
kubectl get pods -n kube-system | grep controller

# View configuration
cat /etc/kubernetes/manifests/kube-controller-manager.yaml

# Check running process
ps -aux | grep kube-controller-manager
```

---

## Kube Scheduler

Determines which node should run a new pod using a two-phase process:

1. **Filtering**: Eliminates nodes that don't meet resource requirements
2. **Ranking**: Scores remaining nodes (0-10) based on available resources

### Common Commands

```bash
# View scheduler pod
kubectl get pods -n kube-system | grep scheduler

# View configuration
cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Check running process
ps -aux | grep kube-scheduler
```

---

## Kubelet

The "captain" of each worker node - manages pod lifecycle and reports status to the API server.

### Key Points

- **NOT automatically deployed by kubeadm** - must be installed manually
- Receives instructions from API server
- Communicates with container runtime to deploy containers

### Common Commands

```bash
# Check kubelet process
ps -aux | grep kubelet

# View kubelet configuration
cat /var/lib/kubelet/config.yaml

# Check kubelet status
systemctl status kubelet
```

---

## Kube Proxy

Network proxy running on every node that maintains network rules for Services.

### Key Points

- Uses **iptables** rules to forward traffic
- Deployed as a **DaemonSet** (one pod per node)
- Enables pod-to-pod and Service-to-pod communication

### Common Commands

```bash
# View kube-proxy pods
kubectl get pods -n kube-system | grep proxy

# View kube-proxy DaemonSet
kubectl get daemonset -n kube-system

# Check iptables rules
iptables -L -t nat | grep <service-name>
```

---

## CKA Exam Relevance

### What to Know

- Understand each component's role and how they interact
- Know where to find configuration files (`/etc/kubernetes/manifests/`)
- Be able to troubleshoot component failures
- Understand ETCD backup and restore

### Common Exam Tasks

- Identify failing components
- View and interpret component logs
- Check component status and configurations

### Key Paths to Remember

| File/Path                    | Purpose                        |
| ---------------------------- | ------------------------------ |
| `/etc/kubernetes/manifests/` | Static pod manifests (kubeadm) |
| `/etc/kubernetes/pki/`       | Certificates                   |
| `/var/lib/kubelet/`          | Kubelet configuration          |
| `/var/lib/etcd/`             | ETCD data directory            |

---

## Official Documentation

- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [ETCD](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
- [kube-apiserver](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
- [kube-scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)
- [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
