# - `kke_bucket_names`: output the names of the bucket created.
output "kke_bucket_names" {
  description = "Names of the created S3 buckets"
  value       = [for bucket in aws_s3_bucket.kke_buckets : bucket.bucket]
}