# Task 002 - Create an Azure Virtual Machine

The Nautilus DevOps team is planning to migrate a portion of their infrastructure to the Azure cloud incrementally. As part of this migration, you are tasked with creating an Azure Virtual Machine (VM).

The requirements are:

1. Use the existing resource group.

2. The VM name must be `datacenter-vm`, it should be in `West US` region.

3. Use the `Ubuntu 22.04 LTS` image for the VM.

4. The VM size must be `Standard_B1s`.

5. Attach a default Network Security Group (NSG) that allows inbound SSH (port 22).

6. Attach a `30 GB` storage disk of type `Standard HDD`.
7. The rest of the configurations should remain as default.

After completing these steps, make sure you can SSH into the virtual machine.

## Solution

1. Log in to the Azure portal.
2. Navigate to "Virtual Machines" and click on "Create" > "Azure virtual machine".

### Basics Tab

- Subscription: Select your subscription.
- Resource group: Select the existing resource group.
- Virtual machine name: `datacenter-vm`
- Region: `West US`
- Image: `Ubuntu 22.04 LTS`
- Size: `Standard_B1s`
- Authentication type: Select `SSH public key`.

### Disks Tab

- OS disk size: `30 GB`
- OS disk type: `Standard HDD`

### Networking Tab

- Ensure that a default Network Security Group (NSG) is created that allows inbound SSH (port 22).

3. Click on "Review + create" and then "Create" to deploy the VM.

```text
*Basics*
Subscription
Azure Free Labs
Resource group
kml_rg_main-09deeb35a3a24af5
Virtual machine name
datacenter-vm
Region
West US
Availability options
No infrastructure redundancy required
Zone options
Self-selected zone
Security type
Trusted launch virtual machines
Enable secure boot
Yes
Enable vTPM
Yes
Integrity monitoring
No
Image
Ubuntu Server 22.04 LTS - Gen2
VM architecture
x64
Size
Standard B1s (1 vcpu, 1 GiB memory)
Enable Hibernation
No
Authentication type
SSH public key
Username
azureuser
SSH Key format
RSA
Key pair name
datacenter-vm_key
Public inbound ports
SSH
Azure Spot
No

*Disks*
OS disk size
Image default
OS disk type
Standard HDD LRS
Use managed disks
Yes
Delete OS disk with VM
Enabled
Ephemeral OS disk
No

*Networking*
Virtual network
(new) datacenter-vm-vnet
Subnet
(new) default (10.0.0.0/24)
Public IP
(new) datacenter-vm-ip
Accelerated networking
Off
Place this virtual machine behind an existing load balancing solution?
No
Delete public IP and NIC when VM is deleted
Disabled

*Management*
Microsoft Defender for Cloud
None
System assigned managed identity
Off
Login with Microsoft Entra ID
Off
Auto-shutdown
Off
Enable periodic assessment
Off
Enable hotpatch
Off
Patch orchestration options
Azure-orchestrated patching (preview): patches will be installed by Azure
Reboot setting
Reboot if required

*Monitoring*
Alerts
Off
Boot diagnostics
On
Enable OS guest diagnostics
Off
Enable application health monitoring
Off

*Advanced*
Extensions
None
VM applications
None
Cloud init
No
User data
No
Disk controller type
SCSI
Proximity placement group
None
Capacity reservation group
None
```

4. Once VM is deployed, obtain its public IP address from the Azure portal.
