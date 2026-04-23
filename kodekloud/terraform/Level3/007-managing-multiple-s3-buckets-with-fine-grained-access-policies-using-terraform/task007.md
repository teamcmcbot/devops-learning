# Task 007: Managing Multiple S3 Buckets with Fine-Grained Access Policies Using Terraform

The Nautilus DevOps team needs to set up three S3 buckets for different environments with backup and policy configurations. Follow the steps below:

1. Create three S3 buckets using `for_each` for environments: `Dev`, `Staging`, and `Prod`.

2. Name the buckets using the following naming convention:

- `datacenter-dev-bucket-32108`
- `datacenter-staging-bucket-32108`
- `datacenter-prod-bucket-32108`

3. Add the following tags to each bucket with the corresponding values:

   - a.) For `datacenter-dev-bucket-32108`:
      - Name = `datacenter-dev-bucket-32108`
      - Environment = `Dev`
      - Owner = `Alice`

   - b.) For `datacenter-staging-bucket-32108`:
      - Name = `datacenter-staging-bucket-32108`
      - Environment = `Staging`
      - Owner = `Bob`

   - c.) For `datacenter-prod-bucket-32108`:
      - Name = `datacenter-prod-bucket-32108`
      - Environment = `Prod`
      - Owner = `Carol`

4. For the `staging` and `prod` buckets, set `Backup = true` and add a lifecycle rule with ID `MoveToGlacier` to transition objects to `Glacier` after `30` days.

5. Use the `lifecycle` block with `ignore_changes` to protect the `tags`.

6. Create a bucket policy that allows `public read access` to all objects in the bucket.

7. Use `depends_on` to ensure the policy is only applied after the bucket has been created.

8. Implement the entire configuration in a single `main.tf` file (do not create a separate .tf file) to provision multiple S3 buckets with the specified configurations.

9. Use `variables.tf` with the following variable:

- `KKE_ENV_TAGS`: `KKE_ENV_TAGS` is a map that holds environment-specific metadata such as bucket name, owner, and backup flag.

10. Use `outputs.tf` file to output the following:

- `kke_bucket_names`: output the names of the bucket created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.kke_buckets["Dev"] will be created
  + resource "aws_s3_bucket" "kke_buckets" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "datacenter-dev-bucket-32108"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "Dev"
          + "Name"        = "datacenter-dev-bucket-32108"
          + "Owner"       = "Alice"
        }
      + tags_all                    = {
          + "Environment" = "Dev"
          + "Name"        = "datacenter-dev-bucket-32108"
          + "Owner"       = "Alice"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket.kke_buckets["Prod"] will be created
  + resource "aws_s3_bucket" "kke_buckets" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "datacenter-prod-bucket-32108"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Backup"      = "true"
          + "Environment" = "Prod"
          + "Name"        = "datacenter-prod-bucket-32108"
          + "Owner"       = "Carol"
        }
      + tags_all                    = {
          + "Backup"      = "true"
          + "Environment" = "Prod"
          + "Name"        = "datacenter-prod-bucket-32108"
          + "Owner"       = "Carol"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket.kke_buckets["Staging"] will be created
  + resource "aws_s3_bucket" "kke_buckets" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "datacenter-staging-bucket-32108"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Backup"      = "true"
          + "Environment" = "Staging"
          + "Name"        = "datacenter-staging-bucket-32108"
          + "Owner"       = "Bob"
        }
      + tags_all                    = {
          + "Backup"      = "true"
          + "Environment" = "Staging"
          + "Name"        = "datacenter-staging-bucket-32108"
          + "Owner"       = "Bob"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"] will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "kke_backup_lifecycle" {
      + bucket                                 = (known after apply)
      + expected_bucket_owner                  = (known after apply)
      + id                                     = (known after apply)
      + transition_default_minimum_object_size = "all_storage_classes_128K"

      + rule {
          + id     = "MoveToGlacier"
          + prefix = (known after apply)
          + status = "Enabled"

          + filter {
              + object_size_greater_than = (known after apply)
              + object_size_less_than    = (known after apply)
                # (1 unchanged attribute hidden)
            }

          + transition {
              + days          = 30
              + storage_class = "GLACIER"
            }
        }
    }

  # aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"] will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "kke_backup_lifecycle" {
      + bucket                                 = (known after apply)
      + expected_bucket_owner                  = (known after apply)
      + id                                     = (known after apply)
      + transition_default_minimum_object_size = "all_storage_classes_128K"

      + rule {
          + id     = "MoveToGlacier"
          + prefix = (known after apply)
          + status = "Enabled"

          + filter {
              + object_size_greater_than = (known after apply)
              + object_size_less_than    = (known after apply)
                # (1 unchanged attribute hidden)
            }

          + transition {
              + days          = 30
              + storage_class = "GLACIER"
            }
        }
    }

  # aws_s3_bucket_policy.kke_public_read["Dev"] will be created
  + resource "aws_s3_bucket_policy" "kke_public_read" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = (known after apply)
    }

  # aws_s3_bucket_policy.kke_public_read["Prod"] will be created
  + resource "aws_s3_bucket_policy" "kke_public_read" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = (known after apply)
    }

  # aws_s3_bucket_policy.kke_public_read["Staging"] will be created
  + resource "aws_s3_bucket_policy" "kke_public_read" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_bucket_names = [
      + "datacenter-dev-bucket-32108",
      + "datacenter-prod-bucket-32108",
      + "datacenter-staging-bucket-32108",
    ]
