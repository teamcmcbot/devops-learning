data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2-instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  tags = {
    Name = "datacenter-ec2"
  }
}

resource "aws_eip" "datacenter-eip" {
  instance = aws_instance.ec2-instance.id
  domain   = "vpc"

  tags = {
    Name = "datacenter-eip"
  }
}