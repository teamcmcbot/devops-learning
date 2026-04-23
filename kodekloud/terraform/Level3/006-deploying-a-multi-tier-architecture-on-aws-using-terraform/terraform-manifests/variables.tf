# - `KKE_ENVIRONMENT`: devEnvironment.
variable "KKE_ENVIRONMENT" {
  description = "Environment name"
  type        = string
}
# - `KKE_DYNAMODB_TABLE_NAME`: name of dynamodb table.
variable "KKE_DYNAMODB_TABLE_NAME" {
  description = "DynamoDB table name"
  type        = string
}
# - `KKE_SNS_TOPIC_NAME`: name of the sns topic.
variable "KKE_SNS_TOPIC_NAME" {
  description = "SNS topic name"
  type        = string
}
# - `KKE_SSM_PARAM_NAME`: name of the SSM parameter.
variable "KKE_SSM_PARAM_NAME" {
  description = "SSM parameter name"
  type        = string
}