# Task 002: Create Security Group

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create a security group under default VPC with the following requirements:

Name of the security group is devops-sg.

The description must be Security group for Nautilus App Servers

Add the inbound rule of type HTTP, with port range of 80. Enter the source CIDR range of 0.0.0.0/0.

Add another inbound rule of type SSH, with port range of 22. Enter the source CIDR range of 0.0.0.0/0.

## Solution

```bash
# Get default VPC ID
~ on ☁️  (us-east-1) ➜  aws ec2 describe-vpcs
{
    "Vpcs": [
        {
            "OwnerId": "096725167319",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-01653be527ed2d96f",
                    "CidrBlock": "172.31.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": true,
            "BlockPublicAccessStates": {
                "InternetGatewayBlockMode": "off"
            },
            "VpcId": "vpc-047a1a8a7569da26e",
            "State": "available",
            "CidrBlock": "172.31.0.0/16",
            "DhcpOptionsId": "dopt-0246fa7caca9605cd"
        }
    ]
}

# Create security group
# Group Name: devops-sg
# Description: Security group for Nautilus App Servers
# VPC ID: vpc-047a1a8a7569da26e

~ on ☁️  (us-east-1) ➜  aws ec2 create-security-group --group-name devops-sg --description "Security group for Nautilus App Servers" --vpc-id vpc-047a1a8a7569da26e
{
    "GroupId": "sg-0ae68f9c8733f4def",
    "SecurityGroupArn": "arn:aws:ec2:us-east-1:096725167319:security-group/sg-0ae68f9c8733f4def"
}

# Inbound Rules:
#   Type: HTTP, Port: 80, Source: 0.0.0.0/0

~ on ☁️  (us-east-1) ➜  aws ec2 authorize-security-group-ingress --group-id sg-0ae68f9c8733f4def --protocol tcp --port 80 --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0594c3be9f742e942",
            "GroupId": "sg-0ae68f9c8733f4def",
            "GroupOwnerId": "096725167319",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:096725167319:security-group-rule/sgr-0594c3be9f742e942"
        }
    ]
}

#  Type: SSH, Port: 22, Source: 0.0.0.0/0
~ on ☁️  (us-east-1) ➜  aws ec2 authorize-security-group-ingress --group-id sg-0ae68f9c8733f4def --protocol tcp --port 22 --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-04fc40603a64b5e72",
            "GroupId": "sg-0ae68f9c8733f4def",
            "GroupOwnerId": "096725167319",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:096725167319:security-group-rule/sgr-04fc40603a64b5e72"
        }
    ]
}

# Verify security group and rules devops-sg
~ on ☁️  (us-east-1) ✖ aws ec2 describe-security-groups --group-names devops-sg
{
    "SecurityGroups": [
        {
            "GroupId": "sg-0ae68f9c8733f4def",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ],
            "VpcId": "vpc-047a1a8a7569da26e",
            "SecurityGroupArn": "arn:aws:ec2:us-east-1:096725167319:security-group/sg-0ae68f9c8733f4def",
            "OwnerId": "096725167319",
            "GroupName": "devops-sg",
            "Description": "Security group for Nautilus App Servers",
            "IpPermissions": [
                {
                    "IpProtocol": "tcp",
                    "FromPort": 80,
                    "ToPort": 80,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
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
