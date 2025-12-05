# Create an IAM policy named `iampolicy_ravi`
resource "aws_iam_policy" "iampolicy_ravi" {
  name = "iampolicy_ravi"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  # allow `read-only access` to the `EC2 console`
  # i.e., allow users to view all instances, AMIs, and snapshots in the Amazon EC2 console
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Output the IAM policy ARN, id, attachment count, tags_all
output "iampolicy_ravi_details" {
  value = {
    arn              = aws_iam_policy.iampolicy_ravi.arn
    id               = aws_iam_policy.iampolicy_ravi.id
    attachment_count = aws_iam_policy.iampolicy_ravi.attachment_count
    tags_all         = aws_iam_policy.iampolicy_ravi.tags_all
  }
}
