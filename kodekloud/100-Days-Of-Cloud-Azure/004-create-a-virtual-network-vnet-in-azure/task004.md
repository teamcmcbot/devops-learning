# Task 004 - Create a Virtual Network (VNet) in Azure

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the Azure cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations.

Create a Virtual Network (VNet) named `nautilus-vnet` in the `East US` region with any `IPv4` CIDR block.

## Solution

### AWS to Azure Comparison

| AWS Concept | Azure Equivalent       |
| ----------- | ---------------------- |
| VPC         | VNet (Virtual Network) |
| Region      | Region (same concept)  |
| CIDR Block  | Address Space          |

### Option 1: Azure Portal (GUI)

1. **Navigate to Virtual Networks**

   - Go to Azure Portal → Search "Virtual networks" → Click **+ Create**

2. **Basics Tab**

   - **Subscription**: Select your subscription
   - **Resource group**: Select existing resource group
   - **Name**: `nautilus-vnet`
   - **Region**: `East US`

3. **IP Addresses Tab**

   - **IPv4 address space**: Enter a CIDR block (e.g., `10.0.0.0/16`)
   - You can add a default subnet or skip for now

4. **Review + Create** → **Create**

### Option 2: Azure CLI

```bash
# First, check your resource group
az group list --output table

# Create the VNet
az network vnet create \
  --name nautilus-vnet \
  --resource-group <your-resource-group> \
  --location eastus \
  --address-prefix 10.0.0.0/16
```

Replace `<your-resource-group>` with your actual resource group name.

### Verify Creation

```bash
# List VNets to confirm
az network vnet list --output table

# Or get details of the specific VNet
az network vnet show \
  --name nautilus-vnet \
  --resource-group <your-resource-group>
```

```bash
~ ➜  az network vnet list --output table
Name           ResourceGroup                 Location    NumSubnets    Prefixes     DnsServers    DDOSProtection    VMProtection
-------------  ----------------------------  ----------  ------------  -----------  ------------  ----------------  --------------
nautilus-vnet  kml_rg_main-7948a7ca5f1a472c  eastus      1             10.0.0.0/16                False


~ ➜  az network vnet show \
  --name nautilus-vnet \
  --resource-group kml_rg_main-7948a7ca5f1a472c
{
  "addressSpace": {
    "addressPrefixes": [
      "10.0.0.0/16"
    ]
  },
  "enableDdosProtection": false,
  "encryption": {
    "enabled": false,
    "enforcement": "AllowUnencrypted"
  },
  "etag": "W/\"d2a3e43d-f3d1-4aa4-adc8-1d45b2d82aac\"",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-7948a7ca5f1a472c/providers/Microsoft.Network/virtualNetworks/nautilus-vnet",
  "location": "eastus",
  "name": "nautilus-vnet",
  "privateEndpointVNetPolicies": "Disabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-7948a7ca5f1a472c",
  "resourceGuid": "de7ee14d-e167-4017-bf16-69ff868f82c5",
  "subnets": [
    {
      "addressPrefixes": [
        "10.0.0.0/24"
      ],
      "delegations": [],
      "etag": "W/\"d2a3e43d-f3d1-4aa4-adc8-1d45b2d82aac\"",
      "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-7948a7ca5f1a472c/providers/Microsoft.Network/virtualNetworks/nautilus-vnet/subnets/default",
      "name": "default",
      "privateEndpointNetworkPolicies": "Disabled",
      "privateLinkServiceNetworkPolicies": "Enabled",
      "provisioningState": "Succeeded",
      "resourceGroup": "kml_rg_main-7948a7ca5f1a472c",
      "type": "Microsoft.Network/virtualNetworks/subnets"
    }
  ],
  "tags": {},
  "type": "Microsoft.Network/virtualNetworks",
  "virtualNetworkPeerings": []
}
```

### Key Differences from AWS VPC

| Feature           | AWS VPC                   | Azure VNet                  |
| ----------------- | ------------------------- | --------------------------- |
| Subnets           | Must specify AZ           | No AZ required (regional)   |
| Internet Gateway  | Separate resource         | Built-in (no IGW needed)    |
| NAT Gateway       | Separate resource         | Separate resource (similar) |
| Default resources | Route tables auto-created | Route tables auto-created   |

### Common CIDR Blocks to Use

Any of these will work for the task:

- `10.0.0.0/16` (65,536 addresses)
- `172.16.0.0/16`
- `192.168.0.0/16`
