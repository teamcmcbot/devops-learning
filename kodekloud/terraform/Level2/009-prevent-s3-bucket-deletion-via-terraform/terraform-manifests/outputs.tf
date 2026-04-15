# `s3_bucket_name`: name of the created bucket.
output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.s3_bucket_with_prevent_destroy.bucket
}