NOTE:
The instructions in the course for installing kubectl are outdated.
Please refer to the official AWS documentation for the most up-to-date instructions:

https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#kubectl-install-update

## Create Cluster

```bash
eksctl create cluster --name fleetman --nodes-min=3 --node-type t3.medium
2025-11-10 04:31:04 [ℹ]  eksctl version 0.216.0
2025-11-10 04:31:04 [ℹ]  using region ap-southeast-1
2025-11-10 04:31:04 [ℹ]  setting availability zones to [ap-southeast-1b ap-southeast-1c ap-southeast-1a]
2025-11-10 04:31:04 [ℹ]  subnets for ap-southeast-1b - public:192.168.0.0/19 private:192.168.96.0/19
2025-11-10 04:31:04 [ℹ]  subnets for ap-southeast-1c - public:192.168.32.0/19 private:192.168.128.0/19
2025-11-10 04:31:04 [ℹ]  subnets for ap-southeast-1a - public:192.168.64.0/19 private:192.168.160.0/19
2025-11-10 04:31:04 [ℹ]  nodegroup "ng-026035af" will use "" [AmazonLinux2023/1.32]
2025-11-10 04:31:04 [!]  Auto Mode will be enabled by default in an upcoming release of eksctl. This means managed node groups and managed networking add-ons will no longer be created by default. To maintain current behavior, explicitly set 'autoModeConfig.enabled: false' in your cluster configuration. Learn more: https://eksctl.io/usage/auto-mode/
2025-11-10 04:31:04 [ℹ]  using Kubernetes version 1.32
2025-11-10 04:31:04 [ℹ]  creating EKS cluster "fleetman" in "ap-southeast-1" region with managed nodes
2025-11-10 04:31:04 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2025-11-10 04:31:04 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-southeast-1 --cluster=fleetman'
2025-11-10 04:31:04 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "fleetman" in "ap-southeast-1"
2025-11-10 04:31:04 [ℹ]  CloudWatch logging will not be enabled for cluster "fleetman" in "ap-southeast-1"
2025-11-10 04:31:04 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-southeast-1 --cluster=fleetman'
2025-11-10 04:31:04 [ℹ]  default addons metrics-server, vpc-cni, kube-proxy, coredns were not specified, will install them as EKS addons
2025-11-10 04:31:04 [ℹ]
2 sequential tasks: { create cluster control plane "fleetman",
    2 sequential sub-tasks: {
        2 sequential sub-tasks: {
            1 task: { create addons },
            wait for control plane to become ready,
        },
        create managed nodegroup "ng-026035af",
    }
}
2025-11-10 04:31:04 [ℹ]  building cluster stack "eksctl-fleetman-cluster"
2025-11-10 04:31:04 [ℹ]  deploying stack "eksctl-fleetman-cluster"
2025-11-10 04:31:34 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:32:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:33:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:34:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:35:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:36:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:37:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:38:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:39:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:40:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:41:04 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-cluster"
2025-11-10 04:41:05 [!]  recommended policies were found for "vpc-cni" addon, but since OIDC is disabled on the cluster, eksctl cannot configure the requested permissions; the recommended way to provide IAM permissions for "vpc-cni" addon is via pod identity associations; after addon creation is completed, add all recommended policies to the config file, under `addon.PodIdentityAssociations`, and run `eksctl update addon`
2025-11-10 04:41:05 [ℹ]  creating addon: vpc-cni
2025-11-10 04:41:06 [ℹ]  successfully created addon: vpc-cni
2025-11-10 04:41:06 [ℹ]  creating addon: kube-proxy
2025-11-10 04:41:07 [ℹ]  successfully created addon: kube-proxy
2025-11-10 04:41:07 [ℹ]  creating addon: coredns
2025-11-10 04:41:08 [ℹ]  successfully created addon: coredns
2025-11-10 04:43:08 [ℹ]  building managed nodegroup stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:43:08 [ℹ]  deploying stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:43:08 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:43:38 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:44:25 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:45:08 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:46:36 [ℹ]  waiting for CloudFormation stack "eksctl-fleetman-nodegroup-ng-026035af"
2025-11-10 04:46:36 [ℹ]  waiting for the control plane to become ready
2025-11-10 04:46:37 [✔]  saved kubeconfig as "/home/ec2-user/.kube/config"
2025-11-10 04:46:37 [ℹ]  no tasks
2025-11-10 04:46:37 [✔]  all EKS cluster resources for "fleetman" have been created
2025-11-10 04:46:37 [ℹ]  nodegroup "ng-026035af" has 3 node(s)
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-2-157.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-44-19.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-92-255.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [ℹ]  waiting for at least 3 node(s) to become ready in "ng-026035af"
2025-11-10 04:46:37 [ℹ]  nodegroup "ng-026035af" has 3 node(s)
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-2-157.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-44-19.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [ℹ]  node "ip-192-168-92-255.ap-southeast-1.compute.internal" is ready
2025-11-10 04:46:37 [✔]  created 1 managed nodegroup(s) in cluster "fleetman"
2025-11-10 04:46:37 [ℹ]  creating addon: metrics-server
2025-11-10 04:46:38 [ℹ]  successfully created addon: metrics-server
2025-11-10 04:46:38 [ℹ]  kubectl command should work with "/home/ec2-user/.kube/config", try 'kubectl get nodes'
2025-11-10 04:46:38 [✔]  EKS cluster "fleetman" in "ap-southeast-1" region is ready
```

```bash
eksctl version
0.216.0

kubectl version
Client Version: v1.33.5-eks-113cf36
Kustomize Version: v5.6.0
Server Version: v1.32.9-eks-3cfe0ce
```

If you are using EKS, you will need to perform the following steps before the next video.

In more recent versions of EKS, it is necessary to install a "driver" to enable your Kubernetes cluster to access EBS. The steps are simple but a bit tedious! Please report to me on the Q&A if in the next video your EBS volume fails to create.

You need to use the correct region in Step 1, and in each step you must replace YourClusterName with.. your cluster name!

Step 1:

eksctl utils associate-iam-oidc-provider --region=YOUR-REGION --cluster=YourClusterNameHere --approve
Step 2:

eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster YourClusterNameHere --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole
Step 3:

eksctl create addon --name aws-ebs-csi-driver --cluster YourClusterNameHere --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force

Note to self:
Need to brush up on NodePort vs LoadBalancer vs ClusterIP services in Kubernetes.
