# Task 018: Configure CloudWatch to Trigger SNS Alerts Using Terraform

The Nautilus DevOps team is expanding their AWS infrastructure and requires the setup of a CloudWatch alarm and SNS integration for monitoring EC2 instances. The team needs to configure an SNS topic for CloudWatch to publish notifications when an EC2 instance’s CPU utilization exceeds 80%. The alarm should trigger whenever the CPU utilization is greater than 80% and notify the SNS topic to alert the team.

1. Create an SNS topic named `devops-sns-topic`.

2. Create a CloudWatch alarm named `devops-cpu-alarm` to monitor EC2 CPU utilization with the following conditions:

- Metric: CPUUtilization
- Threshold: 80%
- Actions enabled
- Alarm actions should be triggered to the SNS topic.

3. Ensure that the SNS topic receives notifications from the CloudWatch alarm when it is triggered.

4. Update the `main.tf` file (do not create a different .tf file) to create SNS Topic and Cloudwatch Alarm.

5. Create an `outputs.tf` file to output the following values:

- `KKE_sns_topic_name` for the SNS topic name.
- `KKE_cloudwatch_alarm_name` for the CloudWatch alarm name.

## Solution

```bash
ob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.devops_cpu_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "devops_cpu_alarm" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_name                            = "devops-cpu-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + tags_all                              = (known after apply)
      + threshold                             = 80
      + treat_missing_data                    = "missing"
    }

  # aws_sns_topic.devops_sns_topic will be created
  + resource "aws_sns_topic" "devops_sns_topic" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "devops-sns-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_cloudwatch_alarm_name = "devops-cpu-alarm"
  + KKE_sns_topic_name        = "devops-sns-topic"
aws_sns_topic.devops_sns_topic: Creating...
aws_sns_topic.devops_sns_topic: Creation complete after 0s [id=arn:aws:sns:us-east-1:000000000000:devops-sns-topic]
aws_cloudwatch_metric_alarm.devops_cpu_alarm: Creating...
aws_cloudwatch_metric_alarm.devops_cpu_alarm: Creation complete after 0s [id=devops-cpu-alarm]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

KKE_cloudwatch_alarm_name = "devops-cpu-alarm"
KKE_sns_topic_name = "devops-sns-topic"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.devops_cpu_alarm:
resource "aws_cloudwatch_metric_alarm" "devops_cpu_alarm" {
    actions_enabled                       = true
    alarm_actions                         = [
        "arn:aws:sns:us-east-1:000000000000:devops-sns-topic",
    ]
    alarm_description                     = null
    alarm_name                            = "devops-cpu-alarm"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:devops-cpu-alarm"
    comparison_operator                   = "GreaterThanThreshold"
    datapoints_to_alarm                   = 0
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "devops-cpu-alarm"
    metric_name                           = "CPUUtilization"
    namespace                             = "AWS/EC2"
    period                                = 300
    statistic                             = "Average"
    tags_all                              = {}
    threshold                             = 80
    threshold_metric_id                   = null
    treat_missing_data                    = "missing"
    unit                                  = null
}

# aws_sns_topic.devops_sns_topic:
resource "aws_sns_topic" "devops_sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:devops-sns-topic"
    beginning_archive_time                   = null
    content_based_deduplication              = false
    delivery_policy                          = null
    display_name                             = null
    fifo_topic                               = false
    firehose_failure_feedback_role_arn       = null
    firehose_success_feedback_role_arn       = null
    firehose_success_feedback_sample_rate    = 0
    http_failure_feedback_role_arn           = null
    http_success_feedback_role_arn           = null
    http_success_feedback_sample_rate        = 0
    id                                       = "arn:aws:sns:us-east-1:000000000000:devops-sns-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "devops-sns-topic"
    name_prefix                              = null
    owner                                    = "000000000000"
    policy                                   = jsonencode(
        {
            Id        = "__default_policy_ID"
            Statement = [
                {
                    Action    = [
                        "SNS:GetTopicAttributes",
                        "SNS:SetTopicAttributes",
                        "SNS:AddPermission",
                        "SNS:RemovePermission",
                        "SNS:DeleteTopic",
                        "SNS:Subscribe",
                        "SNS:ListSubscriptionsByTopic",
                        "SNS:Publish",
                    ]
                    Condition = {
                        StringEquals = {
                            "AWS:SourceOwner" = "000000000000"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        AWS = "*"
                    }
                    Resource  = "arn:aws:sns:us-east-1:000000000000:devops-sns-topic"
                    Sid       = "__default_statement_ID"
                },
            ]
            Version   = "2008-10-17"
        }
    )
    signature_version                        = 0
    sqs_failure_feedback_role_arn            = null
    sqs_success_feedback_role_arn            = null
    sqs_success_feedback_sample_rate         = 0
    tags_all                                 = {}
    tracing_config                           = null
}


Outputs:

KKE_cloudwatch_alarm_name = "devops-cpu-alarm"
KKE_sns_topic_name = "devops-sns-topic"
```