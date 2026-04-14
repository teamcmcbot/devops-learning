# Task 003: Replace Existing EC2 Instance via Terraform

To test resilience and recreation behavior in Terraform, the DevOps team needs to demonstrate the use of the `-replace` option to forcefully recreate an EC2 instance without changing its configuration. Please complete the following tasks:

1. Use the Terraform CLI `-replace` option to destroy and recreate the EC2 instance `datacenter-ec2`, even though the configuration remains unchanged.

2. Ensure that the instance is recreated successfully.


Notes:

The new instance created using the `-replace` option should have a different instance ID than the previously provisioned instance.

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

## Current

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_instance.web_server:
resource "aws_instance" "web_server" {
    ami                                  = "ami-0c55b159cbfafe1f0"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-8d44c7d4ee0cf769b"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-8d44c7d4ee0cf769b"
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
    primary_network_interface_id         = "eni-52b5659a260695fb4"
    private_dns                          = "ip-10-201-50-182.ec2.internal"
    private_ip                           = "10.201.50.182"
    public_dns                           = "ec2-54-214-189-43.compute-1.amazonaws.com"
    public_ip                            = "54.214.189.43"
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-936380850bce10ea2"
    tags                                 = {
        "Name" = "datacenter-ec2"
    }
    tags_all                             = {
        "Name" = "datacenter-ec2"
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
        volume_id             = "vol-d12700a0aecc7b639"
        volume_size           = 8
        volume_type           = "gp2"
    }
}


Outputs:

instance_id = "i-8d44c7d4ee0cf769b"
```

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -replace="aws_instance.web_server"
aws_instance.web_server: Refreshing state... [id=i-8d44c7d4ee0cf769b]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.web_server will be replaced, as requested
-/+ resource "aws_instance" "web_server" {
      ~ arn                                  = "arn:aws:ec2:us-east-1::instance/i-8d44c7d4ee0cf769b" -> (known after apply)
      ~ associate_public_ip_address          = true -> (known after apply)
      ~ availability_zone                    = "us-east-1a" -> (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      ~ disable_api_stop                     = false -> (known after apply)
      ~ disable_api_termination              = false -> (known after apply)
      ~ ebs_optimized                        = false -> (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      - hibernation                          = false -> null
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      ~ id                                   = "i-8d44c7d4ee0cf769b" -> (known after apply)
      ~ instance_initiated_shutdown_behavior = "stop" -> (known after apply)
      + instance_lifecycle                   = (known after apply)
      ~ instance_state                       = "running" -> (known after apply)
      ~ ipv6_address_count                   = 0 -> (known after apply)
      ~ ipv6_addresses                       = [] -> (known after apply)
      + key_name                             = (known after apply)
      ~ monitoring                           = false -> (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      ~ placement_partition_number           = 0 -> (known after apply)
      ~ primary_network_interface_id         = "eni-52b5659a260695fb4" -> (known after apply)
      ~ private_dns                          = "ip-10-201-50-182.ec2.internal" -> (known after apply)
      ~ private_ip                           = "10.201.50.182" -> (known after apply)
      ~ public_dns                           = "ec2-54-214-189-43.compute-1.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "54.214.189.43" -> (known after apply)
      ~ secondary_private_ips                = [] -> (known after apply)
      ~ security_groups                      = [] -> (known after apply)
      + spot_instance_request_id             = (known after apply)
      ~ subnet_id                            = "subnet-936380850bce10ea2" -> (known after apply)
        tags                                 = {
            "Name" = "datacenter-ec2"
        }
      ~ tenancy                              = "default" -> (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      ~ vpc_security_group_ids               = [] -> (known after apply)
        # (6 unchanged attributes hidden)

      ~ capacity_reservation_specification (known after apply)

      ~ cpu_options (known after apply)

      ~ ebs_block_device (known after apply)

      ~ enclave_options (known after apply)

      ~ ephemeral_block_device (known after apply)

      ~ instance_market_options (known after apply)

      ~ maintenance_options (known after apply)

      ~ metadata_options (known after apply)
      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      ~ network_interface (known after apply)

      ~ private_dns_name_options (known after apply)

      ~ root_block_device (known after apply)
      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 0 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-d12700a0aecc7b639" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
            # (1 unchanged attribute hidden)
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ instance_id = "i-8d44c7d4ee0cf769b" -> (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web_server: Destroying... [id=i-8d44c7d4ee0cf769b]
aws_instance.web_server: Still destroying... [id=i-8d44c7d4ee0cf769b, 10s elapsed]
aws_instance.web_server: Destruction complete after 10s
aws_instance.web_server: Creating...
aws_instance.web_server: Still creating... [10s elapsed]
aws_instance.web_server: Creation complete after 10s [id=i-5d780a9f37777edc2]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

instance_id = "i-5d780a9f37777edc2"
```