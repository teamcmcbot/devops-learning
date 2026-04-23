# Task 006: Deploying a Multi-Tier Architecture on AWS Using Terraform

The DevOps team needs to build a secure, modular multi-tier AWS infrastructure to support a modern cloud-native application stack using Terraform. As part of this requirement, use only allowed AWS services and ensure secure variable usage.

As a member of the Nautilus DevOps Team, your tasks are:

1. Create a DynamoDB Table: Provision a table named `datacenter-app-table` with minimal configuration.

2. Create an SNS Topic: Set up a topic named `datacenter-app-topic` for messaging and notifications.

3. Create an SSM Parameter: Store a sensitive configuration value in AWS SSM Parameter Store under the name `/datacenter/app/config`.

4. Create `main.tf` file (do not create a separate .tf file) to provision a dynamoDB table, sns-topic and ssm parameter.

5. Use `variables.tf` file with the following:

- `KKE_ENVIRONMENT`: `dev` Environment.
- `KKE_DYNAMODB_TABLE_NAME`: name of dynamodb table.
- `KKE_SNS_TOPIC_NAME`: name of the sns topic.
- `KKE_SSM_PARAM_NAME`: name of the SSM parameter.

6. Create `terraform.tfvars` to input the name of the variables.

7. Use `outputs.tf` file to output the following:

- `kke_dynamodb_table_name`: name of the dynamodb table.
- `kke_sns_topic_arn`: arn of the sns-topic created.
- `kke_ssm_parameter_name`: name of the ssm parameter created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.app_table will be created
  + resource "aws_dynamodb_table" "app_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "taskId"
      + id               = (known after apply)
      + name             = "datacenter-app-table"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-app-table"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-app-table"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "taskId"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_sns_topic.devops_sns_topic will be created
  + resource "aws_sns_topic" "devops_sns_topic" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "datacenter-app-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-app-topic"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "datacenter-app-topic"
        }
      + tracing_config              = (known after apply)
    }

  # aws_ssm_parameter.app_config will be created
  + resource "aws_ssm_parameter" "app_config" {
      + arn            = (known after apply)
      + data_type      = (known after apply)
      + has_value_wo   = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + key_id         = (known after apply)
      + name           = "/datacenter/app/config"
      + tags           = {
          + "Environment" = "dev"
          + "Name"        = "/datacenter/app/config"
        }
      + tags_all       = {
          + "Environment" = "dev"
          + "Name"        = "/datacenter/app/config"
        }
      + tier           = (known after apply)
      + type           = "SecureString"
      + value          = (sensitive value)
      + value_wo       = (write-only attribute)
      + version        = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_dynamodb_table_name = "datacenter-app-table"
  + kke_sns_topic_arn       = (known after apply)
  + kke_ssm_parameter_name  = "/datacenter/app/config"
aws_ssm_parameter.app_config: Creating...
aws_sns_topic.devops_sns_topic: Creating...
aws_dynamodb_table.app_table: Creating...
aws_sns_topic.devops_sns_topic: Creation complete after 2s [id=arn:aws:sns:us-east-1:000000000000:datacenter-app-topic]
aws_ssm_parameter.app_config: Creation complete after 2s [id=/datacenter/app/config]
aws_dynamodb_table.app_table: Creation complete after 4s [id=datacenter-app-table]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_dynamodb_table_name = "datacenter-app-table"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-app-topic"
kke_ssm_parameter_name = "/datacenter/app/config"
```

## Verfication

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_dynamodb_table.app_table:
resource "aws_dynamodb_table" "app_table" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/datacenter-app-table"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    hash_key                    = "taskId"
    id                          = "datacenter-app-table"
    name                        = "datacenter-app-table"
    read_capacity               = 0
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Environment" = "dev"
        "Name"        = "datacenter-app-table"
    }
    tags_all                    = {
        "Environment" = "dev"
        "Name"        = "datacenter-app-table"
    }
    write_capacity              = 0

    attribute {
        name = "taskId"
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

# aws_sns_topic.devops_sns_topic:
resource "aws_sns_topic" "devops_sns_topic" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:datacenter-app-topic"
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
    id                                       = "arn:aws:sns:us-east-1:000000000000:datacenter-app-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "datacenter-app-topic"
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
                    Resource  = "arn:aws:sns:us-east-1:000000000000:datacenter-app-topic"
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
        "Name"        = "datacenter-app-topic"
    }
    tags_all                                 = {
        "Environment" = "dev"
        "Name"        = "datacenter-app-topic"
    }
    tracing_config                           = null
}

# aws_ssm_parameter.app_config:
resource "aws_ssm_parameter" "app_config" {
    allowed_pattern = null
    arn             = "arn:aws:ssm:us-east-1:000000000000:parameter/datacenter/app/config"
    data_type       = "text"
    description     = null
    id              = "/datacenter/app/config"
    key_id          = "alias/aws/ssm"
    name            = "/datacenter/app/config"
    tags            = {
        "Environment" = "dev"
        "Name"        = "/datacenter/app/config"
    }
    tags_all        = {
        "Environment" = "dev"
        "Name"        = "/datacenter/app/config"
    }
    tier            = null
    type            = "SecureString"
    value           = (sensitive value)
    value_wo        = (write-only attribute)
    version         = 1
}


Outputs:

kke_dynamodb_table_name = "datacenter-app-table"
kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:datacenter-app-topic"
kke_ssm_parameter_name = "/datacenter/app/config"
```