# Task 006 - Create a Subnet in Azure Virtual Network

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the Azure cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition.

For this task, create a Virtual Network (VNet) named `devops-vnet` and one subnet named `devops-subnet` within the VNet in the `East US` region. Make sure the IPv4 address range is `10.0.0.0/16`.

## Solution Steps:

1. Log in to the Azure Portal.
2. Navigate to "Create a resource" and select "Virtual Network".
3. Fill in the required details:
   - Name: `devops-vnet`
   - Region: `East US`
   - Address space: `10.0.0.0/16`
4. Add a subnet:
   - Subnet name: `devops-subnet`
   - Subnet address range: `10.0.0.0/24`
5. Review and create the Virtual Network.
6. Once created, verify the VNet and subnet in the Azure Portal under "Virtual Networks".

---

## Cliff Notes: Understanding the Configuration

### Address Space Breakdown

| Component                      | CIDR                      | IP Range                | Total Addresses  |
| ------------------------------ | ------------------------- | ----------------------- | ---------------- |
| VNet (devops-vnet)             | `10.0.0.0/16`             | 10.0.0.0 - 10.0.255.255 | 65,536           |
| Subnet (devops-subnet)         | `10.0.0.0/24`             | 10.0.0.0 - 10.0.0.255   | 256 (251 usable) |
| Remaining (for future subnets) | `10.0.1.0 - 10.0.255.255` | —                       | 65,280           |

### Azure Reserved IPs (per subnet)

Azure reserves **5 IPs** in each subnet:

- `10.0.0.0` - Network address
- `10.0.0.1` - Default gateway
- `10.0.0.2-3` - Azure DNS mapping
- `10.0.0.255` - Broadcast address

**Usable IPs for VMs:** `10.0.0.4` - `10.0.0.254` (251 addresses)

### Key Concepts

- **VNet** = The overall network container (like a building)
- **Subnet** = A segmented portion of the VNet (like a floor in the building)
- When creating a **Virtual Machine (VM)**, you select the VNet and subnet, and Azure assigns a private IP from that subnet's range

### AWS vs Azure Naming

| AWS            | Azure                        |
| -------------- | ---------------------------- |
| VPC            | Virtual Network (VNet)       |
| EC2 Instance   | Virtual Machine (VM)         |
| Security Group | Network Security Group (NSG) |
