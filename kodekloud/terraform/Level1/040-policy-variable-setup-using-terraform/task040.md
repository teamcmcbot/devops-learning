# Task 040: Policy Variable Setup Using Terraform

The Nautilus DevOps team is automating IAM policy creation using Terraform to enhance security and access management. As part of this task, they need to create an IAM policy with specific requirements.

For this task, create an AWS IAM policy using Terraform with the following requirements:

The IAM policy name `iampolicy_john` should be stored in a variable named `KKE_iampolicy`.
Note:

1. The configuration values should be stored in a `variables.tf` file.

2. The Terraform script should be structured with a `main.tf` file referencing `variables.tf`.

3. The Terraform working directory is /home/bob/terraform.

4. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.policy will be created
  + resource "aws_iam_policy" "policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "My test policy"
      + id               = (known after apply)
      + name             = "iampolicy_john"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:Describe*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.policy will be created
  + resource "aws_iam_policy" "policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "My test policy"
      + id               = (known after apply)
      + name             = "iampolicy_john"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:Describe*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_iam_policy.policy: Creating...
aws_iam_policy.policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/iampolicy_john]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_iam_policy.policy
# aws_iam_policy.policy:
resource "aws_iam_policy" "policy" {
    arn              = "arn:aws:iam::000000000000:policy/iampolicy_john"
    attachment_count = 0
    description      = "My test policy"
    id               = "arn:aws:iam::000000000000:policy/iampolicy_john"
    name             = "iampolicy_john"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "ec2:Describe*",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "AG6NP9ANBT1FHP9ZSULOU"
    tags_all         = {}
}

bob@iac-server ~/terraform via 💠 default ➜  aws iam get-policy --policy-arn arn:aws:iam::000000000000:policy/iampolicy_john
{
    "Policy": {
        "PolicyName": "iampolicy_john",
        "PolicyId": "AG6NP9ANBT1FHP9ZSULOU",
        "Arn": "arn:aws:iam::000000000000:policy/iampolicy_john",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "Description": "My test policy",
        "CreateDate": "2026-03-18T05:51:35.217536Z",
        "UpdateDate": "2026-03-18T05:51:35.217540Z",
        "Tags": []
    }
}
```