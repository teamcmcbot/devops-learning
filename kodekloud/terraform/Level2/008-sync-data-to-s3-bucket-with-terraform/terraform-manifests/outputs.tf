output "new_kke_bucket_name" {
	description = "The name of the new S3 bucket"
	value       = aws_s3_bucket.kke_bucket.bucket
}

output "new_kke_bucket_acl" {
	description = "The ACL of the new S3 bucket"
	value       = aws_s3_bucket_acl.kke_bucket_acl.acl
}
