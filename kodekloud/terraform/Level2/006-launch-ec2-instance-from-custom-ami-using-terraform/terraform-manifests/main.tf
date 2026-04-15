# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-f791b5c7a35798c96"
  ]

  tags = {
    Name = "datacenter-ec2"
  }
}

resource "aws_ami_from_instance" "datacenter-ec2-ami" {
  name               = "datacenter-ec2-ami"
  source_instance_id = aws_instance.ec2.id
}

resource "aws_instance" "datacenter-ec2-new" {
  ami           = aws_ami_from_instance.datacenter-ec2-ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-f791b5c7a35798c96"
  ]

  tags = {
    Name = "datacenter-ec2-new"
  }
}