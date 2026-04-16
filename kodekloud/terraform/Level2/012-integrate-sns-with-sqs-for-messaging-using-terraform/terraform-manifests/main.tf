# 1. Create an SNS topic named `nautilus-sns-topic`.
resource "aws_sns_topic" "nautilus_sns_topic" {
  name = "nautilus-sns-topic"
}

resource "aws_sqs_queue" "nautilus_sqs_queue" {
  name = "nautilus-sqs-queue"
}

resource "aws_sns_topic_subscription" "nautilus_sns_sqs_target" {
  topic_arn = aws_sns_topic.nautilus_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.nautilus_sqs_queue.arn
}

# Required for actual message delivery: grants SNS permission to send to the SQS queue.
# Without this, the subscription is created but messages will be silently rejected by SQS.
resource "aws_sqs_queue_policy" "nautilus_sqs_policy" {
  queue_url = aws_sqs_queue.nautilus_sqs_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.nautilus_sqs_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.nautilus_sns_topic.arn
        }
      }
    }]
  })
}

