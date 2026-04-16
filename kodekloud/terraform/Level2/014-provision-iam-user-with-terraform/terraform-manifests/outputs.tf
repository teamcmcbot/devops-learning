# `kke_iam_user_name`: name of the IAM user.
output "kke_iam_user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.iamuser_ravi.name
}