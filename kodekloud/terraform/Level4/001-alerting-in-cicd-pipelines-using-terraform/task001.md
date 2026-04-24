# Task 001: Alerting in CI/CD Pipelines Using Terraform

The Nautilus DevOps team has been tasked to build a real-time data pipeline on AWS. The pipeline must collect streaming data, stage it in S3, monitor delivery failures, and alert via email. Your task is to implement this end-to-end using Terraform.

Pipeline Requirements:

1. Kinesis Firehose:

- Create a delivery stream named `nautilus-firehose`.
- It should deliver data to an S3 bucket as a staging area.

2. S3 Bucket:

- Create a bucket named `nautilus-staging-4044` (value to come from variables).
- Set `private` ACL and allow Firehose to write objects into it.

3. IAM Role and Policy:

- Create a role `nautilus-firehose-role` and a policy `nautilus-firehose-policy` with least privilege to allow Firehose to write to the staging bucket.

4. CloudWatch Alarm:

- Create a cloudwatch Alarm named `nautilus-firehose-failures`.
- Monitor the Firehose delivery failures metric (`DeliveryToS3.Failures`) and trigger when failures occur.

5. SNS Topic:

- Create a topic `nautilus-alert-topic` and link the CloudWatch alarm to it.

6. SES Email Identity:

- Create an SES email identity named `nautilus@example.com` and verify an SES email identity using an email address provided in the variables.

7. SNS Subscription:

Subscribe the verified SES email identity to the SNS topic to receive notifications.

8. Use `main.tf` file to define all AWS resources and to ensure a clean and modular setup.

9. Use `variables.tf` file with the following variables:

- `KKE_STAGING_BUCKET_NAME`: Name of the S3 bucket for staging data.
- `KKE_FIREHOSE_ROLE_NAME`: Name of the IAM role for the Firehose delivery stream.
- `KKE_FIREHOSE_POLICY_NAME`: Name of the IAM policy for the Firehose delivery stream.
- `KKE_FIREHOSE_NAME`: Name of the Kinesis Firehose delivery stream.
- `KKE_SNS_TOPIC_NAME`: Name of the SNS topic for alerts.
- `KKE_CLOUDWATCH_ALARM_NAME`: Name of the CloudWatch alarm to monitor Firehose delivery failures.
- `KKE_ALERT_EMAIL`: Email address to receive SNS alerts through SES.

10. Use `terraform.tfvars` to input the value of the variables used in the variables.tf.

11. Use `outputs.tf` file to output the following:

