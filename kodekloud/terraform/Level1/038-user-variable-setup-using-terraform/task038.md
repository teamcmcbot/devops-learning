# Task 038: User Variable Setup Using Terraform

The Nautilus DevOps team is automating IAM user creation using Terraform for better identity management.

For this task, create an AWS IAM User using Terraform with the following requirements:

The IAM User name `iamuser_mark` should be stored in a variable named `KKE_user`.
Note:

1. The configuration values should be stored in a `variables.tf` file.

2. The Terraform script should be structured with a `main.tf` file referencing variables.tf.

3. The Terraform working directory is /home/bob/terraform.

4. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Solution 

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.user will be created
  + resource "aws_iam_user" "user" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "iamuser_mark"
      + path          = "/"
      + tags          = {
          + "Name" = "iamuser_mark"
        }
      + tags_all      = {
          + "Name" = "iamuser_mark"
        }
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.user will be created
  + resource "aws_iam_user" "user" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "iamuser_mark"
      + path          = "/"
      + tags          = {
          + "Name" = "iamuser_mark"
        }
      + tags_all      = {
          + "Name" = "iamuser_mark"
        }
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_iam_user.user: Creating...
aws_iam_user.user: Creation complete after 0s [id=iamuser_mark]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_iam_user.user
# aws_iam_user.user:
resource "aws_iam_user" "user" {
    arn                  = "arn:aws:iam::000000000000:user/iamuser_mark"
    force_destroy        = false
    id                   = "iamuser_mark"
    name                 = "iamuser_mark"
    path                 = "/"
    permissions_boundary = null
    tags                 = {
        "Name" = "iamuser_mark"
    }
    tags_all             = {
        "Name" = "iamuser_mark"
    }
    unique_id            = "fntlf4zrb7kp99p1lumu"
}

bob@iac-server ~/terraform via 💠 default ➜  aws iam get-user --user-name iamuser_mark
{
    "User": {
        "Path": "/",
        "UserName": "iamuser_mark",
        "UserId": "fntlf4zrb7kp99p1lumu",
        "Arn": "arn:aws:iam::000000000000:user/iamuser_mark",
        "CreateDate": "2026-03-18T05:28:31.374268Z",
        "Tags": [
            {
                "Key": "Name",
                "Value": "iamuser_mark"
            }
        ]
    }
}
```