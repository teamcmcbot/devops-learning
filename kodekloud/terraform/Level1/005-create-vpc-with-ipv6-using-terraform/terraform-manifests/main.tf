resource "aws_vpc" "xfusion-vpc" {
  cidr_block                       = "10.1.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "xfusion-vpc"
  }
}
