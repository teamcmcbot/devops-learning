# Task 007: Change EC2 Instance Type

During the migration process, the Nautilus DevOps team created several EC2 instances in different regions. They are currently in the process of identifying the correct resources and utilization and are making continuous changes to ensure optimal resource utilization. Recently, they discovered that one of the EC2 instances was underutilized, prompting them to decide to change the instance type. Please make sure the Status check is completed (if its still in Initializing state) before making any changes to the instance.

1. Change the instance type from t2.micro to t2.nano for xfusion-ec2 instance.

2. Make sure the ec2 instance xfusion-ec2 is in running state after the change.

## Instructions

1. Check the current ec2 instance

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 describe-instances
{
    "Reservations": [
        {
            "ReservationId": "r-09056bcf512195dcc",
            "OwnerId": "427001312714",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/xvda",
                            "Ebs": {
                                "AttachTime": "2025-11-29T16:17:55.000Z",
                                "DeleteOnTermination": true,
                                "Status": "attached",
                                "VolumeId": "vol-051b0740a0b1ffaa1"
                            }
                        }
                    ],
                    "ClientToken": "e643af23-987c-4e8a-aca9-410e7fd44cd9",
                    "EbsOptimized": false,
                    "EnaSupport": true,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Association": {
                                "IpOwnerId": "amazon",
                                "PublicDnsName": "ec2-98-81-181-215.compute-1.amazonaws.com",
                                "PublicIp": "98.81.181.215"
                            },
                            "Attachment": {
                                "AttachTime": "2025-11-29T16:17:54.000Z",
                                "AttachmentId": "eni-attach-0b26c2b0201da59b8",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached",
                                "NetworkCardIndex": 0
                            },
                            "Description": "",
                            "Groups": [
                                {
                                    "GroupId": "sg-05787af716e1b23fe",
                                    "GroupName": "default"
                                }
                            ],
                            "Ipv6Addresses": [],
                            "MacAddress": "0a:ff:cd:69:8f:37",
                            "NetworkInterfaceId": "eni-0531bcfa367616cc7",
                            "OwnerId": "427001312714",
                            "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                            "PrivateIpAddress": "172.31.17.249",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "amazon",
                                        "PublicDnsName": "ec2-98-81-181-215.compute-1.amazonaws.com",
                                        "PublicIp": "98.81.181.215"
                                    },
                                    "Primary": true,
                                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                                    "PrivateIpAddress": "172.31.17.249"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-077907132987fe38e",
                            "VpcId": "vpc-0f0464547c317a608",
                            "InterfaceType": "interface",
                            "Operator": {
                                "Managed": false
                            }
                        }
                    ],
                    "RootDeviceName": "/dev/xvda",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-05787af716e1b23fe",
                            "GroupName": "default"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "xfusion-ec2"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "CpuOptions": {
                        "CoreCount": 1,
                        "ThreadsPerCore": 1
                    },
                    "CapacityReservationSpecification": {
                        "CapacityReservationPreference": "open"
                    },
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "State": "applied",
                        "HttpTokens": "required",
                        "HttpPutResponseHopLimit": 2,
                        "HttpEndpoint": "enabled",
                        "HttpProtocolIpv6": "disabled",
                        "InstanceMetadataTags": "disabled"
                    },
                    "EnclaveOptions": {
                        "Enabled": false
                    },
                    "BootMode": "uefi-preferred",
                    "PlatformDetails": "Linux/UNIX",
                    "UsageOperation": "RunInstances",
                    "UsageOperationUpdateTime": "2025-11-29T16:17:54.000Z",
                    "PrivateDnsNameOptions": {
                        "HostnameType": "ip-name",
                        "EnableResourceNameDnsARecord": false,
                        "EnableResourceNameDnsAAAARecord": false
                    },
                    "MaintenanceOptions": {
                        "AutoRecovery": "default",
                        "RebootMigration": "default"
                    },
                    "CurrentInstanceBootMode": "legacy-bios",
                    "NetworkPerformanceOptions": {
                        "BandwidthWeighting": "default"
                    },
                    "Operator": {
                        "Managed": false
                    },
                    "InstanceId": "i-0999156b93629bf10",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                    "PublicDnsName": "ec2-98-81-181-215.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "AmiLaunchIndex": 0,
                    "ProductCodes": [],
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-11-29T16:17:54.000Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1b"
                    },
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-077907132987fe38e",
                    "VpcId": "vpc-0f0464547c317a608",
                    "PrivateIpAddress": "172.31.17.249",
                    "PublicIpAddress": "98.81.181.215"
                }
            ]
        }
    ]
}

```

"InstanceId": "i-0999156b93629bf10"
"State": {
"Code": 16,
"Name": "running"
},
"InstanceType": "t2.micro",

2. Stop the instance

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 stop-instances --instance-ids i-0999156b93629bf10
{
    "StoppingInstances": [
        {
            "InstanceId": "i-0999156b93629bf10",
            "CurrentState": {
                "Code": 64,
                "Name": "stopping"
            },
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}
```

