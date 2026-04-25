# Task 002: Implementing Local Variables Using Terraform

The DevOps team is tasked with designing and implementing a production‑grade, event‑driven infrastructure entirely using Terraform. This initiative is part of our internal platform engineering efforts to standardize infrastructure as code (IaC) practices across the organization.

## Task Requirements:

1. Use a `locals` block in your Terraform configuration to define the following:

- Project name (`datacenter`).
- Environment (`dev`).
- A common name prefix by combining the project name and environment (`datacenter-dev`).
- A map of default tags (`Project`, `Environment`, `Owner`, and `Team`).
- Then, reference these locals values across all resources in your configuration to ensure consistent naming and consistent tagging.


2. Create a `SNS topic` named `project name-environment-topic`.

3. Create a `SQS queue` named `project name-environment-queue` and subscribe it to the SNS topic.

4. Use `depends_on` to ensure the SNS topic is created before subscription.

5. Create a DynamoDB table named `project name-environment-events` with primary key `event_id` (HASH key) and provisioned throughput of 5 read capacity units and 5 write capacity units.

6. Create an IAM Role named `project name-environment-role` with a dynamic inline policy allowing:
  - `sqs:ReceiveMessage`
  - `dynamodb:PutItem`
  - `sns:Publish`

7. Use validation blocks in `variables.tf` to:

- Restrict allowed `AWS regions` to only `us-east-1` (with error message).
- Ensure the `SNS queue` depth threshold is between `1` and `1000` (with the error message).

8. Use `main.tf` file to organize all AWS resources in a clean, modular, and easily maintainable Terraform configuration.

9. Create a `CloudWatch alarm` named `project name-environment-alarm` for the SQS queue when it contains more than 50 messages (threshold configurable).

10. Use `variables.tf` file with the following variables:

- `KKE_AWS_REGION`: AWS region used.
- `KKE_QUEUE_DEPTH_THRESHOLD`: CloudWatch alarm threshold for queue depth (default=50).
- `KKE_IAM_ACTIONS`: IAM actions to allow in dynamic policy.

11. Use `outputs.tf` file to output the following:

- `kke_cloudwatch_alarm_name`: name of the alarm created.
- `kke_dynamodb_table_name`: name of the table created.
- `kke_iam_role_arn`: ARN of the role created.
- `kke_sns_topic_arn`: ARN of the SNS topic created.
- `kke_sqs_queue_url`: URL of the SQS queue created.

