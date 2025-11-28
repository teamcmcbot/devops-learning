# Task 003: Create Subnet

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition.

For this task, create one subnet named `nautilus-subnet` under default VPC.

## Instructions

```bash
# Get the default VPC details
~ on ☁️  (us-east-1) ✖ aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"
{
    "Vpcs": [
        {
            "OwnerId": "059254148810",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-0a1f0dcedcce964fc",
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
            "VpcId": "vpc-00e02ddd40abf341a",
            "State": "available",
            "CidrBlock": "172.31.0.0/16",
            "DhcpOptionsId": "dopt-0f0e50664fcbf412f"
        }
    ]
}

# Note the VPC ID and CIDR block
# VPC ID: vpc-00e02ddd40abf341a
# CIDR Block: 172.31.0.0/16

# Check existing subnets in the default VPC to avoid CIDR conflicts
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-00e02ddd40abf341a" --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' --output table

----------------------------------------------------------------------
|                           DescribeSubnets                          |
+---------------------------+------------------+-------------+-------+
|  subnet-0cace73e4b260cc51 |  172.31.48.0/20  |  us-east-1e |  None |
|  subnet-007d9eab8e8683a08 |  172.31.80.0/20  |  us-east-1b |  None |
|  subnet-0c43182cb6ae9e527 |  172.31.32.0/20  |  us-east-1d |  None |
|  subnet-0f9a4b3ad47f3576b |  172.31.16.0/20  |  us-east-1c |  None |
|  subnet-0ebc110aae091d1fe |  172.31.0.0/20   |  us-east-1a |  None |
|  subnet-01dd79c48d452ef5e |  172.31.64.0/20  |  us-east-1f |  None |
+---------------------------+------------------+-------------+-------+

# Alternative command to see just the CIDR blocks in use
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-00e02ddd40abf341a" --query 'Subnets[*].CidrBlock' --output text

172.31.48.0/20  172.31.80.0/20  172.31.32.0/20  172.31.16.0/20  172.31.0.0/20   172.31.64.0/20

# Analyze existing CIDR blocks from the query results above:
# Existing subnets use /20 CIDR blocks covering large ranges:
# - 172.31.0.0/20   (covers 172.31.0.0 to 172.31.15.255)   - us-east-1a
# - 172.31.16.0/20  (covers 172.31.16.0 to 172.31.31.255)  - us-east-1c
# - 172.31.32.0/20  (covers 172.31.32.0 to 172.31.47.255)  - us-east-1d
# - 172.31.48.0/20  (covers 172.31.48.0 to 172.31.63.255)  - us-east-1e
# - 172.31.64.0/20  (covers 172.31.64.0 to 172.31.79.255)  - us-east-1f
# - 172.31.80.0/20  (covers 172.31.80.0 to 172.31.95.255)  - us-east-1b

# Available CIDR ranges for /24 subnets:
# - 172.31.96.0/24 to 172.31.255.0/24 (ranges 96-255 are available)
# We'll use 172.31.96.0/24 as it's the first available range

# Create the subnet
# NOTE: Using 172.31.96.0/24 as it doesn't conflict with existing /20 subnets
aws ec2 create-subnet \
    --vpc-id vpc-00e02ddd40abf341a \
    --cidr-block 172.31.96.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=nautilus-subnet}]'

{
    "Subnet": {
        "AvailabilityZoneId": "use1-az1",
        "MapCustomerOwnedIpOnLaunch": false,
        "OwnerId": "059254148810",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "Name",
                "Value": "nautilus-subnet"
            }
        ],
        "SubnetArn": "arn:aws:ec2:us-east-1:059254148810:subnet/subnet-007820f4c8b24e1c4",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-007820f4c8b24e1c4",
        "State": "available",
        "VpcId": "vpc-00e02ddd40abf341a",
        "CidrBlock": "172.31.96.0/24",
        "AvailableIpAddressCount": 251,
        "AvailabilityZone": "us-east-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}

# IP Range Analysis for our new subnet:
# Subnet CIDR: 172.31.96.0/24
#   - Start IP: 172.31.96.0
#   - End IP: 172.31.96.255
#   - Usable IPs: 172.31.96.4 to 172.31.96.254 (251 usable addresses)
#   - Network IP: 172.31.96.0 (reserved)
#   - Broadcast IP: 172.31.96.255 (reserved)
#   - AWS Reserved: 172.31.96.1 (VPC router), 172.31.96.2 (DNS), 172.31.96.3 (future use)

# Verify the subnet creation
aws ec2 describe-subnets --filters "Name=tag:Name,Values=nautilus-subnet"
```

## Troubleshooting CIDR Conflicts

**Error**: `InvalidSubnet.Conflict: The CIDR 'X.X.X.X/X' conflicts with another subnet`

**Solution**:

1. Run the subnet query commands above to see existing CIDR blocks
2. Choose an available CIDR range within 172.31.0.0/16
3. Update the `--cidr-block` parameter in the create-subnet command

**Common Available Ranges** (check first):

- 172.31.96.0/24 to 172.31.255.0/24 (any number from 96-255 should work)
- Avoid ranges 0-95 as they're covered by existing /20 subnets

**Memory Aids for CIDR Calculations**:

- Each octet: **0-255** (256 possible values: 2^8)
- `/24` subnet: Only last octet varies (256 total IPs, ~251 usable)
- **AWS "Rule of 5"**: AWS reserves 5 IPs (.0, .1, .2, .3, .255)
- **Quick check**: `32-24=8` bits for hosts → `2^8 = 256` addresses

```

```
