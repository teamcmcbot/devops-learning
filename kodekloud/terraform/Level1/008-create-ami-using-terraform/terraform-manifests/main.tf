# Provision EC2 instance
resource "aws_instance" "devops-ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-a820dd8cbde2f81f3"
  ]

  tags = {
    Name = "devops-ec2"
  }
}

# Create AMI from the EC2 instance
resource "aws_ami_from_instance" "devops-ec2-ami" {
  name               = "devops-ec2-ami"
  source_instance_id = aws_instance.devops-ec2.id
}

# Output the AMI ID
output "devops_ec2_ami_id" {
  value = aws_ami_from_instance.devops-ec2-ami.id
}

output "devops_ec2_ami_arn" {
  value = aws_ami_from_instance.devops-ec2-ami.arn
}
