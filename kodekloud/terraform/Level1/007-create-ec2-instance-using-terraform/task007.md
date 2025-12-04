# Task 007 - Create EC2 Instance using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units.

For this task, create an EC2 instance using Terraform with the following requirements:

The name of the instance must be nautilus-ec2.

Use the Amazon Linux ami-0c101f26f147fa7fd to launch this instance.

The Instance type must be t2.micro.

Create a new RSA key named nautilus-kp.

Attach the default (available by default) security group.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to provision the instance.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-instances
{
    "Reservations": [
        {
            "ReservationId": "r-f3fff099af49bf286",
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
                                "AttachmentId": "eni-attach-30c93addc83cdd75d",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-07e9dd6cba238c418",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-7b18e7a5c2d23ac37",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.137.116.123",
                            "PrivateIpAddresses": [
                                {
                                    "Primary": true,
                                    "PrivateIpAddress": "10.137.116.123"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-9c2376e21ae8d8417",
                            "VpcId": "vpc-73e8851ffe551f654"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [],
                    "SourceDestCheck": true,
                    "StateReason": {
                        "Code": "Client.UserInitiatedShutdown",
                        "Message": "Client.UserInitiatedShutdown: User initiated shutdown"
                    },
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "nautilus-ec2"
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
                    "InstanceId": "i-892938278f3b45ec2",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 48,
                        "Name": "terminated"
                    },
                    "PrivateDnsName": "ip-10-137-116-123.ec2.internal",
                    "PublicDnsName": "None",
                    "StateTransitionReason": "User initiated (2025-12-04 14:18:55 UTC)",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-04T14:17:44Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-9c2376e21ae8d8417",
                    "VpcId": "vpc-73e8851ffe551f654",
                    "PrivateIpAddress": "10.137.116.123"
                }
            ]
        },
        {
            "ReservationId": "r-f588837f55882c034",
            "OwnerId": "000000000000",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "AttachTime": "2025-12-04T14:19:05Z",
                                "DeleteOnTermination": true,
                                "Status": "in-use",
                                "VolumeId": "vol-3a75a87af86c833e0"
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
                                "PublicIp": "54.214.129.200"
                            },
                            "Attachment": {
                                "AttachTime": "2015-01-01T00:00:00Z",
                                "AttachmentId": "eni-attach-981b1019b57081dd8",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached"
                            },
                            "Description": "Primary network interface",
                            "Groups": [
                                {
                                    "GroupId": "sg-07e9dd6cba238c418",
                                    "GroupName": "default"
                                }
                            ],
                            "MacAddress": "1b:2b:3c:4d:5e:6f",
                            "NetworkInterfaceId": "eni-c042266700c296c5e",
                            "OwnerId": "000000000000",
                            "PrivateIpAddress": "10.209.127.185",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "000000000000",
                                        "PublicIp": "54.214.129.200"
                                    },
                                    "Primary": true,
                                    "PrivateIpAddress": "10.209.127.185"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-9c2376e21ae8d8417",
                            "VpcId": "vpc-73e8851ffe551f654"
                        }
                    ],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-07e9dd6cba238c418",
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
                            "Value": "nautilus-ec2"
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
                    "InstanceId": "i-5d8c93f3daddfcd72",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-10-209-127-185.ec2.internal",
                    "PublicDnsName": "ec2-54-214-129-200.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "KeyName": "nautilus-kp",
                    "AmiLaunchIndex": 0,
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-12-04T14:19:05Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1a"
                    },
                    "KernelId": "None",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-9c2376e21ae8d8417",
                    "VpcId": "vpc-73e8851ffe551f654",
                    "PrivateIpAddress": "10.209.127.185",
                    "PublicIpAddress": "54.214.129.200"
                }
            ]
        }
    ]
}

```
