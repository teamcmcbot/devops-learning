# Task 003: Create a VM using Azure CLI

The Nautilus DevOps team is in the process of migrating some of their workloads to Azure. One of the tasks involves creating a new Virtual Machine (VM) using the Azure CLI. The team does not have access to the Azure portal but can manage Azure resources via the azure-client host (the landing host for this lab).

1. Create a new Azure Virtual Machine named `datacenter-vm` using the Azure CLI.

2. Use the `Ubuntu2204` image and set the VM size to `Standard_B2s`.

3. Make sure the admin username is set to `azureuser` and SSH keys are generated for secure access.

4. Use `Standard_LRS` storage account, disk size must be `30GB` and ensure the VM `datacenter-vm` is in the running state after creation.

---

## Solution Steps

### Step 1: Check available resource groups (optional)

```bash
az group list --output table

~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-0de4a8b2d8ad4b67  westus      Succeeded
```

### Step 2: Create the Virtual Machine

```bash
az vm create \
  --name datacenter-vm \
  --resource-group <your-resource-group> \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --storage-sku Standard_LRS \
  --os-disk-size-gb 30
```

> **Note:** Replace `<your-resource-group>` with your actual resource group name.

```bash
~/.ssh ➜  az vm create \
  --name datacenter-vm \
  --resource-group kml_rg_main-0de4a8b2d8ad4b67 \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --storage-sku Standard_LRS \
  --os-disk-size-gb 30
SSH key files '/root/.ssh/id_rsa' and '/root/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
{
  "fqdns": "",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-0de4a8b2d8ad4b67/providers/Microsoft.Compute/virtualMachines/datacenter-vm",
  "location": "westus",
  "macAddress": "60-45-BD-05-87-DB",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "20.184.141.57",
  "resourceGroup": "kml_rg_main-0de4a8b2d8ad4b67",
  "zones": ""
}

~/.ssh ➜  ls -la
total 24
drwx------ 2 root root 4096 Dec 26 03:13 .
drwx------ 1 root root 4096 Dec 26 03:02 ..
-rw------- 1 root root  562 Dec 26 03:01 authorized_keys
-rw------- 1 root root 1675 Dec 26 03:13 id_rsa
-rw-r--r-- 1 root root  380 Dec 26 03:13 id_rsa.pub
```

### Step 3: Verify the VM is running

```bash
~/.ssh ✖ az vm show \
  --name datacenter-vm \
  --resource-group kml_rg_main-0de4a8b2d8ad4b67 \
  --show-details \
  --query "{
    Name:name,
    Status:powerState,
    Size:hardwareProfile.vmSize,
    Image:storageProfile.imageReference.offer,
    AdminUser:osProfile.adminUsername,
    OSDiskSizeGB:storageProfile.osDisk.diskSizeGb,
    StorageSKU:storageProfile.osDisk.managedDisk.storageAccountType,
    PublicIP:publicIps,
    PrivateIP:privateIps
  }" \
  --output table
Name           Status      Size          Image                         AdminUser    OSDiskSizeGB    StorageSKU    PublicIP       PrivateIP
-------------  ----------  ------------  ----------------------------  -----------  --------------  ------------  -------------  -----------
datacenter-vm  VM running  Standard_B2s  0001-com-ubuntu-server-jammy  azureuser    30              Standard_LRS  20.184.141.57  10.0.0.4

```

### Step 4: SSH into the VM (optional)

```bash
~/.ssh ➜  ssh azureuser@20.184.141.57
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1044-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri Dec 26 03:25:31 UTC 2025

  System load:  0.03              Processes:             115
  Usage of /:   5.7% of 28.89GB   Users logged in:       0
  Memory usage: 8%                IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '24.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```

---

## Command Explanation

| Parameter             | Description                                             |
| --------------------- | ------------------------------------------------------- |
| `--name`              | Name of the VM (`datacenter-vm`)                        |
| `--resource-group`    | The resource group where the VM will be created         |
| `--image`             | OS image to use (`Ubuntu2204`)                          |
| `--size`              | VM size (`Standard_B2s`)                                |
| `--admin-username`    | Admin user for the VM (`azureuser`)                     |
| `--generate-ssh-keys` | Automatically generates SSH key pair for authentication |
| `--storage-sku`       | Storage account type (`Standard_LRS`)                   |
| `--os-disk-size-gb`   | OS disk size in GB (`30`)                               |
