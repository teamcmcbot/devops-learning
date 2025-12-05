
# Create a CloudWatch alarm named devops-alarm.
# The alarm should monitor CPU utilization of an EC2 instance.
# Trigger the alarm when CPU utilization exceeds 80%.
# Set the evaluation period to 5 minutes.
# Use a single evaluation period.

resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name          = "devops-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization"
}

# Output arn, id, tags_all
output "cloudwatch_alarm_details" {
  value = {
    arn      = aws_cloudwatch_metric_alarm.foobar.arn
    id       = aws_cloudwatch_metric_alarm.foobar.id
    tags_all = aws_cloudwatch_metric_alarm.foobar.tags_all
  }
}
