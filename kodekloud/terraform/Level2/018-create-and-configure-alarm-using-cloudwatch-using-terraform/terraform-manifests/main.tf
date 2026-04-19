resource "aws_sns_topic" "sns_topic" {
  name = "nautilus-sns-topic"
}

# 1. Launch EC2 Instance: Create an EC2 instance named `nautilus-ec2` using any appropriate Ubuntu AMI (you can use AMI `ami-0c02fb55956c7d316`).
resource "aws_instance" "nautilus_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  tags = {
    Name = "nautilus-ec2"
  }
}

# 2. Create CloudWatch Alarm: Create a CloudWatch alarm named `nautilus-alarm`
resource "aws_cloudwatch_metric_alarm" "nautilus_alarm" {
  alarm_name          = "nautilus-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"

  alarm_actions       = [aws_sns_topic.sns_topic.arn]
}