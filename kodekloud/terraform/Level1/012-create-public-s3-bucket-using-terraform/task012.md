# Task 012 - Create Public S3 Bucket using Terraform

As part of the data migration process, the Nautilus DevOps team is actively creating several S3 buckets on AWS. They plan to utilize both private and public S3 buckets to store the relevant data. Given the ongoing migration of other infrastructure to AWS, it is logical to consolidate data storage within the AWS environment as well.

Create a public S3 bucket named `devops-s3-27094` using Terraform.

Ensure the bucket is accessible publicly once created by setting the proper ACL.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Notes:

Create the resources only in the `us-east-1` region.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
The name of the S3 bucket should be based on `devops-s3-27094`.
You can use the ACL settings to ensure the bucket is publicly accessible.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.devops-s3-bucket will be created
  + resource "aws_s3_bucket" "devops-s3-bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "devops-s3-27094"
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

  # aws_s3_bucket_acl.devops-s3-bucket-acl will be created
  + resource "aws_s3_bucket_acl" "devops-s3-bucket-acl" {
      + acl    = "public-read"
      + bucket = (known after apply)
      + id     = (known after apply)

      + access_control_policy (known after apply)
    }

  # aws_s3_bucket_ownership_controls.devops-s3-bucket-ownership will be created
  + resource "aws_s3_bucket_ownership_controls" "devops-s3-bucket-ownership" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerPreferred"
        }
    }

  # aws_s3_bucket_public_access_block.devops-s3-bucket-public-access will be created
  + resource "aws_s3_bucket_public_access_block" "devops-s3-bucket-public-access" {
      + block_public_acls       = false
      + block_public_policy     = false
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = false
      + restrict_public_buckets = false
    }

Plan: 4 to add, 0 to change, 0 to destroy.
aws_s3_bucket.devops-s3-bucket: Creating...
aws_s3_bucket.devops-s3-bucket: Creation complete after 1s [id=devops-s3-27094]
aws_s3_bucket_public_access_block.devops-s3-bucket-public-access: Creating...
aws_s3_bucket_ownership_controls.devops-s3-bucket-ownership: Creating...
aws_s3_bucket_ownership_controls.devops-s3-bucket-ownership: Creation complete after 0s [id=devops-s3-27094]
aws_s3_bucket_public_access_block.devops-s3-bucket-public-access: Creation complete after 0s [id=devops-s3-27094]
aws_s3_bucket_acl.devops-s3-bucket-acl: Creating...
aws_s3_bucket_acl.devops-s3-bucket-acl: Creation complete after 0s [id=devops-s3-27094,public-read]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2025-12-05 11:27:38 devops-s3-27094

bob@iac-server ~/terraform via 💠 default ➜  aws s3api get-bucket-acl --bucket devops-s3-27094 --region us-east-1
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
        },
        {
            "Grantee": {
                "Type": "Group",
                "URI": "http://acs.amazonaws.com/groups/global/AllUsers"
            },
            "Permission": "READ"
        }
    ]
}

bob@iac-server ~/terraform via 💠 default ➜  aws s3api head-bucket --bucket devops-s3-27094 --region us-east-1
{
    "BucketRegion": "us-east-1"
}

bob@iac-server ~/terraform via 💠 default ➜  aws s3api get-public-access-block --bucket devops-s3-27094 --region us-east-1
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": false,
        "IgnorePublicAcls": false,
        "BlockPublicPolicy": false,
        "RestrictPublicBuckets": false
    }
}
```
