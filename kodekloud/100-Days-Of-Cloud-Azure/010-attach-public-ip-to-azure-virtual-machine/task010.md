# Task 010 - Attach Public IP to Azure Virtual Machine

The Nautilus DevOps team has already set up a virtual machine and allocated a public IP address. The final task is to attach this public IP to the VM's network interface card (NIC).

An existing VM named `nautilus-vm-pip` and a public IP address named `nautilus-pip` already exist.

Attach the public IP `nautilus-pip` to the network interface of the VM `nautilus-vm-pip`.
Make sure the VM is properly assigned the public IP.

## Solution

### Method 1: Using Azure Portal (Console)

1. **Navigate to the Virtual Machine**

   - Sign in to the [Azure Portal](https://portal.azure.com)
   - In the search bar at the top, type "Virtual machines" and select it
   - Click on the VM named `nautilus-vm-pip`

2. **Access Networking Settings**

   - In the left-hand menu under **Settings**, click on **Networking**
   - You'll see the network interface attached to the VM

3. **View Network Interface**

   - Click on the network interface name (e.g., `nautilus-vm-pipVMNic`)
   - This will open the Network Interface resource page

4. **Attach the Public IP**

   - In the left-hand menu under **Settings**, click on **IP configurations**
   - Click on the IP configuration ( named `ipconfignautilus-vm-pip`)
   - Under **Public IP address settings**:
     - Toggle **Associate public IP address** to **Enabled**
     - In the **Public IP address** dropdown, select `nautilus-pip`
   - Click **Save** at the top

5. **Verify the Assignment**
   - Go back to the Virtual Machine overview page
   - You should now see the public IP address displayed under **Public IP address**
   - Alternatively, go to **Networking** → **Network settings** and verify the public IP is listed

### Method 2: Using Azure CLI

```bash
# Get the NIC ID of the VM
nic_id=$(az vm show --resource-group <resource-group-name> --name nautilus-vm-pip --query 'networkProfile.networkInterfaces[0].id' -o tsv)

# Get the Public IP ID
pip_id=$(az network public-ip show --resource-group <resource-group-name> --name nautilus-pip --query 'id' -o tsv)

# Attach the Public IP to the NIC
az network nic ip-config update \
  --resource-group <resource-group-name> \
  --nic-name nautilus-vm-pipVMNic \
  --name ipconfig1 \
  --public-ip-address $pip_id
```

## Verification

After attaching the public IP, verify the configuration:

- The VM overview should display the public IP address
- You should be able to connect to the VM using the public IP (if appropriate security rules are configured)
