# Task 012: Attach Volume to EC2 Instance

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An instance named nautilus-ec2 and a volume named nautilus-volume already exists in us-east-1 region. Attach the nautilus-volume volume to the nautilus-ec2 instance, make sure to set the device name to /dev/sdb while attaching the volume.

## Instructions

1. Log in to the AWS Management Console.
2. Navigate to the EC2 > Instance > Select Instance > Actions > Storage > Attach Volume
3. Select the volume `nautilus-volume` and set the device name to `/dev/sdb` while attaching it to the nautilus-ec2 instance.
4. Verify in storage tab that the Volume State is `in-use` and Attachment status is `Attached`.
