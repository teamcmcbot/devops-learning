# Task 006 - Create Elastic IP using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, allocate an Elastic IP address named datacenter-eip using Terraform.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.datacenter-eip will be created
  + resource "aws_eip" "datacenter-eip" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + ipam_pool_id         = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + ptr_record           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Name" = "datacenter-eip"
        }
      + tags_all             = {
          + "Name" = "datacenter-eip"
        }
      + vpc                  = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_eip.datacenter-eip: Creating...
aws_eip.datacenter-eip: Creation complete after 1s [id=eipalloc-64145e05d8d384f0a]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.


bob@iac-server ~/terraform via 💠 default ✖ aws ec2 describe-addresses
{
    "Addresses": [
        {
            "AllocationId": "eipalloc-64145e05d8d384f0a",
            "Domain": "vpc",
            "NetworkInterfaceId": "",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "datacenter-eip"
                }
            ],
            "InstanceId": "",
            "PublicIp": "127.142.96.120"
        }
    ]
}
```
