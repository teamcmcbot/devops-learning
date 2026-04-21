locals {
  common_tags = {
    Environment = var.KKE_ENVIRONMENT
  }
}

# 1. Create a Kinesis Stream: Provision a stream named `xfusion-dev-stream` with `1` shard and a `24-hour` retention policy.
resource "aws_kinesis_stream" "kke_stream" {
  name             = var.KKE_KINESIS_STREAM_NAME
  shard_count      = 1
  retention_period = 24
  
  tags = merge(local.common_tags, {
    Purpose = "Stream ingestion"
  })

  provisioner "local-exec" {
    command = "echo 'Kinesis Stream ${var.KKE_KINESIS_STREAM_NAME} created' >> /home/bob/terraform/kinesis_creation.log"
  }
}

# 2. Create an S3 Bucket: Create a bucket named `xfusion-dev-8900`.
resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.KKE_S3_BUCKET_NAME
  
  tags = merge(local.common_tags, {
    Owner = "xfusion"
  })

  provisioner "local-exec" {
    command = "echo 'S3 Bucket ${var.KKE_S3_BUCKET_NAME} created' >> /home/bob/terraform/s3_creation.log"
  }
}

# Use STS for Identity Check: Retrieve and print the current AWS Account ID using `aws_caller_identity`.
data "aws_caller_identity" "current" {}
# Wrapper resource to run local-exec using data result
resource "null_resource" "sts_identity_log" {
  triggers = {
    account_id = data.aws_caller_identity.current.account_id
  }

  provisioner "local-exec" {
    command = "echo 'Logged in as account ID:${data.aws_caller_identity.current.account_id}' >> /home/bob/terraform/account_identity.log"
  }
}

