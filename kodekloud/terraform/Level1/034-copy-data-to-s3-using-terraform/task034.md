# Task 034 - Copy Data to S3 using Terraform

The Nautilus DevOps team is presently immersed in data migrations, transferring data from on-premise storage systems to AWS S3 buckets. They have recently received some data that they intend to copy to one of the S3 buckets.

S3 bucket named `nautilus-cp-25362` already exists. Copy the file `/tmp/nautilus.txt` to s3 bucket `nautilus-cp-25362` using Terraform. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to accomplish this task.

## Additional Information

```bash
bob@iac-server ~/terraform via 💠 default ➜  cat /tmp/nautilus.txt
Welcome to KKE Cloud Labs!

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2026-01-10 06:24:16 nautilus-cp-25362

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://nautilus-cp-25362

bob@iac-server ~/terraform via 💠 default ➜  terraform state list
aws_s3_bucket.my_bucket

bob@iac-server ~/terraform via 💠 default ➜  terraform state show aws_s3_bucket.my_bucket
# aws_s3_bucket.my_bucket:
resource "aws_s3_bucket" "my_bucket" {
    acceleration_status         = null
    acl                         = "private"
    arn                         = "arn:aws:s3:::nautilus-cp-25362"
    bucket                      = "nautilus-cp-25362"
    bucket_domain_name          = "nautilus-cp-25362.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "nautilus-cp-25362.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "nautilus-cp-25362"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Name" = "nautilus-cp-25362"
    }
    tags_all                    = {
        "Name" = "nautilus-cp-25362"
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
```

## Solution

Update the `main.tf` file located in the `/home/bob/terraform` directory to include a provisioner that copies the file `/tmp/nautilus.txt` to the S3 bucket `nautilus-cp-25362`. Below is the updated `main.tf` content:

```hcl
resource "aws_s3_bucket" "my_bucket" {
    bucket = "nautilus-cp-25362"
    acl    = "private"

    tags = {
        Name = "nautilus-cp-25362"
    }

    provisioner "local-exec" {
        command = "aws s3 cp /tmp/nautilus.txt s3://${aws_s3_bucket.my_bucket.bucket}/nautilus.txt"
    }
}
```

**NOTE:** As the S3 bucket `nautilus-cp-25362` already exists, the `provisioner` block will not execute the command. You can run `terraform apply -replace="aws_s3_bucket.my_bucket" -auto-approve` to force the recreation of the resource and execute the provisioner.

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -replace="aws_s3_bucket.my_bucket" -auto-approve
aws_s3_bucket.my_bucket: Refreshing state... [id=nautilus-cp-25362]
aws_s3_bucket_acl.my_bucket_acl: Refreshing state... [id=nautilus-cp-25362,private]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_s3_bucket.my_bucket will be replaced, as requested
-/+ resource "aws_s3_bucket" "my_bucket" {
      + acceleration_status         = (known after apply)
      ~ acl                         = "private" -> (known after apply)
      ~ arn                         = "arn:aws:s3:::nautilus-cp-25362" -> (known after apply)
      ~ bucket_domain_name          = "nautilus-cp-25362.s3.amazonaws.com" -> (known after apply)
      + bucket_prefix               = (known after apply)
      ~ bucket_regional_domain_name = "nautilus-cp-25362.s3.us-east-1.amazonaws.com" -> (known after apply)
      ~ hosted_zone_id              = "Z3AQBSTGFYJSTF" -> (known after apply)
      ~ id                          = "nautilus-cp-25362" -> (known after apply)
      ~ object_lock_enabled         = false -> (known after apply)
      + policy                      = (known after apply)
      ~ region                      = "us-east-1" -> (known after apply)
      ~ request_payer               = "BucketOwner" -> (known after apply)
        tags                        = {
            "Name" = "nautilus-cp-25362"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
        # (3 unchanged attributes hidden)

      ~ cors_rule (known after apply)

      ~ grant (known after apply)
      - grant {
          - id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a" -> null
          - permissions = [
              - "FULL_CONTROL",
            ] -> null
          - type        = "CanonicalUser" -> null
            # (1 unchanged attribute hidden)
        }

      ~ lifecycle_rule (known after apply)

      ~ logging (known after apply)

      ~ object_lock_configuration (known after apply)

      ~ replication_configuration (known after apply)

      ~ server_side_encryption_configuration (known after apply)
      - server_side_encryption_configuration {
          - rule {
              - bucket_key_enabled = false -> null

              - apply_server_side_encryption_by_default {
                  - sse_algorithm     = "AES256" -> null
                    # (1 unchanged attribute hidden)
                }
            }
        }

      ~ versioning (known after apply)
      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }

      ~ website (known after apply)
    }

  # aws_s3_bucket_acl.my_bucket_acl must be replaced
-/+ resource "aws_s3_bucket_acl" "my_bucket_acl" {
      ~ bucket                = "nautilus-cp-25362" -> (known after apply) # forces replacement
      ~ id                    = "nautilus-cp-25362,private" -> (known after apply)
        # (2 unchanged attributes hidden)

      ~ access_control_policy (known after apply)
      - access_control_policy {
          - grant {
              - permission = "FULL_CONTROL" -> null

              - grantee {
                  - display_name  = "webfile" -> null
                  - id            = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a" -> null
                  - type          = "CanonicalUser" -> null
                    # (2 unchanged attributes hidden)
                }
            }
          - owner {
              - display_name = "webfile" -> null
              - id           = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a" -> null
            }
        }
    }

Plan: 2 to add, 0 to change, 2 to destroy.
aws_s3_bucket_acl.my_bucket_acl: Destroying... [id=nautilus-cp-25362,private]
aws_s3_bucket_acl.my_bucket_acl: Destruction complete after 0s
aws_s3_bucket.my_bucket: Destroying... [id=nautilus-cp-25362]
aws_s3_bucket.my_bucket: Destruction complete after 0s
aws_s3_bucket.my_bucket: Creating...
aws_s3_bucket.my_bucket: Provisioning with 'local-exec'...
aws_s3_bucket.my_bucket (local-exec): Executing: ["/bin/sh" "-c" "aws s3 cp /tmp/nautilus.txt s3://nautilus-cp-25362/nautilus.txt"]
aws_s3_bucket.my_bucket (local-exec): Completed 27 Bytes/27 Bytes (2.2 KiB/s) with 1 file(s) remaining
aws_s3_bucket.my_bucket (local-exec): upload: ../../../tmp/nautilus.txt to s3://nautilus-cp-25362/nautilus.txt
aws_s3_bucket.my_bucket: Creation complete after 0s [id=nautilus-cp-25362]
aws_s3_bucket_acl.my_bucket_acl: Creating...
aws_s3_bucket_acl.my_bucket_acl: Creation complete after 0s [id=nautilus-cp-25362,private]

Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://nautilus-cp-25362
2026-01-10 06:44:04         27 nautilus.txt
```
