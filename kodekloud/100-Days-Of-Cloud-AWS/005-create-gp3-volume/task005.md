# Task 005: Create a gp3 EBS Volume

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

Create a volume with the following requirements:

Name of the volume should be devops-volume.

Volume type must be gp3.

Volume size must be 2 GiB.

## Instructions

```bash
# Create the gp3 EBS volume
aws ec2 create-volume --availability-zone us-east-1a --size 2 --volume-type gp3 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=devops-volume}]'

# Verify the volume creation
aws ec2 describe-volumes --filter 'Name=tag:Name,Values=devops-volume'
{
    "Volumes": [
        {
            "Iops": 3000,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "devops-volume"
                }
            ],
            "VolumeType": "gp3",
            "MultiAttachEnabled": false,
            "Throughput": 125,
            "Operator": {
                "Managed": false
            },
            "VolumeId": "vol-0b9543e95b4aac48f",
            "Size": 2,
            "SnapshotId": "",
            "AvailabilityZone": "us-east-1a",
            "State": "available",
            "CreateTime": "2025-11-27T16:14:43.138Z",
            "Attachments": [],
            "Encrypted": false
        }
    ]
}
```
