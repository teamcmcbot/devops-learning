# Task 016 - Create IAM Policy using Terraform

When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements.

Create an IAM policy named `iampolicy_ravi` in `us-east-1` region using Terraform. It must allow `read-only access` to the `EC2 console`, i.e., this policy must `allow users to view all instances, AMIs, and snapshots in the Amazon EC2 console`.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.iampolicy_ravi will be created
  + resource "aws_iam_policy" "iampolicy_ravi" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + name             = "iampolicy_ravi"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:Describe*",
                          + "ec2:Get*",
                          + "ec2:List*",
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

Changes to Outputs:
  + iampolicy_ravi_details = {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + tags_all         = (known after apply)
    }
aws_iam_policy.iampolicy_ravi: Creating...
aws_iam_policy.iampolicy_ravi: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/iampolicy_ravi]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

iampolicy_ravi_details = {
  "arn" = "arn:aws:iam::000000000000:policy/iampolicy_ravi"
  "attachment_count" = 0
  "id" = "arn:aws:iam::000000000000:policy/iampolicy_ravi"
  "tags_all" = tomap({})
}

bob@iac-server ~/terraform via 💠 default ✖ aws iam get-policy --policy-arn "arn:aws:iam::000000000000:policy/iampolicy_ravi"
{
    "Policy": {
        "PolicyName": "iampolicy_ravi",
        "PolicyId": "ADY1Y9GWF49UAJ6XUJUUR",
        "Arn": "arn:aws:iam::000000000000:policy/iampolicy_ravi",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-12-05T15:36:34.145377Z",
        "UpdateDate": "2025-12-05T15:36:34.145378Z",
        "Tags": []
    }
}
```
