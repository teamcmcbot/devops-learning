# - `kke_user_name`: name of the created user.
output "kke_user_name" {
  value = aws_iam_user.kke_user.name
}
# - `kke_role_name`: name of the created role.
output "kke_role_name" {
  value = aws_iam_role.kke_role.name
}
# - `kke_tags_applied`: tags applied to the IAM User.
output "kke_tags_applied" {
  value = aws_iam_user.kke_user.tags
}