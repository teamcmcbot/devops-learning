# 1. Create an S3 bucket using Terraform.
resource "aws_s3_bucket" "kke_s3_bucket" {
  bucket = var.KKE_S3_BUCKET_NAME
}

# 2. Create an IAM role and policy that allows Kinesis Firehose to put objects into the S3 bucket.
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
  name        = "${var.KKE_FIREHOSE_ROLE_NAME}-policy"
  description = "Policy for Kinesis Firehose to put objects into S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "${aws_s3_bucket.kke_s3_bucket.arn}/*"
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "kke_firehose_role_attachment" {
  role       = aws_iam_role.kke_firehose_role.name
  policy_arn = aws_iam_policy.kke_firehose_policy.arn
}

# 3. The Firehose delivery stream must use the `IAM role` via `STS` assume role.
# 4. Use `depends_on` in the Firehose resource to ensure it waits for the IAM role policy attachment.
# 5. Create a Firehose delivery stream to deliver data to the S3 bucket.
# 6. Configure buffering with size `5 MB` and interval `300` seconds.
# 7. Enable record processing by setting the `Delimiter` parameter to \n to append a newline after each record.

resource "aws_kinesis_firehose_delivery_stream" "kke_firehose_stream" {
  name        = var.KKE_FIREHOSE_STREAM_NAME
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.kke_firehose_role.arn
    bucket_arn          = aws_s3_bucket.kke_s3_bucket.arn
    buffering_size      = 5
    buffering_interval  = 300
    
    processing_configuration {
      enabled = true

      processors {
        type = "AppendDelimiterToRecord"
        parameters {
          parameter_name  = "Delimiter"
          parameter_value = "\n"  
        }
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.kke_firehose_role_attachment]
}