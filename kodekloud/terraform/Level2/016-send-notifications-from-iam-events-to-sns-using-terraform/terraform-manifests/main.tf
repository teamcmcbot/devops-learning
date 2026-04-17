# 1. Create an SNS topic named `devops-sns-topic`.
resource "aws_sns_topic" "devops_sns_topic" {
  name = local.KKE_SNS_TOPIC_NAME

}

# 2. Create an IAM role named `devops-sns-role` with EC2 as the trusted entity.
resource "aws_iam_role" "devops_sns_role" {
  name = local.KKE_ROLE_NAME
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
}

# 3. Attach an IAM policy named `devops-sns-policy` that grants permission to publish messages to the SNS topic.
resource "aws_iam_policy" "devops_sns_policy" {
  name        = local.KKE_POLICY_NAME
  description = "Policy to allow publishing to SNS topic"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.devops_sns_topic.arn
      }
    ]
  })
}

# 4. Attach the `devops-sns-policy` to the `devops-sns-role`.
resource "aws_iam_role_policy_attachment" "devops_sns_policy_attachment" {
  role       = aws_iam_role.devops_sns_role.name
  policy_arn = aws_iam_policy.devops_sns_policy.arn
}
