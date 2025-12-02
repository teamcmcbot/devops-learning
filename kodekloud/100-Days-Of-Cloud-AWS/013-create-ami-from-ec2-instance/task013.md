# Task 013: Create an AMI from an EC2 Instance

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create an AMI from an existing EC2 instance named nautilus-ec2 with the following requirement:

Name of the AMI should be nautilus-ec2-ami, make sure AMI is in available state.

## Instructions

1. Log in to the AWS Management Console.
2. Navigate to the EC2 Dashboard.
3. Locate the EC2 instance named `nautilus-ec2`.
4. Go to Actions > Image and templates > Create image.
5. In the Create Image dialog box, enter `nautilus-ec2-ami` as the name for the AMI. Click create image.
6. Edit Name tag of the created AMI to `nautilus-ec2-ami`.
7. Verify that the AMI is created and is in the "available" state. Might take a few minutes for the AMI to be in available state.
