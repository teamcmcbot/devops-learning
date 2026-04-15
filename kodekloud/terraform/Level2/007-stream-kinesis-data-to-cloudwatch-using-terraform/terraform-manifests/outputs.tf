# kke_kinesis_stream_name for the Kinesis stream name.
output "kke_kinesis_stream_name" {
  value = aws_kinesis_stream.devops_kinesis_stream.name
}

# kke_kinesis_alarm_name for the CloudWatch alarm name.
output "kke_kinesis_alarm_name" {
  value = aws_cloudwatch_metric_alarm.devops_kinesis_alarm.alarm_name
}