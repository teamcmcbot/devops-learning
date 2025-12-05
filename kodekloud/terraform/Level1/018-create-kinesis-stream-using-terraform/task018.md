# Task 018 - Create Kinesis Stream using Terraform

The Nautilus DevOps team needs to create an AWS Kinesis data stream for real-time data processing. This stream will be used to ingest and process large volumes of streaming data, which will then be consumed by various applications for analytics and real-time decision-making.

1. The stream should be named `devops-stream`.

2. Use Terraform to create this Kinesis stream.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Note:

1. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
2. Before submitting the task, ensure that `terraform plan` returns `No changes. Your infrastructure matches the configuration`.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_kinesis_stream.devops-stream will be created
  + resource "aws_kinesis_stream" "devops-stream" {
      + arn                       = (known after apply)
      + encryption_type           = "NONE"
      + enforce_consumer_deletion = false
      + id                        = (known after apply)
      + name                      = "devops-stream"
      + retention_period          = 24
      + shard_count               = 1
      + tags                      = {
          + "Name" = "devops-stream"
        }
      + tags_all                  = {
          + "Name" = "devops-stream"
        }

      + stream_mode_details {
          + stream_mode = "PROVISIONED"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kinesis_stream_arn      = (known after apply)
  + kinesis_stream_id       = (known after apply)
  + kinesis_stream_name     = "devops-stream"
  + kinesis_stream_tags_all = {
      + Name = "devops-stream"
    }
aws_kinesis_stream.devops-stream: Creating...
aws_kinesis_stream.devops-stream: Still creating... [10s elapsed]
aws_kinesis_stream.devops-stream: Still creating... [20s elapsed]
aws_kinesis_stream.devops-stream: Creation complete after 20s [id=arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

kinesis_stream_arn = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream"
kinesis_stream_id = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream"
kinesis_stream_name = "devops-stream"
kinesis_stream_tags_all = tomap({
  "Name" = "devops-stream"
})


bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_kinesis_stream.devops-stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_kinesis_stream.devops-stream will be updated in-place
  ~ resource "aws_kinesis_stream" "devops-stream" {
        id                        = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream"
        name                      = "devops-stream"
      ~ tags                      = {
          + "Name" = "devops-stream"
        }
      ~ tags_all                  = {
          + "Name" = "devops-stream"
        }
        # (7 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.


bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_kinesis_stream.devops-stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream]

Changes to Outputs:
  ~ kinesis_stream_tags_all = {
      - Name = "devops-stream"
    }

You can apply this plan to save these new output values to the Terraform state, without
changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

kinesis_stream_arn = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream"
kinesis_stream_id = "arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream"
kinesis_stream_name = "devops-stream"
kinesis_stream_tags_all = tomap({})

bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_kinesis_stream.devops-stream: Refreshing state... [id=arn:aws:kinesis:us-east-1:000000000000:stream/devops-stream]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed.

```
