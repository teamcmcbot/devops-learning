# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id     = ""
  vpc_security_group_ids = [
    "sg-d4916cdf44d98e99c"
  ]

  tags = {
    Name = "datacenter-ec2"
  }
}
