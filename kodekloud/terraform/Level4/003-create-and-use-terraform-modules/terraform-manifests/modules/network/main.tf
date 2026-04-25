# Resource-1: VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.KKE_VPC_CIDR
  tags = merge(var.KKE_TAGS, {
    Name = "${var.KKE_NAME_PREFIX}-vpc"
  })
}

# Resource-2: Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 1)

  tags = merge(var.KKE_TAGS, {
    Name = "${var.KKE_NAME_PREFIX}-subnet"
  })
}
