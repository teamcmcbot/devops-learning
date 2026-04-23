# Root level variables - allows values to be passed to the module without hardcoding
# This follows best practices for real-world Terraform projects

# Requirement 8: Define bucket_name variable to pass to module
variable "bucket_name" {
  description = "Name of the S3 bucket for hosting the static website"
  type        = string
}

# Requirement 8: Define index_document variable to pass to module
variable "index_document" {
  description = "Name of the index document for the static website"
  type        = string
  default     = "index.html"
}
