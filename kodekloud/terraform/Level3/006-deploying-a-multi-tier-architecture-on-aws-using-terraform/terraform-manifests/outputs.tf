# - `kke_dynamodb_table_name`: name of the dynamodb table.
output "kke_dynamodb_table_name" {
  value = aws_dynamodb_table.app_table.name
}

# - `kke_sns_topic_arn`: arn of the sns-topic created.
output "kke_sns_topic_arn" {
  value = aws_sns_topic.devops_sns_topic.arn
}

# - `kke_ssm_parameter_name`: name of the ssm parameter created.
output "kke_ssm_parameter_name" {
  value = aws_ssm_parameter.app_config.name
}