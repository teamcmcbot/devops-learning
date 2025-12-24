# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id     = "subnet-88cbacea28f2b5949"
  vpc_security_group_ids = [
    "sg-2e3f820d5447ada9f"
  ]

  tags = {
    Name = "xfusion-ec2"
  }
}

# Provision Elastic IP
resource "aws_eip" "ec2_eip" {
  tags = {
    Name = "xfusion-ec2-eip"
  }
}

# Attach Elastic IP to EC2 instance
resource "aws_eip_association" "ec2_eip_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2_eip.id
}
