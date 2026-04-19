locals {
  cf_template_body = <<JSON
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Parameters": {
    "DynamoDBTableName": {
      "Type": "String"
    }
  },
  "Resources": {
    "MyDynamoDBTable": {
      "Type": "AWS::DynamoDB::Table",
      "Properties": {
        "TableName": { "Ref": "DynamoDBTableName" },
        "AttributeDefinitions": [
          {
            "AttributeName": "ID",
            "AttributeType": "S"
          }
        ],
        "KeySchema": [
          {
            "AttributeName": "ID",
            "KeyType": "HASH"
          }
        ],
        "ProvisionedThroughput": {
          "ReadCapacityUnits": 5,
          "WriteCapacityUnits": 5
        }
      }
    }
  }
}
JSON
}