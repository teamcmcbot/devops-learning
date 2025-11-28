# Task 004: Allocate Elastic IP

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, allocate an Elastic IP address, name it as nautilus-eip.

## Instructions

```bash
# Allocate an Elastic IP address
aws ec2 allocate-address --domain vpc --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=nautilus-eip}]'

{
    "AllocationId": "eipalloc-02f5cfc59e4737705",
    "PublicIpv4Pool": "amazon",
    "NetworkBorderGroup": "us-east-1",
    "Domain": "vpc",
    "PublicIp": "54.236.192.55"
}

# Verify the Elastic IP allocation
aws ec2 describe-addresses --filters "Name=tag:Name,Values=nautilus-eip"
{
    "Addresses": [
        {
            "AllocationId": "eipalloc-02f5cfc59e4737705",
            "Domain": "vpc",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "nautilus-eip"
                }
            ],
            "PublicIpv4Pool": "amazon",
            "NetworkBorderGroup": "us-east-1",
            "PublicIp": "54.236.192.55"
        }
    ]
}

aws ec2 describe-addresses --filters "Name=tag:Name,Values=nautilus-eip" --query 'Addresses[*].[AllocationId,PublicIp,Tags[?Key==`Name`].Value|[0]]' --output table

-----------------------------------------------------------------
|                       DescribeAddresses                       |
+----------------------------+-----------------+----------------+
|  eipalloc-02f5cfc59e4737705|  54.236.192.55  |  nautilus-eip  |
+----------------------------+-----------------+----------------+

```
