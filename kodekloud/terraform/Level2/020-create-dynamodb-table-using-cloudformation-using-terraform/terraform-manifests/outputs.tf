# - `KKE_stack_name`: CloudFormation stack name
output "KKE_stack_name" {
  description = "CloudFormation stack name"
  value       = aws_cloudformation_stack.devops_dynamodb_stack.name
}