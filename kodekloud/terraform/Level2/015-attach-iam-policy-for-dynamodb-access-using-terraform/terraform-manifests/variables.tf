# `KKE_TABLE_NAME`: name of the DynamoDB table
variable "KKE_TABLE_NAME" {
  description = "Name of the DynamoDB table"
  type        = string
}

# `KKE_ROLE_NAME`: name of the IAM role
variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role"
  type        = string
}

# `KKE_POLICY_NAME`: name of the IAM policy
variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy"
  type        = string
}
