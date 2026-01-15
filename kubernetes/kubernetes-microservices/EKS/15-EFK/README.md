# EFK Stack Setup for Kubernetes

This directory contains the configuration for deploying an EFK (Elasticsearch, Fluentd, Kibana) stack for centralized logging in a Kubernetes cluster, specifically designed for EKS (Amazon Elastic Kubernetes Service).

## Overview

The EFK stack provides a complete logging solution that collects, processes, stores, and visualizes logs from your Kubernetes cluster. This setup uses:

- **Fluentd**: Log collection and forwarding agent
- **Elasticsearch**: Search and analytics engine for log storage
- **Kibana**: Web interface for log visualization and analysis

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│    Fluentd      │───▶│   Elasticsearch  │───▶│     Kibana      │
│  (DaemonSet)    │    │   (StatefulSet)  │    │  (Deployment)   │
│                 │    │                  │    │                 │
│ Collects logs   │    │ Stores & indexes │    │ Visualizes logs │
│ from all nodes  │    │ log data         │    │ via web UI      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Components Breakdown

### 1. Fluentd Configuration

**DaemonSet**: `fluentd-es-v2.2.0`

- Runs on every node in the cluster
- Collects logs from multiple sources:
  - Container logs (`/var/log/containers/`)
  - System logs (`/var/log/`)
  - Docker container logs (`/var/lib/docker/containers/`)

**Key Features**:

- **RBAC**: ServiceAccount with permissions to read pods and namespaces
- **Priority**: `system-node-critical` priority class
- **Resources**: 200Mi memory request, 500Mi limit; 100m CPU request
- **Configuration**: Uses ConfigMap `fluentd-es-config-v0.1.4` (separate file)

**Volume Mounts**:

```yaml
- /var/log → Host log directory
- /var/lib/docker/containers → Docker container logs (read-only)
- /etc/fluent/config.d → Fluentd configuration from ConfigMap
```

### 2. Elasticsearch Configuration

**StatefulSet**: `elasticsearch-logging`

- **Replicas**: 2 instances for high availability
- **Version**: v6.2.5
- **Storage**: 31Gi persistent volumes with `cloud-ssd` storage class
- **Ports**:
  - 9200 (REST API)
  - 9300 (Inter-node transport)

**Key Features**:

- **Init Container**: Sets `vm.max_map_count=262144` (Elasticsearch requirement)
- **Service**: Internal service exposing port 9200
- **RBAC**: ServiceAccount with permissions for services, namespaces, and endpoints
- **Resources**: 100m CPU request, 1000m CPU limit (burstable for initialization)

**Environment Variables**:

- `NAMESPACE`: Automatically injected from pod metadata

### 3. Kibana Configuration

**Deployment**: `kibana-logging`

- **Replicas**: 1 instance
- **Version**: 6.2.4 (OSS edition)
- **Port**: 5601 (Web UI)

**Key Features**:

- **Service**: LoadBalancer type for external access
- **Environment**: Points to `http://elasticsearch-logging:9200`
- **Resources**: 100m CPU request, 1000m CPU limit

## Deployment Instructions

### Prerequisites

1. **EKS Cluster**: Running EKS cluster with sufficient resources
2. **StorageClass**: Ensure `cloud-ssd` storage class is available
3. **Fluentd Configuration**: Deploy the `fluentd-config.yaml` ConfigMap first

### Deployment Steps

1. **Apply the Fluentd ConfigMap** (if not already deployed):

   ```bash
   kubectl apply -f fluentd-config.yaml
   ```

2. **Deploy the EFK Stack**:

   ```bash
   kubectl apply -f elastic-stack.yaml
   ```

3. **Verify Deployment**:

   ```bash
   # Check all components
   kubectl get pods -n kube-system | grep -E "(fluentd|elasticsearch|kibana)"

   # Check services
   kubectl get svc -n kube-system | grep -E "(elasticsearch|kibana)"

   # Check storage
   kubectl get pvc -n kube-system
   ```

### Accessing Kibana

1. **Get LoadBalancer URL**:

   ```bash
   kubectl get svc kibana-logging -n kube-system
   ```

2. **Access via Browser**:
   - Use the EXTERNAL-IP from the LoadBalancer service
   - Default port: 5601
   - URL: `http://<EXTERNAL-IP>:5601`

## Configuration Details

### Storage Requirements

- **Elasticsearch**: 31Gi per replica (62Gi total for 2 replicas)
- **Storage Class**: `cloud-ssd` (AWS EBS SSD volumes)
- **Access Mode**: `ReadWriteOnce`

### Resource Requirements

| Component     | CPU Request | CPU Limit | Memory Request | Memory Limit |
| ------------- | ----------- | --------- | -------------- | ------------ |
| Fluentd       | 100m        | -         | 200Mi          | 500Mi        |
| Elasticsearch | 100m        | 1000m     | -              | -            |
| Kibana        | 100m        | 1000m     | -              | -            |

### Security Considerations

- All components run with dedicated ServiceAccounts
- RBAC configured with minimal required permissions
- Fluentd runs with `system-node-critical` priority
- Security context applied where needed

## Troubleshooting

### Common Issues

1. **Pods in Pending State**:

   - Check if storage class `cloud-ssd` exists
   - Verify sufficient cluster resources

2. **Fluentd Not Collecting Logs**:

   - Ensure ConfigMap `fluentd-es-config-v0.1.4` is deployed
   - Check node selector if commented out

3. **Elasticsearch Initialization Issues**:
   - Check if `vm.max_map_count` is set correctly
   - Verify persistent volume provisioning

### Useful Commands

```bash
# Check Fluentd logs
kubectl logs -n kube-system -l k8s-app=fluentd-es

# Check Elasticsearch status
kubectl exec -n kube-system elasticsearch-logging-0 -- curl localhost:9200/_cluster/health

# Port forward to Kibana (if LoadBalancer not working)
kubectl port-forward -n kube-system svc/kibana-logging 5601:5601
```

## Monitoring and Maintenance

### Log Retention

Elasticsearch stores logs indefinitely by default. Consider implementing:

- Index lifecycle management (ILM)
- Automated cleanup policies
- Monitoring disk usage

### Scaling

- **Elasticsearch**: Increase replicas in StatefulSet for more storage/performance
- **Fluentd**: Automatically scales with nodes (DaemonSet)
- **Kibana**: Can be scaled horizontally if needed

### Updates

When updating:

1. Update images in the YAML file
2. Apply changes with `kubectl apply`
3. Monitor rollout status

## Additional Resources

- [Fluentd Documentation](https://docs.fluentd.org/)
- [Elasticsearch Guide](https://www.elastic.co/guide/en/elasticsearch/reference/6.2/index.html)
- [Kibana User Guide](https://www.elastic.co/guide/en/kibana/6.2/index.html)
- [EKS Logging Documentation](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)

## Stack Naming

This setup is technically an **EFK Stack** (Elasticsearch + Fluentd + Kibana), not an ELK stack:

- **E**lasticsearch: Log storage and search engine
- **F**luentd: Log collection and forwarding (instead of Logstash)
- **K**ibana: Visualization and dashboard interface

Fluentd is preferred over Logstash in Kubernetes environments due to its lower resource footprint and cloud-native design.

## Notes

- This configuration is optimized for EKS environments
- Uses older but stable versions (ES 6.2.5, Kibana 6.2.4)
- Consider upgrading to newer versions for production use
- Monitor resource usage and adjust limits as needed
