# Task 020: Create DynamoDB Table Using CloudFormation Using Terraform

The Nautilus DevOps team wants to automate infrastructure provisioning using CloudFormation. As part of the stack setup, they need to create a DynamoDB table.

1. Create a CloudFormation stack named `devops-dynamodb-stack`.

2. The stack must create a DynamoDB table named `devops-cf-dynamodb-table`.

3. Use the `main.tf` file (do not create a separate .tf file) to provision a CloudFormation stack and DynamoDB table. Make sure to add a `lifecycle` block in `main.tf` to ignore changes to the parameters attribute.

4. Use the `variables.tf` file with the following variable names:

- KKE_DYNAMODB_TABLE_NAME: Dynamodb table name.

5. The `locals.tf` file is already provided and includes the following:

- `cf_template_body`: A local variable that stores the CloudFormation template body.

6. Use the `outputs.tf` file to output the following:

- `KKE_stack_name`: CloudFormation stack name

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudformation_stack.devops_dynamodb_stack will be created
  + resource "aws_cloudformation_stack" "devops_dynamodb_stack" {
      + id            = (known after apply)
      + name          = "devops-dynamodb-stack"
      + outputs       = (known after apply)
      + parameters    = {
          + "DynamoDBTableName" = "devops-cf-dynamodb-table"
        }
      + policy_body   = (known after apply)
      + tags_all      = (known after apply)
      + template_body = jsonencode(
            {
              + AWSTemplateFormatVersion = "2010-09-09"
              + Parameters               = {
                  + DynamoDBTableName = {
                      + Type = "String"
                    }
                }
              + Resources                = {
                  + MyDynamoDBTable = {
                      + Properties = {
                          + AttributeDefinitions  = [
                              + {
                                  + AttributeName = "ID"
                                  + AttributeType = "S"
                                },
                            ]
                          + KeySchema             = [
                              + {
                                  + AttributeName = "ID"
                                  + KeyType       = "HASH"
                                },
                            ]
                          + ProvisionedThroughput = {
                              + ReadCapacityUnits  = 5
                              + WriteCapacityUnits = 5
                            }
                          + TableName             = {
                              + Ref = "DynamoDBTableName"
                            }
                        }
                      + Type       = "AWS::DynamoDB::Table"
                    }
                }
            }
        )
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_stack_name = "devops-dynamodb-stack"
aws_cloudformation_stack.devops_dynamodb_stack: Creating...
aws_cloudformation_stack.devops_dynamodb_stack: Still creating... [10s elapsed]
aws_cloudformation_stack.devops_dynamodb_stack: Creation complete after 10s [id=arn:aws:cloudformation:us-east-1:000000000000:stack/devops-dynamodb-stack/db2875bd-613b-410e-882a-643cf00c26fa]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

KKE_stack_name = "devops-dynamodb-stack"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_cloudformation_stack.devops_dynamodb_stack:
resource "aws_cloudformation_stack" "devops_dynamodb_stack" {
    disable_rollback   = false
    iam_role_arn       = null
    id                 = "arn:aws:cloudformation:us-east-1:000000000000:stack/devops-dynamodb-stack/db2875bd-613b-410e-882a-643cf00c26fa"
    name               = "devops-dynamodb-stack"
    outputs            = {}
    parameters         = {
        "DynamoDBTableName" = "devops-cf-dynamodb-table"
    }
    tags_all           = {}
    template_body      = jsonencode(
        {
            AWSTemplateFormatVersion = "2010-09-09"
            Parameters               = {
                DynamoDBTableName = {
                    Type = "String"
                }
            }
            Resources                = {
                MyDynamoDBTable = {
                    Properties = {
                        AttributeDefinitions  = [
                            {
                                AttributeName = "ID"
                                AttributeType = "S"
                            },
                        ]
                        KeySchema             = [
                            {
                                AttributeName = "ID"
                                KeyType       = "HASH"
                            },
                        ]
                        ProvisionedThroughput = {
                            ReadCapacityUnits  = 5
                            WriteCapacityUnits = 5
                        }
                        TableName             = {
                            Ref = "DynamoDBTableName"
                        }
                    }
                    Type       = "AWS::DynamoDB::Table"
                }
            }
        }
    )
    timeout_in_minutes = 0
}


Outputs:

KKE_stack_name = "devops-dynamodb-stack"
```

### Verify CF and DyanmoDB via AWS CLI commands
```bash
bob@iac-server ~/terraform via 💠 default ➜  aws cloudformation describe-stack-resources --stack-name devops-dynamodb-stack
{
    "StackResources": [
        {
            "StackName": "devops-dynamodb-stack",
            "StackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/devops-dynamodb-stack/db2875bd-613b-410e-882a-643cf00c26fa",
            "LogicalResourceId": "MyDynamoDBTable",
            "PhysicalResourceId": "devops-cf-dynamodb-table",
            "ResourceType": "AWS::DynamoDB::Table",
            "Timestamp": "2026-04-19T16:41:48.828766Z",
            "ResourceStatus": "CREATE_COMPLETE",
            "DriftInformation": {
                "StackResourceDriftStatus": "NOT_CHECKED"
            }
        }
    ]
}

bob@iac-server ~/terraform via 💠 default ➜  aws dynamodb describe-table --table-name devops-cf-dynamodb-table
{
    "Table": {
        "AttributeDefinitions": [
            {
                "AttributeName": "ID",
                "AttributeType": "S"
            }
        ],
        "TableName": "devops-cf-dynamodb-table",
        "KeySchema": [
            {
                "AttributeName": "ID",
                "KeyType": "HASH"
            }
        ],
        "TableStatus": "ACTIVE",
        "CreationDateTime": 1776616908.546,
        "ProvisionedThroughput": {
            "LastIncreaseDateTime": 0.0,
            "LastDecreaseDateTime": 0.0,
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 5,
            "WriteCapacityUnits": 5
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/devops-cf-dynamodb-table",
        "TableId": "5e161983-30eb-47ec-90d7-e1a07d70e1fb",
        "DeletionProtectionEnabled": false,
        "WarmThroughput": {
            "ReadUnitsPerSecond": 5,
            "WriteUnitsPerSecond": 5,
            "Status": "ACTIVE"
        }
    }
}
```