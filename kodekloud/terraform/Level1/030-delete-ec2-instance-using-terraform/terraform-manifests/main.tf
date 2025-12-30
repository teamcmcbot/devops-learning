# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-724a249fc408c40ab"
  ]

  tags = {
    Name = "datacenter-ec2"
  }
}

