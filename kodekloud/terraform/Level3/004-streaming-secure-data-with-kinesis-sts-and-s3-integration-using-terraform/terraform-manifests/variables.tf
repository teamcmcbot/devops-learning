# - `KKE_ENVIRONMENT`: dev
variable "KKE_ENVIRONMENT" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# - `KKE_KINESIS_STREAM_NAME`: Name of the Kinesis Stream (non-empty)
variable "KKE_KINESIS_STREAM_NAME" {
  description = "Name of the Kinesis Stream"
  type        = string
  validation {
    condition     = length(var.KKE_KINESIS_STREAM_NAME) > 0
    error_message = "KKE_KINESIS_STREAM_NAME must be a non-empty string."
  }
}

# - `KKE_S3_BUCKET_NAME`: Name of the S3 bucket.
variable "KKE_S3_BUCKET_NAME" {
  description = "Name of the S3 bucket"
  type        = string
}