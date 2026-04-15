# Task 010: Grant EC2 Access to S3 Bucket Using Terraform

The Nautilus DevOps team wants to set up EC2 instances that securely upload application logs to S3 using IAM roles.

1. Create an EC2 instance named `xfusion-ec2` that can access an S3 bucket securely.

2. Create an S3 bucket named `xfusion-logs-21964`.

3. Create an IAM role named `xfusion-role` with a policy named `xfusion-access-policy` allowing `S3 PutObject` on the above bucket.

4. Attach the IAM role to the EC2 instance to allow it to upload logs to the bucket.

5. Create the `main.tf` (do not create a separate .tf file) to provision the EC2, s3, role and policy.

6. Create the `variables.tf` file to declare the following:

- `KKE_BUCKET_NAME`: name of the bucket.
- `KKE_POLICY_NAME`: name of the policy.
- `KKE_ROLE_NAME`: name of the role.

7. Create the `terraform.tfvars` file to assign values to variables.

8. Create a `data.tf` file to fetch the latest Amazon Linux 2 AMI.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_ami.amazon_linux_2: Reading...
data.aws_ami.amazon_linux_2: Read complete after 0s [id=ami-04681a1dbd79675a5]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_instance_profile.xfusion_instance_profile will be created
  + resource "aws_iam_instance_profile" "xfusion_instance_profile" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "ec2-s3-upload-profile"
      + name_prefix = (known after apply)
      + path        = "/"
      + role        = "xfusion-role"
      + tags_all    = (known after apply)
      + unique_id   = (known after apply)
    }

  # aws_iam_policy.xfusion_access_policy will be created
  + resource "aws_iam_policy" "xfusion_access_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + name             = "xfusion-access-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # aws_iam_role.xfusion_role will be created
  + resource "aws_iam_role" "xfusion_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "xfusion-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.xfusion_role_policy_attachment will be created
  + resource "aws_iam_role_policy_attachment" "xfusion_role_policy_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "xfusion-role"
    }

  # aws_instance.xfusion-ec2 will be created
  + resource "aws_instance" "xfusion-ec2" {
      + ami                                  = "ami-04681a1dbd79675a5"
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
      + iam_instance_profile                 = "ec2-s3-upload-profile"
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
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
          + "Name" = "xfusion-ec2"
        }
      + tags_all                             = {
          + "Name" = "xfusion-ec2"
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

  # aws_s3_bucket.xfusion_logs_bucket will be created
  + resource "aws_s3_bucket" "xfusion_logs_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "xfusion-logs-21964"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.
aws_iam_role.xfusion_role: Creating...
aws_s3_bucket.xfusion_logs_bucket: Creating...
aws_iam_role.xfusion_role: Creation complete after 0s [id=xfusion-role]
aws_iam_instance_profile.xfusion_instance_profile: Creating...
aws_s3_bucket.xfusion_logs_bucket: Creation complete after 0s [id=xfusion-logs-21964]
aws_iam_policy.xfusion_access_policy: Creating...
aws_iam_policy.xfusion_access_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/xfusion-access-policy]
aws_iam_role_policy_attachment.xfusion_role_policy_attachment: Creating...
aws_iam_role_policy_attachment.xfusion_role_policy_attachment: Creation complete after 0s [id=xfusion-role-20260415083517093100000001]
aws_iam_instance_profile.xfusion_instance_profile: Creation complete after 5s [id=ec2-s3-upload-profile]
aws_instance.xfusion-ec2: Creating...
aws_instance.xfusion-ec2: Still creating... [10s elapsed]
aws_instance.xfusion-ec2: Creation complete after 10s [id=i-18d40b3bee1328229]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# data.aws_ami.amazon_linux_2:
data "aws_ami" "amazon_linux_2" {
    architecture          = "x86_64"
    arn                   = "arn:aws:ec2:us-east-1::image/ami-04681a1dbd79675a5"
    block_device_mappings = [
        {
            device_name  = "/dev/xvda"
            ebs          = {
                "delete_on_termination" = "false"
                "encrypted"             = "false"
                "iops"                  = "0"
                "snapshot_id"           = "snap-8cb51eca60db49ecc"
                "throughput"            = "0"
                "volume_size"           = "15"
                "volume_type"           = "standard"
            }
            no_device    = null
            virtual_name = null
        },
    ]
    boot_mode             = "uefi"
    creation_date         = "2026-04-15T08:34:33.000Z"
    deprecation_time      = null
    description           = "Amazon Linux 2 AMI 2.0.20180810 x86_64 HVM gp2"
    ena_support           = false
    hypervisor            = "xen"
    id                    = "ami-04681a1dbd79675a5"
    image_id              = "ami-04681a1dbd79675a5"
    image_location        = "amazon/amzn2-ami-hvm-2.0.20180810-x86_64-gp2"
    image_owner_alias     = "amazon"
    image_type            = "machine"
    imds_support          = null
    include_deprecated    = false
    kernel_id             = null
    most_recent           = true
    name                  = "amzn2-ami-hvm-2.0.20180810-x86_64-gp2"
    owner_id              = "137112412989"
    owners                = [
        "amazon",
    ]
    platform              = "Linux/UNIX"
    platform_details      = null
    product_codes         = []
    public                = true
    ramdisk_id            = null
    root_device_name      = "/dev/xvda"
    root_device_type      = "ebs"
    root_snapshot_id      = "snap-8cb51eca60db49ecc"
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
            "amzn2-ami-hvm-*-x86_64-gp2",
        ]
    }
    filter {
        name   = "virtualization-type"
        values = [
            "hvm",
        ]
    }
}

