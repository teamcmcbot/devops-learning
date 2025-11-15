# Prometheus Monitoring Stack Setup

This document explains the complete Prometheus monitoring setup using the Prometheus Operator and kube-prometheus-stack for Kubernetes cluster monitoring.

## Overview

The monitoring stack consists of two main components:

1. **Custom Resource Definitions (CRDs)** - Define new Kubernetes resource types
2. **Monitoring Stack Deployment** - Complete monitoring solution with Prometheus, Grafana, and AlertManager

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Prometheus    │────│  AlertManager    │────│     Slack       │
│   (Metrics)     │    │   (Alerts)       │    │ (Notifications) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │
         │              ┌────────────────┐
         │              │   Grafana      │
         │              │ (Visualization)│
         │              └────────────────┘
         │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  kube-state-    │    │ prometheus-node- │    │   Application   │
│   metrics       │    │    exporter      │    │    Metrics     │
│ (K8s Objects)   │    │ (Node Metrics)   │    │   (Custom)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## File Structure

### 1. crds.yaml - Custom Resource Definitions

**Purpose**: Extends Kubernetes API with Prometheus Operator resource types

**Contents**:

- `AlertmanagerConfig` - Namespaced AlertManager configurations
- `Alertmanager` - AlertManager cluster deployments
- `PodMonitor` - Monitor specific pods for metrics
- `Probe` - Monitor external targets/ingresses
- `Prometheus` - Prometheus server deployments
- `PrometheusRule` - Define alerting and recording rules
- `ServiceMonitor` - Monitor services for metrics
- `ThanosRuler` - Thanos ruler for long-term storage

**Source**:

```
https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.50.0/example/prometheus-operator-crd/
```

**Key Features**:

- **Declarative Configuration**: Manage monitoring as Kubernetes resources
- **Namespace Scoped**: Most resources work within specific namespaces
- **Version**: Uses `v0.50.0` of Prometheus Operator (5-7 years old)

### 2. eks-monitoring.yaml - Complete Monitoring Stack

**Purpose**: Deploys the entire kube-prometheus-stack monitoring solution

**Generated From**: `kube-prometheus-stack` Helm chart (expanded to static YAML)

## Components Deployed

### Core Monitoring Components

#### 1. Prometheus Server

- **Purpose**: Metrics collection and storage
- **Configuration**:
  - Scrapes metrics from Kubernetes API
  - Stores time-series data
  - Evaluates alerting rules
- **Access**: ClusterIP service `monitoring-kube-prometheus-prometheus`

#### 2. AlertManager

- **Purpose**: Alert routing and notification management
- **Configuration**:
  - Default config routes to "null" receiver
  - Watchdog alert handling
  - Ready for Slack integration
- **Access**: ClusterIP service `monitoring-kube-prometheus-alertmanager`

#### 3. Grafana

- **Purpose**: Metrics visualization and dashboarding
- **Configuration**:
  - Pre-configured dashboards for Kubernetes monitoring
  - Connected to Prometheus as data source
  - Default admin credentials (admin/admin)
- **Access**: ClusterIP service `monitoring-grafana`

### Data Collection Components

#### 4. kube-state-metrics

- **Purpose**: Kubernetes object metrics (pods, deployments, etc.)
- **Metrics Provided**:
  - Pod status and restarts
  - Deployment replica counts
  - Node conditions
  - Resource quotas

#### 5. prometheus-node-exporter

- **Purpose**: Node-level metrics (CPU, memory, disk, network)
- **Deployment**: DaemonSet (runs on every node)
- **Metrics Provided**:
  - System resource utilization
  - Hardware information
  - Network statistics

#### 6. Prometheus Operator

- **Purpose**: Manages Prometheus and AlertManager deployments
- **Functions**:
  - Watches for PrometheusRule changes
  - Automatically updates configurations
  - Manages service discovery

## Pre-configured Alert Rules

The monitoring stack includes comprehensive alerting rules:

### AlertManager Rules

- `AlertmanagerFailedReload` - Configuration reload failures
- `AlertmanagerMembersInconsistent` - Cluster member issues
- `AlertmanagerClusterCrashlooping` - Repeated crashes
- `AlertmanagerConfigInconsistent` - Configuration mismatches

### Kubernetes Pod Rules

- `KubePodCrashLooping` - Pods stuck in crash loops
- `KubePodNotReady` - Pods unable to reach ready state

### etcd Rules

- `etcdInsufficientMembers` - etcd cluster too small
- `etcdNoLeader` - etcd leader election issues
- `etcdHighNumberOfLeaderChanges` - Frequent leadership changes

## Grafana Dashboards

Pre-configured dashboards include:

### Cluster Overview

- `cluster-total` - Overall cluster resource usage
- `k8s-resources-cluster` - Cluster-level Kubernetes resources

### Node Monitoring

- `nodes` - Node status and resource usage
- `node-rsrc-use` - Individual node resource utilization
- `node-cluster-rsrc-use` - Cross-node resource analysis

### Pod and Workload Monitoring

