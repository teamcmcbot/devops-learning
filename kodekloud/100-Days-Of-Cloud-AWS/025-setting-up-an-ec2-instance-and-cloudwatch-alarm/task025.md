# Task 025 - Setting up an EC2 Instance and CloudWatch Alarm

The Nautilus DevOps team has been tasked with setting up an EC2 instance for their application. To ensure the application performs optimally, they also need to create a CloudWatch alarm to monitor the instance's CPU utilization. The alarm should trigger if the CPU utilization exceeds 90% for one consecutive 5-minute period. To send notifications, use the SNS topic named `devops-sns-topic` which is already created.

1. Launch EC2 Instance: Create an EC2 instance named `devops-ec2` using any appropriate Ubuntu AMI.

2. Create CloudWatch Alarm: Create a CloudWatch alarm named `devops-alarm` with the following specifications:

- Statistic: Average
- Metric: CPU Utilization
- Threshold: >= 90% for 1 consecutive 5-minute period.
- Alarm Actions: Send a notification to `devops-sns-topic`.

## Solution Steps:

1. Launch EC2 Instance:

- Log in to the AWS Management Console.
- Navigate to the EC2 Dashboard.
- Click on "Launch Instance".
- Choose an appropriate Ubuntu AMI (e.g., Ubuntu Server 20.04 LTS
- Select an instance type (e.g., t2.micro for free tier).
- Configure instance details, add storage, and configure security groups as needed.
- Name the instance `devops-ec2`.

2. Create CloudWatch Alarm:

- Navigate to the CloudWatch Dashboard in the AWS Management Console.
- Click on "Alarms" in the left-hand menu, then click "Create Alarm".
- Select "Select metric" and choose "EC2 Metrics" > "Per-Instance Metrics
- Select the `CPUUtilization` metric for the `devops-ec2` instance.
- Click "Select metric".
- Configure the alarm:
  - Set the statistic to "Average".
  - Set the period to 5 minutes.
  - Set the threshold type to "Static" and define the condition as "Greater than or
    equal to 90".
  - Set the number of consecutive periods to 1.
- Under "Actions", select "In alarm" and choose the SNS topic `devops-sns-topic` for notifications.
- Name the alarm `devops-alarm` and provide a description
- Review the settings and click "Create alarm".

3. Verify the setup:

- Ensure the EC2 instance `devops-ec2` is running in the EC2 Dashboard.
- Check the CloudWatch Alarms section to confirm that `devops-alarm` is created and configured correctly.
