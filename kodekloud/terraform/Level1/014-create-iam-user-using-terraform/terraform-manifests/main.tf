# Create iamuser_javed
resource "aws_iam_user" "iamuser_javed" {
  name = "iamuser_javed"
  tags = {
    Name = "iamuser_javed"
  }
}

# Output the IAM user name, ID, and ARN
output "iamuser_javed_name" {
  value = aws_iam_user.iamuser_javed.name
}
output "iamuser_javed_id" {
  value = aws_iam_user.iamuser_javed.id
}
output "iamuser_javed_arn" {
  value = aws_iam_user.iamuser_javed.arn
}
