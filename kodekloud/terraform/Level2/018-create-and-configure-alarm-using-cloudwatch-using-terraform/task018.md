# Task 018: Create and Configure Alarm Using CloudWatch Using Terraform

The Nautilus DevOps team has been tasked with setting up an EC2 instance for their application. To ensure the application performs optimally, they also need to create a CloudWatch alarm to monitor the instance's CPU utilization. The alarm should trigger if the CPU utilization exceeds 90% for one consecutive 5-minute period. To send notifications, use the SNS topic named `nautilus-sns-topic`, which is already created.

1. Launch EC2 Instance: Create an EC2 instance named `nautilus-ec2` using any appropriate Ubuntu AMI (you can use AMI `ami-0c02fb55956c7d316`).

2. Create CloudWatch Alarm: Create a CloudWatch alarm named `nautilus-alarm` with the following specifications:

- Statistic: Average
- Metric: CPU Utilization
- Threshold: >= 90% for 1 consecutive 5-minute period
- Alarm Actions: Send a notification to the `nautilus-sns-topic` SNS topic.

3. Update the `main.tf` file (do not create a separate .tf file) to create a EC2 Instance and CloudWatch Alarm.

4. Create an `outputs.tf` file to output the following values:

- `KKE_instance_name` for the EC2 instance name.
- `KKE_alarm_name` for the CloudWatch alarm name.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_sns_topic.sns_topic: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.nautilus_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "nautilus_alarm" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic",
        ]
      + alarm_name                            = "nautilus-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + tags_all                              = (known after apply)
      + threshold                             = 90
      + treat_missing_data                    = "missing"
    }

  # aws_instance.nautilus_ec2 will be created
  + resource "aws_instance" "nautilus_ec2" {
      + ami                                  = "ami-0c02fb55956c7d316"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "nautilus-ec2"
        }
      + tags_all                             = {
          + "Name" = "nautilus-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_alarm_name    = "nautilus-alarm"
  + KKE_instance_name = "nautilus-ec2"
aws_cloudwatch_metric_alarm.nautilus_alarm: Creating...
aws_instance.nautilus_ec2: Creating...
aws_cloudwatch_metric_alarm.nautilus_alarm: Creation complete after 0s [id=nautilus-alarm]
aws_instance.nautilus_ec2: Still creating... [10s elapsed]
aws_instance.nautilus_ec2: Creation complete after 10s [id=i-35d1a21bc38b5f8e3]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

KKE_alarm_name = "nautilus-alarm"
KKE_instance_name = "nautilus-ec2"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.nautilus_alarm:
resource "aws_cloudwatch_metric_alarm" "nautilus_alarm" {
    actions_enabled                       = true
    alarm_actions                         = [
        "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic",
    ]
    alarm_description                     = null
    alarm_name                            = "nautilus-alarm"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:nautilus-alarm"
    comparison_operator                   = "GreaterThanOrEqualToThreshold"
    datapoints_to_alarm                   = 0
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "nautilus-alarm"
    metric_name                           = "CPUUtilization"
    namespace                             = "AWS/EC2"
    period                                = 300
    statistic                             = "Average"
    tags_all                              = {}
    threshold                             = 90
    threshold_metric_id                   = null
    treat_missing_data                    = "missing"
    unit                                  = null
}

# aws_instance.nautilus_ec2:
resource "aws_instance" "nautilus_ec2" {
    ami                                  = "ami-0c02fb55956c7d316"
    arn                                  = "arn:aws:ec2:us-east-1::instance/i-35d1a21bc38b5f8e3"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-35d1a21bc38b5f8e3"
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = null
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-d8cbe011b396ddf96"
    private_dns                          = "ip-10-114-94-222.ec2.internal"
    private_ip                           = "10.114.94.222"
    public_dns                           = "ec2-54-214-254-166.compute-1.amazonaws.com"
    public_ip                            = "54.214.254.166"
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-2586278a4390e4832"
    tags                                 = {
        "Name" = "nautilus-ec2"
    }
    tags_all                             = {
        "Name" = "nautilus-ec2"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = []

    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        kms_key_id            = null
        tags                  = {}
        tags_all              = {}
        throughput            = 0
        volume_id             = "vol-5faa88ec841deb645"
        volume_size           = 8
        volume_type           = "gp2"
    }
}

# aws_sns_topic.sns_topic:
resource "aws_sns_topic" "sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
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
    id                                       = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "nautilus-sns-topic"
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
                    Resource  = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
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
    tags                                     = {}
    tags_all                                 = {}
    tracing_config                           = null
}


Outputs:

KKE_alarm_name = "nautilus-alarm"
KKE_instance_name = "nautilus-ec2"
```