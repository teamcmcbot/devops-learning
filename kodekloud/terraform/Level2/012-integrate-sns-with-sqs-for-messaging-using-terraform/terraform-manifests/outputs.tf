# The ARN of the SNS topic using the output variable kke_sns_topic_arn.
output "kke_sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.nautilus_sns_topic.arn
}

# The URL of the SQS queue using the output variable kke_sqs_queue_url.
output "kke_sqs_queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.nautilus_sqs_queue.url
}