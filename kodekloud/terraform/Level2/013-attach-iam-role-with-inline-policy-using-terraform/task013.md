# Task 013: Attach IAM Role with Inline Policy Using Terraform

The Nautilus DevOps team is setting up IAM-based access control for internal AWS resources. They need to create an IAM Role and an IAM Policy using Terraform and attach the policy to the role.

1. Create an IAM Role named `nautilus-role`.

2. Create an IAM Policy named `nautilus-policy` that allows listing EC2 instances.

3. Attach the policy to the role

4. Create the `main.tf` file (do not create a separate .tf file) to provision a Role, policy and attach it.

5. Use the `variables.tf` file with the following:

- KKE_ROLE_NAME: name of the role.
- KKE_POLICY_NAME: name of the policy.

6. Use `terraform.tfvars` file to input the role and policy names.

7. Use `outputs.tf` file to output the following:

- kke_iam_role_name: name of the role created.
- kke_iam_policy_name: name of the policy ceated.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.nautilus_policy will be created
  + resource "aws_iam_policy" "nautilus_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy to allow listing EC2 instances"
      + id               = (known after apply)
      + name             = "nautilus-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = "ec2:DescribeInstances"
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

  # aws_iam_role.nautilus_role will be created
  + resource "aws_iam_role" "nautilus_role" {
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
      + name                  = "nautilus-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.nautilus_attachment will be created
  + resource "aws_iam_role_policy_attachment" "nautilus_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "nautilus-role"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_iam_policy_name = "nautilus-policy"
  + kke_iam_role_name   = "nautilus-role"
aws_iam_policy.nautilus_policy: Creating...
aws_iam_role.nautilus_role: Creating...
aws_iam_policy.nautilus_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/nautilus-policy]
aws_iam_role.nautilus_role: Creation complete after 0s [id=nautilus-role]
aws_iam_role_policy_attachment.nautilus_attachment: Creating...
aws_iam_role_policy_attachment.nautilus_attachment: Creation complete after 0s [id=nautilus-role-20260416143114982500000001]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_iam_policy_name = "nautilus-policy"
kke_iam_role_name = "nautilus-role"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform show
# aws_iam_policy.nautilus_policy:
resource "aws_iam_policy" "nautilus_policy" {
    arn              = "arn:aws:iam::000000000000:policy/nautilus-policy"
    attachment_count = 0
    description      = "Policy to allow listing EC2 instances"
    id               = "arn:aws:iam::000000000000:policy/nautilus-policy"
    name             = "nautilus-policy"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = "ec2:DescribeInstances"
                    Effect   = "Allow"
                    Resource = "*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "AMAGAFQNV34WKLO062CV0"
    tags_all         = {}
}

# aws_iam_role.nautilus_role:
resource "aws_iam_role" "nautilus_role" {
    arn                   = "arn:aws:iam::000000000000:role/nautilus-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-16T14:31:14Z"
    description           = null
    force_detach_policies = false
    id                    = "nautilus-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "nautilus-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAGBWEDRUST"
}

# aws_iam_role_policy_attachment.nautilus_attachment:
resource "aws_iam_role_policy_attachment" "nautilus_attachment" {
    id         = "nautilus-role-20260416143114982500000001"
    policy_arn = "arn:aws:iam::000000000000:policy/nautilus-policy"
    role       = "nautilus-role"
}


Outputs:

kke_iam_policy_name = "nautilus-policy"
kke_iam_role_name = "nautilus-role"
```