# Task 009: Prevent S3 Bucket Deletion via Terraform

To ensure secure and accidental-deletion-proof storage, the DevOps team must configure an S3 bucket using Terraform with strict lifecycle protections. The goal is to create a bucket that is dynamically named and protected from being destroyed by mistake. Please complete the following tasks:

1. Create an S3 bucket named `datacenter-s3-2748`.

2. Apply the `prevent_destroy` lifecycle rule to protect the bucket.

3. Create the `main.tf` file (do not create a separate .tf file) to provision a s3 bucket with `prevent_destroy` lifecycle rule.

4. Use the `variables.tf `file with the following:

- `KKE_BUCKET_NAME`: name of the bucket.

5. Use the `terraform.tfvars` file to input the name of the bucket.

6. Use the `outputs.tf` file with the following:

- `s3_bucket_name`: name of the created bucket.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.s3_bucket_with_prevent_destroy will be created
  + resource "aws_s3_bucket" "s3_bucket_with_prevent_destroy" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "datacenter-s3-2748"
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

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + s3_bucket_name = "datacenter-s3-2748"
aws_s3_bucket.s3_bucket_with_prevent_destroy: Creating...
aws_s3_bucket.s3_bucket_with_prevent_destroy: Creation complete after 1s [id=datacenter-s3-2748]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

s3_bucket_name = "datacenter-s3-2748"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_s3_bucket.s3_bucket_with_prevent_destroy:
resource "aws_s3_bucket" "s3_bucket_with_prevent_destroy" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::datacenter-s3-2748"
    bucket                      = "datacenter-s3-2748"
    bucket_domain_name          = "datacenter-s3-2748.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "datacenter-s3-2748.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "datacenter-s3-2748"
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


Outputs:

s3_bucket_name = "datacenter-s3-2748"



bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2026-04-15 07:46:19 datacenter-s3-2748

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://datacenter-s3-2748
```