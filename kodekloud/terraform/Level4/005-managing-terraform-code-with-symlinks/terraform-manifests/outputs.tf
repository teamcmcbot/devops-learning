# - `kke_sns_topic_name`: name of the SNS topic created.
output "kke_sns_topic_name" {
  value = module.sns.kke_sns_topic
}

# `kke_sns_topic_arn`: ARN of the SNS topic created.
output "kke_sns_topic_arn" {
  value = module.sns.kke_sns_topic_arn
}

# - `kke_ssm_parameter_name`: name of the SSM parameter created.
output "kke_ssm_parameter_name" {
  value = module.ssm.kke_ssm_parameter_name
}

# - `kke_step_function_name`: name of the Step Function created.
output "kke_step_function_name" {
  value = module.stepfunctions.kke_step_function_name
}