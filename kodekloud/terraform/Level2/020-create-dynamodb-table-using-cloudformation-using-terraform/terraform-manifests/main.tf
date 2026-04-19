# 1. Create a CloudFormation stack named `devops-dynamodb-stack`.
resource "aws_cloudformation_stack" "devops_dynamodb_stack" {
  name          = "devops-dynamodb-stack"
  template_body = local.cf_template_body

  parameters = {
    DynamoDBTableName = var.KKE_DYNAMODB_TABLE_NAME
  }

  # add a lifecycle block in main.tf to ignore changes to the parameters attribute
  lifecycle {
    ignore_changes        = [parameters]
  }
}

