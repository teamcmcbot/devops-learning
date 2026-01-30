# Certified Kubernetes Administrator (CKA)

## Overview

The Certified Kubernetes Administrator (CKA) program provides assurance that CKAs have the skills, knowledge, and competency to perform the responsibilities of Kubernetes administrators. This certification is for Kubernetes administrators, cloud administrators and other IT professionals who manage Kubernetes instances.

https://www.cncf.io/training/certification/cka/

## Exam Details

- **Duration:** 2 hours
- **Format:** Performance-based tasks (hands-on)
- **Passing Score:** 66%
- **Cost:** $445
- **Validity:** 2 years
- **Format:** The exams consist of 15-20 performance-based tasks.

## Domains

### Storage – 10%

- Implement storage classes and dynamic volume provisioning
- Configure volume types, access modes and reclaim policies
- Manage persistent volumes and persistent volume claims

### Troubleshooting – 30%

- Troubleshoot clusters and nodes
- Troubleshoot cluster components
- Monitor cluster and application resource usage
- Manage and evaluate container output streams
- Troubleshoot services and networking

### Workloads and Scheduling – 15%

- Understand application deployments and how to perform rolling update and rollbacks
- Use ConfigMaps and Secrets to configure applications
- Configure workload autoscaling
- Understand the primitives used to create robust, self-healing, application deployments
- Configure Pod admission and scheduling (limits, node affinity, etc.)

### Cluster Architecture, Installation and Configuration – 25%

- Manage role based access control (RBAC)
- Prepare underlying infrastructure for installing a Kubernetes cluster
- Create and manage Kubernetes clusters using kubeadm
- Manage the lifecycle of Kubernetes clusters
- Implement and configure a highly-available control plane
- Use Helm and Kustomize to install cluster components
- Understand extension interfaces (CNI, CSI, CRI, etc.)
- Understand CRDs, install and configure operators

### Services and Networking – 20%

- Understand connectivity between Pods
- Define and enforce Network Policies
- Use ClusterIP, NodePort, LoadBalancer service types and endpoints
- Use the Gateway API to manage Ingress traffic
- Know how to use Ingress controllers and Ingress resources
- Understand and use CoreDNS

## CKA Exam Environment

### Task Execution

- You must complete each task in this exam on a **designated host**
- An infobox at the start of each task provides instructions to SSH into the designated host
- Once you have completed a task, exit the SSH session to return to the base system (hostname `base`)
- Nested SSH is **not supported**

### SSH Access

Hosts can be reached via SSH using the following command:

```bash
ssh <nodename>
```

### Elevated Privileges

You can assume elevated privileges on any host by issuing:

```bash
sudo -i
```

You can also use `sudo` to execute commands with elevated privileges at any time.

### Pre-installed Tools

For your convenience, all SSH hosts have the following command-line tools pre-installed and pre-configured:

| Tool | Description |
|------|-------------|
| `kubectl` | With `k` alias and Bash autocompletion |
| `yq` | For YAML processing |
| `curl` and `wget` | For testing web services |
| `man` | Man pages for further documentation |

> **Note:** The base system (hostname `base`) does not have any of the above tools pre-installed as all tasks on this exam must be completed on a designated SSH host.

### Kubernetes Version

- **CKA environment:** Kubernetes v1.34
- **CKAD environment:** Kubernetes v1.34

The CKA and CKAD exam environment will be aligned with the most recent K8s minor version within approximately 4 to 8 weeks of the K8s release date.

### Resources Allowed

The following tools and resources are allowed during the exam as long as they are used by candidates to work independently on exam tasks (i.e. not used for 3rd party assistance or research) and are accessed from within the Linux server terminal on which the Exam is delivered.

#### During the exam, candidates may:

**Use the browser within the VM to access the following documentation:**

| Resource | URL |
|----------|-----|
| Kubernetes Documentation | https://kubernetes.io/docs |
| Kubernetes Blog | https://kubernetes.io/blog |
| Helm Documentation | https://helm.sh/docs |
| Gateway API Documentation *(CKA only)* | https://gateway-api.sigs.k8s.io |

> **Note:** Using the search function on https://kubernetes.io/docs/ is allowed, but you must **not** open external search results.

This includes all available language translations (e.g. https://kubernetes.io/zh/docs/)

**Additional allowed resources:**

- Task-specific documentation provided in the Quick Reference box (includes links to documentation for various tools needed to solve a task)
- Review the Exam content instructions presented in the command line terminal
- Review documents installed by the distribution (i.e. `/usr/share` and its subdirectories)
- Use packages that are part of the distribution (may also be installed by candidate if not available by default)