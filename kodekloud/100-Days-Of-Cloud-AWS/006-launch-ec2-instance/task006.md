# Task 006: Launch an EC2 Instance

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units.

For this task, create an EC2 instance with following requirements:

1. The name of the instance must be nautilus-ec2.

2. You can use the Amazon Linux AMI to launch this instance.

3. The Instance type must be t2.micro.

4. Create a new RSA key pair named nautilus-kp.

5. Attach the default (available by default) security group.

# Instructions

1. Create a new RSA key pair named nautilus-kp.

```bash
aws ec2 create-key-pair --key-name nautilus-kp --key-type rsa --tag-specifications "ResourceType=key-pair,Tags=[{Key=Name,Value=nautilus-kp}]"
{
    "KeyPairId": "key-034c441b62def89b6",
    "Tags": [
        {
            "Key": "Name",
            "Value": "nautilus-kp"
        }
    ],
    "KeyName": "nautilus-kp",
    "KeyFingerprint": "af:01:94:ae:7c:fd:16:95:f1:8f:22:3f:83:31:45:ca:88:b1:be:a1",
    "KeyMaterial": "[PRIVATE KEY DATA HIDDEN FOR SECURITY REASONS]"
}
```

2. List t2.micro instance with the Amazon Linux 2 AMI, and default security group.

NOTE: This is much easier to do via AWS Management Console.

- EC2 > Instances > Lanch Instances
- Choose Amazon Linux 2 AMI
- Choose t2.micro instance type
- Create new key pair, select RSA and provide the name nautilus-kp
- Select existing security group, choose default security group
- Launch instance

3. Verify that the instance is running and has the name nautilus-ec2.

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-ec2"
```
