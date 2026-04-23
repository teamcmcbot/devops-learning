# Requirement 4: Define variables for bucket configuration without hardcoding
# bucket_name is required (no default) - must be explicitly provided by module caller
variable "bucket_name" {
  description = "The name of the S3 bucket to be created for hosting the static website."
  type        = string
}

# Requirement 4: index_document variable with standard default value
variable "index_document" {
  description = "The name of the index document for the static website."
  type        = string
  default     = "index.html"
}

# Requirement 9: Variable for the path to the index.html file to upload
variable "index_html_path" {
  description = "Path to the index.html file to upload to the S3 bucket"
  type        = string
  default     = "index.html"
}