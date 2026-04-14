# Task 005: Associate Elastic IP with EC2 Instance Using Terraform

The Nautilus DevOps Team has received a new request from the Development Team to set up a new EC2 instance. This instance will be used to host a new application that requires a stable IP address. To ensure that the instance has a consistent public IP, an Elastic IP address needs to be associated with it. This setup will help the Development Team to have a reliable and consistent access point for their application.

1. Create an EC2 instance named `datacenter-ec2` using any Linux AMI like Ubuntu.

2. Instance type must be `t2.micro` and associate an Elastic IP address named `datacenter-eip` with this instance.

3. Use the `main.tf` file (do not create a separate .tf file) to provision the EC2-Instance and Elastic IP.

4. Use the `outputs.tf` file and output the instance name using variable `KKE_instance_name` and the Elastic IP using variable `KKE_eip`.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_ami.amazon_linux_2: Reading...
data.aws_ami.amazon_linux_2: Read complete after 1s [id=ami-04681a1dbd79675a5]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.datacenter-eip will be created
  + resource "aws_eip" "datacenter-eip" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + ipam_pool_id         = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + ptr_record           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Name" = "datacenter-eip"
        }
      + tags_all             = {
          + "Name" = "datacenter-eip"
        }
      + vpc                  = (known after apply)
    }

  # aws_instance.ec2-instance will be created
  + resource "aws_instance" "ec2-instance" {
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
          + "Name" = "datacenter-ec2"
        }
      + tags_all                             = {
          + "Name" = "datacenter-ec2"
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

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_eip           = (known after apply)
  + KKE_instance_name = "datacenter-ec2"
aws_instance.ec2-instance: Creating...
aws_instance.ec2-instance: Still creating... [10s elapsed]
aws_instance.ec2-instance: Creation complete after 10s [id=i-8b4b34e4531ed8e2d]
aws_eip.datacenter-eip: Creating...
aws_eip.datacenter-eip: Creation complete after 0s [id=eipalloc-39315389c9407e78f]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

KKE_eip = "127.85.46.4"
KKE_instance_name = "datacenter-ec2"
```

## Verification:

```bash
bob@iac-server ~/terraform via 💠 default ✖ aws ec2 describe-instances
{
    "Reservations": [
        {
            "ReservationId": "r-0e97842893c4a2c0e",
            "OwnerId": "000000000000",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "AttachTime": "2026-04-14T08:51:15Z",
                                "DeleteOnTermination": true,
                                "Status": "in-use",
                                "VolumeId": "vol-fbd172e7e6be62c38"
                            }
                        }
                    ],
                    "ClientToken": "ABCDE0000000000003",
                    "EbsOptimized": false,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Association": {
                                "IpOwnerId": "000000000000",
                                "PublicIp": "127.85.46.4"
                            },
                            "Attachment": {
                                "AttachTime": "2015-01-01T00:00:00Z",
                                "AttachmentId": "eni-attach-203459d6668438018",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-3a1a252edbd14c8cd",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-714cfab7f068f5b90",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.210.2.136",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "000000000000",
                                        "PublicIp": "127.85.46.4"
                                    },
                                    "Primary": true,
                                    "PrivateIpAddress": "10.210.2.136"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-e7aa009e5af56055b",
                            "VpcId": "vpc-80f371e876a82d25c"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [],
                    "SourceDestCheck": true,
                    "StateReason": {
                        "Code": "",
                        "Message": ""
                    },
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "datacenter-ec2"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "HttpTokens": "optional",
                        "HttpPutResponseHopLimit": 1,
                        "HttpEndpoint": "enabled",
                        "HttpProtocolIpv6": "disabled",
                        "InstanceMetadataTags": "disabled"
                    },
                    "InstanceId": "i-8b4b34e4531ed8e2d",
                    "ImageId": "ami-04681a1dbd79675a5",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-10-210-2-136.ec2.internal",
                    "PublicDnsName": "ec2-127-85-46-4.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2026-04-14T08:51:15Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Platform": "Linux/UNIX",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-e7aa009e5af56055b",
                    "VpcId": "vpc-80f371e876a82d25c",
                    "PrivateIpAddress": "10.210.2.136",
                    "PublicIpAddress": "127.85.46.4"
                }
            ]
        }
    ]
}
```