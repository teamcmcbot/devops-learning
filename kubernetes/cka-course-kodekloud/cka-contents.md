# CKA Conents

## Core Concepts

Kubernetes Architecture
Docker vs ContainerD
etcd
API Server
Controller Manager
Scheduler
Kubelet
Kube Proxy
Kubernetes Extension Interfaces
Container Runtime Interface (CRI)
Container Storage Interface (CSI)
Pods
Pods with YAML
ReplicaSets
Deployments
Services
Cluster IP
Load Balancer
Namespaces
Imperative vs Declarative
Kubectl Apply Command

## Scheduling

Manual Scheduling
Labels and Selectors
Taints and Tolerations
Node Selectors
Node Affinity
Taints and Tolerations vs Node Affinity
Resource Quotas & Limits
DaemonSets
Static Pods
Multiple Schedulers
Configuring Kubernetes Scheduler Profiles

## Logging & Monitoring

Monitor Cluster Components
Managing Application/Container Logs

## Application Lifecycle Management

Rolling Updates & Rollbacks
Commands and Arguments
Environment Variables
ConfigMaps
Secrets
Scale Applications
Autoscaling
Horizontal Pod Autoscaler (HPA)
Vertical Pod Autoscaler (VPA)
Cluster Autoscaler
Event-Driven Autoscaling with KEDA
Readiness Probes
Liveness Probes
Multi Container PODs
Multi-container PODs Design Patterns
Init Containers

## Cluster Maintenance

OS Upgrades
Kubernetes Software Versions
Cluster Upgrade
Backup and Restore Methods
ETCDCTL

## Security

Kubernetes Security Primitives
Authentication
TLS Basics
TLS in Kubernetes
PKI Certificates & API
KubeConfig
API Groups
Authorization
Role Based Access Controls (RBAC)
Cluster Roles
Service Accounts
Image Security
Security in Docker
Security Contexts
Network Policies
Admission Controllers
Validating and Mutating Admission Controllers
Kubectx and Kubens

## Storage

Volume Driver Plugins in Docker
Docker Storage
Volumes
Persistent Volumes (PV)
Persistent Volume Claims (PVC)
Using PVC in Pods
Storage Classes
Dynamic Volume Provisioning

## Networking

Switching, Routing, Gateways CNI in Kubernetes
CoreDNS
Network Namespaces
Container Networking Interface (CNI)
Docker Networking
Cluster Networking
Pod Networking
Weave
IPAM Weave
Ingress
The Need for Gateway API
Introduction to Gateway API & Resource Model
Configure a Gateway Resource
Expose a deployment on the Gateway
Traffic Switching

## Install

Infrastructure Setup
Cluster Configuration & Initialization
Cluster Security & Management
Core Services & Tools
Testing & Validation
Advanced Setup - Deploy with Kubeadm
ETCD in HA
Helm Overview
Helm Installation
Helm Concepts
Kustomize Overview
Kustomize vs Helm
Kustomize Installation
Kustomize.yaml file
Kustomize Output
Kustomize ApiVersion & Kind
Managing Directories with Kustomize
Common Kustomize Transformers
Kustomize Patches
Kustomize Different Types of Patches
Kustomize Patches List
Kustomize Patches Dictionary
Kustomize Overlays
Kustomize Components
Custom Resource Definition (CRD)
Operator Framework

## Troubleshooting

Application Failure
Control Plane Failure
Worker Node Failure
Troubleshoot Services and Networking
Common Networking Issues
Troubleshooting the API Server, Scheduler
Network Troubleshooting
