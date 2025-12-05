# Task 020 - Create SSM Parameter using Terraform

The Nautilus DevOps team needs to create an SSM parameter in AWS with the following requirements:

1. The name of the parameter should be `devops-ssm-parameter`.

2. Set the parameter type to `String`.

3. Set the parameter value to `devops-value`.

4. The parameter should be created in the `us-east-1` region.

5. Ensure the parameter is successfully created using `terraform` and can be retrieved when the task is completed.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ssm_parameter.devops-ssm-parameter will be created
  + resource "aws_ssm_parameter" "devops-ssm-parameter" {
      + arn            = (known after apply)
      + data_type      = (known after apply)
      + has_value_wo   = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + key_id         = (known after apply)
      + name           = "devops-ssm-parameter"
      + tags_all       = (known after apply)
      + tier           = (known after apply)
      + type           = "String"
      + value          = (sensitive value)
      + value_wo       = (write-only attribute)
      + version        = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ssm_parameter_arn      = (known after apply)
  + ssm_parameter_tags_all = (known after apply)
  + ssm_parameter_version  = (known after apply)
aws_ssm_parameter.devops-ssm-parameter: Creating...
aws_ssm_parameter.devops-ssm-parameter: Creation complete after 2s [id=devops-ssm-parameter]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ssm_parameter_arn = "arn:aws:ssm:us-east-1:000000000000:parameter/devops-ssm-parameter"
ssm_parameter_tags_all = tomap({})
ssm_parameter_version = 1

bob@iac-server ~/terraform via 💠 default ➜  aws ssm get-parameter --name "devops-ssm-parameter"
{
    "Parameter": {
        "Name": "devops-ssm-parameter",
        "Type": "String",
        "Value": "devops-value",
        "Version": 1,
        "LastModifiedDate": 1764953813.885,
        "ARN": "arn:aws:ssm:us-east-1:000000000000:parameter/devops-ssm-parameter",
        "DataType": "text"
    }
}
```
