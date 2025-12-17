# Task 021 - CloudWatch Setup Using Terraform

The Nautilus DevOps team needs to set up CloudWatch logging for their application. They need to create a CloudWatch log group and log stream with the following specifications:

1. The log group name should be `devops-log-group`.

2. The log stream name should be `devops-log-stream`.

Use Terraform to create the CloudWatch log group and log stream. The Terraform working directory is `/home/bob/terraform`. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verifications

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_log_group.devops_log_group will be created
  + resource "aws_cloudwatch_log_group" "devops_log_group" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + log_group_class   = (known after apply)
      + name              = "devops-log-group"
      + name_prefix       = (known after apply)
      + retention_in_days = 0
      + skip_destroy      = false
      + tags_all          = (known after apply)
    }

  # aws_cloudwatch_log_stream.devops_log_stream will be created
  + resource "aws_cloudwatch_log_stream" "devops_log_stream" {
      + arn            = (known after apply)
      + id             = (known after apply)
      + log_group_name = "devops-log-group"
      + name           = "devops-log-stream"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + log_group_arn  = (known after apply)
  + log_stream_arn = (known after apply)
aws_cloudwatch_log_group.devops_log_group: Creating...
aws_cloudwatch_log_group.devops_log_group: Creation complete after 1s [id=devops-log-group]
aws_cloudwatch_log_stream.devops_log_stream: Creating...
aws_cloudwatch_log_stream.devops_log_stream: Creation complete after 0s [id=devops-log-stream]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

log_group_arn = "arn:aws:logs:us-east-1:000000000000:log-group:devops-log-group"
log_stream_arn = "arn:aws:logs:us-east-1:000000000000:log-group:devops-log-group:log-stream:devops-log-stream"

```
