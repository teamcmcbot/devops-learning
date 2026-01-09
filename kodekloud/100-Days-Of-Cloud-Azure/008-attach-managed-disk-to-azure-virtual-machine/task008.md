# Task 008 - Attach Managed Disk to Azure Virtual Machine

The Nautilus DevOps team is migrating services to Azure. They are breaking down tasks to ensure better control and optimization. You are tasked with attaching an existing data disk to a virtual machine (VM).

An existing VM named `xfusion-vm` and a managed disk named `xfusion-disk` already exist in the East US region.

- Attach the disk `xfusion-disk` to the VM `xfusion-vm` as a data disk.
- Ensure the disk is attached to the VM `xfusion-vm`.

Make sure that the virtual machine initialization has been completed before submitting this task.

## Solution

# Find VM across all resource groups

az vm list --query "[?name=='xfusion-vm'].{Name:name, ResourceGroup:resourceGroup}" -o table

# Find disk across all resource groups

az disk list --query "[?name=='xfusion-disk'].{Name:name, ResourceGroup:resourceGroup}" -o table
