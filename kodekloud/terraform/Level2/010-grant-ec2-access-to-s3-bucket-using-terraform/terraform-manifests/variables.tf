# - `KKE_BUCKET_NAME`: name of the bucket.
variable "KKE_BUCKET_NAME" {
  description = "Name of the S3 bucket to be created"
  type        = string
}

# - `KKE_POLICY_NAME`: name of the policy.
variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy to be created"
  type        = string
}

# - `KKE_ROLE_NAME`: name of the role.
variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role to be created"
  type        = string
}