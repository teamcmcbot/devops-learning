# `KKE_instance_name` for the EC2 instance name.
output "KKE_instance_name" {
  description = "Name of the EC2 instance created"
  value       = aws_instance.nautilus_ec2.tags["Name"]
}
# `KKE_alarm_name` for the CloudWatch alarm name.
output "KKE_alarm_name" {
  description = "Name of the CloudWatch alarm created"
  value       = aws_cloudwatch_metric_alarm.nautilus_alarm.alarm_name
}