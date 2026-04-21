# Task 004: Streaming Secure Data with Kinesis, STS, and S3 Integration Using Terraform

The Nautilus DevOps team is working on a secure cloud-native architecture using Terraform. As part of this, they need to provision streaming and storage infrastructure using only the allowed AWS services supported by LocalStack.

Your task as a DevOps engineer is to complete the following:

1. Create a Kinesis Stream: Provision a stream named `xfusion-dev-stream` with `1` shard and a `24-hour` retention policy.

2. Create an S3 Bucket: Create a bucket named `xfusion-dev-8900`.

3. Use STS for Identity Check: Retrieve and print the current AWS Account ID using `aws_caller_identity`.

4. Ensure that the resources kinesis stream and s3 bucket are tagged with following:

- Environment : `dev` (both the resources)
- Purpose : `Stream ingestion` (Kinesis Stream)
- Owner : `xfusion` (S3-bucket)

5. Add `local-exec` provisioners to output the creation messages and save them under the `/home/bob/terraform` directory. Specifically:

- When creating the `Kinesis stream`, write the following message to a file named `kinesis_creation.log`:

`"Kinesis Stream xfusion-dev-stream created"`

- When creating the `S3 bucket`, write the message to a file named `s3_creation.log`:

`"S3 Bucket xfusion-dev-8900 created"`

- When retrieving the `STS caller identity`, write the following message to a file named `account_identity.log`:

`"Logged in as account ID:<AWS account ID>"`

6. Create `main.tf` file (do not create a separate .tf file) to provision the `kinesis stream`, `s3-bucket` and retrieve the Current `AWS Account ID`.

7. Use `variables.tf` file with the following variables:

- `KKE_ENVIRONMENT`: dev
- `KKE_KINESIS_STREAM_NAME`: Name of the Kinesis Stream (non-empty)
- `KKE_S3_BUCKET_NAME`: Name of the S3 bucket.

8. Use `terraform.tfvars` to input the variable values.

9. Use `outputs.tf` to output the following:

