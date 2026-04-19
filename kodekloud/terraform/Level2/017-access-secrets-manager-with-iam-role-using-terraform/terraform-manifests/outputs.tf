# `KKE_secret_name`: The secret name
output "KKE_secret_name" {
  value = aws_secretsmanager_secret.xfusion_app_secret.name
}

# `KKE_role_name`: The IAM role name
output "KKE_role_name" {
  value = aws_iam_role.xfusion_app_role.name
}

# `KKE_policy_name`: The IAM policy name
output "KKE_policy_name" {
  value = aws_iam_role_policy.xfusion_app_policy.name
}