# Create SSM Parameter
resource "aws_ssm_parameter" "devops-ssm-parameter" {
  name  = "devops-ssm-parameter"
  type  = "String"
  value = "devops-value"
}

# Output the SSM Parameter arn, version and tags_all

output "ssm_parameter_arn" {
  value = aws_ssm_parameter.devops-ssm-parameter.arn
}
output "ssm_parameter_version" {
  value = aws_ssm_parameter.devops-ssm-parameter.version
}
output "ssm_parameter_tags_all" {
  value = aws_ssm_parameter.devops-ssm-parameter.tags_all
}