- `kke_staging_bucket_name`:name of the bucket used.
- `kke_firehose_name`:name of the firehose delivery stream used.
- `kke_sns_topic_name`:name of the sns topic used.
- `kke_cloudwatch_alarm_name`:name of the cloudwatch used.
- `kke_ses_identity`:name of the ses identity used.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.kke_firehose_failures_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "kke_firehose_failures_alarm" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_name                            = "nautilus-firehose-failures"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "DeliveryToS3.Failures"
      + namespace                             = "AWS/Firehose"
      + period                                = 300
      + statistic                             = "Sum"
      + tags_all                              = (known after apply)
      + threshold                             = 1
      + treat_missing_data                    = "missing"
    }

  # aws_iam_policy.kke_firehose_policy will be created
  + resource "aws_iam_policy" "kke_firehose_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy for Kinesis Firehose to put objects into S3 bucket"
      + id               = (known after apply)
      + name             = "nautilus-firehose-policy"
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
      + name                  = "nautilus-firehose-role"
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
      + role       = "nautilus-firehose-role"
    }

  # aws_kinesis_firehose_delivery_stream.kke_firehose_stream will be created
  + resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
      + arn            = (known after apply)
      + destination    = "extended_s3"
      + destination_id = (known after apply)
      + id             = (known after apply)
      + name           = "nautilus-firehose"
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
        }
    }

  # aws_s3_bucket.kke_staging_bucket will be created
  + resource "aws_s3_bucket" "kke_staging_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "nautilus-staging-4044"
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

  # aws_s3_bucket_acl.kke_staging_bucket will be created
  + resource "aws_s3_bucket_acl" "kke_staging_bucket" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)

      + access_control_policy (known after apply)
    }

  # aws_s3_bucket_ownership_controls.kke_staging_bucket_ownership will be created
  + resource "aws_s3_bucket_ownership_controls" "kke_staging_bucket_ownership" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerPreferred"
        }
    }

  # aws_ses_email_identity.kke_ses_identity will be created
  + resource "aws_ses_email_identity" "kke_ses_identity" {
      + arn   = (known after apply)
      + email = "nautilus@example.com"
      + id    = (known after apply)
    }

  # aws_sns_topic.nautilus_sns_topic will be created
  + resource "aws_sns_topic" "nautilus_sns_topic" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "nautilus-alert-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

  # aws_sns_topic_subscription.kke_sns_subscription will be created
  + resource "aws_sns_topic_subscription" "kke_sns_subscription" {
      + arn                             = (known after apply)
      + confirmation_timeout_in_minutes = 1
      + confirmation_was_authenticated  = (known after apply)
      + endpoint                        = "nautilus@example.com"
      + endpoint_auto_confirms          = false
      + filter_policy_scope             = (known after apply)
      + id                              = (known after apply)
      + owner_id                        = (known after apply)
      + pending_confirmation            = (known after apply)
      + protocol                        = "email"
      + raw_message_delivery            = false
      + topic_arn                       = (known after apply)
    }

Plan: 11 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_cloudwatch_alarm_name = "nautilus-firehose-failures"
  + kke_firehose_name         = "nautilus-firehose"
  + kke_ses_identity          = "nautilus@example.com"
  + kke_sns_topic_name        = "nautilus-alert-topic"
  + kke_staging_bucket_name   = "nautilus-staging-4044"
aws_ses_email_identity.kke_ses_identity: Creating...
aws_iam_role.kke_firehose_role: Creating...
aws_sns_topic.nautilus_sns_topic: Creating...
aws_s3_bucket.kke_staging_bucket: Creating...
aws_iam_role.kke_firehose_role: Creation complete after 1s [id=nautilus-firehose-role]
aws_ses_email_identity.kke_ses_identity: Creation complete after 1s [id=nautilus@example.com]
aws_sns_topic.nautilus_sns_topic: Creation complete after 2s [id=arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic]
aws_sns_topic_subscription.kke_sns_subscription: Creating...
aws_cloudwatch_metric_alarm.kke_firehose_failures_alarm: Creating...
aws_sns_topic_subscription.kke_sns_subscription: Creation complete after 0s [id=arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic:88489740-7eb1-4c0b-95b5-d595c382e9ba]
aws_s3_bucket.kke_staging_bucket: Creation complete after 2s [id=nautilus-staging-4044]
aws_s3_bucket_ownership_controls.kke_staging_bucket_ownership: Creating...
aws_iam_policy.kke_firehose_policy: Creating...
aws_s3_bucket_ownership_controls.kke_staging_bucket_ownership: Creation complete after 0s [id=nautilus-staging-4044]
aws_s3_bucket_acl.kke_staging_bucket: Creating...
aws_iam_policy.kke_firehose_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/nautilus-firehose-policy]
aws_iam_role_policy_attachment.kke_firehose_role_attachment: Creating...
aws_iam_role_policy_attachment.kke_firehose_role_attachment: Creation complete after 0s [id=nautilus-firehose-role-20260424065637679100000001]
aws_s3_bucket_acl.kke_staging_bucket: Creation complete after 0s [id=nautilus-staging-4044,private]
aws_kinesis_firehose_delivery_stream.kke_firehose_stream: Creating...
aws_kinesis_firehose_delivery_stream.kke_firehose_stream: Creation complete after 0s [id=arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose]
aws_cloudwatch_metric_alarm.kke_firehose_failures_alarm: Creation complete after 0s [id=nautilus-firehose-failures]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

