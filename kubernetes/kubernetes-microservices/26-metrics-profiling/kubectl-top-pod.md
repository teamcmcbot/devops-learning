# Metrics Profiling: Using `kubectl top pod` to Monitor Pod Resource Usage

```bash
kubectl top pod
NAME                                 CPU(cores)   MEMORY(bytes)
api-gateway-757f97ff78-rt6zp         6m           161Mi
mongodb-568bf769f9-9g7lf             26m          162Mi
position-simulator-5bc8d9bf7-vhcjk   4m           189Mi
position-tracker-7f49d5dd5d-ffjbn    26m          209Mi
queue-5b9c94d5b8-5tvxf               17m          249Mi
webapp-fbb947f8f-bsfjh               1m           3Mi
kubectl top node
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
minikube   212m         1%       2489Mi          31%
```

## Setting Requests and Limits Based on Metrics

Based on the observed resource usage patterns, here are the recommended resource configurations:

### Analysis Summary:

- **queue**: 17m CPU, 249Mi Memory (highest memory consumer - message buffering)
- **position-tracker**: 26m CPU, 209Mi Memory (highest CPU - heavy processing)
- **mongodb**: 26m CPU, 162Mi Memory (database operations)
- **api-gateway**: 6m CPU, 161Mi Memory (request routing)
- **position-simulator**: 4m CPU, 189Mi Memory (data generation)
- **webapp**: 1m CPU, 3Mi Memory (static frontend - minimal resources)

### Resource Configuration Strategy:

- **Requests**: Set slightly below observed usage for guaranteed scheduling
- **Limits**: Set 2-3x higher to allow for traffic spikes and burst processing
- **Consider**: Message queuing can cause memory spikes, processing components need CPU headroom

### Recommended Configurations:

#### Queue (Memory-intensive, message buffering)

```yaml
resources:
  requests:
    cpu: "15m" # Below observed 17m
    memory: "240Mi" # Below observed 249Mi
  limits:
    cpu: "50m" # Allow processing bursts
    memory: "500Mi" # Handle message accumulation
```

#### Position Tracker (CPU-intensive, heavy processing)

```yaml
resources:
  requests:
    cpu: "25m" # Match observed usage
    memory: "200Mi" # Below observed 209Mi
  limits:
    cpu: "100m" # Processing spikes
    memory: "400Mi" # In-memory data processing
```

#### Position Simulator (Moderate resources)

```yaml
resources:
  requests:
    cpu: "5m" # Above observed 4m
    memory: "180Mi" # Below observed 189Mi
  limits:
    cpu: "20m" # Burst for data generation
    memory: "300Mi" # Simulation datasets
```

#### API Gateway (Request routing)

```yaml
resources:
  requests:
    cpu: "5m" # Below observed 6m
    memory: "150Mi" # Below observed 161Mi
  limits:
    cpu: "50m" # Traffic spikes
    memory: "300Mi" # Request buffering
```

#### WebApp (Static content - minimal)

```yaml
resources:
  requests:
    cpu: "1m" # Match minimal usage
    memory: "5Mi" # Above observed 3Mi
  limits:
    cpu: "10m" # Static serving bursts
    memory: "50Mi" # Generous for frontend
```

### Implementation Notes:

- Current queue configuration (250m CPU request) is **over-provisioned** based on actual 17m usage
- Most components can reduce CPU requests while maintaining adequate limits
- Memory requests should accommodate baseline working sets plus reasonable buffers

## Minikube dashboard

```bash
minikube dashboard
🔌  Enabling dashboard ...
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

	minikube addons enable metrics-server

🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:57950/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...

```
