# `KKE_sns_topic_name` for the SNS topic name.
output "KKE_sns_topic_name" {
  description = "Name of the SNS topic created"
  value       = aws_sns_topic.devops_sns_topic.name
}
# `KKE_cloudwatch_alarm_name` for the CloudWatch alarm name.
output "KKE_cloudwatch_alarm_name" {
  description = "Name of the CloudWatch alarm created"
  value       = aws_cloudwatch_metric_alarm.devops_cpu_alarm.alarm_name
}