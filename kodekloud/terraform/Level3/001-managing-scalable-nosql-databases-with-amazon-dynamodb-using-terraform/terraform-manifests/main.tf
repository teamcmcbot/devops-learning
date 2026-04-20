# 1. Create a DynamoDB table named `devops-tasks` with a primary key called `taskId` (string).
# 2. Insert the following tasks into the table:
# - Task 1: taskId: `1`, description: `Learn DynamoDB`, status: `completed`
# - Task 2: taskId: `2`, description: `Build To-Do App`, status: `in-progress`

resource "aws_dynamodb_table" "devops_tasks" {
  name           = var.KKE_TABLE_NAME
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  tags = {
    Name = var.KKE_TABLE_NAME
  }
}

resource "aws_dynamodb_table_item" "task1" {
  table_name = aws_dynamodb_table.devops_tasks.name
  hash_key   = aws_dynamodb_table.devops_tasks.hash_key

  item = jsonencode({
    taskId = {
      S = "1"
    }
    description = {
      S = "Learn DynamoDB"
    }
    status = {
      S = "completed"
    }
  })
} 

resource "aws_dynamodb_table_item" "task2" {
  table_name = aws_dynamodb_table.devops_tasks.name
  hash_key   = aws_dynamodb_table.devops_tasks.hash_key

  item = jsonencode({
    taskId = {
      S = "2"
    }
    description = {
      S = "Build To-Do App"
    }
    status = {
      S = "in-progress"
    }
  })
}