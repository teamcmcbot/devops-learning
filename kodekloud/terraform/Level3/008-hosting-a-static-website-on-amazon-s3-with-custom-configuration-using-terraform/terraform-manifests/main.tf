# Requirement 8: Call the s3-static-site module with required input variables
# The module variables are sourced from root variables.tf and terraform.tfvars
module "s3_static_site" {
  source = "./modules/s3-static-site"

  # Requirement 8: Pass bucket_name from root variables (not hardcoded)
  bucket_name = var.bucket_name

  # Requirement 8: Pass index_document from root variables (not hardcoded)
  index_document = var.index_document

  # Requirement 9: Pass a root-based path so index.html is always resolvable
  index_html_path = "${path.root}/index.html"
}

# Output the website URL from the module
output "s3_website_url" {
  description = "The URL to access the static website hosted on S3"
  value       = module.s3_static_site.website_url
}

output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = module.s3_static_site.bucket_name
}
