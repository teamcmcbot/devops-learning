resource "aws_vpc" "datacenter-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.KKE_VPC_NAME
  }
}

resource "aws_subnet" "datacenter-subnet" {
  vpc_id     = aws_vpc.datacenter-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = var.KKE_SUBNET_NAME
  }

  depends_on = [ aws_vpc.datacenter-vpc ]
}