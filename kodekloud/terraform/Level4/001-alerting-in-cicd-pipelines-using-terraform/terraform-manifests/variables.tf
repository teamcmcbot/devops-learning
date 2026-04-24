# - `KKE_STAGING_BUCKET_NAME`: Name of the S3 bucket for staging data.
# - `KKE_FIREHOSE_ROLE_NAME`: Name of the IAM role for the Firehose delivery stream.
# - `KKE_FIREHOSE_POLICY_NAME`: Name of the IAM policy for the Firehose delivery stream.
# - `KKE_FIREHOSE_NAME`: Name of the Kinesis Firehose delivery stream.
# - `KKE_SNS_TOPIC_NAME`: Name of the SNS topic for alerts.
# - `KKE_CLOUDWATCH_ALARM_NAME`: Name of the CloudWatch alarm to monitor Firehose delivery failures.
# - `KKE_ALERT_EMAIL`: Email address to receive SNS alerts through SES.

variable "KKE_STAGING_BUCKET_NAME" {
  description = "Name of the S3 bucket for staging data."
  type        = string
}
variable "KKE_FIREHOSE_ROLE_NAME" {
  description = "Name of the IAM role for the Firehose delivery stream."
  type        = string
}
variable "KKE_FIREHOSE_POLICY_NAME" {
  description = "Name of the IAM policy for the Firehose delivery stream."
  type        = string
}
variable "KKE_FIREHOSE_NAME" {
    description = "Name of the Kinesis Firehose delivery stream."
    type        = string
}
variable "KKE_SNS_TOPIC_NAME" {
    description = "Name of the SNS topic for alerts."
    type        = string
}
variable "KKE_CLOUDWATCH_ALARM_NAME" {
    description = "Name of the CloudWatch alarm to monitor Firehose delivery failures."
    type        = string
}
variable "KKE_ALERT_EMAIL" {
    description = "Email address to receive SNS alerts through SES."
    type        = string
}