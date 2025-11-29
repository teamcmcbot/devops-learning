# Task 009: Enable Termination Protection for EC2 Instance

As part of the migration, there were some components created under the AWS account. The Nautilus DevOps team created one EC2 instance where they forgot to enable the termination protection which is needed for this instance.

An instance named devops-ec2 already exists in us-east-1 region. Enable termination protection for the same.

## Instructions

It is easier to do this via AWS Management Console.

- EC2 > Instances > Select the instance named devops-ec2
- Actions > Instance Settings > Change termination protection
- Enable the Termination Protection and save.
- Verify termination protection is enabled in Details tab.
