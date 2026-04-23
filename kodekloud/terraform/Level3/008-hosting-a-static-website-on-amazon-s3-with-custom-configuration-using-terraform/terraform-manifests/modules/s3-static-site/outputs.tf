# Requirement 5: Output the S3 static website URL
# Requirement 6: Website URL format - http://aws:4566/<bucketname>/index.html
output "website_url" {
  description = "The S3 static website URL"
  value       = "http://aws:4566/${aws_s3_bucket.static_site.id}/index.html"
}

# Additional useful output: bucket endpoint
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_site.id
}

output "bucket_endpoint" {
  description = "The S3 bucket endpoint"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}
