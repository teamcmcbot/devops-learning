# Task 027: Configuring a Public VPC with an EC2 Instance for Internet Access

The Nautilus DevOps Team has received a request from the Networking Team to set up a new public VPC to support a set of public-facing services. This VPC will host various resources that need to be accessible over the internet. As part of this setup, you need to ensure the VPC has public subnets with automatic IP assignment for resources. Additionally, a new EC2 instance will be launched within this VPC to host public applications that require SSH access. This setup will enable the Networking Team to deploy and manage public-facing applications.

Create a public VPC named `nautilus-pub-vpc`, and a subnet named `nautilus-pub-subnet` under the same, make sure public IP is being auto assigned to resources under this subnet. Further, create an EC2 instance named `nautilus-pub-ec2` under this VPC with instance type `t2.micro`. Make sure SSH port 22 is open for this instance and accessible over the internet.

## Important Notes

**Key AWS Components Required for Internet Access:**

While the requirements specify creating a VPC, subnet, and EC2 instance, successful internet connectivity requires several additional components that are not explicitly mentioned but are essential:

1. **Internet Gateway (IGW)**

   - Must be created and attached to the VPC
   - Without IGW, resources in the VPC cannot communicate with the internet
   - This is the entry/exit point for internet traffic to/from the VPC

2. **Route Table Configuration**

   - A route table must have a route directing internet-bound traffic (0.0.0.0/0) to the Internet Gateway
   - The subnet must be associated with this route table to become "public"
   - Without proper routing, instances cannot reach the internet even with public IPs

3. **Public IP Assignment (Auto-assign Public IPv4)**

   **What it means:**

   - When enabled at the subnet level, AWS automatically assigns a public IPv4 address to every EC2 instance launched in that subnet
   - This public IP is assigned from AWS's pool of public IP addresses
   - The public IP is free and dynamic (changes when instance stops/starts)

   **What it does:**

   - **Private IP**: Every instance gets a private IP (e.g., 10.0.1.50) for internal VPC communication
   - **Public IP**: With auto-assign enabled, instances also get a public IP (e.g., 44.211.33.213) for internet communication
   - **Internet Accessibility**: The public IP allows the instance to be reached from the internet and to reach the internet
   - **NAT Mapping**: AWS automatically handles the mapping between public and private IPs

   **Configuration levels:**

   - **Subnet level** (recommended): Enable "Auto-assign public IPv4 address" in subnet settings - applies to all instances in that subnet
   - **Instance level**: Override subnet setting when launching individual instances

   **Without auto-assign public IP:**

   - Instances only get private IPs
   - Cannot be accessed directly from the internet
   - Cannot initiate connections to the internet (unless using NAT Gateway)
   - Suitable for private/internal resources only

   **Note:** For production, consider using Elastic IPs (static public IPs) instead of auto-assigned public IPs if you need a consistent IP address

4. **Security Group Rules**

   - **Inbound**: SSH (port 22) from 0.0.0.0/0 for external access
   - **Outbound**: All traffic (0.0.0.0/0) to allow the instance to reach the internet (usually default)
   - Missing outbound rules will prevent the instance from initiating internet connections

5. **Default Username by AMI Type**
   - Amazon Linux 2: `ec2-user`
   - Ubuntu: `ubuntu`
   - Red Hat/CentOS: `ec2-user` or `centos`

**Common Pitfalls:**

- Creating a VPC and subnet alone doesn't provide internet access
- Forgetting to attach the IGW to the VPC
- Not adding the 0.0.0.0/0 route to the IGW in the route table
- Not associating the route table with the subnet
- Using the wrong SSH username for the AMI type

## Solution

1. Create a VPC in AWS Management Console.

- Navigate to the VPC Dashboard.
- Click on "Create VPC".
- Select "VPC only" option.
- Name the VPC `nautilus-pub-vpc`.
- Set the IPv4 CIDR block to `10.0.0.0/16`.
- Leave other settings as default and create the VPC.

## VPC IP Range Breakdown

**VPC CIDR: `10.0.0.0/16`**

- **Total IP addresses**: 65,536 IPs
- **Usable IP range**: `10.0.0.1` to `10.0.255.254`
- **Network address**: `10.0.0.0`
- **Broadcast address**: `10.0.255.255`
- **Subnet mask**: `255.255.0.0`

This VPC can be divided into 256 subnets of `/24` size (each with 256 IP addresses), allowing for significant scalability and network segmentation. The current subnet `nautilus-pub-subnet` uses only a small portion (`10.0.1.0/24`) of the available address space.

2. Create a public subnet in the VPC.

- In the VPC Dashboard, go to "Subnets" and click "Create subnet".
- Select the VPC `nautilus-pub-vpc`.
- Name the subnet `nautilus-pub-subnet`.
- Set the IPv4 CIDR block to `10.0.1.0/24`.
- Ensure "Auto-assign IPv4" is enabled.
- Create the subnet.

## CIDR Block Breakdown

**Network Information:**

- Network address: `10.0.1.0`
- Usable IP range: `10.0.1.1` to `10.0.1.254` (254 usable IPs)
- Broadcast address: `10.0.1.255`
- Subnet mask: `255.255.255.0`
- Total IPs: 256 (including network and broadcast addresses)

**AWS Reserved IP Addresses:**
AWS reserves the following 5 IP addresses in each subnet:

- `10.0.1.0` - Network address
- `10.0.1.1` - VPC router
- `10.0.1.2` - DNS server
- `10.0.1.3` - Reserved for future use
- `10.0.1.255` - Broadcast address

3. Navigate to EC2 > Instances and launch a new instance.

- Click on "Launch Instance".
- Choose "Amazon Linux 2 AMI".
- Select instance type `t2.micro`.
- Configure instance details:
  - Select the VPC `nautilus-pub-vpc`.
  - Select the subnet `nautilus-pub-subnet`.
  - Ensure "Auto-assign Public IP" is enabled.
  - Security Group: Create a new security group named `nautilus-pub-sg` with the following rule:
    - Type: SSH, Protocol: TCP, Port Range: 22, Source: Anywhere (0.0.0.0/0)
- Review and launch the instance.
