# Task 007 - Create a Public IP Address for Azure VM

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the Azure cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, allocate a `Public IP address`, name it as `datacenter-pip`.

Use below given Azure Credentials: (You can run the showcreds command on the azure-client host to retrieve credentials)

## Solution Steps (Azure Portal)

1. **Sign in to Azure Portal**

   - Navigate to [https://portal.azure.com](https://portal.azure.com)
   - Enter your Azure credentials

2. **Navigate to Public IP Addresses**

   - In the search bar at the top, type `Public IP addresses`
   - Click on **Public IP addresses** under Services

3. **Create a New Public IP Address**

   - Click **+ Create** button

4. **Configure Basic Settings**

   - **Subscription**: Select your subscription
   - **Resource group**: Select an existing resource group or create a new one
   - **Region**: Select your preferred region
   - **Name**: Enter `datacenter-pip`
   - **IP Version**: IPv4
   - **SKU**: Basic or Standard (based on requirements)
   - **Tier**: Regional
   - **IP address assignment**:
     - For Basic SKU: Dynamic or Static
     - For Standard SKU: Static (default)

5. **Review and Create**

   - Click **Review + create**
   - Verify the configuration details
   - Click **Create** to deploy the Public IP address

6. **Verify Creation**
   - Once deployment is complete, click **Go to resource**
   - Confirm the Public IP address `datacenter-pip` has been created successfully

---

## Alternative: Azure CLI Command

```bash
az network public-ip create \
  --name datacenter-pip \
  --resource-group <your-resource-group> \
  --allocation-method Static \
  --sku Standard
```
