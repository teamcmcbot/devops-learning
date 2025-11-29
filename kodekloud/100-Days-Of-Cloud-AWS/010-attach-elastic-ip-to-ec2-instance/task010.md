# Task 010: Attach Elastic IP to EC2 Instance

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

There is an instance named devops-ec2 and an elastic-ip named devops-ec2-eip in us-east-1 region. Attach the devops-ec2-eip elastic-ip to the devops-ec2 instance.

## Instructions

1. EC2 > Elastic IPs > Select the elastic IP named devops-ec2-eip > Actions > Associate Elastic IP address.
2. Instance > Select the instance named devops-ec2 > Associate.
3. Verify in EC2 Networking tab that the elastic IP is attached to the instance.
