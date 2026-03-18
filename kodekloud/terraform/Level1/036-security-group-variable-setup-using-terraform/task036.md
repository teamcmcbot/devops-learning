# Task 036: Security Group Variable Setup Using Terraform

The Nautilus DevOps team is enhancing infrastructure automation and needs to provision a Security Group using Terraform with specific configurations.

For this task, create an AWS Security Group using Terraform with the following requirements:

The Security Group name `nautilus-sg` should be stored in a variable named `KKE_sg`.
Note:

1. The configuration values should be stored in a `variables.tf` file.

2. The Terraform script should be structured with a `main.tf` file referencing `variables.tf`.

3. The Terraform working directory is /home/bob/terraform.

4. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Solution

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_security_group.my_sg will be created
  + resource "aws_security_group" "my_sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "nautilus-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "nautilus-sg"
        }
      + tags_all               = {
          + "Name" = "nautilus-sg"
        }
      + vpc_id                 = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_security_group.my_sg: Creating...
aws_security_group.my_sg: Creation complete after 1s [id=sg-ac938beee77531c8a]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

## Verification 

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_security_group.my_sg
💠 default ➜  terraform state s
# aws_security_group.my_sg:
resource "aws_security_group" "my_sg" {
    arn                    = "arn:aws:ec2:us-east-1:000000000000:security-group/sg-ac938beee77531c8a"
    description            = "Managed by Terraform"
    egress                 = []
    id                     = "sg-ac938beee77531c8a"
    ingress                = []
    name                   = "nautilus-sg"
    name_prefix            = null
    owner_id               = "000000000000"
    revoke_rules_on_delete = false
    tags                   = {
        "Name" = "nautilus-sg"
    }
    tags_all               = {
        "Name" = "nautilus-sg"
    }
    vpc_id                 = "vpc-b01aba0e2bc31d7f5"
}

bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-security-groups --filters "Name=gro
up-name,Values=nautilus-sg"
{
    "SecurityGroups": [
        {
            "GroupId": "sg-ac938beee77531c8a",
            "IpPermissionsEgress": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "nautilus-sg"
                }
            ],
            "VpcId": "vpc-b01aba0e2bc31d7f5",
            "SecurityGroupArn": "arn:aws:ec2:us-east-1:000000000000:security-group/sg-ac938beee77531c8a",
            "OwnerId": "000000000000",
            "GroupName": "nautilus-sg",
            "Description": "Managed by Terraform",
            "IpPermissions": []
        }
    ]
}
```