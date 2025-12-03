# Task 005 - Create VPC with IPv6 using Terraform

The Nautilus DevOps team is strategically planning the migration of a portion of their infrastructure to the AWS cloud. Acknowledging the magnitude of this endeavor, they have chosen to tackle the migration incrementally rather than as a single, massive transition. Their approach involves creating Virtual Private Clouds (VPCs) as the initial step, as they will be provisioning various services under different VPCs.

For this task, create a VPC named xfusion-vpc in the us-east-1 region with the Amazon-provided IPv6 CIDR block using terraform.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-vpcs --filter "Name=tag:Name,Values=xfusion-vpc"
{
    "Vpcs": [
        {
            "OwnerId": "000000000000",
            "InstanceTenancy": "default",
            "Ipv6CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-b1071d4385d1faa52",
                    "Ipv6CidrBlock": "2400:6500:424c:a000::/56",
                    "Ipv6CidrBlockState": {
                        "State": "associated"
                    },
                    "Ipv6Pool": "Amazon"
                }
            ],
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-44e8d2d4485940fdf",
                    "CidrBlock": "10.1.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "xfusion-vpc"
                }
            ],
            "VpcId": "vpc-7fa682ab77ad71b09",
            "State": "available",
            "CidrBlock": "10.1.0.0/16",
            "DhcpOptionsId": "default"
        }
    ]
}
```
