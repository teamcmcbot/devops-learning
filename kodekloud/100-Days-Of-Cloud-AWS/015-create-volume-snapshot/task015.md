# Task 015: Create Volume Snapshot

The Nautilus DevOps team has some volumes in different regions in their AWS account. They are going to setup some automated backups so that all important data can be backed up on regular basis. For now they shared some requirements to take a snapshot of one of the volumes they have.

Create a snapshot of an existing volume named `xfusion-vol` in `us-east-1` region.

1. The name of the snapshot must be `xfusion-vol-ss`.

2. The description must be `xfusion Snapshot`.
3. Make sure the snapshot status is completed before submitting the task.

**Note:** You can use AWS Management Console or AWS CLI to perform this task.

## Solution

1. Login to AWS Management Console and navigate to EC2 Dashboard in us-east-1 region.
2. Go to EC2 > Elastic Block Store > Volumes.
3. Find the volume named `xfusion-vol`.
4. Select the volume, click on "Actions" and choose "Create Snapshot".
5. Description: Enter `xfusion Snapshot`.
6. Tags: Add a tag with Key as `Name` and Value as `xfusion-vol-ss`.
7. Click on "Create Snapshot".
8. Navigate to EC2 > Elastic Block Store > Snapshots.
9. Verify that the snapshot named `xfusion-vol-ss` is created and its status is `completed`.
