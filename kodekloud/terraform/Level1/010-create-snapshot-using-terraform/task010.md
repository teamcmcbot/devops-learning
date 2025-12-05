# Task 010 - Create Snapshot using Terraform

The Nautilus DevOps team has some volumes in different regions in their AWS account. They are going to setup some automated backups so that all important data can be backed up on regular basis. For now they shared some requirements to take a snapshot of one of the volumes they have.

Create a snapshot of an existing volume named devops-vol in us-east-1 region using terraform.

1. The name of the snapshot must be devops-vol-ss.

2. The description must be Devops Snapshot.

3. Make sure the snapshot status is completed before submitting the task.

The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to accomplish this task.

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_ebs_volume.k8s_volume: Refreshing state... [id=vol-09aaf8a6661681166]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ebs_snapshot.devops-vol-ss will be created
  + resource "aws_ebs_snapshot" "devops-vol-ss" {
      + arn                    = (known after apply)
      + data_encryption_key_id = (known after apply)
      + description            = "Devops Snapshot"
      + encrypted              = (known after apply)
      + id                     = (known after apply)
      + kms_key_id             = (known after apply)
      + owner_alias            = (known after apply)
      + owner_id               = (known after apply)
      + storage_tier           = (known after apply)
      + tags                   = {
          + "Name" = "devops-vol-ss"
        }
      + tags_all               = {
          + "Name" = "devops-vol-ss"
        }
      + volume_id              = "vol-09aaf8a6661681166"
      + volume_size            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + snapshot_arn  = (known after apply)
  + snapshot_id   = (known after apply)
  + snapshot_size = (known after apply)
  + snapshot_tags = {
      + Name = "devops-vol-ss"
    }
  + volume_arn    = "arn:aws:ec2:us-east-1::volume/vol-09aaf8a6661681166"
  + volume_id     = "vol-09aaf8a6661681166"
  + volume_tags   = {
      + Name = "devops-vol"
    }
aws_ebs_snapshot.devops-vol-ss: Creating...
aws_ebs_snapshot.devops-vol-ss: Creation complete after 0s [id=snap-264e406bc9feb877e]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

snapshot_arn = "arn:aws:ec2:us-east-1::snapshot/snap-264e406bc9feb877e"
snapshot_id = "snap-264e406bc9feb877e"
snapshot_size = 5
snapshot_tags = tomap({
  "Name" = "devops-vol-ss"
})
volume_arn = "arn:aws:ec2:us-east-1::volume/vol-09aaf8a6661681166"
volume_id = "vol-09aaf8a6661681166"
volume_tags = tomap({
  "Name" = "devops-vol"
})


bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-snapshots --filters "Name=tag:Name,Values=devops-vol-ss" --region us-east-1
{
    "Snapshots": [
        {
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "devops-vol-ss"
                }
            ],
            "SnapshotId": "snap-264e406bc9feb877e",
            "VolumeId": "vol-09aaf8a6661681166",
            "State": "completed",
            "StartTime": "2025-12-05T02:00:42Z",
            "Progress": "100%",
            "OwnerId": "000000000000",
            "Description": "Devops Snapshot",
            "VolumeSize": 5,
            "Encrypted": false
        }
    ]
}
```
