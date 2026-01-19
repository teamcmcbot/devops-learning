# ConfigMaps & Environment Variables in Kubernetes

## Executive Summary

**ConfigMaps** are Kubernetes objects that store non-confidential configuration data as key-value pairs. They allow you to decouple environment-specific configuration from container images, making applications portable and easier to manage.

**Three ways to set environment variables in pods:**

| Method            | Use Case                                   |
| ----------------- | ------------------------------------------ |
| Direct `value`    | Simple, static values                      |
| `configMapKeyRef` | Reference specific key from ConfigMap      |
| `envFrom`         | Inject all keys from ConfigMap as env vars |

**Key Benefit:** Centralize configuration management instead of hardcoding values in each pod definition.

---

## Real-World Usage Examples

### Scenario 1: Web App with Color Theme Configuration

```yaml
# ConfigMap storing app settings
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod
  LOG_LEVEL: info
---
# Pod using the ConfigMap
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
    - name: simple-webapp-color
      image: simple-webapp-color
      ports:
        - containerPort: 8080
      envFrom:
        - configMapRef:
            name: app-config
```

### Scenario 2: Database Connection Settings

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  MYSQL_PORT: "3306"
  MYSQL_DATABASE: myapp
  MAX_CONNECTIONS: "100"
```

### Scenario 3: Configuration File as Volume

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    server {
      listen 80;
      server_name localhost;
      location / {
        root /usr/share/nginx/html;
      }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: config-volume
      configMap:
        name: nginx-config
```

---

## Common Commands

### Create ConfigMap (Imperative)

```bash
# From literal values
kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod

# From a file
kubectl create configmap app-config --from-file=app.properties

# From a file with custom key name
kubectl create configmap app-config --from-file=config.txt=app.properties

# From directory (each file becomes a key)
kubectl create configmap app-config --from-file=config-dir/

# Dry-run to generate YAML
kubectl create configmap app-config --from-literal=APP_COLOR=blue --dry-run=client -o yaml > configmap.yaml
```

### Create ConfigMap (Declarative)

```bash
kubectl apply -f configmap.yaml
```

### View ConfigMaps

```bash
# List all ConfigMaps
kubectl get configmaps
kubectl get cm

# Describe ConfigMap (see keys and values)
kubectl describe configmap app-config

# Get ConfigMap in YAML format
kubectl get configmap app-config -o yaml

# Get specific key value
kubectl get configmap app-config -o jsonpath='{.data.APP_COLOR}'
```

### Edit/Delete ConfigMaps

```bash
# Edit ConfigMap
kubectl edit configmap app-config

# Delete ConfigMap
kubectl delete configmap app-config
```

---

## YAML Configuration Reference

### ConfigMap Definition

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  # Simple key-value pairs
  APP_COLOR: blue
  APP_MODE: prod

  # Multi-line value (config file)
  app.properties: |
    color=blue
    mode=prod
```

### Three Ways to Inject ConfigMap into Pods

#### 1. Inject ALL keys as environment variables (`envFrom`)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      envFrom:
        - configMapRef:
            name: app-config
```

#### 2. Inject SINGLE key as environment variable (`valueFrom`)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      env:
        - name: APP_COLOR
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_COLOR
```

#### 3. Mount as Volume (for config files)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: app-config
```

### Direct Environment Variable (No ConfigMap)

```yaml
spec:
  containers:
    - name: myapp
      image: myapp
      env:
        - name: APP_COLOR
          value: "blue"
```

---

## Environment Variable Methods Comparison

| Method             | Syntax                       | When to Use             |
| ------------------ | ---------------------------- | ----------------------- |
| Direct value       | `value: "blue"`              | Simple, static config   |
| ConfigMap (all)    | `envFrom: configMapRef`      | Inject all keys at once |
| ConfigMap (single) | `valueFrom: configMapKeyRef` | Selective key injection |
| Secret (single)    | `valueFrom: secretKeyRef`    | Sensitive data          |
| Volume mount       | `volumes: configMap`         | Config files            |

---

## CKA Exam Relevance

### How This Topic is Tested:

1. **Create ConfigMaps** - Imperatively or declaratively
2. **Inject ConfigMaps into Pods** - Using `envFrom`, `valueFrom`, or volumes
3. **Troubleshooting** - Fix pods not reading ConfigMap values correctly
4. **Edit existing ConfigMaps** - Update configuration values
5. **Identify correct injection method** - Choose between envFrom, env, or volume

### Exam Tips:

- Use imperative commands with `--dry-run=client -o yaml` to quickly generate YAML
- Remember: `envFrom` injects ALL keys, `valueFrom` injects ONE key
- ConfigMap must exist BEFORE the pod references it (unless marked optional)
- Changes to ConfigMap don't auto-update running pods (need restart for env vars)
- Volume-mounted ConfigMaps DO auto-update (with slight delay)
- ConfigMaps are namespace-scoped

### Sample Exam Tasks:

> _Create a ConfigMap named `webapp-config-map` with data `APP_COLOR=darkblue` and `APP_OTHER=disregard`_

```bash
kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue --from-literal=APP_OTHER=disregard
```

> _Update pod `webapp-color` to use environment variable `APP_COLOR` from ConfigMap `webapp-config-map`_

---

## Official Documentation Links

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [Define Environment Variables for a Container](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)

---

## Quick Reference Card

```
┌────────────────────────────────────────────────────────────────┐
│  CREATE CONFIGMAP                                              │
├────────────────────────────────────────────────────────────────┤
│  kubectl create cm NAME --from-literal=KEY=VALUE               │
│  kubectl create cm NAME --from-file=FILE                       │
│  kubectl apply -f configmap.yaml                               │
├────────────────────────────────────────────────────────────────┤
│  INJECT INTO POD                                               │
├────────────────────────────────────────────────────────────────┤
│  ALL KEYS:    envFrom:                                         │
│                 - configMapRef:                                │
│                     name: app-config                           │
│                                                                │
│  ONE KEY:     env:                                             │
│                 - name: APP_COLOR                              │
│                   valueFrom:                                   │
│                     configMapKeyRef:                           │
│                       name: app-config                         │
│                       key: APP_COLOR                           │
│                                                                │
│  AS FILE:     volumes:                                         │
│                 - name: config-vol                             │
│                   configMap:                                   │
│                     name: app-config                           │
└────────────────────────────────────────────────────────────────┘
```
