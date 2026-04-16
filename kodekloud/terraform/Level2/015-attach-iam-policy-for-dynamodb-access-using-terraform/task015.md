# Task 015: Attach IAM Policy for DynamoDB Access Using Terraform

The DevOps team has been tasked with creating a secure DynamoDB table and enforcing fine-grained access control using IAM. This setup will allow secure and restricted access to the table from trusted AWS services only.

As a member of the Nautilus DevOps Team, your task is to perform the following using Terraform:

1. Create a DynamoDB Table: Create a table named `nautilus-table` with minimal configuration.

2. Create an IAM Role: Create an IAM role named `nautilus-role` that will be allowed to access the table.

3. Create an IAM Policy: Create a policy named `nautilus-readonly-policy ` that should grant read-only access (GetItem, Scan, Query) to the specific DynamoDB table and attach it to the role.

4. Create the `main.tf` file (do not create a separate .tf file) to provision the table, role, and policy.

5. Create the `variables.tf` file with the following variables:

- `KKE_TABLE_NAME`: name of the DynamoDB table
- `KKE_ROLE_NAME`: name of the IAM role
- `KKE_POLICY_NAME`: name of the IAM policy

6. Create the `outputs.tf` file with the following outputs:

- `kke_dynamodb_table`: name of the DynamoDB table
- `kke_iam_role_name`: name of the IAM role
- `kke_iam_policy_name`: name of the IAM policy

7. Define the actual values for these variables in the terraform.tfvars file.

8. Ensure that the `IAM policy` allows only read access and restricts it to the specific `DynamoDB table` created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.nautilus_table will be created
  + resource "aws_dynamodb_table" "nautilus_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "nautilus-table"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags_all         = (known after apply)
      + write_capacity   = (known after apply)

      + attribute {
          + name = "id"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_iam_policy.nautilus_readonly_policy will be created
  + resource "aws_iam_policy" "nautilus_readonly_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + name             = "nautilus-readonly-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
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
                          + Service = "dynamodb.amazonaws.com"
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

  # aws_iam_role_policy_attachment.nautilus_readonly_policy_attach will be created
  + resource "aws_iam_role_policy_attachment" "nautilus_readonly_policy_attach" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "nautilus-role"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_dynamodb_table  = "nautilus-table"
  + kke_iam_policy_name = "nautilus-readonly-policy"
  + kke_iam_role_name   = "nautilus-role"
aws_iam_role.nautilus_role: Creating...
aws_dynamodb_table.nautilus_table: Creating...
aws_iam_role.nautilus_role: Creation complete after 0s [id=nautilus-role]
aws_dynamodb_table.nautilus_table: Creation complete after 0s [id=nautilus-table]
aws_iam_policy.nautilus_readonly_policy: Creating...
aws_iam_policy.nautilus_readonly_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/nautilus-readonly-policy]
aws_iam_role_policy_attachment.nautilus_readonly_policy_attach: Creating...
aws_iam_role_policy_attachment.nautilus_readonly_policy_attach: Creation complete after 0s [id=nautilus-role-20260416160747900800000001]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_dynamodb_table = "nautilus-table"
kke_iam_policy_name = "nautilus-readonly-policy"
kke_iam_role_name = "nautilus-role"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_dynamodb_table.nautilus_table:
resource "aws_dynamodb_table" "nautilus_table" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/nautilus-table"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    hash_key                    = "id"
    id                          = "nautilus-table"
    name                        = "nautilus-table"
    read_capacity               = 0
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags_all                    = {}
    write_capacity              = 0

    attribute {
        name = "id"
        type = "S"
    }

    point_in_time_recovery {
        enabled = false
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}

# aws_iam_policy.nautilus_readonly_policy:
resource "aws_iam_policy" "nautilus_readonly_policy" {
    arn              = "arn:aws:iam::000000000000:policy/nautilus-readonly-policy"
    attachment_count = 0
    description      = null
    id               = "arn:aws:iam::000000000000:policy/nautilus-readonly-policy"
    name             = "nautilus-readonly-policy"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "dynamodb:GetItem",
                        "dynamodb:Scan",
                        "dynamodb:Query",
                    ]
                    Effect   = "Allow"
                    Resource = "arn:aws:dynamodb:us-east-1:000000000000:table/nautilus-table"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "A3JE6USHPIKA7I26AYBNK"
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
                        Service = "dynamodb.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-16T16:07:47Z"
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
    unique_id             = "AROAQAAAAAAAA6A5ZFQFP"
}

# aws_iam_role_policy_attachment.nautilus_readonly_policy_attach:
resource "aws_iam_role_policy_attachment" "nautilus_readonly_policy_attach" {
    id         = "nautilus-role-20260416160747900800000001"
    policy_arn = "arn:aws:iam::000000000000:policy/nautilus-readonly-policy"
    role       = "nautilus-role"
}


Outputs:

kke_dynamodb_table = "nautilus-table"
kke_iam_policy_name = "nautilus-readonly-policy"
kke_iam_role_name = "nautilus-role"
```