kke_cloudwatch_alarm_name = "nautilus-firehose-failures"
kke_firehose_name = "nautilus-firehose"
kke_ses_identity = "nautilus@example.com"
kke_sns_topic_name = "nautilus-alert-topic"
kke_staging_bucket_name = "nautilus-staging-4044"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.kke_firehose_failures_alarm:
resource "aws_cloudwatch_metric_alarm" "kke_firehose_failures_alarm" {
    actions_enabled                       = true
    alarm_actions                         = [
        "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic",
    ]
    alarm_description                     = null
    alarm_name                            = "nautilus-firehose-failures"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:nautilus-firehose-failures"
    comparison_operator                   = "GreaterThanOrEqualToThreshold"
    datapoints_to_alarm                   = 0
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "nautilus-firehose-failures"
    metric_name                           = "DeliveryToS3.Failures"
    namespace                             = "AWS/Firehose"
    period                                = 300
    statistic                             = "Sum"
    tags_all                              = {}
    threshold                             = 1
    threshold_metric_id                   = null
    treat_missing_data                    = "missing"
    unit                                  = null
}

# aws_iam_policy.kke_firehose_policy:
resource "aws_iam_policy" "kke_firehose_policy" {
    arn              = "arn:aws:iam::000000000000:policy/nautilus-firehose-policy"
    attachment_count = 0
    description      = "Policy for Kinesis Firehose to put objects into S3 bucket"
    id               = "arn:aws:iam::000000000000:policy/nautilus-firehose-policy"
    name             = "nautilus-firehose-policy"
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
                    Resource = "arn:aws:s3:::nautilus-staging-4044/*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "A5TH2SDDELW362LTUGVTY"
    tags_all         = {}
}

# aws_iam_role.kke_firehose_role:
resource "aws_iam_role" "kke_firehose_role" {
    arn                   = "arn:aws:iam::000000000000:role/nautilus-firehose-role"
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
    create_date           = "2026-04-24T06:56:37Z"
    description           = null
    force_detach_policies = false
    id                    = "nautilus-firehose-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "nautilus-firehose-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAOAJJMPKQQ"
}

# aws_iam_role_policy_attachment.kke_firehose_role_attachment:
resource "aws_iam_role_policy_attachment" "kke_firehose_role_attachment" {
    id         = "nautilus-firehose-role-20260424065637679100000001"
    policy_arn = "arn:aws:iam::000000000000:policy/nautilus-firehose-policy"
    role       = "nautilus-firehose-role"
}

# aws_kinesis_firehose_delivery_stream.kke_firehose_stream:
resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
    arn            = "arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose"
    destination    = "extended_s3"
    destination_id = "02856fec"
    id             = "arn:aws:firehose:us-east-1:000000000000:deliverystream/nautilus-firehose"
    name           = "nautilus-firehose"
    tags_all       = {}
    version_id     = "1"

    extended_s3_configuration {
        bucket_arn          = "arn:aws:s3:::nautilus-staging-4044"
        buffering_interval  = 300
        buffering_size      = 5
        compression_format  = "UNCOMPRESSED"
        custom_time_zone    = "UTC"
        error_output_prefix = null
        file_extension      = null
        kms_key_arn         = null
        prefix              = null
        role_arn            = "arn:aws:iam::000000000000:role/nautilus-firehose-role"
        s3_backup_mode      = "Disabled"

        processing_configuration {
            enabled = false
        }
    }

    server_side_encryption {
        enabled  = false
        key_arn  = null
        key_type = "AWS_OWNED_CMK"
    }
}

# aws_s3_bucket.kke_staging_bucket:
resource "aws_s3_bucket" "kke_staging_bucket" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::nautilus-staging-4044"
    bucket                      = "nautilus-staging-4044"
    bucket_domain_name          = "nautilus-staging-4044.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "nautilus-staging-4044.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "nautilus-staging-4044"
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

