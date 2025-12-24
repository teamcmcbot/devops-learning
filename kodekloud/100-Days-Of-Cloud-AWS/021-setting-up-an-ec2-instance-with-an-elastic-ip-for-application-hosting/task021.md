# Task 021: Setting up an EC2 Instance with an Elastic IP for Application Hosting

The Nautilus DevOps Team has received a new request from the Development Team to set up a new EC2 instance. This instance will be used to host a new application that requires a stable IP address. To ensure that the instance has a consistent public IP, an Elastic IP address needs to be associated with it. The instance will be named `devops-ec2`, and the Elastic IP will be named `devops-eip`. This setup will help the Development Team to have a reliable and consistent access point for their application.

Create an EC2 instance named `devops-ec2` using any linux AMI like ubuntu, the Instance type must be `t2.micro` and associate an Elastic IP address with this instance, name it as `devops-eip`.

## Steps to Complete the Task

### Launch an EC2 Instance

1. Navigate to EC2 > Instances > Launch Instances.
2. Enter `devops-ec2` as the instance name.
3. Choose an Amazon Machine Image (AMI) such as Ubuntu.
4. Select the instance type `t2.micro`.
5. For key pair, proceed without a key pair.
6. Select the default security group.
7. Review and launch the instance.

### Allocate an Elastic IP Address

1. Navigate to EC2 > Network & Security > Elastic IPs.
2. Click on "Allocate Elastic IP address".
3. Choose the default settings and click "Allocate".
4. Once allocated, update name tag to `devops-eip`.

### Associate the Elastic IP with the EC2 Instance

1. Select the newly created Elastic IP address.
2. Click on "Actions" > "Associate Elastic IP address".
3. In the "Instance" field, select `devops-ec2`.
4. Click "Associate".

### Verification

1. Go to EC2 > Instances and select `devops-ec2`.
2. Networking tab > elastic ip address should show `devops-eip` associated with it.
