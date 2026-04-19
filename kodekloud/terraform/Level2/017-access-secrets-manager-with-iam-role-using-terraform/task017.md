# Task 017: Access Secrets Manager with IAM Role Using Terraform

To enable secure retrieval of secrets, the Nautilus DevOps team needs to configure access to a secret in AWS Secrets Manager using IAM roles and policies. The objective is to allow EC2 instances to retrieve secrets securely. Please complete the following tasks:

1. Create a secret in AWS Secrets Manager named xfusion-app-secret with the following secret string:

`{"db_user":"admin","db_pass":"supersecret"}`

2. Create an IAM role named `xfusion-app-role` with EC2 as the trusted entity.

3. Attach an inline IAM policy named `xfusion-app-policy` that grants permission to retrieve the secret from AWS Secrets Manager.

4. Use the `main.tf` file (do not create a separate .tf file) to provision the IAM Role and IAM Policy.

5. Create the `variables.tf` file, ensure the following variables are defined in variables.tf file:

- `KKE_SECRET_NAME` for the secret name.
- `KKE_SECRET_VALUE` for the secret value.
- `KKE_ROLE_NAME` for the IAM role name.
- `KKE_POLICY_NAME` for the IAM policy name.

6. Create the `outputs.tf` file, and use the following:

- `KKE_secret_name`: The secret name
- `KKE_role_name`: The IAM role name
- `KKE_policy_name`: The IAM policy name

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.xfusion_app_role will be created
  + resource "aws_iam_role" "xfusion_app_role" {
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
      + name                  = "xfusion-app-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "tag-key" = "tag-value"
        }
      + tags_all              = {
          + "tag-key" = "tag-value"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy.xfusion_app_policy will be created
  + resource "aws_iam_role_policy" "xfusion_app_policy" {
      + id          = (known after apply)
      + name        = "xfusion-app-policy"
      + name_prefix = (known after apply)
      + policy      = (known after apply)
      + role        = (known after apply)
    }

  # aws_secretsmanager_secret.xfusion_app_secret will be created
  + resource "aws_secretsmanager_secret" "xfusion_app_secret" {
      + arn                            = (known after apply)
      + force_overwrite_replica_secret = false
      + id                             = (known after apply)
      + name                           = "xfusion-app-secret"
      + name_prefix                    = (known after apply)
      + policy                         = (known after apply)
      + recovery_window_in_days        = 30
      + tags_all                       = (known after apply)

      + replica (known after apply)
    }

  # aws_secretsmanager_secret_version.xfusion_app_secret_version will be created
  + resource "aws_secretsmanager_secret_version" "xfusion_app_secret_version" {
      + arn                  = (known after apply)
      + has_secret_string_wo = (known after apply)
      + id                   = (known after apply)
      + secret_id            = (known after apply)
      + secret_string        = (sensitive value)
      + secret_string_wo     = (write-only attribute)
      + version_id           = (known after apply)
      + version_stages       = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_policy_name = "xfusion-app-policy"
  + KKE_role_name   = "xfusion-app-role"
  + KKE_secret_name = "xfusion-app-secret"
aws_iam_role.xfusion_app_role: Creating...
aws_secretsmanager_secret.xfusion_app_secret: Creating...
aws_secretsmanager_secret.xfusion_app_secret: Creation complete after 1s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx]
aws_secretsmanager_secret_version.xfusion_app_secret_version: Creating...
aws_secretsmanager_secret_version.xfusion_app_secret_version: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx|terraform-20260419150746727000000002]
aws_iam_role.xfusion_app_role: Creation complete after 1s [id=xfusion-app-role]
aws_iam_role_policy.xfusion_app_policy: Creating...
aws_iam_role_policy.xfusion_app_policy: Creation complete after 0s [id=xfusion-app-role:xfusion-app-policy]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

KKE_policy_name = "xfusion-app-policy"
KKE_role_name = "xfusion-app-role"
KKE_secret_name = "xfusion-app-secret"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_iam_role.xfusion_app_role:
resource "aws_iam_role" "xfusion_app_role" {
    arn                   = "arn:aws:iam::000000000000:role/xfusion-app-role"
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
    create_date           = "2026-04-19T15:07:46Z"
    description           = null
    force_detach_policies = false
    id                    = "xfusion-app-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "xfusion-app-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags                  = {
        "tag-key" = "tag-value"
    }
    tags_all              = {
        "tag-key" = "tag-value"
    }
    unique_id             = "AROAQAAAAAAAPY26K2G3T"
}

# aws_iam_role_policy.xfusion_app_policy:
resource "aws_iam_role_policy" "xfusion_app_policy" {
    id          = "xfusion-app-role:xfusion-app-policy"
    name        = "xfusion-app-policy"
    name_prefix = null
    policy      = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "secretsmanager:GetSecretValue",
                        "secretsmanager:DescribeSecret",
                    ]
                    Effect   = "Allow"
                    Resource = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    role        = "xfusion-app-role"
}

# aws_secretsmanager_secret.xfusion_app_secret:
resource "aws_secretsmanager_secret" "xfusion_app_secret" {
    arn                            = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx"
    description                    = null
    force_overwrite_replica_secret = false
    id                             = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx"
    kms_key_id                     = null
    name                           = "xfusion-app-secret"
    name_prefix                    = null
    policy                         = null
    recovery_window_in_days        = 30
    tags_all                       = {}
}

# aws_secretsmanager_secret_version.xfusion_app_secret_version:
resource "aws_secretsmanager_secret_version" "xfusion_app_secret_version" {
    arn              = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx"
    id               = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx|terraform-20260419150746727000000002"
    secret_binary    = (sensitive value)
    secret_id        = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-app-secret-mnfcNx"
    secret_string    = (sensitive value)
    secret_string_wo = (write-only attribute)
    version_id       = "terraform-20260419150746727000000002"
    version_stages   = [
        "AWSCURRENT",
    ]
}


Outputs:

KKE_policy_name = "xfusion-app-policy"
KKE_role_name = "xfusion-app-role"
KKE_secret_name = "xfusion-app-secret"
```