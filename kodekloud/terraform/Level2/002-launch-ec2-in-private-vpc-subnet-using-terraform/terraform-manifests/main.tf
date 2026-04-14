resource "aws_vpc" "devops-priv-vpc" {
  cidr_block       = var.KKE_VPC_CIDR
  instance_tenancy = "default"

  tags = {
    Name = "devops-priv-vpc"
  }
}

resource "aws_subnet" "devops-priv-subnet" {
  vpc_id     = aws_vpc.devops-priv-vpc.id
  cidr_block = var.KKE_SUBNET_CIDR

  tags = {
    Name = "devops-priv-subnet"
  }

  ## `auto-assign` IP option must not be enabled
  map_public_ip_on_launch = false

  depends_on = [ aws_vpc.devops-priv-vpc ]
}

# Create an EC2 instance named `devops-priv-ec2` inside the subnet and instance type must be `t2.micro`.

resource "aws_security_group" "private-sg" {
  name        = "devops-priv-sg"
  description = "Security group for devops-priv-ec2"
  vpc_id      = aws_vpc.devops-priv-vpc.id

  tags = {
    Name = "devops-priv-sg"
  }
}

resource "aws_security_group_rule" "allow_vpc_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private-sg.id
  cidr_blocks       = [var.KKE_VPC_CIDR]
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "example" {
  ami           = var.app_ami_id != null ? var.app_ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.devops-priv-subnet.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]

  tags = {
    Name = "devops-priv-ec2"
  }
}