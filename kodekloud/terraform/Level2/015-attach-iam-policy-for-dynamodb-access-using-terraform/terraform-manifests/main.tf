# 1. Create a DynamoDB Table: Create a table named `nautilus-table` with minimal configuration.
resource "aws_dynamodb_table" "nautilus_table" {
  name         = var.KKE_TABLE_NAME
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# 2. Create an IAM Role: Create an IAM role named `nautilus-role` that will be allowed to access the table.
resource "aws_iam_role" "nautilus_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Create an IAM Policy that grants read-only access (GetItem, Scan, Query) to the specific DynamoDB table.
resource "aws_iam_policy" "nautilus_readonly_policy" {
  name = var.KKE_POLICY_NAME

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.nautilus_table.arn
      }
    ]
  })
}

# Attach the managed IAM policy to the role.
resource "aws_iam_role_policy_attachment" "nautilus_readonly_policy_attach" {
  role       = aws_iam_role.nautilus_role.name
  policy_arn = aws_iam_policy.nautilus_readonly_policy.arn
}