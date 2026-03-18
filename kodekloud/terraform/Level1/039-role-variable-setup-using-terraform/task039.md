# Task 039: Role Variable Setup Using Terraform

The Nautilus DevOps team is automating IAM role creation using Terraform to streamline permissions management. As part of this task, they need to create an IAM role with specific requirements.

For this task, create an AWS IAM role using Terraform with the following requirements:

The IAM role name `iamrole_mark` should be stored in a variable named `KKE_iamrole`.
Note:

1. The configuration values should be stored in a `variables.tf` file.

2. The Terraform script should be structured with a `main.tf` file referencing `variables.tf`.

3. The Terraform working directory is /home/bob/terraform.

4. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.test_role will be created
  + resource "aws_iam_role" "test_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "iamrole_mark"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Name" = "iamrole_mark"
        }
      + tags_all              = {
          + "Name" = "iamrole_mark"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.test_role will be created
  + resource "aws_iam_role" "test_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "iamrole_mark"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Name" = "iamrole_mark"
        }
      + tags_all              = {
          + "Name" = "iamrole_mark"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_iam_role.test_role: Creating...
aws_iam_role.test_role: Creation complete after 0s [id=iamrole_mark]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_iam_role.test_role
# aws_iam_role.test_role:
resource "aws_iam_role" "test_role" {
    arn                   = "arn:aws:iam::000000000000:role/iamrole_mark"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                    Sid       = ""
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-03-18T05:41:55Z"
    description           = null
    force_detach_policies = false
    id                    = "iamrole_mark"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "iamrole_mark"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags                  = {
        "Name" = "iamrole_mark"
    }
    tags_all              = {
        "Name" = "iamrole_mark"
    }
    unique_id             = "AROAQAAAAAAAMP2QPSRFH"
}

bob@iac-server ~/terraform via 💠 default ➜  aws iam get-role --role-name iamrole_mark
{
    "Role": {
        "Path": "/",
        "RoleName": "iamrole_mark",
        "RoleId": "AROAQAAAAAAAMP2QPSRFH",
        "Arn": "arn:aws:iam::000000000000:role/iamrole_mark",
        "CreateDate": "2026-03-18T05:41:55.128821Z",
        "AssumeRolePolicyDocument": {
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Sid": ""
                }
            ],
            "Version": "2012-10-17"
        },
        "MaxSessionDuration": 3600,
        "Tags": [
            {
                "Key": "Name",
                "Value": "iamrole_mark"
            }
        ],
        "RoleLastUsed": {}
    }
}

```