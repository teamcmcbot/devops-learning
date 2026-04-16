# Use the variable name `KKE_bucket_name` in the `outputs.tf` file to output the created bucket name.
output "KKE_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.xfusion_s3_bucket.bucket
}