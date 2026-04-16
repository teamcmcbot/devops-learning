# Task 011: Implement S3 Lifecycle Management Policy Using Terraform

The Nautilus DevOps team is implementing lifecycle policies to manage object storage efficiently in AWS. They want to create an S3 bucket with a specific lifecycle rule that transitions objects to infrequent access (IA) storage after 30 days and deletes them after 365 days.

1. Create an S3 bucket named `xfusion-lifecycle-22645`.

2. Enable the `S3 Versioning` on the bucket.

3. Add a lifecycle rule named `xfusion-lifecycle-rule` with:

- Transition to `STANDARD_IA` storage class after `30 days`.
- Expiration of objects after `365 days`.

4. Use the `main.tf` file (do not create a separate .tf file) to provision the S3 bucket.

5. Use the variable name `KKE_bucket_name` in the `outputs.tf` file to output the created bucket name.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.xfusion_s3_bucket will be created
  + resource "aws_s3_bucket" "xfusion_s3_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "xfusion-lifecycle-22645"
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
      + tags_all                    = (known after apply)
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

  # aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "xfusion_lifecycle_rule" {
      + bucket                                 = "xfusion-lifecycle-22645"
      + expected_bucket_owner                  = (known after apply)
      + id                                     = (known after apply)
      + transition_default_minimum_object_size = "all_storage_classes_128K"

      + rule {
          + id     = "xfusion-lifecycle-rule"
          + prefix = (known after apply)
          + status = "Enabled"

          + expiration {
              + days                         = 365
              + expired_object_delete_marker = (known after apply)
            }

          + filter {
              + object_size_greater_than = (known after apply)
              + object_size_less_than    = (known after apply)
                # (1 unchanged attribute hidden)
            }

          + transition {
              + days          = 30
              + storage_class = "STANDARD_IA"
            }
        }
    }

  # aws_s3_bucket_versioning.xfusion_s3_bucket_versioning will be created
  + resource "aws_s3_bucket_versioning" "xfusion_s3_bucket_versioning" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_bucket_name = "xfusion-lifecycle-22645"

───────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.xfusion_s3_bucket will be created
  + resource "aws_s3_bucket" "xfusion_s3_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "xfusion-lifecycle-22645"
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
      + tags_all                    = (known after apply)
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

  # aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "xfusion_lifecycle_rule" {
      + bucket                                 = "xfusion-lifecycle-22645"
      + expected_bucket_owner                  = (known after apply)
      + id                                     = (known after apply)
      + transition_default_minimum_object_size = "all_storage_classes_128K"

      + rule {
          + id     = "xfusion-lifecycle-rule"
          + prefix = (known after apply)
          + status = "Enabled"

          + expiration {
              + days                         = 365
              + expired_object_delete_marker = (known after apply)
            }

          + filter {
              + object_size_greater_than = (known after apply)
              + object_size_less_than    = (known after apply)
                # (1 unchanged attribute hidden)
            }

          + transition {
              + days          = 30
              + storage_class = "STANDARD_IA"
            }
        }
    }

  # aws_s3_bucket_versioning.xfusion_s3_bucket_versioning will be created
  + resource "aws_s3_bucket_versioning" "xfusion_s3_bucket_versioning" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_bucket_name = "xfusion-lifecycle-22645"
aws_s3_bucket.xfusion_s3_bucket: Creating...
aws_s3_bucket.xfusion_s3_bucket: Creation complete after 0s [id=xfusion-lifecycle-22645]
aws_s3_bucket_versioning.xfusion_s3_bucket_versioning: Creating...
aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule: Creating...
aws_s3_bucket_versioning.xfusion_s3_bucket_versioning: Creation complete after 2s [id=xfusion-lifecycle-22645]
aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule: Still creating... [10s elapsed]
aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule: Still creating... [20s elapsed]
aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule: Creation complete after 20s [id=xfusion-lifecycle-22645]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

KKE_bucket_name = "xfusion-lifecycle-22645"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_s3_bucket.xfusion_s3_bucket:
resource "aws_s3_bucket" "xfusion_s3_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::xfusion-lifecycle-22645"
    bucket                      = "xfusion-lifecycle-22645"
    bucket_domain_name          = "xfusion-lifecycle-22645.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "xfusion-lifecycle-22645.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "xfusion-lifecycle-22645"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags_all                    = {}

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

# aws_s3_bucket_lifecycle_configuration.xfusion_lifecycle_rule:
resource "aws_s3_bucket_lifecycle_configuration" "xfusion_lifecycle_rule" {
    bucket                                 = "xfusion-lifecycle-22645"
    expected_bucket_owner                  = null
    id                                     = "xfusion-lifecycle-22645"
    transition_default_minimum_object_size = "all_storage_classes_128K"

    rule {
        id     = "xfusion-lifecycle-rule"
        prefix = null
        status = "Enabled"

        expiration {
            days                         = 365
            expired_object_delete_marker = false
        }

        filter {
            prefix = null
        }

        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }
    }
}

# aws_s3_bucket_versioning.xfusion_s3_bucket_versioning:
resource "aws_s3_bucket_versioning" "xfusion_s3_bucket_versioning" {
    bucket                = "xfusion-lifecycle-22645"
    expected_bucket_owner = null
    id                    = "xfusion-lifecycle-22645"

    versioning_configuration {
        mfa_delete = null
        status     = "Enabled"
    }
}


Outputs:

KKE_bucket_name = "xfusion-lifecycle-22645"
```