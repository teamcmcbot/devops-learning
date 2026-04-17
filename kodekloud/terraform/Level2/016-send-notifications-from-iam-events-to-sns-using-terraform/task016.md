# Task 016: Send Notifications from IAM Events to SNS Using Terraform

To enable secure inter-service communication, the DevOps team needs to configure access to an SNS topic using IAM roles and policies. The objective is to allow EC2 instances to publish messages to the topic using proper permissions and role assumptions. Please complete the following tasks:

1. Create an SNS topic named `devops-sns-topic`.

2. Create an IAM role named `devops-sns-role` with EC2 as the trusted entity.

3. Attach an IAM policy named `devops-sns-policy` that grants permission to publish messages to the SNS topic.

4. Use the `main.tf` file (do not create a separate .tf file) to provision the sns-topic, role and policy.

5. Create the `locals.tf` with the following names:

- `KKE_SNS_TOPIC_NAME`:name of the sns topic created.
- `KKE_ROLE_NAME`: name of the role created.
- `KKE_POLICY_NAME`: name of the policy created.

6. Create the `outputs.tf` file to the output the following:

- The name of the SNS topic using the output variable `kke_sns_topic_name`.
- The name of the role using the output variable `kke_role_name`.
- The name of the policy using the output variable `kke_policy_name`.


## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.devops_sns_policy will be created
  + resource "aws_iam_policy" "devops_sns_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy to allow publishing to SNS topic"
      + id               = (known after apply)
      + name             = "devops-sns-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # aws_iam_role.devops_sns_role will be created
  + resource "aws_iam_role" "devops_sns_role" {
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
      + name                  = "devops-sns-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.devops_sns_policy_attachment will be created
  + resource "aws_iam_role_policy_attachment" "devops_sns_policy_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "devops-sns-role"
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

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_policy_name    = "devops-sns-policy"
  + kke_role_name      = "devops-sns-role"
  + kke_sns_topic_name = "devops-sns-topic"
aws_sns_topic.devops_sns_topic: Creating...
aws_iam_role.devops_sns_role: Creating...
aws_iam_role.devops_sns_role: Creation complete after 0s [id=devops-sns-role]
aws_sns_topic.devops_sns_topic: Creation complete after 0s [id=arn:aws:sns:us-east-1:000000000000:devops-sns-topic]
aws_iam_policy.devops_sns_policy: Creating...
aws_iam_policy.devops_sns_policy: Creation complete after 0s [id=arn:aws:iam::000000000000:policy/devops-sns-policy]
aws_iam_role_policy_attachment.devops_sns_policy_attachment: Creating...
aws_iam_role_policy_attachment.devops_sns_policy_attachment: Creation complete after 0s [id=devops-sns-role-20260417061211024700000001]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_policy_name = "devops-sns-policy"
kke_role_name = "devops-sns-role"
kke_sns_topic_name = "devops-sns-topic"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_iam_policy.devops_sns_policy:
resource "aws_iam_policy" "devops_sns_policy" {
    arn              = "arn:aws:iam::000000000000:policy/devops-sns-policy"
    attachment_count = 0
    description      = "Policy to allow publishing to SNS topic"
    id               = "arn:aws:iam::000000000000:policy/devops-sns-policy"
    name             = "devops-sns-policy"
    name_prefix      = null
    path             = "/"
    policy           = jsonencode(
        {
            Statement = [
                {
                    Action   = "sns:Publish"
                    Effect   = "Allow"
                    Resource = "arn:aws:sns:us-east-1:000000000000:devops-sns-topic"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    policy_id        = "A21T7BHV3NA5YN766HKF1"
    tags_all         = {}
}

# aws_iam_role.devops_sns_role:
resource "aws_iam_role" "devops_sns_role" {
    arn                   = "arn:aws:iam::000000000000:role/devops-sns-role"
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
    create_date           = "2026-04-17T06:12:10Z"
    description           = null
    force_detach_policies = false
    id                    = "devops-sns-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "devops-sns-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAOAAVCBZWC"
}

# aws_iam_role_policy_attachment.devops_sns_policy_attachment:
resource "aws_iam_role_policy_attachment" "devops_sns_policy_attachment" {
    id         = "devops-sns-role-20260417061211024700000001"
    policy_arn = "arn:aws:iam::000000000000:policy/devops-sns-policy"
    role       = "devops-sns-role"
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

kke_policy_name = "devops-sns-policy"
kke_role_name = "devops-sns-role"
kke_sns_topic_name = "devops-sns-topic"

```