# - `kke_table_name`:exposes the name of the created DynamoDB table
output "kke_table_name" {
  value = aws_dynamodb_table.dynamodb_table.name
}