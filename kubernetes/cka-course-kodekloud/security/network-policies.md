# Network Policies

## Executive Summary

Network Policies control traffic flow between pods and external endpoints. By default, Kubernetes allows all pod-to-pod communication (all-allow). Network policies let you define ingress (incoming) and egress (outgoing) rules to restrict traffic based on pod labels, namespaces, and IP blocks.

## Key Concepts

| Term                  | Description                                     |
| --------------------- | ----------------------------------------------- |
| **Ingress**           | Incoming traffic to a pod                       |
| **Egress**            | Outgoing traffic from a pod                     |
| **podSelector**       | Selects which pods the policy applies to        |
| **namespaceSelector** | Filters traffic by source/destination namespace |
| **ipBlock**           | Filters traffic by IP CIDR ranges               |

### Important Notes

- Network policies are **additive** (combine all matching policies)
- Pods without any policy: **all traffic allowed**
- Pods with policy: only traffic matching rules is allowed
- **Response traffic** is automatically allowed (stateful)

### CNI Support

Network policies require a CNI plugin that supports them:

- ✅ Calico, Cilium, Weave Net, Kube-router, Romana
- ❌ Flannel (does not enforce network policies)

## Real-World Usage

- Isolating database pods from direct frontend access
- Restricting pods to communicate only within their namespace
- Blocking external traffic to internal services
- Compliance requirements for network segmentation

## YAML Configurations

### Basic Ingress Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db # Apply to pods with label role=db
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              name: api-pod # Allow from pods with label name=api-pod
      ports:
        - protocol: TCP
          port: 3306
```

### Deny All Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {} # Apply to all pods in namespace
  policyTypes:
    - Ingress
  # No ingress rules = deny all incoming traffic
```

### Allow All Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - {} # Empty rule = allow all
```

### Ingress with Namespace Selector

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-prod
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        # AND condition: must match BOTH pod AND namespace
        - podSelector:
            matchLabels:
              name: api-pod
          namespaceSelector:
            matchLabels:
              env: prod
      ports:
        - protocol: TCP
          port: 3306
```

### Multiple Sources (OR Condition)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: multi-source-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        # OR condition: separate list items
        - podSelector:
            matchLabels:
              name: api-pod
        - ipBlock:
            cidr: 192.168.1.0/24
            except:
              - 192.168.1.100/32
      ports:
        - protocol: TCP
          port: 3306
```

### Egress Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/24
      ports:
        - protocol: TCP
          port: 5978
```

### Combined Ingress and Egress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: complete-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              name: api-pod
          namespaceSelector:
            matchLabels:
              name: prod
      ports:
        - protocol: TCP
          port: 3306
  egress:
    - to:
        - ipBlock:
            cidr: 192.168.5.10/32
      ports:
        - protocol: TCP
          port: 80
```

### Allow DNS Egress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
```

## Common Commands

```bash
# Create network policy
kubectl apply -f network-policy.yaml

# List network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe netpol db-policy

# Delete network policy
kubectl delete netpol db-policy

# Check pod labels (for selector matching)
kubectl get pods --show-labels

# Label namespace (for namespaceSelector)
kubectl label namespace prod env=prod
```

## Selector Logic

### AND vs OR Conditions

```yaml
# AND condition (single array item with multiple selectors)
- from:
    - podSelector:
        matchLabels:
          name: api-pod
      namespaceSelector:
        matchLabels:
          env: prod
# Traffic must match: (pod=api-pod) AND (namespace=prod)

# OR condition (multiple array items)
- from:
    - podSelector:
        matchLabels:
          name: api-pod
    - namespaceSelector:
        matchLabels:
          env: prod
# Traffic can match: (pod=api-pod) OR (namespace=prod)
```

## CKA Exam Tips

### What to Expect

- Create network policies to restrict pod traffic
- Write policies for specific ingress/egress scenarios
- Debug network policy issues
- Understand selector logic (AND vs OR)

### Quick Reference

```yaml
# Template for exam
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: <policy-name>
  namespace: <namespace>
spec:
  podSelector:
    matchLabels:
      <key>: <value>
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: <port>
  egress:
    - to:
        - ipBlock:
            cidr: <cidr>
      ports:
        - protocol: TCP
          port: <port>
```

### Testing Network Policies

```bash
# Test connectivity between pods
kubectl exec -it source-pod -- curl target-pod:port

# Test with timeout
kubectl exec -it source-pod -- curl --connect-timeout 5 target-pod:port
```

## Official Documentation

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Declare Network Policy](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)
