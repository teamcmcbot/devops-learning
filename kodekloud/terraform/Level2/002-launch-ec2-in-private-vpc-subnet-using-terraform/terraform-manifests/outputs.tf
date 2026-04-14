# KKE_vpc_name for the name of the VPC.
output "KKE_vpc_name" {
  value = aws_vpc.devops-priv-vpc.tags["Name"]
}

# KKE_subnet_name for the name of the subnet.
output "KKE_subnet_name" {
  value = aws_subnet.devops-priv-subnet.tags["Name"]
}

# KKE_ec2_private for the name of the EC2 instance.
output "KKE_ec2_private" {
  value = aws_instance.example.tags["Name"]
}