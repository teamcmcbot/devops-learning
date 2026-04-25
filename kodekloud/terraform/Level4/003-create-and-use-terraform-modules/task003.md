# Task 003: Create and Use Terraform Modules

The Nautilus DevOps team is implementing a production-grade, event-driven system using Terraform with workspaces and modules. The goal is to teach advanced Terraform concepts. The requirements are as follows:

## Task Requirements:

1. Use two Terraform workspaces: `dev` and `prod`.

2. Implement two Terraform modules:
  - `network` module to create a VPC and a subnet.
  - `compute` module to create an EC2 instance in the subnet.

3. Use a `locals` block in the root module to define:

- A common name prefix: `devops-${terraform.workspace}`.
- Default tags with keys `Project = devops` and `Environment = terraform.workspace`.

4. Use `main.tf` file to define all resources in a structured and modular way, ensuring clarity and maintainability across modules and workspaces.

5. Use `variables.tf` file from the root module with the following variable names:

- `KKE_VPC_CIDR`: CIDR block for the VPC (`10.0.0.0/16`).
- `KKE_INSTANCE_TYPE`: EC2 instance type.

6. Use validation in `variables.tf` to ensure that `KKE_INSTANCE_TYPE` only accepts `t3.micro` or `t3.large`, and display an appropriate error message if any other value is provided.

7. The modules must merge the incoming tags with resource-specific `Name` tags.

8. Use `dev.tfvars` and `prod.tfvars` files with the following:

- In `dev.tfvars`: `KKE_INSTANCE_TYPE = t3.micro`
- In `prod.tfvars`: `KKE_INSTANCE_TYPE = t3.large`

9. Use `outputs.tf` file from the root module with the following output names:

- `kke_vpc_name`: Name of the created VPC.
- `kke_subnet_name`: Name of the created Subnet.
- `kke_instance_name`: Name of the created EC2 instance.

10. Network Module:

Use `variables.tf` file from the network module with the following variable names:

- `KKE_NAME_PREFIX`: Name prefix to use for network resources.
- `KKE_VPC_CIDR`: CIDR block for the VPC.
- `KKE_TAGS`: Common tags map for network resources.

11. Use `outputs.tf` file from the network module with the following output names:
- `kke_vpc_name`: Name of the created VPC.
- `kke_subnet_name`: Name of the created Subnet.

12. Compute Module:

Use the Amazon Linux 2 AMI image with ID `ami-0c94855ba95c71c99` for the EC2 instance in the `compute` module.

13. Use `variables.tf` file from the compute module with the following variable names:
  
- `KKE_NAME_PREFIX`: Name prefix to use for compute resources.
- `KKE_SUBNET_ID`: Subnet ID where the instance will be created.
- `KKE_INSTANCE_TYPE`: EC2 instance type.
- `KKE_TAGS`: Common tags map for compute resources.

14. Use `outputs.tf` file from the compute module with the following output names:

- `kke_instance_name`: Name of the created EC2 instance.

## Create modules directory and tf files

```bash
mkdir -p modules/network

mkdir -p modules/compute

cd modules/network/

touch main.tf outputs.tf variables.tf

cd ../compute/

touch main.tf outputs.tf variables.tf

cd ../..

touch main.tf outputs.tf variables.tf dev.tfvars prod.tfvars
```

## Create Workspaces
```bash
terraform workspace new prod
terraform workspace new dev
```

### Workspace Usage

```bash
terraform workspace select dev
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

```bash
terraform workspace select prod
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

## Solution (DEV)

```bash
bob@iac-server ~/terraform via 💠 dev ➜  terraform apply -var-file=dev.tfvars

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.compute.aws_instance.compute will be created
  + resource "aws_instance" "compute" {
      + ami                                  = "ami-0c94855ba95c71c99"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-instance"
          + "Project"     = "devops"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-instance"
          + "Project"     = "devops"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # module.network.aws_subnet.public_subnet will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-subnet"
          + "Project"     = "devops"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-subnet"
          + "Project"     = "devops"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_vpc.main_vpc will be created
  + resource "aws_vpc" "main_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-vpc"
          + "Project"     = "devops"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "Name"        = "devops-dev-vpc"
          + "Project"     = "devops"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_instance_name = "devops-dev-instance"
  + kke_subnet_name   = "devops-dev-subnet"
  + kke_vpc_name      = "devops-dev-vpc"

Do you want to perform these actions in workspace "dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.network.aws_vpc.main_vpc: Creating...
module.network.aws_vpc.main_vpc: Creation complete after 1s [id=vpc-d7ce5e40ad29bbdc4]
module.network.aws_subnet.public_subnet: Creating...
module.network.aws_subnet.public_subnet: Creation complete after 0s [id=subnet-fe236d6825d6f4175]
module.compute.aws_instance.compute: Creating...
module.compute.aws_instance.compute: Still creating... [10s elapsed]
module.compute.aws_instance.compute: Creation complete after 10s [id=i-3f585401c25293d44]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_instance_name = "devops-dev-instance"
kke_subnet_name = "devops-dev-subnet"
kke_vpc_name = "devops-dev-vpc"
```