aws_s3_bucket.kke_buckets["Staging"]: Creating...
aws_s3_bucket.kke_buckets["Dev"]: Creating...
aws_s3_bucket.kke_buckets["Prod"]: Creating...
aws_s3_bucket.kke_buckets["Staging"]: Creation complete after 1s [id=datacenter-staging-bucket-32108]
aws_s3_bucket.kke_buckets["Prod"]: Creation complete after 1s [id=datacenter-prod-bucket-32108]
aws_s3_bucket.kke_buckets["Dev"]: Creation complete after 1s [id=datacenter-dev-bucket-32108]
aws_s3_bucket_policy.kke_public_read["Staging"]: Creating...
aws_s3_bucket_policy.kke_public_read["Dev"]: Creating...
aws_s3_bucket_policy.kke_public_read["Prod"]: Creating...
aws_s3_bucket_policy.kke_public_read["Dev"]: Creation complete after 0s [id=datacenter-dev-bucket-32108]
aws_s3_bucket_policy.kke_public_read["Prod"]: Creation complete after 0s [id=datacenter-prod-bucket-32108]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"]: Creating...
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"]: Creating...
aws_s3_bucket_policy.kke_public_read["Staging"]: Creation complete after 0s [id=datacenter-staging-bucket-32108]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"]: Still creating... [10s elapsed]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"]: Still creating... [10s elapsed]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"]: Still creating... [20s elapsed]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"]: Still creating... [20s elapsed]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"]: Creation complete after 20s [id=datacenter-staging-bucket-32108]
aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"]: Creation complete after 20s [id=datacenter-prod-bucket-32108]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

