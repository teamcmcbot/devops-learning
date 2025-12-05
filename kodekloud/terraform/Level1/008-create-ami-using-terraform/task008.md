# Task 008: Create AMI using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create an AMI from an existing EC2 instance named devops-ec2 using Terraform.

Name of the AMI should be devops-ec2-ami, make sure AMI is in available state.

The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to create the AMI.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Verification

```bash
## Verify Instance is created
bob@iac-server ~/terraform via 💠 default ✖ aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-ec2"
{
    "Reservations": [
        {
            "ReservationId": "r-556bf1715d54dd175",
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
                                "AttachmentId": "eni-attach-420a72717cf053d4b",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-a820dd8cbde2f81f3",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-2bb14b77d1fe35ce9",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.161.7.217",
                            "PrivateIpAddresses": [
                                {
                                    "Primary": true,
                                    "PrivateIpAddress": "10.161.7.217"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-66618896db1f0a9a2",
                            "VpcId": "vpc-9160a2b06994aa28f"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-a820dd8cbde2f81f3",
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
                            "Value": "devops-ec2"
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
                    "InstanceId": "i-a7f823ae589f31e8b",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 48,
                        "Name": "terminated"
                    },
                    "PrivateDnsName": "ip-10-161-7-217.ec2.internal",
                    "PublicDnsName": "None",
                    "StateTransitionReason": "User initiated (2025-12-04 16:14:54 UTC)",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-04T15:57:00Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-66618896db1f0a9a2",
                    "VpcId": "vpc-9160a2b06994aa28f",
                    "PrivateIpAddress": "10.161.7.217"
                }
            ]
        },
        {
            "ReservationId": "r-433a723957bf9b10a",
            "OwnerId": "000000000000",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "AttachTime": "2025-12-04T16:14:54Z",
                                "DeleteOnTermination": true,
                                "Status": "in-use",
                                "VolumeId": "vol-957e2a03812b11bb2"
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
                                "PublicIp": "54.214.6.201"
                            },
                            "Attachment": {
                                "AttachTime": "2015-01-01T00:00:00Z",
                                "AttachmentId": "eni-attach-8bb2887ef20bea905",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-a820dd8cbde2f81f3",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-15320d19ef69884e7",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.87.20.21",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "000000000000",
                                        "PublicIp": "54.214.6.201"
                                    },
                                    "Primary": true,
                                    "PrivateIpAddress": "10.87.20.21"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-66618896db1f0a9a2",
                            "VpcId": "vpc-9160a2b06994aa28f"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-a820dd8cbde2f81f3",
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
                            "Value": "devops-ec2"
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
                    "InstanceId": "i-9bff588b4bc07a5a4",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-10-87-20-21.ec2.internal",
                    "PublicDnsName": "ec2-54-214-6-201.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-04T16:14:54Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-66618896db1f0a9a2",
                    "VpcId": "vpc-9160a2b06994aa28f",
                    "PrivateIpAddress": "10.87.20.21",
                    "PublicIpAddress": "54.214.6.201"
                }
            ]
        }
    ]
}

## Verify AMI is created and in available state
bob@iac-server ~/terraform via 💠 default ➜   aws ec2 describe-images --filters "Name=name,Values=devops-ec2-ami"
{
    "Images": [
        {
            "BlockDeviceMappings": [
                {
                    "Ebs": {
                        "DeleteOnTermination": false,
                        "SnapshotId": "snap-a716284b0dfcaae4a",
                        "VolumeSize": 15,
                        "VolumeType": "standard"
                    },
                    "DeviceName": "/dev/sda1"
                }
            ],
            "Description": "",
            "Name": "devops-ec2-ami",
            "RootDeviceName": "/dev/sda1",
            "RootDeviceType": "standard",
            "Tags": [],
            "VirtualizationType": "paravirtual",
            "BootMode": "uefi",
            "SourceInstanceId": "i-9bff588b4bc07a5a4",
            "ImageId": "ami-5e8d84a753a46414d",
            "State": "available",
            "OwnerId": "000000000000",
            "CreationDate": "2025-12-04T16:15:04.000Z",
            "Public": false,
            "ProductCodes": [],
            "Architecture": "x86_64",
            "ImageType": "machine"
        }
    ]
}
```
