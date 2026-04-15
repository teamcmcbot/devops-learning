# Task 007: Stream Kinesis Data to CloudWatch Using Terraform

The monitoring team wants to improve observability into the streaming infrastructure. Your task is to implement a solution using Amazon Kinesis and CloudWatch. The team wants to ensure that if write throughput exceeds provisioned limits, an alert is triggered immediately.

As a member of the Nautilus DevOps Team, perform the following tasks using Terraform:

1. Create a Kinesis Data Stream: Name the stream `devops-kinesis-stream ` with a shard count of 1.

2. Enable Monitoring: Enable shard-level metrics for the stream to track ingestion and throughput errors.

3. Create a CloudWatch Alarm: Name the alarm `devops-kinesis-alarm` and monitor the `WriteProvisionedThroughputExceeded` metric. The alarm should trigger if the metric exceeds a threshold of 1.

4. Ensure Alerting: Configure the CloudWatch alarm to detect write throughput issues exceeding provisioned limits.

5. Create the `main.tf` file (do not create a separate .tf file) to provision the Kinesis stream, CloudWatch alarm, and ensure alerting.

6. Create the `outputs.tf` file with the following variable names to output:

- kke_kinesis_stream_name for the Kinesis stream name.
- kke_kinesis_alarm_name for the CloudWatch alarm name.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.devops_kinesis_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "devops_kinesis_alarm" {
      + actions_enabled                       = true
      + alarm_name                            = "devops-kinesis-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + datapoints_to_alarm                   = 1
      + dimensions                            = {
          + "StreamName" = "devops-kinesis-stream"
        }
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "WriteProvisionedThroughputExceeded"
      + namespace                             = "AWS/Kinesis"
      + period                                = 60
      + statistic                             = "Sum"
      + tags_all                              = (known after apply)
      + threshold                             = 1
      + treat_missing_data                    = "notBreaching"
    }

  # aws_kinesis_stream.devops_kinesis_stream will be created
  + resource "aws_kinesis_stream" "devops_kinesis_stream" {
      + arn                       = (known after apply)
      + encryption_type           = "NONE"
      + enforce_consumer_deletion = false
      + id                        = (known after apply)
      + name                      = "devops-kinesis-stream"
      + retention_period          = 24
      + shard_count               = 1
      + shard_level_metrics       = [
          + "IncomingBytes",
          + "IncomingRecords",
          + "WriteProvisionedThroughputExceeded",
        ]
      + tags                      = {
          + "Name" = "devops-kinesis-stream"
        }
      + tags_all                  = {
          + "Name" = "devops-kinesis-stream"
        }

      + stream_mode_details {
          + stream_mode = "PROVISIONED"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_kinesis_alarm_name  = "devops-kinesis-alarm"
  + kke_kinesis_stream_name = "devops-kinesis-stream"
aws_kinesis_stream.devops_kinesis_stream: Creating...
aws_kinesis_stream.devops_kinesis_stream: Still creating... [10s elapsed]
aws_kinesis_stream.devops_kinesis_stream: Still creating... [20s elapsed]
aws_kinesis_stream.devops_kinesis_stream: Still creating... [30s elapsed]
aws_kinesis_stream.devops_kinesis_stream: Creation complete after 30s [id=arn:aws:kinesis:us-east-1:000000000000:stream/devops-kinesis-stream]
aws_cloudwatch_metric_alarm.devops_kinesis_alarm: Creating...
aws_cloudwatch_metric_alarm.devops_kinesis_alarm: Creation complete after 0s [id=devops-kinesis-alarm]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kke_kinesis_alarm_name = "devops-kinesis-alarm"
kke_kinesis_stream_name = "devops-kinesis-stream"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.devops_kinesis_alarm:
resource "aws_cloudwatch_metric_alarm" "devops_kinesis_alarm" {
    actions_enabled                       = true
    alarm_description                     = null
    alarm_name                            = "devops-kinesis-alarm"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:devops-kinesis-alarm"
    comparison_operator                   = "GreaterThanThreshold"
    datapoints_to_alarm                   = 1
    dimensions                            = {
        "StreamName" = "devops-kinesis-stream"
    }
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "devops-kinesis-alarm"
    metric_name                           = "WriteProvisionedThroughputExceeded"
    namespace                             = "AWS/Kinesis"
    period                                = 60
    statistic                             = "Sum"
    tags_all                              = {}
    threshold                             = 1
    threshold_metric_id                   = null
    treat_missing_data                    = "notBreaching"
    unit                                  = null
}

# aws_kinesis_stream.devops_kinesis_stream:
resource "aws_kinesis_stream" "devops_kinesis_stream" {
    arn                       = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-kinesis-stream"
    encryption_type           = "NONE"
    enforce_consumer_deletion = false
    id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-kinesis-stream"
    kms_key_id                = null
    name                      = "devops-kinesis-stream"
    retention_period          = 24
    shard_count               = 1
    shard_level_metrics       = [
        "IncomingBytes",
        "IncomingRecords",
        "WriteProvisionedThroughputExceeded",
    ]
    tags                      = {}
    tags_all                  = {}

    stream_mode_details {
        stream_mode = "PROVISIONED"
    }
}


Outputs:

kke_kinesis_alarm_name = "devops-kinesis-alarm"
kke_kinesis_stream_name = "devops-kinesis-stream"
```