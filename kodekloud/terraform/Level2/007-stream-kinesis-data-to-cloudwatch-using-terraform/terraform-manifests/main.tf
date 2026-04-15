resource "aws_kinesis_stream" "devops_kinesis_stream" {
  name             = "devops-kinesis-stream"
  shard_count      = 1

  # Track ingestion and throughput errors
  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "WriteProvisionedThroughputExceeded",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  
}

# Create a CloudWatch alarm for the Kinesis stream to monitor the WriteProvisionedThroughputExceeded metric.
# https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
resource "aws_cloudwatch_metric_alarm" "devops_kinesis_alarm" {
  alarm_name          = "devops-kinesis-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "WriteProvisionedThroughputExceeded"
  namespace           = "AWS/Kinesis"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    StreamName = aws_kinesis_stream.devops_kinesis_stream.name
  }
}