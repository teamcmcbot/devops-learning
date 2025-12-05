# Task 017 - Create DynamoDB Table using Terraform

The Nautilus DevOps team needs to set up a DynamoDB table for storing user data. They need to create a DynamoDB table with the following specifications:

1. The table name should be `datacenter-users`.

2. The primary key should be `datacenter_id` (String).

3. The table should use `PAY_PER_REQUEST` billing mode.

Use Terraform to create this DynamoDB table. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to create the DynamoDB table.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.dynamodb-table-datacenter-users will be created
  + resource "aws_dynamodb_table" "dynamodb-table-datacenter-users" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "datacenter_id"
      + id               = (known after apply)
      + name             = "datacenter-users"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name" = "datacenter-users"
        }
      + tags_all         = {
          + "Name" = "datacenter-users"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "datacenter_id"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + dynamodb_table_datacenter_users_arn      = (known after apply)
  + dynamodb_table_datacenter_users_id       = (known after apply)
  + dynamodb_table_datacenter_users_tags_all = {
      + Name = "datacenter-users"
    }
aws_dynamodb_table.dynamodb-table-datacenter-users: Creating...
aws_dynamodb_table.dynamodb-table-datacenter-users: Creation complete after 3s [id=datacenter-users]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

dynamodb_table_datacenter_users_arn = "arn:aws:dynamodb:us-east-1:000000000000:table/datacenter-users"
dynamodb_table_datacenter_users_id = "datacenter-users"
dynamodb_table_datacenter_users_tags_all = tomap({
  "Name" = "datacenter-users"
})


bob@iac-server ~/terraform via 💠 default ➜  aws dynamodb describe-table --table-name datacenter-users
{
    "Table": {
        "AttributeDefinitions": [
            {
                "AttributeName": "datacenter_id",
                "AttributeType": "S"
            }
        ],
        "TableName": "datacenter-users",
        "KeySchema": [
            {
                "AttributeName": "datacenter_id",
                "KeyType": "HASH"
            }
        ],
        "TableStatus": "ACTIVE",
        "CreationDateTime": 1764950525.791,
        "ProvisionedThroughput": {
            "LastIncreaseDateTime": 0.0,
            "LastDecreaseDateTime": 0.0,
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 0,
            "WriteCapacityUnits": 0
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/datacenter-users",
        "TableId": "9b936831-dae1-4cd7-be12-013d8f178e43",
        "BillingModeSummary": {
            "BillingMode": "PAY_PER_REQUEST",
            "LastUpdateToPayPerRequestDateTime": 1764950525.791
        },
        "DeletionProtectionEnabled": false,
        "WarmThroughput": {
            "ReadUnitsPerSecond": 12000,
            "WriteUnitsPerSecond": 4000,
            "Status": "ACTIVE"
        }
    }
}
```
