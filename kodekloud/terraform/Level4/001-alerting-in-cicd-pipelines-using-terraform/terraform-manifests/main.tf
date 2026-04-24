# 2. S3 Bucket:

# - Create a bucket named `nautilus-staging-15280` (value to come from variables).
# - Set `private` ACL and allow Firehose to write objects into it.
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket" "kke_staging_bucket" {
  bucket = var.KKE_STAGING_BUCKET_NAME
}

resource "aws_s3_bucket_ownership_controls" "kke_staging_bucket_ownership" {
  bucket = aws_s3_bucket.kke_staging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kke_staging_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.kke_staging_bucket_ownership]

  bucket = aws_s3_bucket.kke_staging_bucket.id
  acl    = "private"
}


# 3. IAM Role and Policy:

# - Create a role `nautilus-firehose-role` and a policy `nautilus-firehose-policy` with least privilege to allow Firehose to write to the staging bucket.

resource "aws_iam_role" "kke_firehose_role" {
  name = var.KKE_FIREHOSE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "kke_firehose_policy" {
  name        = var.KKE_FIREHOSE_POLICY_NAME
  description = "Policy for Kinesis Firehose to put objects into S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "${aws_s3_bucket.kke_staging_bucket.arn}/*"
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "kke_firehose_role_attachment" {
  role       = aws_iam_role.kke_firehose_role.name
  policy_arn = aws_iam_policy.kke_firehose_policy.arn
}

# 1. Kinesis Firehose:

# - Create a delivery stream named `nautilus-firehose`.
# - It should deliver data to an S3 bucket as a staging area.

resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
  name        = var.KKE_FIREHOSE_NAME
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.kke_firehose_role.arn
    bucket_arn          = aws_s3_bucket.kke_staging_bucket.arn
    buffering_size      = 5
    buffering_interval  = 300
  }

  depends_on = [aws_iam_role_policy_attachment.kke_firehose_role_attachment]
}


# 4. CloudWatch Alarm:

# - Create a cloudwatch Alarm named `nautilus-firehose-failures`.
# - Monitor the Firehose delivery failures metric (`DeliveryToS3.Failures`) and trigger when failures occur.
resource "aws_cloudwatch_metric_alarm" "kke_firehose_failures_alarm" {
  alarm_name          = var.KKE_CLOUDWATCH_ALARM_NAME
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DeliveryToS3.Failures"
  namespace           = "AWS/Firehose"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  alarm_actions       = [aws_sns_topic.nautilus_sns_topic.arn]
}

# 5. SNS Topic:

# - Create a topic `nautilus-alert-topic` and link the CloudWatch alarm to it.

resource "aws_sns_topic" "nautilus_sns_topic" {
  name = var.KKE_SNS_TOPIC_NAME
}

# 6. SES Email Identity:

# - Create an SES email identity named `nautilus@example.com` and verify an SES email identity using an email address provided in the variables.

resource "aws_ses_email_identity" "kke_ses_identity" {
  email = var.KKE_ALERT_EMAIL
}

# 7. SNS Subscription:

# Subscribe the verified SES email identity to the SNS topic to receive notifications.

resource "aws_sns_topic_subscription" "kke_sns_subscription" {
  topic_arn = aws_sns_topic.nautilus_sns_topic.arn
  protocol  = "email"
  endpoint  = aws_ses_email_identity.kke_ses_identity.email
}