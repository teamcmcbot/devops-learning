# Task 005 - Create a Virtual Network (IPv4) in Azure

The Nautilus DevOps team is strategically planning the migration of a portion of their infrastructure to the Azure cloud. Acknowledging the magnitude of this endeavor, they have chosen to tackle the migration incrementally rather than as a single, massive transition. Their approach involves creating Virtual Networks (VNets) as the initial step, as they will be provisioning various services under different VNets.

Create a Virtual Network (VNet) named `devops-vnet` in the `East US` region with `192.168.0.0/24` IPv4 CIDR.

## Solution Steps:

1. Log in to the Azure Portal using your credentials.
2. In the left-hand menu, click on "Create a resource."
3. In the "Search the Marketplace" box, type "Virtual Network" and select it
4. Click on the "Create" button to start the VNet creation process.
5. In the "Basics" tab, fill in the following details:
   - Subscription: Select your Azure subscription.
   - Resource group: Select an existing resource group.
   - Virtual network name: Enter `devops-vnet`.
   - Region: Select `East US`.
6. In the "IP Addresses" tab, under "IPv4 address space," enter `
   - Address space: `192.168.0.0/24`
7. Review the settings in the "Review + create" tab and click on "Create" to deploy the VNet.
8. Wait for the deployment to complete. Once done, navigate to the "Resource groups" section, select the resource group you used, and verify that the `devops-vnet` has been created successfully.
9. Click on the `devops-vnet` to view its details and confirm that the IPv4 CIDR is set to `192.168.0.0/24`.
