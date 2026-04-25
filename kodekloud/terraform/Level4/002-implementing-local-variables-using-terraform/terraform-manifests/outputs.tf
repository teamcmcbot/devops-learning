# - `kke_cloudwatch_alarm_name`: name of the alarm created.
output "kke_cloudwatch_alarm_name" {
  description = "Name of the CloudWatch alarm created."
  value       = aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm.alarm_name
}

# - `kke_dynamodb_table_name`: name of the table created.
output "kke_dynamodb_table_name" {
  description = "Name of the DynamoDB table created."
  value       = aws_dynamodb_table.datacenter_dynamodb_events.name
}

# - `kke_iam_role_arn`: ARN of the role created.
output "kke_iam_role_arn" {
  description = "ARN of the IAM role created."
  value       = aws_iam_role.datacenter_iam_role.arn
}

# - `kke_sns_topic_arn`: ARN of the SNS topic created.
output "kke_sns_topic_arn" {
  description = "ARN of the SNS topic created."
  value       = aws_sns_topic.datacenter_sns_topic.arn
}

# - `kke_sqs_queue_url`: URL of the SQS queue created.
output "kke_sqs_queue_url" {
  description = "URL of the SQS queue created."
  value       = aws_sqs_queue.datacenter_sqs_queue.url
}