# aws_iam_instance_profile.xfusion_instance_profile:
resource "aws_iam_instance_profile" "xfusion_instance_profile" {
    arn         = "arn:aws:iam::000000000000:instance-profile/ec2-s3-upload-profile"
    create_date = "2026-04-15T08:35:16Z"
    id          = "ec2-s3-upload-profile"
    name        = "ec2-s3-upload-profile"
    name_prefix = null
    path        = "/"
    role        = "xfusion-role"
    tags_all    = {}
    unique_id   = "em58ln98w8idxyyrpf5u"
}

# aws_iam_policy.xfusion_access_policy:
resource "aws_iam_policy" "xfusion_access_policy" {
    arn              = "arn:aws:iam::000000000000:policy/xfusion-access-policy"
    attachment_count = 0
    description      = null
    id               = "arn:aws:iam::000000000000:policy/xfusion-access-policy"
    name             = "xfusion-access-policy"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = "s3:PutObject"
                    Effect   = "Allow"
                    Resource = "arn:aws:s3:::xfusion-logs-21964/*"
                    Sid      = "AllowPutObjectToXfusionLogsBucket"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "AQVQXFTVWB7RQRXPG8X0C"
    tags_all         = {}
}

# aws_iam_role.xfusion_role:
resource "aws_iam_role" "xfusion_role" {
    arn                   = "arn:aws:iam::000000000000:role/xfusion-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-15T08:35:16Z"
    description           = null
    force_detach_policies = false
    id                    = "xfusion-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "xfusion-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAM7T3LJ5IF"
}

# aws_iam_role_policy_attachment.xfusion_role_policy_attachment:
resource "aws_iam_role_policy_attachment" "xfusion_role_policy_attachment" {
    id         = "xfusion-role-20260415083517093100000001"
    policy_arn = "arn:aws:iam::000000000000:policy/xfusion-access-policy"
    role       = "xfusion-role"
}

# aws_instance.xfusion-ec2:
resource "aws_instance" "xfusion-ec2" {
    ami                                  = "ami-04681a1dbd79675a5"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-18d40b3bee1328229"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = "ec2-s3-upload-profile"
    id                                   = "i-18d40b3bee1328229"
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
    primary_network_interface_id         = "eni-6cea2ef21ba042315"
    private_dns                          = "ip-10-105-11-217.ec2.internal"
    private_ip                           = "10.105.11.217"
    public_dns                           = "ec2-54-214-194-2.compute-1.amazonaws.com"
    public_ip                            = "54.214.194.2"
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-945f8312bee395d9f"
    tags                                 = {
        "Name" = "xfusion-ec2"
    }
    tags_all                             = {
        "Name" = "xfusion-ec2"
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
        volume_id             = "vol-e8d416ec7e54deeab"
        volume_size           = 8
        volume_type           = "gp2"
    }
}

# aws_s3_bucket.xfusion_logs_bucket:
resource "aws_s3_bucket" "xfusion_logs_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::xfusion-logs-21964"
    bucket                      = "xfusion-logs-21964"
    bucket_domain_name          = "xfusion-logs-21964.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "xfusion-logs-21964.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "xfusion-logs-21964"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags_all                    = {}

    grant {
        id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

```