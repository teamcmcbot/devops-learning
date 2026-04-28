# - `kke_sns_topic_name`: name of the SNS topic created.
output "kke_sns_topic" {
  value = aws_sns_topic.this.name
}

# `kke_sns_topic_arn`: ARN of the SNS topic created.
output "kke_sns_topic_arn" {
  value = aws_sns_topic.this.arn
}