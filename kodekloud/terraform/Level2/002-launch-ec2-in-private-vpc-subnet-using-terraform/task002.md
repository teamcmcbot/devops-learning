# Task 002: Launch EC2 in Private VPC Subnet Using Terraform

The Nautilus DevOps team is expanding their AWS infrastructure and requires the setup of a private Virtual Private Cloud (VPC) along with a subnet. This VPC and subnet configuration will ensure that resources deployed within them remain isolated from external networks and can only communicate within the VPC. Additionally, the team needs to provision an EC2 instance under the newly created private VPC. This instance should be accessible only from within the VPC, allowing for secure communication and resource management within the AWS environment.

1. Create a VPC named `devops-priv-vpc` with the CIDR block `10.0.0.0/16`.

2. Create a subnet named `devops-priv-subnet` inside the VPC with the CIDR block `10.0.1.0/24` and `auto-assign` IP option must not be enabled.

3. Create an EC2 instance named `devops-priv-ec2` inside the subnet and instance type must be `t2.micro`.

4. Ensure the security group of the EC2 instance allows access only from within the VPC's CIDR block.

5. Create the `main.tf` file (do not create a separate .tf file) to provision the VPC, subnet and EC2 instance.

6. Use `variables.tf` file with the following variable names:

- KKE_VPC_CIDR for the VPC CIDR block.
- KKE_SUBNET_CIDR for the subnet CIDR block.

7. Use the `outputs.tf` file with the following variable names:

- KKE_vpc_name for the name of the VPC.
- KKE_subnet_name for the name of the subnet.
- KKE_ec2_private for the name of the EC2 instance.

## Verifications

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# data.aws_ami.amazon_linux_2023:
data "aws_ami" "amazon_linux_2023" {
    architecture          = "x86_64"
    arn                   = "arn:aws:ec2:us-east-1::image/ami-0886832e6b5c3b9e2"
    block_device_mappings = [
        {
            device_name  = "/dev/xvda"
            ebs          = {
                "delete_on_termination" = "false"
                "encrypted"             = "false"
                "iops"                  = "0"
                "snapshot_id"           = "snap-5f9741974c26194f3"
                "throughput"            = "0"
                "volume_size"           = "15"
                "volume_type"           = "standard"
            }
            no_device    = null
            virtual_name = null
        },
    ]
    boot_mode             = "uefi"
    creation_date         = "2026-04-14T07:15:53.000Z"
    deprecation_time      = null
    description           = "Amazon Linux 2023 AMI 2023.8.20250915.0 x86_64 HVM kernel-6.12"
    ena_support           = false
    hypervisor            = "xen"
    id                    = "ami-0886832e6b5c3b9e2"
    image_id              = "ami-0886832e6b5c3b9e2"
    image_location        = null
    image_owner_alias     = "amazon"
    image_type            = "machine"
    imds_support          = null
    include_deprecated    = false
    kernel_id             = null
    most_recent           = true
    name                  = "al2023-ami-2023.8.20250915.0-kernel-6.12-x86_64"
    owner_id              = "137112412989"
    owners                = [
        "amazon",
    ]
    platform              = null
    platform_details      = null
    product_codes         = []
    public                = true
    ramdisk_id            = null
    root_device_name      = "/dev/xvda"
    root_device_type      = "ebs"
    root_snapshot_id      = "snap-5f9741974c26194f3"
    sriov_net_support     = null
    state                 = "available"
    state_reason          = {
        "code"    = "UNSET"
        "message" = "UNSET"
    }
    tags                  = {}
    tpm_support           = null
    usage_operation       = null
    virtualization_type   = "hvm"

    filter {
        name   = "architecture"
        values = [
            "x86_64",
        ]
    }
    filter {
        name   = "name"
        values = [
            "al2023-ami-2023.*-x86_64",
        ]
    }
    filter {
        name   = "virtualization-type"
        values = [
            "hvm",
        ]
    }
}

