# - `kke_dynamodb_table_name`: name of the dynamo_db table created.
output "kke_dynamodb_table_name" {
	description = "Name of the DynamoDB table created"
	value       = aws_dynamodb_table.devops_tasks.name
}

output "task1_status" {
	description = "Status of task 1 for verification"
	value       = jsondecode(aws_dynamodb_table_item.task1.item).status.S
}

output "task2_status" {
	description = "Status of task 2 for verification"
	value       = jsondecode(aws_dynamodb_table_item.task2.item).status.S
}