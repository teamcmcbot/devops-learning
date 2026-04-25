# 1. Use a `locals` block in your Terraform configuration to define the following:

# - Project name (`datacenter`).
# - Environment (`dev`).
# - A common name prefix by combining the project name and environment (`datacenter-dev`).
# - A map of default tags (`Project`, `Environment`, `Owner`, and `Team`).
# - Then, reference these locals values across all resources in your configuration to ensure consistent naming and consistent tagging.

locals {
  project_name       = "datacenter"
  environment        = "dev"
  common_name_prefix = "${local.project_name}-${local.environment}"
  default_tags = {
    Project     = local.project_name
    Environment = local.environment
    Owner       = "KodeKloud"
    Team        = "Development Team"
  }
}

# 2. Create a `SNS topic` named `project name-environment-topic`.

resource "aws_sns_topic" "datacenter_sns_topic" {
  name = "${local.common_name_prefix}-topic"

  tags = merge(local.default_tags, {
    Name = "${local.common_name_prefix}-topic"
  })
}

# 3. Create a `SQS queue` named `project name-environment-queue` and subscribe it to the SNS topic.

resource "aws_sqs_queue" "datacenter_sqs_queue" {
  name = "${local.common_name_prefix}-queue"

  tags = merge(local.default_tags, {
    Name = "${local.common_name_prefix}-queue"
  })
}

# Required for actual message delivery: grants SNS permission to send to the SQS queue.
# Without this, the subscription is created but messages will be silently rejected by SQS.
resource "aws_sqs_queue_policy" "datacenter_sqs_policy" {
  queue_url = aws_sqs_queue.datacenter_sqs_queue.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.datacenter_sqs_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.datacenter_sns_topic.arn
        }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "datacenter_sns_to_sqs_subscription" {
  topic_arn = aws_sns_topic.datacenter_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.datacenter_sqs_queue.arn

  # 4. Use `depends_on` to ensure the SNS topic is created before subscription.
  depends_on = [aws_sqs_queue.datacenter_sqs_queue, aws_sns_topic.datacenter_sns_topic, aws_sqs_queue_policy.datacenter_sqs_policy]

}

# 5. Create a DynamoDB table named `project name-environment-events` with primary key `event_id` (HASH key) and provisioned throughput of 5 read capacity units and 5 write capacity units.
resource "aws_dynamodb_table" "datacenter_dynamodb_events" {
  name           = "${local.common_name_prefix}-events"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  tags = merge(local.default_tags, {
    Name = "${local.common_name_prefix}-events"
  })
}

# 6. Create an IAM Role named `project name-environment-role` with a dynamic inline policy allowing:
#   - `sqs:ReceiveMessage`
#   - `dynamodb:PutItem`
#   - `sns:Publish`

resource "aws_iam_role" "datacenter_iam_role" {
  name = "${local.common_name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.default_tags, {
    Name = "${local.common_name_prefix}-role"
  })
}
resource "aws_iam_role_policy" "datacenter_iam_role_policy" {
  name = "${local.common_name_prefix}-policy"
  role = aws_iam_role.datacenter_iam_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.KKE_IAM_ACTIONS
        Resource = "*"
      }
    ]
  })

}

# 9. Create a `CloudWatch alarm` named `project name-environment-alarm` for the SQS queue when it contains more than 50 messages (threshold configurable).
resource "aws_cloudwatch_metric_alarm" "datacenter_sqs_queue_depth_alarm" {
  alarm_name          = "${local.common_name_prefix}-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = var.KKE_QUEUE_DEPTH_THRESHOLD

  dimensions = {
    QueueName = aws_sqs_queue.datacenter_sqs_queue.name
  }

  tags = merge(local.default_tags, {
    Name = "${local.common_name_prefix}-alarm"
  })

}