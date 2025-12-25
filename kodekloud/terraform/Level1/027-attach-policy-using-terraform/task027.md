# Task 027 - Attach Policy using Terraform

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An IAM user named `iamuser_jim` and a policy named `iampolicy_jim` already exists. Use Terraform to attach the IAM policy `iampolicy_jim` to the IAM user `iamuser_jim`. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to attach the specified IAM policy to the IAM user.

## Solution

1. Add the following code to the existing main.tf file located at /home/bob/terraform/terraform-manifests/main.tf to attach the IAM policy to the IAM user.

```hcl
# Attach IAM Policy to IAM User
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}
```

2. Run terraform plan and terraform apply to implement the changes.

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_iam_user.user: Refreshing state... [id=iamuser_jim]
aws_iam_policy.policy: Refreshing state... [id=arn:aws:iam::000000000000:policy/iampolicy_jim]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user_policy_attachment.user_policy_attachment will be created
  + resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::000000000000:policy/iampolicy_jim"
      + user       = "iamuser_jim"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_iam_user.user: Refreshing state... [id=iamuser_jim]
aws_iam_policy.policy: Refreshing state... [id=arn:aws:iam::000000000000:policy/iampolicy_jim]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user_policy_attachment.user_policy_attachment will be created
  + resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::000000000000:policy/iampolicy_jim"
      + user       = "iamuser_jim"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_iam_user_policy_attachment.user_policy_attachment: Creating...
aws_iam_user_policy_attachment.user_policy_attachment: Creation complete after 0s [id=iamuser_jim-20251225142533936800000001]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.


```

3. Verify the policy is attached to the user using AWS CLI.

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws iam list-attached-user-policies --user-name iamuser_jim
{
    "AttachedPolicies": [
        {
            "PolicyName": "iampolicy_jim",
            "PolicyArn": "arn:aws:iam::000000000000:policy/iampolicy_jim"
        }
    ]
}
```