# aws_instance.example:
resource "aws_instance" "example" {
    ami                                  = "ami-0c0292c4186d3d1ec"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-1dba66e7b2347bf87"
    associate_public_ip_address          = false
    availability_zone                    = "us-east-1d"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-1dba66e7b2347bf87"
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = null
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-522caaf75f65440b5"
    private_dns                          = "ip-10-0-1-4.ec2.internal"
    private_ip                           = "10.0.1.4"
    public_dns                           = "None"
    public_ip                            = null
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-09628c9e2d9406c40"
    tags                                 = {
        "Name" = "devops-priv-ec2"
    }
    tags_all                             = {
        "Name" = "devops-priv-ec2"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-4b988e23ae2150482",
    ]

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
        volume_id             = "vol-b3f7b21538be6f50a"
        volume_size           = 8
        volume_type           = "gp2"
    }
}

# aws_security_group.private-sg:
resource "aws_security_group" "private-sg" {
    arn                    = "arn:aws:ec2:us-east-1:000000000000:security-group/sg-4b988e23ae2150482"
    description            = "Security group for devops-priv-ec2"
    egress                 = []
    id                     = "sg-4b988e23ae2150482"
    ingress                = [
        {
            cidr_blocks      = [
                "10.0.0.0/16",
            ]
            description      = null
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    name                   = "devops-priv-sg"
    name_prefix            = null
    owner_id               = "000000000000"
    revoke_rules_on_delete = false
    tags                   = {
        "Name" = "devops-priv-sg"
    }
    tags_all               = {
        "Name" = "devops-priv-sg"
    }
    vpc_id                 = "vpc-98b67e1b9b3581749"
}

# aws_security_group_rule.allow_vpc_internal:
resource "aws_security_group_rule" "allow_vpc_internal" {
    cidr_blocks            = [
        "10.0.0.0/16",
    ]
    from_port              = 0
    id                     = "sgrule-417592408"
    protocol               = "-1"
    security_group_id      = "sg-4b988e23ae2150482"
    security_group_rule_id = "sgr-c18ce8a79bfe3c6c4"
    self                   = false
    to_port                = 0
    type                   = "ingress"
}

# aws_subnet.devops-priv-subnet:
resource "aws_subnet" "devops-priv-subnet" {
    arn                                            = "arn:aws:ec2:us-east-1:000000000000:subnet/subnet-09628c9e2d9406c40"
    assign_ipv6_address_on_creation                = false
    availability_zone                              = "us-east-1d"
    availability_zone_id                           = "use1-az4"
    cidr_block                                     = "10.0.1.0/24"
    customer_owned_ipv4_pool                       = null
    enable_dns64                                   = false
    enable_lni_at_device_index                     = 0
    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    id                                             = "subnet-09628c9e2d9406c40"
    ipv6_cidr_block                                = null
    ipv6_cidr_block_association_id                 = null
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = false
    outpost_arn                                    = null
    owner_id                                       = "000000000000"
    private_dns_hostname_type_on_launch            = "ip-name"
    tags                                           = {
        "Name" = "devops-priv-subnet"
    }
    tags_all                                       = {
        "Name" = "devops-priv-subnet"
    }
    vpc_id                                         = "vpc-98b67e1b9b3581749"
}

# aws_vpc.devops-priv-vpc:
resource "aws_vpc" "devops-priv-vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-98b67e1b9b3581749"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-ce3a91a75a6ccf8a5"
    default_route_table_id               = "rtb-3ec359ffb6fb5ec12"
    default_security_group_id            = "sg-53b43a7c3f4809c48"
    dhcp_options_id                      = "default"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-98b67e1b9b3581749"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-3ec359ffb6fb5ec12"
    owner_id                             = "000000000000"
    tags                                 = {
        "Name" = "devops-priv-vpc"
    }
    tags_all                             = {
        "Name" = "devops-priv-vpc"
    }
}


Outputs:

KKE_ec2_private = "devops-priv-ec2"
KKE_subnet_name = "devops-priv-subnet"
KKE_vpc_name = "devops-priv-vpc"
```