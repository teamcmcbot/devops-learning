# Task 015 - Create IAM Group using Terraform

The ammar DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

Create an IAM group named `iamgroup_ammar` using terraform.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.iamgroup_ammar will be created
  + resource "aws_iam_group" "iamgroup_ammar" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "iamgroup_ammar"
      + path      = "/"
      + unique_id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + iamgroup_arn  = (known after apply)
  + iamgroup_id   = (known after apply)
  + iamgroup_name = "iamgroup_ammar"
aws_iam_group.iamgroup_ammar: Creating...
aws_iam_group.iamgroup_ammar: Creation complete after 0s [id=iamgroup_ammar]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

iamgroup_arn = "arn:aws:iam::000000000000:group/iamgroup_ammar"
iamgroup_id = "iamgroup_ammar"
iamgroup_name = "iamgroup_ammar"
```
