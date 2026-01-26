# Custom Resource Definitions (CRDs) and Operators

## Executive Summary

CRDs extend Kubernetes by allowing you to define custom resources beyond built-in types like Pods and Deployments. Combined with Custom Controllers, they enable automation of complex application management. Operators package CRDs and controllers together to manage entire application lifecycles.

## Key Concepts

| Component                | Purpose                                |
| ------------------------ | -------------------------------------- |
| **CRD**                  | Schema definition for custom resources |
| **Custom Resource (CR)** | Instance of a CRD                      |
| **Custom Controller**    | Watches CRs and takes action           |
| **Operator**             | CRD + Controller packaged together     |

### Built-in vs Custom Resources

- **Built-in**: Pods, Deployments, Services, ConfigMaps
- **Custom**: FlightTicket, EtcdCluster, Database, etc.

## Real-World Usage

- Database operators (MySQL, PostgreSQL, MongoDB)
- Message queue operators (Kafka, RabbitMQ)
- Monitoring operators (Prometheus, Grafana)
- CI/CD operators (ArgoCD, Tekton)
- Certificate management (cert-manager)

## YAML Configurations

### Custom Resource Definition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: flighttickets.flights.com # plural.group
spec:
  group: flights.com
  scope: Namespaced # or Cluster
  names:
    kind: FlightTicket
    singular: flightticket
    plural: flighttickets
    shortNames:
      - ft
  versions:
    - name: v1
      served: true # Served by API server
      storage: true # Storage version
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                from:
                  type: string
                to:
                  type: string
                number:
                  type: integer
                  minimum: 1
          required:
            - spec
```

### Custom Resource Instance

```yaml
apiVersion: flights.com/v1
kind: FlightTicket
metadata:
  name: my-flight-ticket
spec:
  from: Mumbai
  to: London
  number: 2
```

### CRD with Additional Printer Columns

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.mycompany.com
spec:
  group: mycompany.com
  scope: Namespaced
  names:
    kind: Database
    singular: database
    plural: databases
    shortNames:
      - db
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                engine:
                  type: string
                version:
                  type: string
                replicas:
                  type: integer
      additionalPrinterColumns:
        - name: Engine
          type: string
          jsonPath: .spec.engine
        - name: Version
          type: string
          jsonPath: .spec.version
        - name: Replicas
          type: integer
          jsonPath: .spec.replicas
```

## Common Commands

### Manage CRDs

```bash
# Create CRD
kubectl apply -f crd.yaml

# List CRDs
kubectl get crds
kubectl get customresourcedefinitions

# Describe CRD
kubectl describe crd flighttickets.flights.com

# Delete CRD (also deletes all CRs of that type!)
kubectl delete crd flighttickets.flights.com
```

### Manage Custom Resources

```bash
# Create custom resource
kubectl apply -f flightticket.yaml

# List custom resources
kubectl get flighttickets
kubectl get ft  # using shortName

# Describe custom resource
kubectl describe flightticket my-flight-ticket

# Delete custom resource
kubectl delete flightticket my-flight-ticket
```

### Explore API Resources

```bash
# List all API resources (includes CRDs)
kubectl api-resources

# Filter by group
kubectl api-resources --api-group=flights.com

# Get API versions for a resource
kubectl api-versions | grep flights
```

## Operators

### What Operators Do

1. Install and configure applications
2. Perform backups and restores
3. Handle upgrades
4. Scale applications
5. Manage application lifecycle

### Installing Operators

```bash
# Install Operator Lifecycle Manager (OLM)
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.26.0/install.sh | bash -s v0.26.0

# Install operator from OperatorHub
kubectl create -f https://operatorhub.io/install/etcd.yaml

# Check installed operators
kubectl get csv -n <namespace>

# List operator pods
kubectl get pods -n <namespace> | grep operator
```

### Popular Operators

- **etcd-operator**: etcd cluster management
- **prometheus-operator**: Prometheus monitoring
- **cert-manager**: TLS certificate automation
- **strimzi**: Apache Kafka on Kubernetes

## CKA Exam Tips

### What to Expect

- Create CRDs with proper schema
- Create instances of custom resources
- Query custom resources
- Basic understanding of operators

### Quick Reference

```bash
# Check if CRD exists
kubectl get crd <name>

# Verify custom resource creation
kubectl get <cr-plural>

# Debug CRD issues
kubectl describe crd <name>
```

### CRD Template for Exam

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: <plural>.<group>
spec:
  group: <group>
  scope: Namespaced
  names:
    kind: <Kind>
    singular: <singular>
    plural: <plural>
    shortNames:
      - <short>
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                <field>:
                  type: <type>
```

## Official Documentation

- [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Extend the Kubernetes API with CustomResourceDefinitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
- [Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [OperatorHub.io](https://operatorhub.io/)
