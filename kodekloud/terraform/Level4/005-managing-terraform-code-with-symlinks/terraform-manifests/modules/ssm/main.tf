variable "SNS_TOPIC_ARN" {
  description = "ARN of the SNS topic created"
  type        = string
}

resource "aws_ssm_parameter" "this" {
  name  = var.KKE_SSM_PARAM_NAME
  type  = "String"
  value = var.SNS_TOPIC_ARN
}