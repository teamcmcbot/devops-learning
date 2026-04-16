# 1. Create an IAM Role named `nautilus-role`.
resource "aws_iam_role" "nautilus_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
}

# 2. Create an IAM Policy named `nautilus-policy` that allows listing EC2 instances.
resource "aws_iam_policy" "nautilus_policy" {
  name        = var.KKE_POLICY_NAME
  description = "Policy to allow listing EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2:DescribeInstances"
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 3. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "nautilus_attachment" {
  role       = aws_iam_role.nautilus_role.name
  policy_arn = aws_iam_policy.nautilus_policy.arn
}