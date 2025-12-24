# Task 026 - Attach Elastic IP using Terraform

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

There is an instance named `xfusion-ec2` and an elastic-ip named `xfusion-ec2-eip` in `us-east-1` region. Attach the `xfusion-ec2-eip` elastic-ip to the `xfusion-ec2` instance using Terraform only. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to attach the specified Elastic IP to the instance.

## Instructions

1. Add the necessary Terraform resource block in the existing `main.tf` file to attach the specified Elastic IP to the instance.

```
# Attach Elastic IP to EC2 instance
resource "aws_eip_association" "ec2_eip_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2_eip.id
}
```

2. run terraform plan to see the execution plan.

```bash

bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_eip.ec2_eip: Refreshing state... [id=eipalloc-0577b0158ee584b1d]
aws_instance.ec2: Refreshing state... [id=i-b067bf252c881e8c5]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip_association.ec2_eip_assoc will be created
  + resource "aws_eip_association" "ec2_eip_assoc" {
      + allocation_id        = "eipalloc-0577b0158ee584b1d"
      + id                   = (known after apply)
      + instance_id          = "i-b067bf252c881e8c5"
      + network_interface_id = (known after apply)
      + private_ip_address   = (known after apply)
      + public_ip            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

```

3. Terraform apply to apply the changes.

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_eip.ec2_eip: Refreshing state... [id=eipalloc-0577b0158ee584b1d]
aws_instance.ec2: Refreshing state... [id=i-b067bf252c881e8c5]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip_association.ec2_eip_assoc will be created
  + resource "aws_eip_association" "ec2_eip_assoc" {
      + allocation_id        = "eipalloc-0577b0158ee584b1d"
      + id                   = (known after apply)
      + instance_id          = "i-b067bf252c881e8c5"
      + network_interface_id = (known after apply)
      + private_ip_address   = (known after apply)
      + public_ip            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_eip_association.ec2_eip_assoc: Creating...
aws_eip_association.ec2_eip_assoc: Creation complete after 0s [id=eipassoc-086b948c1ee2f4d14]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

4. Verify the Elastic IP is attached to the instance.

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-addresses --filters "Name=tag:Name,Values=xfusion-ec2-eip"
{
    "Addresses": [
        {
            "AllocationId": "eipalloc-0577b0158ee584b1d",
            "AssociationId": "eipassoc-086b948c1ee2f4d14",
            "Domain": "vpc",
            "NetworkInterfaceId": "eni-6d1acdcbddcdc9dba",
            "NetworkInterfaceOwnerId": "000000000000",
            "PrivateIpAddress": "172.31.0.4",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "xfusion-ec2-eip"
                }
            ],
            "InstanceId": "i-b067bf252c881e8c5",
            "PublicIp": "127.51.50.61"
        }
    ]
}


bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-instances
{
    "Reservations": [
        {
            "ReservationId": "r-e0ebfecef7a292244",
            "OwnerId": "000000000000",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "AttachTime": "2025-12-24T04:28:58Z",
                                "DeleteOnTermination": true,
                                "Status": "in-use",
                                "VolumeId": "vol-721b8ab222baa6c33"
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
                                "PublicIp": "127.51.50.61"
                            },
                            "Attachment": {
                                "AttachTime": "2015-01-01T00:00:00Z",
                                "AttachmentId": "eni-attach-4901ed0b7b9a40727",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-2e3f820d5447ada9f",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-6d1acdcbddcdc9dba",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "172.31.0.4",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "000000000000",
                                        "PublicIp": "127.51.50.61"
                                    },
                                    "Primary": true,
                                    "PrivateIpAddress": "172.31.0.4"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-88cbacea28f2b5949",
                            "VpcId": "vpc-b419949a73fd043ee"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-2e3f820d5447ada9f",
                            "GroupName": "default"
                        }
                    ],
                    "SourceDestCheck": true,
                    "StateReason": {
                        "Code": "",
                        "Message": ""
                    },
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "xfusion-ec2"
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
                    "InstanceId": "i-b067bf252c881e8c5",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-172-31-0-4.ec2.internal",
                    "PublicDnsName": "ec2-127-51-50-61.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-24T04:28:58Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-88cbacea28f2b5949",
                    "VpcId": "vpc-b419949a73fd043ee",
                    "PrivateIpAddress": "172.31.0.4",
                    "PublicIpAddress": "127.51.50.61"
                }
            ]
        }
    ]
}

```

**NOTE:** You can see the public-ip of eip and ec2 instance are same which means the elastic-ip is successfully attached to the instance.
