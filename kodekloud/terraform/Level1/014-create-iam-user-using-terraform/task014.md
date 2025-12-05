# Task 014 - Create IAM User using Terraform

When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements:

For this task, create an IAM user named `iamuser_javed` using terraform. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.iamuser_javed will be created
  + resource "aws_iam_user" "iamuser_javed" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "iamuser_javed"
      + path          = "/"
      + tags          = {
          + "Name" = "iamuser_javed"
        }
      + tags_all      = {
          + "Name" = "iamuser_javed"
        }
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + iamuser_javed_arn  = (known after apply)
  + iamuser_javed_id   = (known after apply)
  + iamuser_javed_name = "iamuser_javed"
aws_iam_user.iamuser_javed: Creating...
aws_iam_user.iamuser_javed: Creation complete after 1s [id=iamuser_javed]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

iamuser_javed_arn = "arn:aws:iam::000000000000:user/iamuser_javed"
iamuser_javed_id = "iamuser_javed"
iamuser_javed_name = "iamuser_javed"
```