3. Check State until it is stopped

```bash
aws ec2 describe-instances --instance-ids i-0999156b93629bf10
```

"State": {
"Code": 80,
"Name": "stopped"
},

4. Change the instance type to t2.nano

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 modify-instance-attribute --instance-id i-0999156b93629bf10 --instance-type "{\"Value\": \"t2.nano\"}"

~ on ☁️  (us-east-1) ➜  aws ec2 describe-instances --instance-ids i-0999156b93629bf10
{
    "Reservations": [
        {
            "ReservationId": "r-09056bcf512195dcc",
            "OwnerId": "427001312714",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/xvda",
                            "Ebs": {
                                "AttachTime": "2025-11-29T16:17:55.000Z",
                                "DeleteOnTermination": true,
                                "Status": "attached",
                                "VolumeId": "vol-051b0740a0b1ffaa1"
                            }
                        }
                    ],
                    "ClientToken": "e643af23-987c-4e8a-aca9-410e7fd44cd9",
                    "EbsOptimized": false,
                    "EnaSupport": true,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Attachment": {
                                "AttachTime": "2025-11-29T16:17:54.000Z",
                                "AttachmentId": "eni-attach-0b26c2b0201da59b8",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached",
                                "NetworkCardIndex": 0
                            },
                            "Description": "",
                            "Groups": [
                                {
                                    "GroupId": "sg-05787af716e1b23fe",
                                    "GroupName": "default"
                                }
                            ],
                            "Ipv6Addresses": [],
                            "MacAddress": "0a:ff:cd:69:8f:37",
                            "NetworkInterfaceId": "eni-0531bcfa367616cc7",
                            "OwnerId": "427001312714",
                            "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                            "PrivateIpAddress": "172.31.17.249",
                            "PrivateIpAddresses": [
                                {
                                    "Primary": true,
                                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                                    "PrivateIpAddress": "172.31.17.249"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-077907132987fe38e",
                            "VpcId": "vpc-0f0464547c317a608",
                            "InterfaceType": "interface",
                            "Operator": {
                                "Managed": false
                            }
                        }
                    ],
                    "RootDeviceName": "/dev/xvda",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-05787af716e1b23fe",
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
                            "Value": "xfusion-ec2"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "CpuOptions": {
                        "CoreCount": 1,
                        "ThreadsPerCore": 1
                    },
                    "CapacityReservationSpecification": {
                        "CapacityReservationPreference": "open"
                    },
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "State": "applied",
                        "HttpTokens": "required",
                        "HttpPutResponseHopLimit": 2,
                        "HttpEndpoint": "enabled",
                        "HttpProtocolIpv6": "disabled",
                        "InstanceMetadataTags": "disabled"
                    },
                    "EnclaveOptions": {
                        "Enabled": false
                    },
                    "BootMode": "uefi-preferred",
                    "PlatformDetails": "Linux/UNIX",
                    "UsageOperation": "RunInstances",
                    "UsageOperationUpdateTime": "2025-11-29T16:17:54.000Z",
                    "PrivateDnsNameOptions": {
                        "HostnameType": "ip-name",
                        "EnableResourceNameDnsARecord": false,
                        "EnableResourceNameDnsAAAARecord": false
                    },
                    "MaintenanceOptions": {
                        "AutoRecovery": "default",
                        "RebootMigration": "default"
                    },
                    "CurrentInstanceBootMode": "legacy-bios",
                    "NetworkPerformanceOptions": {
                        "BandwidthWeighting": "default"
                    },
                    "Operator": {
                        "Managed": false
                    },
                    "InstanceId": "i-0999156b93629bf10",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 80,
                        "Name": "stopped"
                    },
                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                    "PublicDnsName": "",
                    "StateTransitionReason": "User initiated (2025-11-29 16:23:36 GMT)",
                    "AmiLaunchIndex": 0,
                    "ProductCodes": [],
                    "InstanceType": "t2.nano",
                    "LaunchTime": "2025-11-29T16:17:54.000Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1b"
                    },
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-077907132987fe38e",
                    "VpcId": "vpc-0f0464547c317a608",
                    "PrivateIpAddress": "172.31.17.249"
                }
            ]
        }
    ]
}
```

5. Start the instance

```bash
aws ec2 start-instances --instance-ids i-0999156b93629bf10
```

6. Verify the instance is running

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 describe-instances --instance-ids i-0999156b93629bf10
{
    "Reservations": [
        {
            "ReservationId": "r-09056bcf512195dcc",
            "OwnerId": "427001312714",
            "Groups": [],
            "Instances": [
                {
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/xvda",
                            "Ebs": {
                                "AttachTime": "2025-11-29T16:17:55.000Z",
                                "DeleteOnTermination": true,
                                "Status": "attached",
                                "VolumeId": "vol-051b0740a0b1ffaa1"
                            }
                        }
                    ],
                    "ClientToken": "e643af23-987c-4e8a-aca9-410e7fd44cd9",
                    "EbsOptimized": false,
                    "EnaSupport": true,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [
                        {
                            "Association": {
                                "IpOwnerId": "amazon",
                                "PublicDnsName": "ec2-44-223-4-21.compute-1.amazonaws.com",
                                "PublicIp": "44.223.4.21"
                            },
                            "Attachment": {
                                "AttachTime": "2025-11-29T16:17:54.000Z",
                                "AttachmentId": "eni-attach-0b26c2b0201da59b8",
                                "DeleteOnTermination": true,
                                "DeviceIndex": 0,
                                "Status": "attached",
                                "NetworkCardIndex": 0
                            },
                            "Description": "",
                            "Groups": [
                                {
                                    "GroupId": "sg-05787af716e1b23fe",
                                    "GroupName": "default"
                                }
                            ],
                            "Ipv6Addresses": [],
                            "MacAddress": "0a:ff:cd:69:8f:37",
                            "NetworkInterfaceId": "eni-0531bcfa367616cc7",
                            "OwnerId": "427001312714",
                            "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                            "PrivateIpAddress": "172.31.17.249",
                            "PrivateIpAddresses": [
                                {
                                    "Association": {
                                        "IpOwnerId": "amazon",
                                        "PublicDnsName": "ec2-44-223-4-21.compute-1.amazonaws.com",
                                        "PublicIp": "44.223.4.21"
                                    },
                                    "Primary": true,
                                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                                    "PrivateIpAddress": "172.31.17.249"
                                }
                            ],
                            "SourceDestCheck": true,
                            "Status": "in-use",
                            "SubnetId": "subnet-077907132987fe38e",
                            "VpcId": "vpc-0f0464547c317a608",
                            "InterfaceType": "interface",
                            "Operator": {
                                "Managed": false
                            }
                        }
                    ],
                    "RootDeviceName": "/dev/xvda",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [
                        {
                            "GroupId": "sg-05787af716e1b23fe",
                            "GroupName": "default"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "xfusion-ec2"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "CpuOptions": {
                        "CoreCount": 1,
                        "ThreadsPerCore": 1
                    },
                    "CapacityReservationSpecification": {
                        "CapacityReservationPreference": "open"
                    },
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "State": "applied",
                        "HttpTokens": "required",
                        "HttpPutResponseHopLimit": 2,
                        "HttpEndpoint": "enabled",
                        "HttpProtocolIpv6": "disabled",
                        "InstanceMetadataTags": "disabled"
                    },
                    "EnclaveOptions": {
                        "Enabled": false
                    },
                    "BootMode": "uefi-preferred",
                    "PlatformDetails": "Linux/UNIX",
                    "UsageOperation": "RunInstances",
                    "UsageOperationUpdateTime": "2025-11-29T16:17:54.000Z",
                    "PrivateDnsNameOptions": {
                        "HostnameType": "ip-name",
                        "EnableResourceNameDnsARecord": false,
                        "EnableResourceNameDnsAAAARecord": false
                    },
                    "MaintenanceOptions": {
                        "AutoRecovery": "default",
                        "RebootMigration": "default"
                    },
                    "CurrentInstanceBootMode": "legacy-bios",
                    "NetworkPerformanceOptions": {
                        "BandwidthWeighting": "default"
                    },
                    "Operator": {
                        "Managed": false
                    },
                    "InstanceId": "i-0999156b93629bf10",
                    "ImageId": "ami-0c101f26f147fa7fd",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateDnsName": "ip-172-31-17-249.ec2.internal",
                    "PublicDnsName": "ec2-44-223-4-21.compute-1.amazonaws.com",
                    "StateTransitionReason": "",
                    "AmiLaunchIndex": 0,
                    "ProductCodes": [],
                    "InstanceType": "t2.nano",
                    "LaunchTime": "2025-11-29T16:27:25.000Z",
                    "Placement": {
                        "GroupName": "",
                        "Tenancy": "default",
                        "AvailabilityZone": "us-east-1b"
                    },
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "SubnetId": "subnet-077907132987fe38e",
                    "VpcId": "vpc-0f0464547c317a608",
                    "PrivateIpAddress": "172.31.17.249",
                    "PublicIpAddress": "44.223.4.21"
                }
            ]
        }
    ]
}

```

## Verification ✅

| Requirement                                       | Status      | Evidence                                                   |
| ------------------------------------------------- | ----------- | ---------------------------------------------------------- |
| Change instance type from `t2.micro` to `t2.nano` | ✅ Complete | `"InstanceType": "t2.nano"` in final output                |
| Instance `xfusion-ec2` is in running state        | ✅ Complete | `"State": {"Code": 16, "Name": "running"}` in final output |

**Task completed successfully!**
