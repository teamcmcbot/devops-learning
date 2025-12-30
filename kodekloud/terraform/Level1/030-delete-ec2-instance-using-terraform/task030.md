# Task 030 - Delete EC2 Instance using Terraform

During the migration process, several resources were created under the AWS account. Some of these test resources are no longer needed at the moment, so we need to clean them up temporarily. One such instance is currently unused and should be deleted.

1. Delete the ec2 instance named `datacenter-ec2` present in `us-east-1` region using terraform. Make sure to **keep the provisioning code**, as we might need to provision this instance again later.

2. Before submitting your task, make sure instance is in `terminated` state.

The Terraform working directory is /home/bob/terraform.

## Solution

To delete the EC2 instance named `datacenter-ec2` using Terraform while keeping the provisioning code, follow these steps:

1. **Navigate to the Terraform working directory:**
   ```bash
   cd /home/bob/terraform
   ```
2. **Initialize the Terraform configuration (if not already initialized):**
   ```bash
   terraform init
   ```
3. **Plan the destruction of the specific resource:**
   Use the `-target` option to specify the resource you want to delete. First, identify the resource name in your Terraform configuration file (usually `main.tf` or similar). It might look something like `aws_instance.ec2`.
   ```bash
   terraform plan -destroy -target=aws_instance.ec2
   ```

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform plan -destroy -target=aws_instance.ec2
aws_instance.ec2: Refreshing state... [id=i-b1fe47dad4f2674ed]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.ec2 will be destroyed
  - resource "aws_instance" "ec2" {
      - ami                                  = "ami-0c101f26f147fa7fd" -> null
      - arn                                  = "arn:aws:ec2:us-east-1::instance/i-b1fe47dad4f2674ed" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1a" -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-b1fe47dad4f2674ed" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-6978287a1ce5e8b4e" -> null
      - private_dns                          = "ip-10-152-94-162.ec2.internal" -> null
      - private_ip                           = "10.152.94.162" -> null
      - public_dns                           = "ec2-54-214-126-109.compute-1.amazonaws.com" -> null
      - public_ip                            = "54.214.126.109" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "default",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-00f38f16c61affe02" -> null
      - tags                                 = {
          - "Name" = "datacenter-ec2"
        } -> null
      - tags_all                             = {
          - "Name" = "datacenter-ec2"
        } -> null
      - tenancy                              = "default" -> null
      - user_data_replace_on_change          = false -> null
      - vpc_security_group_ids               = [
          - "sg-724a249fc408c40ab",
        ] -> null
        # (8 unchanged attributes hidden)

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 0 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-9b7e38cd4ca28af90" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
            # (1 unchanged attribute hidden)
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan
│ may not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations
│ such as recovering from errors or mistakes, or when Terraform specifically suggests to use
│ it as part of an error message.
╵

─────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.
```

4. **Apply the destruction plan:**

   ```bash
   terraform apply -destroy -target=aws_instance.ec2
   ```

   Confirm the action when prompted by typing `yes`.

5. **Verify the instance is terminated:**
   You can check the AWS Management Console or use the AWS CLI to verify that the instance is in the `terminated` state:
   ```bash
   aws ec2 describe-instances --filters "Name=tag:Name,Values=datacenter-ec2" --region us-east-1
   ```

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-instances --filters "Name=tag:Name,Values=datacenter-ec2" --region us-east-1
{
    "Reservations": [
        {
            "ReservationId": "r-a4a79314ca683d102",
            "OwnerId": "000000000000",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [],
                    "ClientToken": "ABCDE0000000000003",
                    "EbsOptimized": false,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Attachment": {
                                "AttachTime": "2015-01-01T00:00:00Z",
                                "AttachmentId": "eni-attach-19448bb178d96bb05",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-724a249fc408c40ab",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-6978287a1ce5e8b4e",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.152.94.162",
                            "PrivateIpAddresses": [
                                {
                                    "Primary": true,
                                    "PrivateIpAddress": "10.152.94.162"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-00f38f16c61affe02",
                            "VpcId": "vpc-a2d1727036a399e34"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-724a249fc408c40ab",
                            "GroupName": "default"
                        }
                    ],
                    "SourceDestCheck": true,
                    "StateReason": {
                        "Code": "Client.UserInitiatedShutdown",
                        "Message": "Client.UserInitiatedShutdown: User initiated shutdown"
                    },
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "datacenter-ec2"
                        }
                    ],
                    "VirtualizationType": "paravirtual",
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
                    "InstanceId": "i-b1fe47dad4f2674ed",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 48,
                        "Name": "terminated"
                    },
                    "PrivateDnsName": "ip-10-152-94-162.ec2.internal",
                    "PublicDnsName": "None",
                    "StateTransitionReason": "User initiated (2025-12-30 11:34:51 UTC)",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-30T11:16:55Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-00f38f16c61affe02",
                    "VpcId": "vpc-a2d1727036a399e34",
                    "PrivateIpAddress": "10.152.94.162"
                }
            ]
        }
    ]
}

```
