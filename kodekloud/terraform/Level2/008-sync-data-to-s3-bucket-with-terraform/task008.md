# Task 008: Sync Data to S3 Bucket with Terraform

As part of a data migration project, the team lead has tasked the team with migrating data from an existing S3 bucket to a new S3 bucket. The existing bucket contains a substantial amount of data that must be accurately transferred to the new bucket. The team is responsible for creating the new S3 bucket using Terraform and ensuring that all data from the existing bucket is copied or synced to the new bucket completely and accurately. It is imperative to perform thorough verification steps to confirm that all data has been successfully transferred to the new bucket without any loss or corruption.

As a member of the Nautilus DevOps Team, your task is to perform the following using Terraform:

1. Create a New Private S3 Bucket: Name the bucket `devops-sync-28643` and store this bucket name in a variable named `KKE_BUCKET`.

2. Data Migration: Migrate all data from the existing `devops-s3-20919` bucket to the new `devops-sync-28643 bucket`.

3. Ensure Data Consistency: Ensure that both buckets contain the same data after migration.

4. Update the `main.tf` file (do not create a separate .tf file) to provision a new private S3 bucket and migrate the data.

5. Use the `variables.tf` file with the following variable:

- `KKE_BUCKET`: The name for the new bucket created.

6. Use the `outputs.tf` file with the following outputs:

- `new_kke_bucket_name`: The name of the new bucket created.
- `new_kke_bucket_acl`: The ACL of the new bucket created.

## Solution

```bash
erraform_data.s3_sync (local-exec): copy: s3://devops-s3-20919/wp-login.php to s3://devops-sync-28643/wp-login.php
terraform_data.s3_sync (local-exec): Completed 72.7 MiB/72.7 MiB (12.3 MiB/s) with 1 file(s) remaining
terraform_data.s3_sync (local-exec): Completed 72.7 MiB/72.7 MiB (12.3 MiB/s) with 1 file(s) remaining
terraform_data.s3_sync (local-exec): copy: s3://devops-s3-20919/xmlrpc.php to s3://devops-sync-28643/xmlrpc.php
terraform_data.s3_sync (local-exec): Data consistency check passed: source and destination both have 3349 objects
terraform_data.s3_sync: Creation complete after 8s [id=7146c217-2a42-7d80-a40a-3ca148337b83]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

new_kke_bucket_acl = "private"
new_kke_bucket_name = "devops-sync-28643"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_s3_bucket.kke_bucket:
resource "aws_s3_bucket" "kke_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::devops-sync-28643"
    bucket                      = "devops-sync-28643"
    bucket_domain_name          = "devops-sync-28643.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "devops-sync-28643.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "devops-sync-28643"
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

# aws_s3_bucket.wordpress_bucket:
resource "aws_s3_bucket" "wordpress_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::devops-s3-20919"
    bucket                      = "devops-s3-20919"
    bucket_domain_name          = "devops-s3-20919.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "devops-s3-20919.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "devops-s3-20919"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {}
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

# aws_s3_bucket_acl.kke_bucket_acl:
resource "aws_s3_bucket_acl" "kke_bucket_acl" {
    acl                   = "private"
    bucket                = "devops-sync-28643"
    expected_bucket_owner = null
    id                    = "devops-sync-28643,private"

    access_control_policy {
        grant {
            permission = "FULL_CONTROL"

            grantee {
                display_name  = "webfile"
                email_address = null
                id            = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
                type          = "CanonicalUser"
                uri           = null
            }
        }
        owner {
            display_name = "webfile"
            id           = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        }
    }
}

# aws_s3_bucket_acl.wordpress_bucket_acl:
resource "aws_s3_bucket_acl" "wordpress_bucket_acl" {
    acl                   = "private"
    bucket                = "devops-s3-20919"
    expected_bucket_owner = null
    id                    = "devops-s3-20919,private"

    access_control_policy {
        grant {
            permission = "FULL_CONTROL"

            grantee {
                display_name  = "webfile"
                email_address = null
                id            = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
                type          = "CanonicalUser"
                uri           = null
            }
        }
        owner {
            display_name = "webfile"
            id           = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        }
    }
}

# terraform_data.s3_sync:
resource "terraform_data" "s3_sync" {
    id               = "7146c217-2a42-7d80-a40a-3ca148337b83"
    triggers_replace = [
        "devops-s3-20919",
        "devops-sync-28643",
    ]
}


Outputs:

new_kke_bucket_acl = "private"
new_kke_bucket_name = "devops-sync-28643"



bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2026-04-15 06:36:40 devops-s3-20919
2026-04-15 07:20:52 devops-sync-28643

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://devops-s3-20919 | wc -l
19

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://devops-s3-20919 --recursive | wc -l
3349

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://devops-sync-28643 --recursive | wc -l
3349
```