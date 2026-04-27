variable "KKE_ENV" {
  description = "Environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "KKE_DYNAMODB_TABLE_NAME" {
  description = "Name of the DynamoDB table to create."
  type        = string
}