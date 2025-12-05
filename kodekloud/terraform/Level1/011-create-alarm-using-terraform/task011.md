# Task 011 - Create Alarm using Terraform

The Nautilus DevOps team is setting up monitoring in their AWS account. As part of this, they need to create a CloudWatch alarm.

Using Terraform, perform the following:

Task Details:
Create a CloudWatch alarm named `devops-alarm`.
The alarm should monitor CPU utilization of an EC2 instance.
Trigger the alarm when CPU utilization exceeds 80%.
Set the evaluation period to 5 minutes.
Use a single evaluation period.
Ensure that the entire configuration is implemented using Terraform. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_cloudwatch_metric_alarm.foobar: Refreshing state... [id=devops-alarm]

Changes to Outputs:
  + cloudwatch_alarm_details = {
      + arn      = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:devops-alarm"
      + id       = "devops-alarm"
      + tags_all = {}
    }

You can apply this plan to save these new output values to the Terraform state, without
changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

cloudwatch_alarm_details = {
  "arn" = "arn:aws:cloudwatch:us-east-1:000000000000:alarm:devops-alarm"
  "id" = "devops-alarm"
  "tags_all" = tomap({})
}

bob@iac-server ~/terraform via 💠 default ➜  aws cloudwatch describe-alarms --alarm-names "devops-alarm" --region us-east-1
{
    "MetricAlarms": [
        {
            "AlarmName": "devops-alarm",
            "AlarmArn": "arn:aws:cloudwatch:us-east-1:000000000000:alarm:devops-alarm",
            "AlarmDescription": "This metric monitors ec2 cpu utilization",
            "AlarmConfigurationUpdatedTimestamp": "2025-12-05T10:51:11.568706Z",
            "ActionsEnabled": true,
            "OKActions": [],
            "AlarmActions": [],
            "InsufficientDataActions": [],
            "StateValue": "INSUFFICIENT_DATA",
            "StateReason": "Unchecked: Initial alarm creation",
            "StateUpdatedTimestamp": "2025-12-05T10:51:11.568706Z",
            "MetricName": "CPUUtilization",
            "Namespace": "AWS/EC2",
            "Statistic": "Average",
            "Dimensions": [],
            "Period": 300,
            "EvaluationPeriods": 1,
            "Threshold": 80.0,
            "ComparisonOperator": "GreaterThanOrEqualToThreshold",
            "TreatMissingData": "missing",
            "StateTransitionedTimestamp": "2025-12-05T10:51:11.568706Z"
        }
    ],
    "CompositeAlarms": []
}
```
