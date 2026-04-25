# - `KKE_AWS_REGION`: AWS region used.
variable "KKE_AWS_REGION" {
  description = "AWS region used."
  type        = string
  default     = "us-east-1"

  # - Restrict allowed `AWS regions` to only `us-east-1` (with error message).
  validation {
    condition     = contains(["us-east-1"], var.KKE_AWS_REGION)
    error_message = "Only us-east-1 region is allowed."
  }
}

# - `KKE_QUEUE_DEPTH_THRESHOLD`: CloudWatch alarm threshold for queue depth (default=50).
variable "KKE_QUEUE_DEPTH_THRESHOLD" {
  description = "CloudWatch alarm threshold for queue depth."
  type        = number
  default     = 50
  # - Ensure the `SNS queue` depth threshold is between `1` and `1000` (with the error message).
  validation {
    condition     = var.KKE_QUEUE_DEPTH_THRESHOLD >= 1 && var.KKE_QUEUE_DEPTH_THRESHOLD <= 1000
    error_message = "Queue depth threshold must be between 1 and 1000."
  }
}
# - `KKE_IAM_ACTIONS`: IAM actions to allow in dynamic policy.
variable "KKE_IAM_ACTIONS" {
  description = "IAM actions to allow in dynamic policy."
  type        = list(string)
  default     = ["sqs:ReceiveMessage", "dynamodb:PutItem", "sns:Publish"]
}