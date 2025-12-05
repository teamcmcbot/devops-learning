# Task 009 - Create EBS Volume using Terraform

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create an AWS EBS volume using Terraform with the following requirements:

Name of the volume should be nautilus-volume.

Volume type must be gp3.

Volume size must be 2 GiB.

Ensure the volume is created in us-east-1.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 0s [id=us-east-1]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ebs_volume.nautilus-volume will be created
  + resource "aws_ebs_volume" "nautilus-volume" {
      + arn               = (known after apply)
      + availability_zone = "us-east-1a"
      + encrypted         = (known after apply)
      + final_snapshot    = false
      + id                = (known after apply)
      + iops              = (known after apply)
      + kms_key_id        = (known after apply)
      + size              = 2
      + snapshot_id       = (known after apply)
      + tags              = {
          + "Name" = "nautilus-volume"
        }
      + tags_all          = {
          + "Name" = "nautilus-volume"
        }
      + throughput        = (known after apply)
      + type              = "gp3"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ebs_volume_arn = (known after apply)
  + ebs_volume_id  = (known after apply)
aws_ebs_volume.nautilus-volume: Creating...
aws_ebs_volume.nautilus-volume: Still creating... [10s elapsed]
aws_ebs_volume.nautilus-volume: Creation complete after 10s [id=vol-365ed1a824fcaadf1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ebs_volume_arn = "arn:aws:ec2:us-east-1::volume/vol-365ed1a824fcaadf1"
ebs_volume_id = "vol-365ed1a824fcaadf1"


bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-volumes
{
    "Volumes": [
        {
            "Iops": 3000,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "nautilus-volume"
                }
            ],
            "VolumeType": "gp3",
            "VolumeId": "vol-365ed1a824fcaadf1",
            "Size": 2,
            "SnapshotId": "",
            "AvailabilityZone": "us-east-1a",
            "State": "available",
            "CreateTime": "2025-12-05T01:41:44Z",
            "Attachments": [],
            "Encrypted": false
        }
    ]
}
```
