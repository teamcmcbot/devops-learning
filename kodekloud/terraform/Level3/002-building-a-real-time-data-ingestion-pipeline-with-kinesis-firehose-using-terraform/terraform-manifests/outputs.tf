# - `kke_firehose_stream_name`: name of the firehose stream created.
output "kke_firehose_stream_name" {
  description = "Name of the Kinesis Firehose stream created"
  value       = aws_kinesis_firehose_delivery_stream.kke_firehose_stream.name
}
# - `kke_s3_bucket_name`: name of the bucket created.
output "kke_s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.kke_s3_bucket.bucket
}
# - `kke_firehose_role_arn`: arn of the created firehose role.
output "kke_firehose_role_arn" {
  description = "ARN of the IAM role created for Kinesis Firehose"
  value       = aws_iam_role.kke_firehose_role.arn
}