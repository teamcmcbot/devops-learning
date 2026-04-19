# Create an SNS topic named devops-sns-topic.
resource "aws_sns_topic" "devops_sns_topic" {
  name = "devops-sns-topic"
}

# 2. Create a CloudWatch alarm named devops-cpu-alarm to monitor EC2 CPU utilization with the following conditions:
# - Metric: CPUUtilization
# - Threshold: 80%
# - Actions enabled
# - Alarm actions should be triggered to the SNS topic.
resource "aws_cloudwatch_metric_alarm" "devops_cpu_alarm" {
  alarm_name          = "devops-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions       = [aws_sns_topic.devops_sns_topic.arn]
}