## Verification (DEV)

```bash
bob@iac-server ~/terraform via 💠 dev ➜  terraform show
# module.compute.aws_instance.compute:
resource "aws_instance" "compute" {
    ami                                  = "ami-0c94855ba95c71c99"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-3f585401c25293d44"
    associate_public_ip_address          = false
    availability_zone                    = "us-east-1b"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-3f585401c25293d44"
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_state                       = "running"
    instance_type                        = "t3.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = null
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-4118fb74552c11682"
    private_dns                          = "ip-10-0-1-4.ec2.internal"
    private_ip                           = "10.0.1.4"
    public_dns                           = "None"
    public_ip                            = null
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-fe236d6825d6f4175"
    tags                                 = {
        "Environment" = "dev"
        "Name"        = "devops-dev-instance"
        "Project"     = "devops"
    }
    tags_all                             = {
        "Environment" = "dev"
        "Name"        = "devops-dev-instance"
        "Project"     = "devops"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = []

    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        kms_key_id            = null
        tags                  = {}
        tags_all              = {}
        throughput            = 0
        volume_id             = "vol-cddefd0403a6c5c29"
        volume_size           = 8
        volume_type           = "gp2"
    }
}
# module.network.aws_subnet.public_subnet:
resource "aws_subnet" "public_subnet" {
    arn                                            = "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-fe236d6825d6f4175"
    assign_ipv6_address_on_creation                = false
    availability_zone                              = "us-east-1b"
    availability_zone_id                           = "use1-az1"
    cidr_block                                     = "10.0.1.0/24"
    customer_owned_ipv4_pool                       = null
    enable_dns64                                   = false
    enable_lni_at_device_index                     = 0
    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    id                                             = "subnet-fe236d6825d6f4175"
    ipv6_cidr_block                                = null
    ipv6_cidr_block_association_id                 = null
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = false
    outpost_arn                                    = null
    owner_id                                       = "000000000000"
    private_dns_hostname_type_on_launch            = "ip-name"
    tags                                           = {
        "Environment" = "dev"
        "Name"        = "devops-dev-subnet"
        "Project"     = "devops"
    }
    tags_all                                       = {
        "Environment" = "dev"
        "Name"        = "devops-dev-subnet"
        "Project"     = "devops"
    }
    vpc_id                                         = "vpc-d7ce5e40ad29bbdc4"
}

# module.network.aws_vpc.main_vpc:
resource "aws_vpc" "main_vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-d7ce5e40ad29bbdc4"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-7a572d9fdb120bbb0"
    default_route_table_id               = "rtb-cfcef9003ffaca060"
    default_security_group_id            = "sg-bd35f7493f3cec6cb"
    dhcp_options_id                      = "default"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-d7ce5e40ad29bbdc4"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-cfcef9003ffaca060"
    owner_id                             = "000000000000"
    tags                                 = {
        "Environment" = "dev"
        "Name"        = "devops-dev-vpc"
        "Project"     = "devops"
    }
    tags_all                             = {
        "Environment" = "dev"
        "Name"        = "devops-dev-vpc"
        "Project"     = "devops"
    }
}


Outputs:

kke_instance_name = "devops-dev-instance"
kke_subnet_name = "devops-dev-subnet"
kke_vpc_name = "devops-dev-vpc"
```

## Solution (PROD)

