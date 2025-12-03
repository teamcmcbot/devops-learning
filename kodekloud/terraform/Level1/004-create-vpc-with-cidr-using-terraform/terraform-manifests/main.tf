resource "aws_vpc" "devops-vpc" {
  cidr_block       = "192.168.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "devops-vpc"
  }
}
