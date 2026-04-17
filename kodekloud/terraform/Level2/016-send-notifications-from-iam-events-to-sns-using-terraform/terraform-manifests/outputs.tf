# The name of the SNS topic using the output variable `kke_sns_topic_name`.
output "kke_sns_topic_name" {
  description = "The name of the SNS topic created."
  value       = aws_sns_topic.devops_sns_topic.name
}

# The name of the role using the output variable `kke_role_name`.
output "kke_role_name" {
  description = "The name of the role created."
  value       = aws_iam_role.devops_sns_role.name
}

# The name of the policy using the output variable `kke_policy_name`.
output "kke_policy_name" {
  description = "The name of the policy created."
  value       = aws_iam_policy.devops_sns_policy.name
}