# kke_iam_role_name: name of the role created.
output "kke_iam_role_name" {
  value = aws_iam_role.nautilus_role.name
}
# kke_iam_policy_name: name of the policy created.
output "kke_iam_policy_name" {
  value = aws_iam_policy.nautilus_policy.name
}