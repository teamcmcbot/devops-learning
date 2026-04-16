# `kke_dynamodb_table`: name of the DynamoDB table
output "kke_dynamodb_table" {
  value = aws_dynamodb_table.nautilus_table.name
}

# `kke_iam_role_name`: name of the IAM role
output "kke_iam_role_name" {
  value = aws_iam_role.nautilus_role.name
}

# `kke_iam_policy_name`: name of the IAM policy
output "kke_iam_policy_name" {
  value = aws_iam_policy.nautilus_readonly_policy.name
}