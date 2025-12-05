# Create IAM Group
resource "aws_iam_group" "iamgroup_ammar" {
  name = "iamgroup_ammar"
}

# Output the IAM group name, ID, and ARN
output "iamgroup_name" {
  value = aws_iam_group.iamgroup_ammar.name
}
output "iamgroup_id" {
  value = aws_iam_group.iamgroup_ammar.id
}
output "iamgroup_arn" {
  value = aws_iam_group.iamgroup_ammar.arn
}
