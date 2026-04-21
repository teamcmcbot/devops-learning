# Task 002: Building a Real-Time Data Ingestion Pipeline with Kinesis Firehose Using Terraform

The DevOps team needs to create a data ingestion pipeline using AWS Kinesis Firehose to deliver streaming data into an S3 bucket. The Firehose delivery stream must assume an IAM role using STS, deliver data to an S3 bucket, and add a newline delimiter after each record. Buffering settings should be configured to deliver data either when the buffer reaches 5 MB or after 300 seconds, whichever comes first.

You are required to complete this task using Terraform.

Task Requirements:

1. Create an S3 bucket named `nautilus-stream-bucket-22256` using Terraform.

2. Create an `IAM` role named `firehose-sts-role` and policy that allows `Kinesis Firehose` to put objects into the `S3` bucket.

3. The Firehose delivery stream must use the `IAM role` via `STS` assume role.

4. Use `depends_on` in the Firehose resource to ensure it waits for the IAM role policy attachment.

5. Create a Firehose delivery stream named `nautilus-firehose-stream` to deliver data to the S3 bucket.

6. Configure buffering with size `5 MB` and interval `300` seconds.

7. Enable record processing by setting the `Delimiter` parameter to \n to append a newline after each record.

8. Create `main.tf` file to create a S3 bucket,IAM role and Firehose delivery stream.

9. Use `variables.tf` file with the following variables:

- `KKE_S3_BUCKET_NAME`: name of the bucket.
- `KKE_FIREHOSE_STREAM_NAME`: name of the firehose stream.
- `KKE_FIREHOSE_ROLE_NAME` : name of the firehose role

10. Use `outputs.tf` file to output the following:

- `kke_firehose_stream_name`: name of the firehose stream created.
- `kke_s3_bucket_name`: name of the bucket created.
- `kke_firehose_role_arn`: arn of the created firehose role.

11. Send test data to the `Firehose stream` and verify that each record in the `S3` files ends with a newline character.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.kke_firehose_policy will be created
  + resource "aws_iam_policy" "kke_firehose_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy for Kinesis Firehose to put objects into S3 bucket"
      + id               = (known after apply)
      + name             = "firehose-sts-role-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # aws_iam_role.kke_firehose_role will be created
  + resource "aws_iam_role" "kke_firehose_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "firehose.amazonaws.com"
                        }
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
      + name                  = "firehose-sts-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.kke_firehose_role_attachment will be created
  + resource "aws_iam_role_policy_attachment" "kke_firehose_role_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "firehose-sts-role"
    }

  # aws_kinesis_firehose_delivery_stream.kke_firehose_stream will be created
  + resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
      + arn            = (known after apply)
      + destination    = "extended_s3"
      + destination_id = (known after apply)
      + id             = (known after apply)
      + name           = "nautilus-firehose-stream"
      + tags_all       = (known after apply)
      + version_id     = (known after apply)

      + extended_s3_configuration {
          + bucket_arn         = (known after apply)
          + buffering_interval = 300
          + buffering_size     = 5
          + compression_format = "UNCOMPRESSED"
          + custom_time_zone   = "UTC"
          + role_arn           = (known after apply)
          + s3_backup_mode     = "Disabled"

          + cloudwatch_logging_options (known after apply)

          + processing_configuration {
              + enabled = true

              + processors {
                  + type = "AppendDelimiterToRecord"

                  + parameters {
                      + parameter_name  = "Delimiter"
                      + parameter_value = <<-EOT
                            
                        EOT
                    }
                }
            }
        }
    }

  # aws_s3_bucket.kke_s3_bucket will be created
  + resource "aws_s3_bucket" "kke_s3_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "nautilus-stream-bucket-22256"
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

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_firehose_role_arn    = (known after apply)
  + kke_firehose_stream_name = "nautilus-firehose-stream"
  + kke_s3_bucket_name       = "nautilus-stream-bucket-22256"
aws_iam_role.kke_firehose_role: Creating...
aws_s3_bucket.kke_s3_bucket: Creating...
aws_iam_role.kke_firehose_role: Creation complete after 0s [id=firehose-sts-role]
aws_s3_bucket.kke_s3_bucket: Creation complete after 0s [id=nautilus-stream-bucket-22256]
aws_iam_policy.kke_firehose_policy: Creating...
aws_iam_policy.kke_firehose_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/firehose-sts-role-policy]
aws_iam_role_policy_attachment.kke_firehose_role_attachment: Creating...
aws_iam_role_policy_attachment.kke_firehose_role_attachment: Creation complete after 0s [id=firehose-sts-role-20260421072531173800000001]
aws_kinesis_firehose_delivery_stream.kke_firehose_stream: Creating...
aws_kinesis_firehose_delivery_stream.kke_firehose_stream: Creation complete after 0s [id=arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose-stream]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