# aws_s3_bucket_acl.kke_staging_bucket:
resource "aws_s3_bucket_acl" "kke_staging_bucket" {
    acl                   = "private"
    bucket                = "nautilus-staging-4044"
    expected_bucket_owner = null
    id                    = "nautilus-staging-4044,private"

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

# aws_s3_bucket_ownership_controls.kke_staging_bucket_ownership:
resource "aws_s3_bucket_ownership_controls" "kke_staging_bucket_ownership" {
    bucket = "nautilus-staging-4044"
    id     = "nautilus-staging-4044"

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# aws_ses_email_identity.kke_ses_identity:
resource "aws_ses_email_identity" "kke_ses_identity" {
    arn   = "arn:aws:ses:us-east-1::identity/nautilus@example.com"
    email = "nautilus@example.com"
    id    = "nautilus@example.com"
}

# aws_sns_topic.nautilus_sns_topic:
resource "aws_sns_topic" "nautilus_sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic"
    beginning_archive_time                   = null
    content_based_deduplication              = false
    delivery_policy                          = null
    display_name                             = null
    fifo_topic                               = false
    firehose_failure_feedback_role_arn       = null
    firehose_success_feedback_role_arn       = null
    firehose_success_feedback_sample_rate    = 0
    http_failure_feedback_role_arn           = null
    http_success_feedback_role_arn           = null
    http_success_feedback_sample_rate        = 0
    id                                       = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "nautilus-alert-topic"
    name_prefix                              = null
    owner                                    = "000000000000"
    policy                                   = jsonencode(
        {
            Id        = "__default_policy_ID"
            Statement = [
                {
                    Action    = [
                        "SNS:GetTopicAttributes",
                        "SNS:SetTopicAttributes",
                        "SNS:AddPermission",
                        "SNS:RemovePermission",
                        "SNS:DeleteTopic",
                        "SNS:Subscribe",
                        "SNS:ListSubscriptionsByTopic",
                        "SNS:Publish",
                    ]
                    Condition = {
                        StringEquals = {
                            "AWS:SourceOwner" = "000000000000"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        AWS = "*"
                    }
                    Resource  = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic"
                    Sid       = "__default_statement_ID"
                },
            ]
            Version   = "2008-10-17"
        }
    )
    signature_version                        = 0
    sqs_failure_feedback_role_arn            = null
    sqs_success_feedback_role_arn            = null
    sqs_success_feedback_sample_rate         = 0
    tags_all                                 = {}
    tracing_config                           = null
}

# aws_sns_topic_subscription.kke_sns_subscription:
resource "aws_sns_topic_subscription" "kke_sns_subscription" {
    arn                             = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic:88489740-7eb1-4c0b-95b5-d595c382e9ba"
    confirmation_timeout_in_minutes = 1
    confirmation_was_authenticated  = false
    delivery_policy                 = null
    endpoint                        = "nautilus@example.com"
    endpoint_auto_confirms          = false
    filter_policy                   = null
    filter_policy_scope             = null
    id                              = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic:88489740-7eb1-4c0b-95b5-d595c382e9ba"
    owner_id                        = "000000000000"
    pending_confirmation            = true
    protocol                        = "email"
    raw_message_delivery            = false
    redrive_policy                  = null
    replay_policy                   = null
    subscription_role_arn           = null
    topic_arn                       = "arn:aws:sns:us-east-1:000000000000:nautilus-alert-topic"
}


Outputs:

kke_cloudwatch_alarm_name = "nautilus-firehose-failures"
kke_firehose_name = "nautilus-firehose"
kke_ses_identity = "nautilus@example.com"
kke_sns_topic_name = "nautilus-alert-topic"
kke_staging_bucket_name = "nautilus-staging-4044"
```