kke_bucket_names = [
  "datacenter-dev-bucket-32108",
  "datacenter-prod-bucket-32108",
  "datacenter-staging-bucket-32108",
]
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_s3_bucket.kke_buckets["Dev"]:
resource "aws_s3_bucket" "kke_buckets" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::datacenter-dev-bucket-32108"
    bucket                      = "datacenter-dev-bucket-32108"
    bucket_domain_name          = "datacenter-dev-bucket-32108.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "datacenter-dev-bucket-32108.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "datacenter-dev-bucket-32108"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "Dev"
        "Name"        = "datacenter-dev-bucket-32108"
        "Owner"       = "Alice"
    }
    tags_all                    = {
        "Environment" = "Dev"
        "Name"        = "datacenter-dev-bucket-32108"
        "Owner"       = "Alice"
    }

    grant {
        id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

# aws_s3_bucket.kke_buckets["Prod"]:
resource "aws_s3_bucket" "kke_buckets" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::datacenter-prod-bucket-32108"
    bucket                      = "datacenter-prod-bucket-32108"
    bucket_domain_name          = "datacenter-prod-bucket-32108.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "datacenter-prod-bucket-32108.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "datacenter-prod-bucket-32108"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Backup"      = "true"
        "Environment" = "Prod"
        "Name"        = "datacenter-prod-bucket-32108"
        "Owner"       = "Carol"
    }
    tags_all                    = {
        "Backup"      = "true"
        "Environment" = "Prod"
        "Name"        = "datacenter-prod-bucket-32108"
        "Owner"       = "Carol"
    }

    grant {
        id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

# aws_s3_bucket.kke_buckets["Staging"]:
resource "aws_s3_bucket" "kke_buckets" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::datacenter-staging-bucket-32108"
    bucket                      = "datacenter-staging-bucket-32108"
    bucket_domain_name          = "datacenter-staging-bucket-32108.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "datacenter-staging-bucket-32108.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "datacenter-staging-bucket-32108"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Backup"      = "true"
        "Environment" = "Staging"
        "Name"        = "datacenter-staging-bucket-32108"
        "Owner"       = "Bob"
    }
    tags_all                    = {
        "Backup"      = "true"
        "Environment" = "Staging"
        "Name"        = "datacenter-staging-bucket-32108"
        "Owner"       = "Bob"
    }

    grant {
        id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

# aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Prod"]:
resource "aws_s3_bucket_lifecycle_configuration" "kke_backup_lifecycle" {
    bucket                                 = "datacenter-prod-bucket-32108"
    expected_bucket_owner                  = null
    id                                     = "datacenter-prod-bucket-32108"
    transition_default_minimum_object_size = "all_storage_classes_128K"

    rule {
        id     = "MoveToGlacier"
        prefix = null
        status = "Enabled"

        filter {
            prefix = null
        }

        transition {
            days          = 30
            storage_class = "GLACIER"
        }
    }
}

# aws_s3_bucket_lifecycle_configuration.kke_backup_lifecycle["Staging"]:
resource "aws_s3_bucket_lifecycle_configuration" "kke_backup_lifecycle" {
    bucket                                 = "datacenter-staging-bucket-32108"
    expected_bucket_owner                  = null
    id                                     = "datacenter-staging-bucket-32108"
    transition_default_minimum_object_size = "all_storage_classes_128K"

    rule {
        id     = "MoveToGlacier"
        prefix = null
        status = "Enabled"

        filter {
            prefix = null
        }

        transition {
            days          = 30
            storage_class = "GLACIER"
        }
    }
}

# aws_s3_bucket_policy.kke_public_read["Dev"]:
resource "aws_s3_bucket_policy" "kke_public_read" {
    bucket = "datacenter-dev-bucket-32108"
    id     = "datacenter-dev-bucket-32108"
    policy = jsonencode(
        {
            Statement = [
                {
                    Action    = [
                        "s3:GetObject",
                    ]
                    Effect    = "Allow"
                    Principal = "*"
                    Resource  = [
                        "arn:aws:s3:::datacenter-dev-bucket-32108/*",
                    ]
                    Sid       = "PublicReadGetObject"
                },
            ]
            Version   = "2012-10-17"
        }
    )
}

# aws_s3_bucket_policy.kke_public_read["Prod"]:
resource "aws_s3_bucket_policy" "kke_public_read" {
    bucket = "datacenter-prod-bucket-32108"
    id     = "datacenter-prod-bucket-32108"
    policy = jsonencode(
        {
            Statement = [
                {
                    Action    = [
                        "s3:GetObject",
                    ]
                    Effect    = "Allow"
                    Principal = "*"
                    Resource  = [
                        "arn:aws:s3:::datacenter-prod-bucket-32108/*",
                    ]
                    Sid       = "PublicReadGetObject"
                },
            ]
            Version   = "2012-10-17"
        }
    )
}

# aws_s3_bucket_policy.kke_public_read["Staging"]:
resource "aws_s3_bucket_policy" "kke_public_read" {
    bucket = "datacenter-staging-bucket-32108"
    id     = "datacenter-staging-bucket-32108"
    policy = jsonencode(
        {
            Statement = [
                {
                    Action    = [
                        "s3:GetObject",
                    ]
                    Effect    = "Allow"
                    Principal = "*"
                    Resource  = [
                        "arn:aws:s3:::datacenter-staging-bucket-32108/*",
                    ]
                    Sid       = "PublicReadGetObject"
                },
            ]
            Version   = "2012-10-17"
        }
    )
}


Outputs:

kke_bucket_names = [
    "datacenter-dev-bucket-32108",
    "datacenter-prod-bucket-32108",
    "datacenter-staging-bucket-32108",
]



bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2026-04-23 02:12:15 datacenter-dev-bucket-32108
2026-04-23 02:12:15 datacenter-prod-bucket-32108
2026-04-23 02:12:15 datacenter-staging-bucket-32108
```