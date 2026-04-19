# - KKE_DYNAMODB_TABLE_NAME: Dynamodb table name.
variable "KKE_DYNAMODB_TABLE_NAME" {
  description = "Dynamodb table name."
  type        = string
  default     = "devops-cf-dynamodb-table"
}