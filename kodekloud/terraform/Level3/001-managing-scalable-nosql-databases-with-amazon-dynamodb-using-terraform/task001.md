# Task 001: Managing Scalable NoSQL Databases with Amazon DynamoDB Using Terraform

The Nautilus DevOps team is developing a simple 'To-Do' application using DynamoDB to store and manage tasks efficiently. The team needs to create a DynamoDB table to hold tasks, each identified by a unique task ID. Each task will have a description and a status, which indicates the progress of the task (e.g., 'completed' or 'in-progress').

Your task is to:

1. Create a DynamoDB table named `devops-tasks` with a primary key called `taskId` (string).

2. Insert the following tasks into the table:

- Task 1: taskId: `1`, description: `Learn DynamoDB`, status: `completed`

- Task 2: taskId: `2`, description: `Build To-Do App`, status: `in-progress`

3. Verify that Task 1 has a status of `completed` and Task 2 has a status of `in-progress`.

4. Create `main.tf` (do not create a separate .tf file) to provision a `dynamo_db` table and insert tasks.

5. Create a `variables.tf` file with the following:

- `KKE_TABLE_NAME`: name of the dynamo_db table.

6. Use `terraform.tfvars` file to input the name of the dynamo_db table.

7. Use `outputs.tf` file for the following:

- `kke_dynamodb_table_name`: name of the dynamo_db table created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.devops_tasks will be created
  + resource "aws_dynamodb_table" "devops_tasks" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "taskId"
      + id               = (known after apply)
      + name             = "devops-tasks"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name" = "devops-tasks"
        }
      + tags_all         = {
          + "Name" = "devops-tasks"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "taskId"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_dynamodb_table_item.task1 will be created
  + resource "aws_dynamodb_table_item" "task1" {
      + hash_key   = "taskId"
      + id         = (known after apply)
      + item       = jsonencode(
            {
              + description = {
                  + S = "Learn DynamoDB"
                }
              + status      = {
                  + S = "completed"
                }
              + taskId      = {
                  + S = "1"
                }
            }
        )
      + table_name = "devops-tasks"
    }

  # aws_dynamodb_table_item.task2 will be created
  + resource "aws_dynamodb_table_item" "task2" {
      + hash_key   = "taskId"
      + id         = (known after apply)
      + item       = jsonencode(
            {
              + description = {
                  + S = "Build To-Do App"
                }
              + status      = {
                  + S = "in-progress"
                }
              + taskId      = {
                  + S = "2"
                }
            }
        )
      + table_name = "devops-tasks"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_dynamodb_table_name = "devops-tasks"
  + task1_status            = "completed"
  + task2_status            = "in-progress"
aws_dynamodb_table.devops_tasks: Creating...
aws_dynamodb_table.devops_tasks: Creation complete after 2s [id=devops-tasks]
aws_dynamodb_table_item.task2: Creating...
aws_dynamodb_table_item.task1: Creating...
aws_dynamodb_table_item.task2: Creation complete after 1s [id=devops-tasks|taskId|2]
aws_dynamodb_table_item.task1: Creation complete after 1s [id=devops-tasks|taskId|1]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

kke_dynamodb_table_name = "devops-tasks"
task1_status = "completed"
task2_status = "in-progress"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_dynamodb_table.devops_tasks:
resource "aws_dynamodb_table" "devops_tasks" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/devops-tasks"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    hash_key                    = "taskId"
    id                          = "devops-tasks"
    name                        = "devops-tasks"
    read_capacity               = 0
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Name" = "devops-tasks"
    }
    tags_all                    = {
        "Name" = "devops-tasks"
    }
    write_capacity              = 0

    attribute {
        name = "taskId"
        type = "S"
    }

    point_in_time_recovery {
        enabled = false
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}

# aws_dynamodb_table_item.task1:
resource "aws_dynamodb_table_item" "task1" {
    hash_key   = "taskId"
    id         = "devops-tasks|taskId|1"
    item       = jsonencode(
        {
            description = {
                S = "Learn DynamoDB"
            }
            status      = {
                S = "completed"
            }
            taskId      = {
                S = "1"
            }
        }
    )
    table_name = "devops-tasks"
}

# aws_dynamodb_table_item.task2:
resource "aws_dynamodb_table_item" "task2" {
    hash_key   = "taskId"
    id         = "devops-tasks|taskId|2"
    item       = jsonencode(
        {
            description = {
                S = "Build To-Do App"
            }
            status      = {
                S = "in-progress"
            }
            taskId      = {
                S = "2"
            }
        }
    )
    table_name = "devops-tasks"
}


Outputs:

kke_dynamodb_table_name = "devops-tasks"
task1_status = "completed"
task2_status = "in-progress"
```

```bash
# Set variables (adjust region if needed)
TABLE_NAME="devops-tasks"
AWS_REGION="us-east-1"

# 4) Optional: list all items in table
aws dynamodb scan \
  --table-name "$TABLE_NAME" \
  --region "$AWS_REGION" \
  --output json



 bob@iac-server ~/terraform via 💠 default ➜  aws dynamodb scan \
  --table-name "$TABLE_NAME" \
  --region "$AWS_REGION" \
  --output json
{
    "Items": [
        {
            "description": {
                "S": "Learn DynamoDB"
            },
            "taskId": {
                "S": "1"
            },
            "status": {
                "S": "completed"
            }
        },
        {
            "description": {
                "S": "Build To-Do App"
            },
            "taskId": {
                "S": "2"
            },
            "status": {
                "S": "in-progress"
            }
        }
    ],
    "Count": 2,
    "ScannedCount": 2,
    "ConsumedCapacity": null
} 

```