kke_firehose_role_arn = "arn:aws:iam::000000000000:role/firehose-sts-role"
kke_firehose_stream_name = "nautilus-firehose-stream"
kke_s3_bucket_name = "nautilus-stream-bucket-22256"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_iam_policy.kke_firehose_policy:
resource "aws_iam_policy" "kke_firehose_policy" {
    arn              = "arn:aws:iam::000000000000:policy/firehose-sts-role-policy"
    attachment_count = 0
    description      = "Policy for Kinesis Firehose to put objects into S3 bucket"
    id               = "arn:aws:iam::000000000000:policy/firehose-sts-role-policy"
    name             = "firehose-sts-role-policy"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "s3:PutObject",
                    ]
                    Effect   = "Allow"
                    Resource = "arn:aws:s3:::nautilus-stream-bucket-22256/*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "AKY9RU0J3FU46SAS0I4LB"
    tags_all         = {}
}

# aws_iam_role.kke_firehose_role:
resource "aws_iam_role" "kke_firehose_role" {
    arn                   = "arn:aws:iam::000000000000:role/firehose-sts-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "firehose.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-21T07:25:30Z"
    description           = null
    force_detach_policies = false
    id                    = "firehose-sts-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "firehose-sts-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAGYSCQTCIY"
}

# aws_iam_role_policy_attachment.kke_firehose_role_attachment:
resource "aws_iam_role_policy_attachment" "kke_firehose_role_attachment" {
    id         = "firehose-sts-role-20260421072531173800000001"
    policy_arn = "arn:aws:iam::000000000000:policy/firehose-sts-role-policy"
    role       = "firehose-sts-role"
}

# aws_kinesis_firehose_delivery_stream.kke_firehose_stream:
resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
    arn            = "arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose-stream"
    destination    = "extended_s3"
    destination_id = "88d2839e"
    id             = "arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose-stream"
    name           = "nautilus-firehose-stream"
    tags_all       = {}
    version_id     = "1"

    extended_s3_configuration {
        bucket_arn          = "arn:aws:s3:::nautilus-stream-bucket-22256"
        buffering_interval  = 300
        buffering_size      = 5
        compression_format  = "UNCOMPRESSED"
        custom_time_zone    = "UTC"
        error_output_prefix = null
        file_extension      = null
        kms_key_arn         = null
        prefix              = null
        role_arn            = "arn:aws:iam::000000000000:role/firehose-sts-role"
        s3_backup_mode      = "Disabled"

        processing_configuration {
            enabled = true

            processors {
                type = "AppendDelimiterToRecord"

                parameters {
                    parameter_name  = "Delimiter"
                    parameter_value = <<-EOT
                        
                    EOT
                }
            }
        }
    }

    server_side_encryption {
        enabled  = false
        key_arn  = null
        key_type = "AWS_OWNED_CMK"
    }
}

# aws_s3_bucket.kke_s3_bucket:
resource "aws_s3_bucket" "kke_s3_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::nautilus-stream-bucket-22256"
    bucket                      = "nautilus-stream-bucket-22256"
    bucket_domain_name          = "nautilus-stream-bucket-22256.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "nautilus-stream-bucket-22256.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "nautilus-stream-bucket-22256"
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

kke_firehose_role_arn = "arn:aws:iam::000000000000:role/firehose-sts-role"
kke_firehose_stream_name = "nautilus-firehose-stream"
kke_s3_bucket_name = "nautilus-stream-bucket-22256"
```

## Test

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2026-04-21 07:25:31 nautilus-stream-bucket-22256

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://nautilus-stream-bucket-22256 --recursive
```

### Put Record
```bash
aws firehose put-record-batch \
  --delivery-stream-name nautilus-firehose-stream \
  --records '[
    {"Data":"first"},
    {"Data":"second"},
    {"Data":"third"}
  ]'

bob@iac-server ~/terraform via 💠 default ➜  aws firehose put-record-batch \
  --delivery-stream-name nautilus-firehose-stream \
  --records '[
    {"Data":"first"},
    {"Data":"second"},
    {"Data":"third"}
  ]'
{
    "FailedPutCount": 0,
    "RequestResponses": [
        {
            "RecordId": "26240bac-65ca-49c5-8457-050ac43cc370"
        },
        {
            "RecordId": "d3a723df-e054-4ed1-a2fd-ae9b77fb7c6d"
        },
        {
            "RecordId": "b06848cf-3c81-4dd9-ba53-a2630893c635"
        }
    ]
}

```

### Check S3

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://nautilus-stream-bucket-22256 --recursive
2026-04-21 07:28:10         16 2026/04/21/07/nautilus-firehose-stream-2026-04-21-07-28-10-81539d80-cecd-420b-9024-70e18d7da6c5
```

### Verify Newline Delimiter

Download one of the objects and check that each record ends with a newline (0a in hex):

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 cp s3://nautilus-stream-bucket-22256/2026/04/21/07/nautilus-firehose-stream-2026-04-21-07-28-10-81539d80-cecd-420b-9024-70e18d7da6c5 - | od -An -t x1 -c
  66  69  72  73  74  73  65  63  6f  6e  64  74  68  69  72  64
   f   i   r   s   t   s   e   c   o   n   d   t   h   i   r   d

```

