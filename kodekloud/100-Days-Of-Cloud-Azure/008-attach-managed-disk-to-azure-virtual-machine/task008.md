# Task 008 - Attach Managed Disk to Azure Virtual Machine

The Nautilus DevOps team is migrating services to Azure. They are breaking down tasks to ensure better control and optimization. You are tasked with attaching an existing data disk to a virtual machine (VM).

An existing VM named `devops-vm` and a managed disk named `devops-disk` already exist in the East US region.

Attach the disk `devops-disk` to the VM `devops-vm` as a data disk.
Ensure the disk is attached to the VM `devops-vm`.
Make sure that the virtual machine initialization has been completed before submitting this task.

// ...existing code...

## Solution

### Azure Portal Steps

1. Navigate to the Virtual Machine:

   - Go to Azure Portal and search for `devops-vm`
   - Click on the VM

2. Attach the Data Disk:

   - In the left menu, under **Settings**, click **Disks**
   - Under **Data disks** section, click **Attach existing disks**
   - In the **Disk name** dropdown, select `devops-disk`
   - LUN will be auto-assigned (0)
   - Click **Save** at the top

3. Verify the attachment:
   - The disk should now appear in the data disks list with status "Attached"

### Azure CLI Commands

# Find VM across all resource groups

```bash
~ ➜  az vm list --query "[?name=='devops-vm'].{Name:name, ResourceGroup:resourceGroup}" -o table
Name       ResourceGroup
---------  ----------------------------
devops-vm  KML_RG_MAIN-51EE7BA16CFA4AA8
```

# Find disk across all resource groups

```bash
~ ➜  az disk list --query "[?name=='devops-disk'].{Name:name, ResourceGroup:resourceGroup}" -o table
Name         ResourceGroup
-----------  ----------------------------
devops-disk  KML_RG_MAIN-51EE7BA16CFA4AA8
```

# Attach the disk to the VM

```bash
az vm disk attach \
  --resource-group KML_RG_MAIN-51EE7BA16CFA4AA8 \
  --vm-name devops-vm \
  --name devops-disk
```

# Verify the disk is attached

```bash
az vm show \
  --resource-group KML_RG_MAIN-51EE7BA16CFA4AA8 \
  --name devops-vm \
  --query "storageProfile.dataDisks" -o table
```
