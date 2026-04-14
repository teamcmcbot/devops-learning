# Task 001: Create VPC and subnet using terraform

To ensure proper resource provisioning order, the DevOps team wants to explicitly define the dependency between an AWS VPC and a Subnet. The objective is to create a VPC and then a Subnet that explicitly depends on it using Terraform's `depends_on` argument.

Please complete the following tasks:

1. Create a VPC named `datacenter-vpc`.

2. Create a Subnet named `datacenter-subnet`.

3. Ensure the Subnet uses the `depends_on` argument to explicitly depend on the VPC resource.

4. Create the `main.tf` file (do not create a separate .tf file) to provision a VPC and Subnet.

5. Use `variables.tf`, define the following variables:
- `KKE_VPC_NAME` for the VPC name.
- `KKE_SUBNET_NAME` for the Subnet name.

6. Use `terraform.tfvars` to input the names of the VPC and subnet.

7. In `outputs.tf`, output the following:
- `kke_vpc_name`: The name of the VPC.
- `kke_subnet_name`: The name of the Subnet.

## Verification 

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_subnet.datacenter-subnet:
resource "aws_subnet" "datacenter-subnet" {
    arn                                            = "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-19f87c037081973ba"
    assign_ipv6_address_on_creation                = false
    availability_zone                              = "us-east-1e"
    availability_zone_id                           = "use1-az3"
    cidr_block                                     = "10.0.1.0/24"
    customer_owned_ipv4_pool                       = null
    enable_dns64                                   = false
    enable_lni_at_device_index                     = 0
    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    id                                             = "subnet-19f87c037081973ba"
    ipv6_cidr_block                                = null
    ipv6_cidr_block_association_id                 = null
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = false
    outpost_arn                                    = null
    owner_id                                       = "000000000000"
    private_dns_hostname_type_on_launch            = "ip-name"
    tags                                           = {
        "Name" = "datacenter-subnet"
    }
    tags_all                                       = {
        "Name" = "datacenter-subnet"
    }
    vpc_id                                         = "vpc-c25d35979de566a03"
}

# aws_vpc.datacenter-vpc:
resource "aws_vpc" "datacenter-vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-c25d35979de566a03"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-d0f8de9f59375e45a"
    default_route_table_id               = "rtb-b4cd006115b54ea59"
    default_security_group_id            = "sg-7d1843725afee48c6"
    dhcp_options_id                      = "default"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-c25d35979de566a03"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-b4cd006115b54ea59"
    owner_id                             = "000000000000"
    tags                                 = {
        "Name" = "datacenter-vpc"
    }
    tags_all                             = {
        "Name" = "datacenter-vpc"
    }
}


Outputs:

kke_subnet_name = "datacenter-subnet"
kke_vpc_name = "datacenter-vpc"
```