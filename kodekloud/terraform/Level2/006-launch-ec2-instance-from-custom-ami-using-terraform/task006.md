# Task 006: Launch EC2 Instance from Custom AMI Using Terraform

The Nautilus DevOps team needs to create an AMI from an existing EC2 instance for backup and scaling purposes. The following steps are required:

1. They have an existing EC2 instance named `datacenter-ec2`.

2. They need to create an AMI named `datacenter-ec2-ami` from this instance.

3. Additionally, they need to launch a new EC2 instance named `datacenter-ec2-new` using this AMI.

4. Update the `main.tf` file (do not create a different or separate.tf file) to provision an AMI and then launch an EC2 Instance from that AMI.

5. Create an outputs.tf file to output the following values:

- KKE_ami_id for the AMI ID you created.
- KKE_new_instance_id for the EC2 instance ID you created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_instance.ec2: Refreshing state... [id=i-6fcc06664322fd793]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ami_from_instance.datacenter-ec2-ami will be created
  + resource "aws_ami_from_instance" "datacenter-ec2-ami" {
      + architecture         = (known after apply)
      + arn                  = (known after apply)
      + boot_mode            = (known after apply)
      + ena_support          = (known after apply)
      + hypervisor           = (known after apply)
      + id                   = (known after apply)
      + image_location       = (known after apply)
      + image_owner_alias    = (known after apply)
      + image_type           = (known after apply)
      + imds_support         = (known after apply)
      + kernel_id            = (known after apply)
      + manage_ebs_snapshots = (known after apply)
      + name                 = "datacenter-ec2-ami"
      + owner_id             = (known after apply)
      + platform             = (known after apply)
      + platform_details     = (known after apply)
      + public               = (known after apply)
      + ramdisk_id           = (known after apply)
      + root_device_name     = (known after apply)
      + root_snapshot_id     = (known after apply)
      + source_instance_id   = "i-6fcc06664322fd793"
      + sriov_net_support    = (known after apply)
      + tags_all             = (known after apply)
      + tpm_support          = (known after apply)
      + uefi_data            = (known after apply)
      + usage_operation      = (known after apply)
      + virtualization_type  = (known after apply)

      + ebs_block_device (known after apply)

      + ephemeral_block_device (known after apply)
    }

  # aws_instance.datacenter-ec2-new will be created
  + resource "aws_instance" "datacenter-ec2-new" {
      + ami                                  = (known after apply)
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
          + "Name" = "datacenter-ec2-new"
        }
      + tags_all                             = {
          + "Name" = "datacenter-ec2-new"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-f791b5c7a35798c96",
        ]

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

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_ami_id          = (known after apply)
  + KKE_new_instance_id = (known after apply)
aws_ami_from_instance.datacenter-ec2-ami: Creating...
aws_ami_from_instance.datacenter-ec2-ami: Creation complete after 5s [id=ami-4acae723948ae941d]
aws_instance.datacenter-ec2-new: Creating...
aws_instance.datacenter-ec2-new: Still creating... [10s elapsed]
aws_instance.datacenter-ec2-new: Creation complete after 10s [id=i-27106ccd59ec9daa0]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

KKE_ami_id = "ami-4acae723948ae941d"
KKE_new_instance_id = "i-27106ccd59ec9daa0"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_ami_from_instance.datacenter-ec2-ami:
resource "aws_ami_from_instance" "datacenter-ec2-ami" {
    architecture         = "x86_64"
    arn                  = "arn:aws:ec2:us-east-1::image/ami-4acae723948ae941d"
    boot_mode            = "uefi"
    deprecation_time     = null
    description          = null
    ena_support          = false
    hypervisor           = null
    id                   = "ami-4acae723948ae941d"
    image_location       = null
    image_owner_alias    = null
    image_type           = "machine"
    imds_support         = null
    kernel_id            = null
    manage_ebs_snapshots = true
    name                 = "datacenter-ec2-ami"
    owner_id             = "000000000000"
    platform             = null
    platform_details     = null
    public               = false
    ramdisk_id           = null
    root_device_name     = "/dev/sda1"
    root_snapshot_id     = "snap-d061ddb9639d72ad2"
    source_instance_id   = "i-6fcc06664322fd793"
    sriov_net_support    = null
    tags_all             = {}
    tpm_support          = null
    usage_operation      = null
    virtualization_type  = "paravirtual"

    ebs_block_device {
        delete_on_termination = false
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        outpost_arn           = null
        snapshot_id           = "snap-d061ddb9639d72ad2"
        throughput            = 0
        volume_size           = 15
        volume_type           = "standard"
    }
}

# aws_instance.datacenter-ec2-new:
resource "aws_instance" "datacenter-ec2-new" {
    ami                                  = "ami-4acae723948ae941d"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-27106ccd59ec9daa0"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-27106ccd59ec9daa0"
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
    primary_network_interface_id         = "eni-e48a80b1fb780e6b5"
    private_dns                          = "ip-10-252-32-134.ec2.internal"
    private_ip                           = "10.252.32.134"
    public_dns                           = "ec2-54-214-141-7.compute-1.amazonaws.com"
    public_ip                            = "54.214.141.7"
    secondary_private_ips                = []
    security_groups                      = [
        "default",
    ]
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-87cb02bdf31b5b5ae"
    tags                                 = {
        "Name" = "datacenter-ec2-new"
    }
    tags_all                             = {
        "Name" = "datacenter-ec2-new"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-f791b5c7a35798c96",
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
        volume_id             = "vol-0e958969f6e165eea"
        volume_size           = 8
        volume_type           = "gp2"
    }
}

# aws_instance.ec2:
resource "aws_instance" "ec2" {
    ami                                  = "ami-0c101f26f147fa7fd"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-6fcc06664322fd793"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-6fcc06664322fd793"
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
    primary_network_interface_id         = "eni-687456e5716887085"
    private_dns                          = "ip-10-160-178-18.ec2.internal"
    private_ip                           = "10.160.178.18"
    public_dns                           = "ec2-54-214-131-234.compute-1.amazonaws.com"
    public_ip                            = "54.214.131.234"
    secondary_private_ips                = []
    security_groups                      = [
        "default",
    ]
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-87cb02bdf31b5b5ae"
    tags                                 = {
        "Name" = "datacenter-ec2"
    }
    tags_all                             = {
        "Name" = "datacenter-ec2"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-f791b5c7a35798c96",
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
        volume_id             = "vol-881d92f1c6f01b1d1"
        volume_size           = 8
        volume_type           = "gp2"
    }
}


Outputs:

KKE_ami_id = "ami-4acae723948ae941d"
KKE_new_instance_id = "i-27106ccd59ec9daa0"
```