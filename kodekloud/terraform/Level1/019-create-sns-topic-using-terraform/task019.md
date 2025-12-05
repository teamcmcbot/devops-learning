# Task 019 - Create SNS Topic using Terraform

The Nautilus DevOps team needs to set up an SNS topic for sending notifications. They need to create an SNS topic with the following specifications:

1. The topic name should be `nautilus-notifications`.

Use Terraform to create this SNS topic. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_sns_topic.nautilus-notifications will be created
  + resource "aws_sns_topic" "nautilus-notifications" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "nautilus-notifications"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + sns_topic_arn      = (known after apply)
  + sns_topic_id       = (known after apply)
  + sns_topic_tags_all = (known after apply)
aws_sns_topic.nautilus-notifications: Creating...
aws_sns_topic.nautilus-notifications: Creation complete after 1s [id=arn:aws:sns:us-east-1:000000000000:nautilus-notifications]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:nautilus-notifications"
sns_topic_id = "arn:aws:sns:us-east-1:000000000000:nautilus-notifications"
sns_topic_tags_all = tomap({})

bob@iac-server ~/terraform via 💠 default ➜  aws sns list-topics
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:us-east-1:000000000000:nautilus-notifications"
        }
    ]
}
```
