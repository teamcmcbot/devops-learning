# Task 001 - Create SSH Key Pair for Azure Virtual Machine

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the Azure cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create an SSH key pair with the following requirements:

The name of the SSH key pair should be `xfusion-kp`.

The key pair type must be `rsa`.

## Instructions

1. Navigate to Home > SSH Keys in the Azure portal.
2. Click on the "+ Add" button to create a new SSH key pair.
3. In the "Create SSH key" pane, provide the following details:
   - Name: `xfusion-kp`
   - Key type: `RSA`
4. Click on the "Review + create" button.

## Basics (Lab Values)

| Field          | Value                        |
| -------------- | ---------------------------- |
| Subscription   | Azure Free Labs              |
| Resource group | kml_rg_main-664fcf56dbd34040 |
| Region         | West US                      |
| Key pair name  | xfusion-kp                   |
| SSH Key format | RSA                          |

5. Finally, click on the "Create" button to generate the SSH key pair.
6. Download the private key and store it securely.
7. Verify that the SSH key pair has been created successfully by checking the list of SSH keys in the Azure portal.

```bash
~ ➜  az sshkey list
[
  {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/KML_RG_MAIN-664FCF56DBD34040/providers/Microsoft.Compute/sshPublicKeys/xfusion-kp",
    "location": "westus",
    "name": "xfusion-kp",
    "publicKey": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0aFynLDCrQSBgm/7+Cq8PSeNPNPz3zpmqLyJcqFIr5/hJPoqic646050mejPS0/mOtj0NpRSI8cEA8wxPPCrAa+yZ+0PDXpgPof5xZSJb5ACDtBWbq196f2KiYOoeyaCbZCyivAhV+MQN6h+LJbp27/VTq9WVJYzXuUZO6x+tK1T3OFqzf7aWd71KCQoJk8DYNoQbSpPgdN+IwOJhSqGZkD1PRvjeGGp/tb+P7wIu7Uvhnx3ZszUh+fwnATGw1BykD8QC9IIuWytm4STKDeOZdWehXrsR2gorJdLq2dBzn1vWO60p00YsnMamK0l7Z5SyiwwrZF9ub0KsxADCQFrhMr49weZPmp/4iubyNPUNaR62zL0ynYSrR8CsWqQIM+w3EwxppBtKxE1DvsRcn0A15YyyRwhDghtGQUS31nIUcwsCecXzSr1dde6GBke8lFQeoyRmBBgWmmmzj7+A3ArH/0QtQ6NHR5cqjsa89NwKDyxdXj1NUZcYjUqf8s7VFVE= generated-by-azure",
    "resourceGroup": "KML_RG_MAIN-664FCF56DBD34040",
    "tags": {},
    "type": null
  }
]

```