## Solution 

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
      + actions_enabled                       = true
      + alarm_name                            = "datacenter-dev-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = {
          + "QueueName" = "datacenter-dev-queue"
        }
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "ApproximateNumberOfMessagesVisible"
      + namespace                             = "AWS/SQS"
      + period                                = 300
      + statistic                             = "Average"
      + tags                                  = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tags_all                              = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + threshold                             = 50
      + treat_missing_data                    = "missing"
    }

  # aws_dynamodb_table.datacenter_dynamodb_events will be created
  + resource "aws_dynamodb_table" "datacenter_dynamodb_events" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "event_id"
      + id               = (known after apply)
      + name             = "datacenter-dev-events"
      + read_capacity    = 5
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-events"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-events"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + write_capacity   = 5

      + attribute {
          + name = "event_id"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_iam_role.datacenter_iam_role will be created
  + resource "aws_iam_role" "datacenter_iam_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "datacenter-dev-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-role"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-role"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy.datacenter_iam_role_policy will be created
  + resource "aws_iam_role_policy" "datacenter_iam_role_policy" {
      + id          = (known after apply)
      + name        = "datacenter-dev-policy"
      + name_prefix = (known after apply)
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "sqs:ReceiveMessage",
                          + "dynamodb:PutItem",
                          + "sns:Publish",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + role        = (known after apply)
    }

  # aws_sns_topic.datacenter_sns_topic will be created
  + resource "aws_sns_topic" "datacenter_sns_topic" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "datacenter-dev-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-topic"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-topic"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tracing_config              = (known after apply)
    }

  # aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription will be created
  + resource "aws_sns_topic_subscription" "datacenter_sns_to_sqs_subscription" {
      + arn                             = (known after apply)
      + confirmation_timeout_in_minutes = 1
      + confirmation_was_authenticated  = (known after apply)
      + endpoint                        = (known after apply)
      + endpoint_auto_confirms          = false
      + filter_policy_scope             = (known after apply)
      + id                              = (known after apply)
      + owner_id                        = (known after apply)
      + pending_confirmation            = (known after apply)
      + protocol                        = "sqs"
      + raw_message_delivery            = false
      + topic_arn                       = (known after apply)
    }

  # aws_sqs_queue.datacenter_sqs_queue will be created
  + resource "aws_sqs_queue" "datacenter_sqs_queue" {
      + arn                               = (known after apply)
      + content_based_deduplication       = false
      + deduplication_scope               = (known after apply)
      + delay_seconds                     = 0
      + fifo_queue                        = false
      + fifo_throughput_limit             = (known after apply)
      + id                                = (known after apply)
      + kms_data_key_reuse_period_seconds = (known after apply)
      + max_message_size                  = 262144
      + message_retention_seconds         = 345600
      + name                              = "datacenter-dev-queue"
      + name_prefix                       = (known after apply)
      + policy                            = (known after apply)
      + receive_wait_time_seconds         = 0
      + redrive_allow_policy              = (known after apply)
      + redrive_policy                    = (known after apply)
      + sqs_managed_sse_enabled           = (known after apply)
      + tags                              = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-queue"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + tags_all                          = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-queue"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      + url                               = (known after apply)
      + visibility_timeout_seconds        = 30
    }

  # aws_sqs_queue_policy.datacenter_sqs_policy will be created
  + resource "aws_sqs_queue_policy" "datacenter_sqs_policy" {
      + id        = (known after apply)
      + policy    = (known after apply)
      + queue_url = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_cloudwatch_alarm_name = "datacenter-dev-alarm"
  + kke_dynamodb_table_name   = "datacenter-dev-events"
  + kke_iam_role_arn          = (known after apply)
  + kke_sns_topic_arn         = (known after apply)
  + kke_sqs_queue_url         = (known after apply)
aws_sqs_queue.datacenter_sqs_queue: Creating...
aws_iam_role.datacenter_iam_role: Creating...
aws_sns_topic.datacenter_sns_topic: Creating...
aws_dynamodb_table.datacenter_dynamodb_events: Creating...
aws_iam_role.datacenter_iam_role: Creation complete after 1s [id=datacenter-dev-role]
aws_iam_role_policy.datacenter_iam_role_policy: Creating...
aws_iam_role_policy.datacenter_iam_role_policy: Creation complete after 0s [id=datacenter-dev-role:datacenter-dev-policy]
aws_sns_topic.datacenter_sns_topic: Creation complete after 1s [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic]
aws_dynamodb_table.datacenter_dynamodb_events: Creation complete after 4s [id=datacenter-dev-events]
aws_sqs_queue.datacenter_sqs_queue: Still creating... [10s elapsed]
aws_sqs_queue.datacenter_sqs_queue: Still creating... [20s elapsed]
aws_sqs_queue.datacenter_sqs_queue: Creation complete after 26s [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_sqs_queue_policy.datacenter_sqs_policy: Creating...
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Creating...
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Creation complete after 0s [id=datacenter-dev-alarm]
aws_sqs_queue_policy.datacenter_sqs_policy: Still creating... [10s elapsed]
aws_sqs_queue_policy.datacenter_sqs_policy: Still creating... [20s elapsed]
aws_sqs_queue_policy.datacenter_sqs_policy: Creation complete after 25s [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription: Creating...
aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription: Creation complete after 0s [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

kke_cloudwatch_alarm_name = "datacenter-dev-alarm"
kke_dynamodb_table_name = "datacenter-dev-events"
kke_iam_role_arn = "arn:aws:iam::000000000000:role/datacenter-dev-role"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm:
resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
    actions_enabled                       = true
    alarm_description                     = null
    alarm_name                            = "datacenter-dev-alarm"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:datacenter-dev-alarm"
    comparison_operator                   = "GreaterThanThreshold"
    datapoints_to_alarm                   = 0
    dimensions                            = {
        "QueueName" = "datacenter-dev-queue"
    }
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "datacenter-dev-alarm"
    metric_name                           = "ApproximateNumberOfMessagesVisible"
    namespace                             = "AWS/SQS"
    period                                = 300
    statistic                             = "Average"
    tags                                  = {}
    tags_all                              = {}
    threshold                             = 50
    threshold_metric_id                   = null
    treat_missing_data                    = "missing"
    unit                                  = null
}

# aws_dynamodb_table.datacenter_dynamodb_events:
resource "aws_dynamodb_table" "datacenter_dynamodb_events" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/datacenter-dev-events"
    billing_mode                = "PROVISIONED"
    deletion_protection_enabled = false
    hash_key                    = "event_id"
    id                          = "datacenter-dev-events"
    name                        = "datacenter-dev-events"
    read_capacity               = 5
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-events"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-events"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    write_capacity              = 5

    attribute {
        name = "event_id"
        type = "S"
    }

    point_in_time_recovery {
        enabled = false
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}

# aws_iam_role.datacenter_iam_role:
resource "aws_iam_role" "datacenter_iam_role" {
    arn                   = "arn:aws:iam::000000000000:role/datacenter-dev-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-25T03:24:25Z"
    description           = null
    force_detach_policies = false
    id                    = "datacenter-dev-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "datacenter-dev-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags                  = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-role"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all              = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-role"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    unique_id             = "AROAQAAAAAAAJ2KZE72IT"
}

# aws_iam_role_policy.datacenter_iam_role_policy:
resource "aws_iam_role_policy" "datacenter_iam_role_policy" {
    id          = "datacenter-dev-role:datacenter-dev-policy"
    name        = "datacenter-dev-policy"
    name_prefix = null
    policy      = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "sqs:ReceiveMessage",
                        "dynamodb:PutItem",
                        "sns:Publish",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    role        = "datacenter-dev-role"
}

# aws_sns_topic.datacenter_sns_topic:
resource "aws_sns_topic" "datacenter_sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
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
    id                                       = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "datacenter-dev-topic"
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
                    Resource  = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
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
    tags                                     = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-topic"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                                 = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-topic"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tracing_config                           = null
}

# aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription:
resource "aws_sns_topic_subscription" "datacenter_sns_to_sqs_subscription" {
    arn                             = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466"
    confirmation_timeout_in_minutes = 1
    confirmation_was_authenticated  = true
    delivery_policy                 = null
    endpoint                        = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
    endpoint_auto_confirms          = false
    filter_policy                   = null
    filter_policy_scope             = null
    id                              = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466"
    owner_id                        = "000000000000"
    pending_confirmation            = false
    protocol                        = "sqs"
    raw_message_delivery            = false
    redrive_policy                  = null
    replay_policy                   = null
    subscription_role_arn           = null
    topic_arn                       = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
}

# aws_sqs_queue.datacenter_sqs_queue:
resource "aws_sqs_queue" "datacenter_sqs_queue" {
    arn                               = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
    content_based_deduplication       = false
    deduplication_scope               = null
    delay_seconds                     = 0
    fifo_queue                        = false
    fifo_throughput_limit             = null
    id                                = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    kms_data_key_reuse_period_seconds = 300
    kms_master_key_id                 = null
    max_message_size                  = 262144
    message_retention_seconds         = 345600
    name                              = "datacenter-dev-queue"
    name_prefix                       = null
    policy                            = null
    receive_wait_time_seconds         = 0
    redrive_allow_policy              = null
    redrive_policy                    = null
    sqs_managed_sse_enabled           = true
    tags                              = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-queue"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                          = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-queue"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    url                               = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    visibility_timeout_seconds        = 30
}

# aws_sqs_queue_policy.datacenter_sqs_policy:
resource "aws_sqs_queue_policy" "datacenter_sqs_policy" {
    id        = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sqs:SendMessage"
                    Condition = {
                        ArnEquals = {
                            "aws:SourceArn" = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "sns.amazonaws.com"
                    }
                    Resource  = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
}


Outputs:

kke_cloudwatch_alarm_name = "datacenter-dev-alarm"
kke_dynamodb_table_name = "datacenter-dev-events"
kke_iam_role_arn = "arn:aws:iam::000000000000:role/datacenter-dev-role"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
```

## Note

Once again the apply did not fully implememnt

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_iam_role.datacenter_iam_role: Refreshing state... [id=datacenter-dev-role]
aws_sqs_queue.datacenter_sqs_queue: Refreshing state... [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_sns_topic.datacenter_sns_topic: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic]
aws_dynamodb_table.datacenter_dynamodb_events: Refreshing state... [id=datacenter-dev-events]
aws_sqs_queue_policy.datacenter_sqs_policy: Refreshing state... [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Refreshing state... [id=datacenter-dev-alarm]
aws_iam_role_policy.datacenter_iam_role_policy: Refreshing state... [id=datacenter-dev-role:datacenter-dev-policy]
aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm will be updated in-place
  ~ resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
        id                                    = "datacenter-dev-alarm"
      ~ tags                                  = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      ~ tags_all                              = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
        # (21 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.
```

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_sns_topic.datacenter_sns_topic: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic]
aws_iam_role.datacenter_iam_role: Refreshing state... [id=datacenter-dev-role]
aws_dynamodb_table.datacenter_dynamodb_events: Refreshing state... [id=datacenter-dev-events]
aws_sqs_queue.datacenter_sqs_queue: Refreshing state... [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_sqs_queue_policy.datacenter_sqs_policy: Refreshing state... [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue]
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Refreshing state... [id=datacenter-dev-alarm]
aws_iam_role_policy.datacenter_iam_role_policy: Refreshing state... [id=datacenter-dev-role:datacenter-dev-policy]
aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm will be updated in-place
  ~ resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
        id                                    = "datacenter-dev-alarm"
      ~ tags                                  = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
      ~ tags_all                              = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-dev-alarm"
          + "Owner"       = "KodeKloud"
          + "Project"     = "datacenter"
          + "Team"        = "Development Team"
        }
        # (21 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Modifying... [id=datacenter-dev-alarm]
aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm: Modifications complete after 0s [id=datacenter-dev-alarm]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

kke_cloudwatch_alarm_name = "datacenter-dev-alarm"
kke_dynamodb_table_name = "datacenter-dev-events"
kke_iam_role_arn = "arn:aws:iam::000000000000:role/datacenter-dev-role"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
```

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudwatch_metric_alarm.datacenter_sqs_queue_depth_alarm:
resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
    actions_enabled                       = true
    alarm_actions                         = []
    alarm_description                     = null
    alarm_name                            = "datacenter-dev-alarm"
    arn                                   = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:datacenter-dev-alarm"
    comparison_operator                   = "GreaterThanThreshold"
    datapoints_to_alarm                   = 0
    dimensions                            = {
        "QueueName" = "datacenter-dev-queue"
    }
    evaluate_low_sample_count_percentiles = null
    evaluation_periods                    = 1
    extended_statistic                    = null
    id                                    = "datacenter-dev-alarm"
    insufficient_data_actions             = []
    metric_name                           = "ApproximateNumberOfMessagesVisible"
    namespace                             = "AWS/SQS"
    ok_actions                            = []
    period                                = 300
    statistic                             = "Average"
    tags                                  = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-alarm"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                              = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-alarm"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    threshold                             = 50
    threshold_metric_id                   = null
    treat_missing_data                    = "missing"
    unit                                  = null
}

# aws_dynamodb_table.datacenter_dynamodb_events:
resource "aws_dynamodb_table" "datacenter_dynamodb_events" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/datacenter-dev-events"
    billing_mode                = "PROVISIONED"
    deletion_protection_enabled = false
    hash_key                    = "event_id"
    id                          = "datacenter-dev-events"
    name                        = "datacenter-dev-events"
    read_capacity               = 5
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-events"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-events"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    write_capacity              = 5

    attribute {
        name = "event_id"
        type = "S"
    }

    point_in_time_recovery {
        enabled = false
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}

# aws_iam_role.datacenter_iam_role:
resource "aws_iam_role" "datacenter_iam_role" {
    arn                   = "arn:aws:iam::000000000000:role/datacenter-dev-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-25T03:24:25Z"
    description           = null
    force_detach_policies = false
    id                    = "datacenter-dev-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "datacenter-dev-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags                  = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-role"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all              = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-role"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    unique_id             = "AROAQAAAAAAAJ2KZE72IT"

    inline_policy {
        name   = "datacenter-dev-policy"
        policy = jsonencode(
            {
                Statement = [
                    {
                        Action   = [
                            "sqs:ReceiveMessage",
                            "dynamodb:PutItem",
                            "sns:Publish",
                        ]
                        Effect   = "Allow"
                        Resource = "*"
                    },
                ]
                Version   = "2012-10-17"
            }
        )
    }
}

# aws_iam_role_policy.datacenter_iam_role_policy:
resource "aws_iam_role_policy" "datacenter_iam_role_policy" {
    id          = "datacenter-dev-role:datacenter-dev-policy"
    name        = "datacenter-dev-policy"
    name_prefix = null
    policy      = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "sqs:ReceiveMessage",
                        "dynamodb:PutItem",
                        "sns:Publish",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    role        = "datacenter-dev-role"
}

# aws_sns_topic.datacenter_sns_topic:
resource "aws_sns_topic" "datacenter_sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
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
    id                                       = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "datacenter-dev-topic"
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
                    Resource  = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
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
    tags                                     = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-topic"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                                 = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-topic"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tracing_config                           = null
}

# aws_sns_topic_subscription.datacenter_sns_to_sqs_subscription:
resource "aws_sns_topic_subscription" "datacenter_sns_to_sqs_subscription" {
    arn                             = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466"
    confirmation_timeout_in_minutes = 1
    confirmation_was_authenticated  = true
    delivery_policy                 = null
    endpoint                        = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
    endpoint_auto_confirms          = false
    filter_policy                   = null
    filter_policy_scope             = null
    id                              = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic:56b82174-f198-465f-9f78-9974120ab466"
    owner_id                        = "000000000000"
    pending_confirmation            = false
    protocol                        = "sqs"
    raw_message_delivery            = false
    redrive_policy                  = null
    replay_policy                   = null
    subscription_role_arn           = null
    topic_arn                       = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
}

# aws_sqs_queue.datacenter_sqs_queue:
resource "aws_sqs_queue" "datacenter_sqs_queue" {
    arn                               = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
    content_based_deduplication       = false
    deduplication_scope               = null
    delay_seconds                     = 0
    fifo_queue                        = false
    fifo_throughput_limit             = null
    id                                = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    kms_data_key_reuse_period_seconds = 300
    kms_master_key_id                 = null
    max_message_size                  = 262144
    message_retention_seconds         = 345600
    name                              = "datacenter-dev-queue"
    name_prefix                       = null
    policy                            = jsonencode(
        {
            Statement = [
                {
                    Action    = "sqs:SendMessage"
                    Condition = {
                        ArnEquals = {
                            "aws:SourceArn" = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "sns.amazonaws.com"
                    }
                    Resource  = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    receive_wait_time_seconds         = 0
    redrive_allow_policy              = null
    redrive_policy                    = null
    sqs_managed_sse_enabled           = true
    tags                              = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-queue"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    tags_all                          = {
        "Environment" = "dev"
        "Name"        = "datacenter-dev-queue"
        "Owner"       = "KodeKloud"
        "Project"     = "datacenter"
        "Team"        = "Development Team"
    }
    url                               = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    visibility_timeout_seconds        = 30
}

# aws_sqs_queue_policy.datacenter_sqs_policy:
resource "aws_sqs_queue_policy" "datacenter_sqs_policy" {
    id        = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
    policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sqs:SendMessage"
                    Condition = {
                        ArnEquals = {
                            "aws:SourceArn" = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "sns.amazonaws.com"
                    }
                    Resource  = "arn:aws:sqs:us-east-1:000000000000:datacenter-dev-queue"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
}


Outputs:

kke_cloudwatch_alarm_name = "datacenter-dev-alarm"
kke_dynamodb_table_name = "datacenter-dev-events"
kke_iam_role_arn = "arn:aws:iam::000000000000:role/datacenter-dev-role"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-dev-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/datacenter-dev-queue"
```