```bash
bob@iac-server ~/terraform via 💠 prod ➜  terraform apply -var-file=prod.tfvars

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.compute.aws_instance.compute will be created
  + resource "aws_instance" "compute" {
      + ami                                  = "ami-0c94855ba95c71c99"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-instance"
          + "Project"     = "devops"
        }
      + tags_all                             = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-instance"
          + "Project"     = "devops"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # module.network.aws_subnet.public_subnet will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-subnet"
          + "Project"     = "devops"
        }
      + tags_all                                       = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-subnet"
          + "Project"     = "devops"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_vpc.main_vpc will be created
  + resource "aws_vpc" "main_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-vpc"
          + "Project"     = "devops"
        }
      + tags_all                             = {
          + "Environment" = "prod"
          + "Name"        = "devops-prod-vpc"
          + "Project"     = "devops"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_instance_name = "devops-prod-instance"
  + kke_subnet_name   = "devops-prod-subnet"
  + kke_vpc_name      = "devops-prod-vpc"

Do you want to perform these actions in workspace "prod"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.network.aws_vpc.main_vpc: Creating...
module.network.aws_vpc.main_vpc: Creation complete after 0s [id=vpc-8e0641c2fe2360430]
module.network.aws_subnet.public_subnet: Creating...
module.network.aws_subnet.public_subnet: Creation complete after 0s [id=subnet-2f77638dc69a30d6f]
module.compute.aws_instance.compute: Creating...
module.compute.aws_instance.compute: Still creating... [10s elapsed]
module.compute.aws_instance.compute: Creation complete after 10s [id=i-1ae5f7813ca61e841]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_instance_name = "devops-prod-instance"
kke_subnet_name = "devops-prod-subnet"
kke_vpc_name = "devops-prod-vpc"
```

## Verification (PROD)

```bash
bob@iac-server ~/terraform via 💠 prod ➜  terraform show
# module.compute.aws_instance.compute:
resource "aws_instance" "compute" {
    ami                                  = "ami-0c94855ba95c71c99"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-1ae5f7813ca61e841"
    associate_public_ip_address          = false
    availability_zone                    = "us-east-1c"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-1ae5f7813ca61e841"
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_state                       = "running"
    instance_type                        = "t3.large"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = null
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-8c72d954d2b958fc0"
    private_dns                          = "ip-10-0-1-4.ec2.internal"
    private_ip                           = "10.0.1.4"
    public_dns                           = "None"
    public_ip                            = null
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-2f77638dc69a30d6f"
    tags                                 = {
        "Environment" = "prod"
        "Name"        = "devops-prod-instance"
        "Project"     = "devops"
    }
    tags_all                             = {
        "Environment" = "prod"
        "Name"        = "devops-prod-instance"
        "Project"     = "devops"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = []

    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        kms_key_id            = null
        tags                  = {}
        tags_all              = {}
        throughput            = 0
        volume_id             = "vol-225096e05ec1def8d"
        volume_size           = 8
        volume_type           = "gp2"
    }
}
# module.network.aws_subnet.public_subnet:
resource "aws_subnet" "public_subnet" {
    arn                                            = "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-2f77638dc69a30d6f"
    assign_ipv6_address_on_creation                = false
    availability_zone                              = "us-east-1c"
    availability_zone_id                           = "use1-az2"
    cidr_block                                     = "10.0.1.0/24"
    customer_owned_ipv4_pool                       = null
    enable_dns64                                   = false
    enable_lni_at_device_index                     = 0
    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    id                                             = "subnet-2f77638dc69a30d6f"
    ipv6_cidr_block                                = null
    ipv6_cidr_block_association_id                 = null
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = false
    outpost_arn                                    = null
    owner_id                                       = "000000000000"
    private_dns_hostname_type_on_launch            = "ip-name"
    tags                                           = {
        "Environment" = "prod"
        "Name"        = "devops-prod-subnet"
        "Project"     = "devops"
    }
    tags_all                                       = {
        "Environment" = "prod"
        "Name"        = "devops-prod-subnet"
        "Project"     = "devops"
    }
    vpc_id                                         = "vpc-8e0641c2fe2360430"
}

# module.network.aws_vpc.main_vpc:
resource "aws_vpc" "main_vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-8e0641c2fe2360430"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-32be4a710f874ca0e"
    default_route_table_id               = "rtb-957e6bc5a07060551"
    default_security_group_id            = "sg-04ab387c9aeff7761"
    dhcp_options_id                      = "default"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-8e0641c2fe2360430"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-957e6bc5a07060551"
    owner_id                             = "000000000000"
    tags                                 = {
        "Environment" = "prod"
        "Name"        = "devops-prod-vpc"
        "Project"     = "devops"
    }
    tags_all                             = {
        "Environment" = "prod"
        "Name"        = "devops-prod-vpc"
        "Project"     = "devops"
    }
}


Outputs:

kke_instance_name = "devops-prod-instance"
kke_subnet_name = "devops-prod-subnet"
kke_vpc_name = "devops-prod-vpc"
```