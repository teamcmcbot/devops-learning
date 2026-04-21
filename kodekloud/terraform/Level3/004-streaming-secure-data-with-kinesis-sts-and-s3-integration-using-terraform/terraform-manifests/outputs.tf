# - `kke_caller_identity_account_id`: current AWS account ID.
output "kke_caller_identity_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# - `kke_kinesis_stream_name`: name of the stream created.
output "kke_kinesis_stream_name" {
  value = aws_kinesis_stream.kke_stream.name
}

# - `kke_s3_bucket_name`: name of the bucket created.
output "kke_s3_bucket_name" {
  value = aws_s3_bucket.kke_bucket.bucket
}