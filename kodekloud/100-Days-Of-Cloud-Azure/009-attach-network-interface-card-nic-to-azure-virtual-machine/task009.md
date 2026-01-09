# Task 009: Attach Network Interface Card (NIC) to Azure Virtual Machine

The Nautilus DevOps team is migrating services to Azure. They are breaking down tasks to ensure better control and optimization. You are tasked with attaching an existing network interface (NIC) to a virtual machine (VM).

An existing VM named `devops-vm` and a network interface named `devops-nic` already exist in the West US region.

- Attach the network interface `devops-nic` to the VM `devops-vm`.
- Ensure the NIC's status is attached before submitting the task.
  Make sure that the virtual mac

## Solution

1. In Azure Portal, navigate to "Virtual Machines" and select `devops-vm`.
2. Stop the VM if it is running.
3. Go to the "Networking" section of the VM. Ensure the VM is in the "Stopped (deallocated)" state before attaching the NIC.
4. Click on "Attach network interface", select `devops-nic`, and click "OK".
5. Go to overview and start the VM.

### Verification

1. Navigate to the "Networking" section of the VM and verify that `devops-nic` is listed as an attached network interface.
2. Go to Network foundations > Network interfaces and check that the `devops-nic` is attached to `devops-vm`.
