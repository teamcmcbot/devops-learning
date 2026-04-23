# Task 009: Storing and Accessing Sensitive Data Securely with AWS Secrets Manager Using Terraform

The Nautilus DevOps team needs to securely manage sensitive information using AWS Secrets Manager. The task is to create a secret in AWS Secrets Manager using Terraform. Store a database password securely in this secret. Ensure the password is passed as a `sensitive` Terraform variable, and it should not appear in Terraform logs or output without being marked `sensitive`.

Requirements:

1. Create an AWS Secrets Manager secret named `datacenter-db-password`.

2. Store the database password `SuperSecretPassword123!` in the secret using Terraform.

3. Mark the Terraform variable for the password as sensitive.

4. Do not expose the actual password in Terraform outputs without marking it `sensitive`.

5. Create `main.tf` file (do not create a separate .tf file) to provision a Secret and add the database password in it.

6. Use `variables.tf` file for the following:

- `KKE_DB_PASSWORD`: database password stored in secrets manager.

7. Create a `terraform.tfvars` to input the database password.

8. Use `outputs.tf` file to output the following:

- `kke_secret_arn`: arn of the secret created.
- `kke_secret_string`: database password.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_secretsmanager_secret.datacenter_db_password will be created
  + resource "aws_secretsmanager_secret" "datacenter_db_password" {
      + arn                            = (known after apply)
      + force_overwrite_replica_secret = false
      + id                             = (known after apply)
      + name                           = "datacenter-db-password"
      + name_prefix                    = (known after apply)
      + policy                         = (known after apply)
      + recovery_window_in_days        = 30
      + tags_all                       = (known after apply)

      + replica (known after apply)
    }

  # aws_secretsmanager_secret_version.datacenter_db_password will be created
  + resource "aws_secretsmanager_secret_version" "datacenter_db_password" {
      + arn                  = (known after apply)
      + has_secret_string_wo = (known after apply)
      + id                   = (known after apply)
      + secret_id            = (known after apply)
      + secret_string        = (sensitive value)
      + secret_string_wo     = (write-only attribute)
      + version_id           = (known after apply)
      + version_stages       = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_secret_arn    = (known after apply)
  + kke_secret_string = (sensitive value)
aws_secretsmanager_secret.datacenter_db_password: Creating...
aws_secretsmanager_secret.datacenter_db_password: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk]
aws_secretsmanager_secret_version.datacenter_db_password: Creating...
aws_secretsmanager_secret_version.datacenter_db_password: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk|terraform-20260423091642245400000002]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
kke_secret_string = <sensitive>
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_secretsmanager_secret.datacenter_db_password:
resource "aws_secretsmanager_secret" "datacenter_db_password" {
    arn                            = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
    description                    = null
    force_overwrite_replica_secret = false
    id                             = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
    kms_key_id                     = null
    name                           = "datacenter-db-password"
    name_prefix                    = null
    policy                         = null
    recovery_window_in_days        = 30
    tags_all                       = {}
}

# aws_secretsmanager_secret_version.datacenter_db_password:
resource "aws_secretsmanager_secret_version" "datacenter_db_password" {
    arn              = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
    id               = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk|terraform-20260423091642245400000002"
    secret_binary    = (sensitive value)
    secret_id        = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
    secret_string    = (sensitive value)
    secret_string_wo = (write-only attribute)
    version_id       = "terraform-20260423091642245400000002"
    version_stages   = [
        "AWSCURRENT",
    ]
}


Outputs:

kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk"
kke_secret_string = (sensitive value)


bob@iac-server ~/terraform via 💠 default ✖ aws secretsmanager list-secrets
{
    "SecretList": [
        {
            "ARN": "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk",
            "Name": "datacenter-db-password",
            "LastChangedDate": 1776935802.247,
            "LastAccessedDate": 1776902400.0,
            "SecretVersionsToStages": {
                "terraform-20260423091642245400000002": [
                    "AWSCURRENT"
                ]
            },
            "CreatedDate": 1776935802.235236
        }
    ]
}
```

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws secretsmanager get-secret-value --secret-id datacenter-db-password
{
    "ARN": "arn:aws:secretsmanager:us-east-1:000000000000:secret:datacenter-db-password-aaEVgk",
    "Name": "datacenter-db-password",
    "VersionId": "terraform-20260423091642245400000002",
    "SecretString": "SuperSecretPassword123!",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": 1776935802.0
}

bob@iac-server ~/terraform via 💠 default ➜  aws secretsmanager get-secret-value --secret-id datacenter-db-password --query SecretString --output text
SuperSecretPassword123!
```