# Task 012: Integrate SNS with SQS for Messaging Using Terraform

The Nautilus DevOps team is implementing a messaging system in AWS. They want to create an SNS topic and an SQS queue. The team needs to subscribe the SQS queue to the SNS topic so that any messages sent to the SNS topic will be delivered to the SQS queue.

1. Create an SNS topic named `nautilus-sns-topic`.

2. Create an SQS queue named `nautilus-sqs-queue`.

3. Subscribe the SQS queue to the SNS topic.

4. Use the `main.tf` file (do not create a separate .tf file) to provision the SNS topic and SQS queue.

5. Create the `outputs.tf` file, and use the following:

- The ARN of the SNS topic using the output variable kke_sns_topic_arn.
- The URL of the SQS queue using the output variable kke_sqs_queue_url.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_sns_topic.nautilus_sns_topic will be created
  + resource "aws_sns_topic" "nautilus_sns_topic" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "nautilus-sns-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

  # aws_sns_topic_subscription.nautilus_sns_sqs_target will be created
  + resource "aws_sns_topic_subscription" "nautilus_sns_sqs_target" {
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

  # aws_sqs_queue.nautilus_sqs_queue will be created
  + resource "aws_sqs_queue" "nautilus_sqs_queue" {
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
      + name                              = "nautilus-sqs-queue"
      + name_prefix                       = (known after apply)
      + policy                            = (known after apply)
      + receive_wait_time_seconds         = 0
      + redrive_allow_policy              = (known after apply)
      + redrive_policy                    = (known after apply)
      + sqs_managed_sse_enabled           = (known after apply)
      + tags_all                          = (known after apply)
      + url                               = (known after apply)
      + visibility_timeout_seconds        = 30
    }

  # aws_sqs_queue_policy.nautilus_sqs_policy will be created
  + resource "aws_sqs_queue_policy" "nautilus_sqs_policy" {
      + id        = (known after apply)
      + policy    = (known after apply)
      + queue_url = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_sns_topic_arn = (known after apply)
  + kke_sqs_queue_url = (known after apply)
aws_sqs_queue.nautilus_sqs_queue: Creating...
aws_sns_topic.nautilus_sns_topic: Creating...
aws_sns_topic.nautilus_sns_topic: Creation complete after 1s [id=arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic]
aws_sqs_queue.nautilus_sqs_queue: Still creating... [10s elapsed]
aws_sqs_queue.nautilus_sqs_queue: Still creating... [20s elapsed]
aws_sqs_queue.nautilus_sqs_queue: Creation complete after 26s [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue]
aws_sqs_queue_policy.nautilus_sqs_policy: Creating...
aws_sns_topic_subscription.nautilus_sns_sqs_target: Creating...
aws_sns_topic_subscription.nautilus_sns_sqs_target: Creation complete after 0s [id=arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic:d1bbce20-8f20-44ca-8577-302ed4eb6b36]
aws_sqs_queue_policy.nautilus_sqs_policy: Still creating... [10s elapsed]
aws_sqs_queue_policy.nautilus_sqs_policy: Still creating... [20s elapsed]
aws_sqs_queue_policy.nautilus_sqs_policy: Creation complete after 25s [id=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_sns_topic.nautilus_sns_topic:
resource "aws_sns_topic" "nautilus_sns_topic" {
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
    tags_all                                 = {}
    tracing_config                           = null
}

# aws_sns_topic_subscription.nautilus_sns_sqs_target:
resource "aws_sns_topic_subscription" "nautilus_sns_sqs_target" {
    arn                             = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic:d1bbce20-8f20-44ca-8577-302ed4eb6b36"
    confirmation_timeout_in_minutes = 1
    confirmation_was_authenticated  = true
    delivery_policy                 = null
    endpoint                        = "arn:aws:sqs:us-east-1:000000000000:nautilus-sqs-queue"
    endpoint_auto_confirms          = false
    filter_policy                   = null
    filter_policy_scope             = null
    id                              = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic:d1bbce20-8f20-44ca-8577-302ed4eb6b36"
    owner_id                        = "000000000000"
    pending_confirmation            = false
    protocol                        = "sqs"
    raw_message_delivery            = false
    redrive_policy                  = null
    replay_policy                   = null
    subscription_role_arn           = null
    topic_arn                       = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
}

# aws_sqs_queue.nautilus_sqs_queue:
resource "aws_sqs_queue" "nautilus_sqs_queue" {
    arn                               = "arn:aws:sqs:us-east-1:000000000000:nautilus-sqs-queue"
    content_based_deduplication       = false
    deduplication_scope               = null
    delay_seconds                     = 0
    fifo_queue                        = false
    fifo_throughput_limit             = null
    id                                = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
    kms_data_key_reuse_period_seconds = 300
    kms_master_key_id                 = null
    max_message_size                  = 262144
    message_retention_seconds         = 345600
    name                              = "nautilus-sqs-queue"
    name_prefix                       = null
    policy                            = null
    receive_wait_time_seconds         = 0
    redrive_allow_policy              = null
    redrive_policy                    = null
    sqs_managed_sse_enabled           = true
    tags_all                          = {}
    url                               = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
    visibility_timeout_seconds        = 30
}

# aws_sqs_queue_policy.nautilus_sqs_policy:
resource "aws_sqs_queue_policy" "nautilus_sqs_policy" {
    id        = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
    policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sqs:SendMessage"
                    Condition = {
                        ArnEquals = {
                            "aws:SourceArn" = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "sns.amazonaws.com"
                    }
                    Resource  = "arn:aws:sqs:us-east-1:000000000000:nautilus-sqs-queue"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
}


Outputs:

kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
kke_sqs_queue_url = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/nautilus-sqs-queue"
```