- `k8s-resources-pod` - Pod-level resource usage
- `k8s-resources-workload` - Workload (deployment/daemonset) metrics
- `k8s-resources-workloads-namespace` - Namespace workload overview

### Component-Specific

- `prometheus` - Prometheus server metrics
- `alertmanager-overview` - AlertManager status
- `kubelet` - Kubelet metrics
- `etcd` - etcd cluster health
- `k8s-coredns` - CoreDNS performance

## Deployment Instructions

### 1. Deploy CRDs First

```bash
kubectl apply -f crds.yaml
```

**What this does**:

- Registers new Kubernetes resource types
- Enables Prometheus Operator functionality
- Must be applied before the monitoring stack

### 2. Deploy Monitoring Stack

```bash
kubectl apply -f eks-monitoring.yaml
```

**What this deploys**:

- Complete monitoring infrastructure
- All components in `monitoring` namespace
- Pre-configured integrations between components

### 3. Verify Deployment

```bash
# Check all monitoring components
kubectl get all -n monitoring

# Check custom resources
kubectl get prometheusrules -n monitoring
kubectl get servicemonitors -n monitoring
kubectl get prometheus -n monitoring
kubectl get alertmanager -n monitoring
```

## Access Services

### Port Forward Access

```bash
# Prometheus UI
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

# Grafana UI
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

# AlertManager UI
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093
```

### Default Credentials

- **Grafana**: admin / admin (encoded in secret)
- **Prometheus**: No authentication
- **AlertManager**: No authentication

## RBAC and Security

The deployment includes comprehensive RBAC:

### Service Accounts

- `monitoring-kube-prometheus-operator` - Operator permissions
- `monitoring-kube-prometheus-prometheus` - Prometheus scraping permissions
- `monitoring-kube-prometheus-alertmanager` - AlertManager permissions
- `monitoring-grafana` - Grafana access permissions

### ClusterRoles

- Read access to all Kubernetes resources for metrics collection
- Pod Security Policy bindings
- Network policy monitoring permissions

## Customization for AlertManager

### Slack Integration

To enable Slack notifications, update the AlertManager secret:

1. Decode current config:

```bash
kubectl get secret -n monitoring alertmanager-monitoring-kube-prometheus-alertmanager -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d
```

2. Create custom AlertManager config:

```yaml
global:
  slack_api_url: "YOUR_SLACK_WEBHOOK_URL"
route:
  group_by: ["alertname"]
  group_wait: 5s
  group_interval: 1m
  repeat_interval: 10m
  receiver: "slack"
receivers:
  - name: "slack"
    slack_configs:
      - channel: "#alerts"
        icon_emoji: ":bell:"
        send_resolved: true
        text: "<!channel> \nsummary: {{ .CommonAnnotations.summary }}\ndescription: {{ .CommonAnnotations.description }}"
```

3. Update the secret:

```bash
kubectl create secret generic alertmanager-monitoring-kube-prometheus-alertmanager \
  --from-file=alertmanager.yaml \
  --dry-run=client -o yaml | kubectl apply -n monitoring -f -
```

## Course Context Notes

### Outdated Elements (5-7 years old)

- **Prometheus Operator v0.50.0** (current: v0.70+)
- **Image registries**: Some references to deprecated registries
- **Dashboard versions**: 1.14 compatibility (current: 4.x+)
- **Security policies**: Uses PodSecurityPolicy (deprecated in K8s 1.25+)

### Still Valid Elements

- **Core architecture** - Still industry standard
- **Alert rule structure** - Prometheus alerting unchanged
- **RBAC patterns** - Still required and correct
- **Service discovery** - Kubernetes integration unchanged

### Modern Alternatives

- **Helm deployment**: Use `helm install kube-prometheus-stack`
- **GitOps**: Manage via ArgoCD/Flux
- **Pod Security Standards**: Replace PodSecurityPolicy
- **Custom metrics**: OpenTelemetry integration

## Troubleshooting

### Common Issues

1. **CRDs not applied**: Apply crds.yaml first
2. **RBAC errors**: Check service account permissions
3. **Metrics not appearing**: Verify ServiceMonitor configurations
4. **Alerts not firing**: Check PrometheusRule syntax and evaluation

### Useful Commands

```bash
# Check Prometheus config
kubectl exec -n monitoring deployment/monitoring-kube-prometheus-operator -- promtool check config /etc/prometheus/prometheus.yml

# View AlertManager config
kubectl logs -n monitoring alertmanager-monitoring-kube-prometheus-alertmanager-0

# Check rule evaluation
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Navigate to Status > Rules in UI
```

## Testing Alert Flow

Use the provided `bad-pod.yaml` to test the complete alerting pipeline:

1. Deploy failing pod → Pod crashes
2. Prometheus scrapes metrics → Detects failures
3. `KubePodCrashLooping` rule fires → Alert generated
4. AlertManager processes alert → Groups and routes
5. Notification sent → Slack (if configured)

This validates the entire monitoring and alerting workflow.
