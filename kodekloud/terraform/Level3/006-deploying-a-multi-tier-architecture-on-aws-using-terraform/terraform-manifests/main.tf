# 1. Create a DynamoDB Table: Provision a table named `datacenter-app-table` with minimal configuration.
resource "aws_dynamodb_table" "app_table" {
  name           = var.KKE_DYNAMODB_TABLE_NAME
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  tags = {
    Name = var.KKE_DYNAMODB_TABLE_NAME
    Environment = var.KKE_ENVIRONMENT
  }
}

# 2. Create an SNS Topic: Set up a topic named `datacenter-app-topic` for messaging and notifications.
resource "aws_sns_topic" "devops_sns_topic" {
  name = var.KKE_SNS_TOPIC_NAME

  tags = {
    Name = var.KKE_SNS_TOPIC_NAME
    Environment = var.KKE_ENVIRONMENT
  }
}

# 3. Create an SSM Parameter: Store a sensitive configuration value in AWS SSM Parameter Store under the name `/datacenter/app/config`.
resource "aws_ssm_parameter" "app_config" {
  name  = var.KKE_SSM_PARAM_NAME
  type  = "SecureString"
  value = "sensitive_app_config_value"
  tags = {
    Name = var.KKE_SSM_PARAM_NAME
    Environment = var.KKE_ENVIRONMENT
  }
}