- `kke_caller_identity_account_id`: current AWS account ID.
- `kke_kinesis_stream_name`: name of the stream created.
- `kke_s3_bucket_name`: name of the bucket created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform apply -auto-approve
data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Read complete after 0s [id=000000000000]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_kinesis_stream.kke_stream will be created
  + resource "aws_kinesis_stream" "kke_stream" {
      + arn                       = (known after apply)
      + encryption_type           = "NONE"
      + enforce_consumer_deletion = false
      + id                        = (known after apply)
      + name                      = "xfusion-dev-stream"
      + retention_period          = 24
      + shard_count               = 1
      + tags                      = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }
      + tags_all                  = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }

      + stream_mode_details (known after apply)
    }

  # aws_s3_bucket.kke_bucket will be created
  + resource "aws_s3_bucket" "kke_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "xfusion-dev-8900"
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
          + "Environment" = "dev"
          + "Owner"       = "xfusion"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Owner"       = "xfusion"
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

  # null_resource.sts_identity_log will be created
  + resource "null_resource" "sts_identity_log" {
      + id       = (known after apply)
      + triggers = {
          + "account_id" = "000000000000"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_caller_identity_account_id = "000000000000"
  + kke_kinesis_stream_name        = "xfusion-dev-stream"
  + kke_s3_bucket_name             = "xfusion-dev-8900"
null_resource.sts_identity_log: Creating...
null_resource.sts_identity_log: Provisioning with 'local-exec'...
null_resource.sts_identity_log (local-exec): Executing: ["/bin/sh" "-c" "echo 'Logged in as account ID:000000000000' >> /home/bob/terraform/account_identity.log"]
null_resource.sts_identity_log: Creation complete after 0s [id=6886145058767649493]
aws_s3_bucket.kke_bucket: Creating...
aws_kinesis_stream.kke_stream: Creating...
aws_s3_bucket.kke_bucket: Provisioning with 'local-exec'...
aws_s3_bucket.kke_bucket (local-exec): Executing: ["/bin/sh" "-c" "echo 'S3 Bucket xfusion-dev-8900 created' >> /home/bob/terraform/s3_creation.log"]
aws_s3_bucket.kke_bucket: Creation complete after 0s [id=xfusion-dev-8900]
aws_kinesis_stream.kke_stream: Still creating... [10s elapsed]
aws_kinesis_stream.kke_stream: Still creating... [20s elapsed]
aws_kinesis_stream.kke_stream: Provisioning with 'local-exec'...
aws_kinesis_stream.kke_stream (local-exec): Executing: ["/bin/sh" "-c" "echo 'Kinesis Stream xfusion-dev-stream created' >> /home/bob/terraform/kinesis_creation.log"]
aws_kinesis_stream.kke_stream: Creation complete after 20s [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_caller_identity_account_id = "000000000000"
kke_kinesis_stream_name = "xfusion-dev-stream"
kke_s3_bucket_name = "xfusion-dev-8900"

```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# data.aws_caller_identity.current:
data "aws_caller_identity" "current" {
    account_id = "000000000000"
    arn        = "arn:aws:iam::000000000000:root"
    id         = "000000000000"
    user_id    = "AKIAIOSFODNN7EXAMPLE"
}

# aws_kinesis_stream.kke_stream:
resource "aws_kinesis_stream" "kke_stream" {
    arn                       = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
    encryption_type           = "NONE"
    enforce_consumer_deletion = false
    id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
    kms_key_id                = null
    name                      = "xfusion-dev-stream"
    retention_period          = 24
    shard_count               = 1
    tags                      = {}
    tags_all                  = {}

    stream_mode_details {
        stream_mode = "PROVISIONED"
    }
}

# aws_s3_bucket.kke_bucket:
resource "aws_s3_bucket" "kke_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::xfusion-dev-8900"
    bucket                      = "xfusion-dev-8900"
    bucket_domain_name          = "xfusion-dev-8900.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "xfusion-dev-8900.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "xfusion-dev-8900"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "dev"
        "Owner"       = "xfusion"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Owner"       = "xfusion"
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

# null_resource.sts_identity_log:
resource "null_resource" "sts_identity_log" {
    id       = "6886145058767649493"
    triggers = {
        "account_id" = "000000000000"
    }
}


Outputs:

kke_caller_identity_account_id = "000000000000"
kke_kinesis_stream_name = "xfusion-dev-stream"
kke_s3_bucket_name = "xfusion-dev-8900"
```

## Oberservations

Something seems to be run after the first apply, in the plan you can see tags added for aws_kinesis_stream, however in the terraform show, you can see the tags is empty. On running terraform plan again, it detected the tag was not added, after running terraform apply a second time, only then is the tag added.

2nd: terraform plan
```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan
data.aws_caller_identity.current: Reading...
aws_kinesis_stream.kke_stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]
aws_s3_bucket.kke_bucket: Refreshing state... [id=xfusion-dev-8900]
data.aws_caller_identity.current: Read complete after 0s [id=000000000000]
null_resource.sts_identity_log: Refreshing state... [id=6886145058767649493]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_kinesis_stream.kke_stream will be updated in-place
  ~ resource "aws_kinesis_stream" "kke_stream" {
        id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
        name                      = "xfusion-dev-stream"
      ~ tags                      = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }
      ~ tags_all                  = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }
        # (7 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

2nd terraform apply:
```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_caller_identity.current: Reading...
aws_kinesis_stream.kke_stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]
aws_s3_bucket.kke_bucket: Refreshing state... [id=xfusion-dev-8900]
data.aws_caller_identity.current: Read complete after 0s [id=000000000000]
null_resource.sts_identity_log: Refreshing state... [id=6886145058767649493]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_kinesis_stream.kke_stream will be updated in-place
  ~ resource "aws_kinesis_stream" "kke_stream" {
        id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
        name                      = "xfusion-dev-stream"
      ~ tags                      = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }
      ~ tags_all                  = {
          + "Environment" = "dev"
          + "Purpose"     = "Stream ingestion"
        }
        # (7 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
aws_kinesis_stream.kke_stream: Modifying... [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]
aws_kinesis_stream.kke_stream: Modifications complete after 0s [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

kke_caller_identity_account_id = "000000000000"
kke_kinesis_stream_name = "xfusion-dev-stream"
kke_s3_bucket_name = "xfusion-dev-8900"

bob@iac-server ~/terraform via 💠 default ➜  terraform plan
data.aws_caller_identity.current: Reading...
aws_kinesis_stream.kke_stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream]
aws_s3_bucket.kke_bucket: Refreshing state... [id=xfusion-dev-8900]
data.aws_caller_identity.current: Read complete after 0s [id=000000000000]
null_resource.sts_identity_log: Refreshing state... [id=6886145058767649493]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed.

bob@iac-server ~/terraform via 💠 default ➜  terraform show
# data.aws_caller_identity.current:
data "aws_caller_identity" "current" {
    account_id = "000000000000"
    arn        = "arn:aws:iam::000000000000:root"
    id         = "000000000000"
    user_id    = "AKIAIOSFODNN7EXAMPLE"
}

# aws_kinesis_stream.kke_stream:
resource "aws_kinesis_stream" "kke_stream" {
    arn                       = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
    encryption_type           = "NONE"
    enforce_consumer_deletion = false
    id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/xfusion-dev-stream"
    kms_key_id                = null
    name                      = "xfusion-dev-stream"
    retention_period          = 24
    shard_count               = 1
    shard_level_metrics       = []
    tags                      = {
        "Environment" = "dev"
        "Purpose"     = "Stream ingestion"
    }
    tags_all                  = {
        "Environment" = "dev"
        "Purpose"     = "Stream ingestion"
    }

    stream_mode_details {
        stream_mode = "PROVISIONED"
    }
}

# aws_s3_bucket.kke_bucket:
resource "aws_s3_bucket" "kke_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::xfusion-dev-8900"
    bucket                      = "xfusion-dev-8900"
    bucket_domain_name          = "xfusion-dev-8900.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "xfusion-dev-8900.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "xfusion-dev-8900"
    object_lock_enabled         = false
    policy                      = null
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "dev"
        "Owner"       = "xfusion"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Owner"       = "xfusion"
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

# null_resource.sts_identity_log:
resource "null_resource" "sts_identity_log" {
    id       = "6886145058767649493"
    triggers = {
        "account_id" = "000000000000"
    }
}


Outputs:

kke_caller_identity_account_id = "000000000000"
kke_kinesis_stream_name = "xfusion-dev-stream"
kke_s3_bucket_name = "xfusion-dev-8900"
```