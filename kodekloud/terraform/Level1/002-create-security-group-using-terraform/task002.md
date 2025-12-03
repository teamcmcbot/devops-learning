# Task 002: Create Security Group using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

Use Terraform to create a security group under the default VPC with the following requirements:

1. The name of the security group must be datacenter-sg.

2. The description must be Security group for Nautilus App Servers.

3. Add an inbound rule of type HTTP, with a port range of 80, and source CIDR range 0.0.0.0/0.

4. Add another inbound rule of type SSH, with a port range of 22, and source CIDR range 0.0.0.0/0.

Ensure that the security group is created in the us-east-1 region using Terraform. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-security-groups --filters "Name=group-name,Values=datacenter-sg"
{
    "SecurityGroups": [
        {
            "GroupId": "sg-38713ebc808bceb9d",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "Description": "All protocols",
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [
                        {
                            "Description": "All protocols",
                            "CidrIpv6": "::/0"
                        }
                    ],
                    "PrefixListIds": []
                }
            ],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "datacenter-sg"
                }
            ],
            "VpcId": "vpc-664e6b1ae97d658c8",
            "SecurityGroupArn": "arn:aws:ec2:us-east-1:000000000000:security-group/sg-38713ebc808bceb9d",
            "OwnerId": "000000000000",
            "GroupName": "datacenter-sg",
            "Description": "Security group for Nautilus App Servers",
            "IpPermissions": [
                {
                    "IpProtocol": "tcp",
                    "FromPort": 80,
                    "ToPort": 80,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "Description": "HTTP",
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                },
                {
                    "IpProtocol": "tcp",
                    "FromPort": 22,
                    "ToPort": 22,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "Description": "SSH",
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ]
        }
    ]
}
```
