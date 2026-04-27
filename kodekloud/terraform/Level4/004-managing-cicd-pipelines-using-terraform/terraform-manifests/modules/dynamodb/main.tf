#- **dynamodb**:Provision a DynamoDB table named `xfusion-<env>-table` (based on the environment)`(dev & prod)`, using `id` as the HASH key.
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.KKE_DYNAMODB_TABLE_NAME}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "${var.KKE_ENV}"
  }
}