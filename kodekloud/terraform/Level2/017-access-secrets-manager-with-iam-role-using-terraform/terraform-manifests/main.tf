# 1. Create a secret in AWS Secrets Manager named xfusion-app-secret
resource "aws_secretsmanager_secret" "xfusion_app_secret" {
  name = var.KKE_SECRET_NAME
}

resource "aws_secretsmanager_secret_version" "xfusion_app_secret_version" {
  secret_id     = aws_secretsmanager_secret.xfusion_app_secret.id
  secret_string = var.KKE_SECRET_VALUE
}

# 2. Create an IAM role named `xfusion-app-role` with EC2 as the trusted entity.
resource "aws_iam_role" "xfusion_app_role" {
  name = var.KKE_ROLE_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# 3. Attach an inline IAM policy named `xfusion-app-policy` that grants permission to retrieve the secret from AWS Secrets Manager.
resource "aws_iam_role_policy" "xfusion_app_policy" {
  name   = var.KKE_POLICY_NAME
  role   = aws_iam_role.xfusion_app_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.xfusion_app_secret.arn
      },
    ]
  })
}

