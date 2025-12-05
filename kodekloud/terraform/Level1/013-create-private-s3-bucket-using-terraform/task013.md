# Task 013 - Create Private S3 Bucket using Terraform

As part of the data migration process, the Nautilus DevOps team is actively creating several S3 buckets on AWS using Terraform. They plan to utilize both private and public S3 buckets to store the relevant data. Given the ongoing migration of other infrastructure to AWS, it is logical to consolidate data storage within the AWS environment as well.

Create an S3 bucket using Terraform with the following details:

1. The name of the S3 bucket must be `nautilus-s3-15798`.

2. The S3 bucket must block all public access, making it a private bucket.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Notes:

Use Terraform to provision the S3 bucket.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
Ensure the resources are created in the us-east-1 region.
The bucket must have block public access enabled to restrict any public access.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.nautilus-s3-bucket will be created
  + resource "aws_s3_bucket" "nautilus-s3-bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "nautilus-s3-15798"
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

  # aws_s3_bucket_acl.nautilus-s3-bucket-acl will be created
  + resource "aws_s3_bucket_acl" "nautilus-s3-bucket-acl" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)

      + access_control_policy (known after apply)
    }

  # aws_s3_bucket_ownership_controls.nautilus-s3-bucket-ownership will be created
  + resource "aws_s3_bucket_ownership_controls" "nautilus-s3-bucket-ownership" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerPreferred"
        }
    }

  # aws_s3_bucket_public_access_block.nautilus-s3-bucket-public-access will be created
  + resource "aws_s3_bucket_public_access_block" "nautilus-s3-bucket-public-access" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

Plan: 4 to add, 0 to change, 0 to destroy.
aws_s3_bucket.nautilus-s3-bucket: Creating...
aws_s3_bucket.nautilus-s3-bucket: Creation complete after 0s [id=nautilus-s3-15798]
aws_s3_bucket_public_access_block.nautilus-s3-bucket-public-access: Creating...
aws_s3_bucket_ownership_controls.nautilus-s3-bucket-ownership: Creating...
aws_s3_bucket_public_access_block.nautilus-s3-bucket-public-access: Creation complete after 0s [id=nautilus-s3-15798]
aws_s3_bucket_ownership_controls.nautilus-s3-bucket-ownership: Creation complete after 0s [id=nautilus-s3-15798]
aws_s3_bucket_acl.nautilus-s3-bucket-acl: Creating...
aws_s3_bucket_acl.nautilus-s3-bucket-acl: Creation complete after 0s [id=nautilus-s3-15798,private]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2025-12-05 12:47:36 nautilus-s3-15798

bob@iac-server ~/terraform via 💠 default ➜  aws s3api get-bucket-acl --bucket nautilus-s3-15798 --region us-east-1
{
    "Owner": {
        "DisplayName": "webfile",
        "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
    },
    "Grants": [
        {
            "Grantee": {
                "DisplayName": "webfile",
                "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a",
                "Type": "CanonicalUser"
            },
            "Permission": "FULL_CONTROL"
        }
    ]
}

bob@iac-server ~/terraform via 💠 default ➜  aws s3api get-public-access-block --bucket nautilus-s3-15798 --region us-east-1
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}

```
