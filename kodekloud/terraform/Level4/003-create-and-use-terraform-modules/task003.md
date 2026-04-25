# Task 003: Create and Use Terraform Modules

The Nautilus DevOps team is implementing a production-grade, event-driven system using Terraform with workspaces and modules. The goal is to teach advanced Terraform concepts. The requirements are as follows:

## Task Requirements:

1. Workspaces:

- Use two Terraform workspaces: `dev` and `prod`.

2. Modules:

- Implement two Terraform modules:
  - `network` module to create a VPC and a subnet.
  - `compute` module to create an EC2 instance in the subnet.

3. Use a `locals` block in the root module to define:

- A common name prefix: `datacenter-${terraform.workspace}`.
- Default tags with keys `Project = datacenter` and `Environment = terraform.workspace`.

4. Use `main.tf` file to define all resources in a structured and modular way, ensuring clarity and maintainability across modules and workspaces.

5. Use `variables.tf` file from the root module with the following variable names:

- `KKE_VPC_CIDR`: CIDR block for the VPC (`10.0.0.0/16`).
- `KKE_INSTANCE_TYPE`: EC2 instance type.
- Use validation in `variables.tf` to ensure that `KKE_INSTANCE_TYPE` only accepts `t3.micro` or `t3.large`, and display an appropriate error message if any other value is provided.

6. The modules must merge the incoming tags with resource-specific `Name` tags.

7. Use `dev.tfvars` and `prod.tfvars` files with the following:

- In `dev.tfvars`: `KKE_INSTANCE_TYPE = t3.micro`
- In `prod.tfvars`: `KKE_INSTANCE_TYPE = t3.large`

8. Use `outputs.tf` file from the root module with the following output names:

- `kke_vpc_name`: Name of the created VPC.
- `kke_subnet_name`: Name of the created Subnet.
- `kke_instance_name`: Name of the created EC2 instance.

## Network Module:

- Use `variables.tf` file from the network module with the following variable names:
  - `KKE_NAME_PREFIX`: Name prefix to use for network resources.
  - `KKE_VPC_CIDR`: CIDR block for the VPC.
  - `KKE_TAGS`: Common tags map for network resources.
- Use `outputs.tf` file from the network module with the following output names:
  - `kke_vpc_name`: Name of the created VPC.
  - `kke_subnet_name`: Name of the created Subnet.

## Compute Module:

- Use the Amazon Linux 2 AMI image with ID `ami-0c94855ba95c71c99` for the EC2 instance in the compute module.
- Use `variables.tf` file from the compute module with the following variable names:
  - `KKE_NAME_PREFIX`: Name prefix to use for compute resources.
  - `KKE_SUBNET_ID`: Subnet ID where the instance will be created.
  - `KKE_INSTANCE_TYPE`: EC2 instance type.
  - `KKE_TAGS`: Common tags map for compute resources.
- Use `outputs.tf` file from the compute module with the following output names:
  - `kke_instance_name`: Name of the created EC2 instance.