# Task 037: Elastic IP Variable Setup Using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. As part of this phased migration approach, they need to allocate an Elastic IP address to support external access for specific workloads.

For this task, create an AWS Elastic IP using Terraform with the following requirement:

The Elastic IP name `xfusion-eip` should be stored in a variable named `KKE_eip`. The Terraform working directory is /home/bob/terraform.
Note:

The configuration values should be stored in a variables.tf file.

The Terraform script should be structured with a main.tf file referencing variables.tf.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.lb will be created
  + resource "aws_eip" "lb" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
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
          + "Name" = "xfusion-eip"
        }
      + tags_all             = {
          + "Name" = "xfusion-eip"
        }
      + vpc                  = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.lb will be created
  + resource "aws_eip" "lb" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
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
          + "Name" = "xfusion-eip"
        }
      + tags_all             = {
          + "Name" = "xfusion-eip"
        }
      + vpc                  = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_eip.lb: Creating...
aws_eip.lb: Creation complete after 2s [id=eipalloc-a0c2b219abe5465ed]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_eip.lb
# aws_eip.lb:
resource "aws_eip" "lb" {
    allocation_id            = "eipalloc-a0c2b219abe5465ed"
    arn                      = "arn:aws:ec2:us-east-1::elastic-ip/eipalloc-a0c2b219abe5465ed"
    association_id           = null
    carrier_ip               = null
    customer_owned_ip        = null
    customer_owned_ipv4_pool = null
    domain                   = "vpc"
    id                       = "eipalloc-a0c2b219abe5465ed"
    instance                 = null
    network_border_group     = null
    network_interface        = null
    private_ip               = null
    ptr_record               = null
    public_dns               = "ec2-127-88-17-31.compute-1.amazonaws.com"
    public_ip                = "127.88.17.31"
    public_ipv4_pool         = null
    tags                     = {
        "Name" = "xfusion-eip"
    }
    tags_all                 = {
        "Name" = "xfusion-eip"
    }
    vpc                      = true
}

bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_eip.lb
aws ec2 describe-addresses --filters "Name=tag:Name,Values=xfusion-eip"
# aws_eip.lb:
resource "aws_eip" "lb" {
    allocation_id            = "eipalloc-a0c2b219abe5465ed"
    arn                      = "arn:aws:ec2:us-east-1::elastic-ip/eipalloc-a0c2b219abe5465ed"
    association_id           = null
    carrier_ip               = null
    customer_owned_ip        = null
    customer_owned_ipv4_pool = null
    domain                   = "vpc"
    id                       = "eipalloc-a0c2b219abe5465ed"
    instance                 = null
    network_border_group     = null
    network_interface        = null
    private_ip               = null
    ptr_record               = null
    public_dns               = "ec2-127-88-17-31.compute-1.amazonaws.com"
    public_ip                = "127.88.17.31"
    public_ipv4_pool         = null
    tags                     = {
        "Name" = "xfusion-eip"
    }
    tags_all                 = {
        "Name" = "xfusion-eip"
    }
    vpc                      = true
}
{
    "Addresses": [
        {
            "AllocationId": "eipalloc-a0c2b219abe5465ed",
            "Domain": "vpc",
            "NetworkInterfaceId": "",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "xfusion-eip"
                }
            ],
            "InstanceId": "",
            "PublicIp": "127.88.17.31"
        }
    ]
}
```