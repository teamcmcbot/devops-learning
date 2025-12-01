# Task 007: Attach Elastic Network Interface to EC2 Instance

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An instance named xfusion-ec2 and an elastic network interface named xfusion-eni already exists in us-east-1 region.

Attach the xfusion-eni network interface to the xfusion-ec2 instance.
Make sure status is attached before submitting the task.
Please make sure instance initialisation has been completed before submitting this task.

## Instructions

1. Log in to the AWS Management Console.
2. Navigate to the EC2 > Instance > Select Instance > Actions > Networking > Attach Network Interface.
3. Select VPC, select network interface `xfusion-eni` network interface and attach it to the xfusion-ec2 instance.
4. Verify that the network interface status is "attached".
