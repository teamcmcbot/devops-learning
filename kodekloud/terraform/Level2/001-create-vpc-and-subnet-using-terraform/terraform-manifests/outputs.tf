output "kke_vpc_name" {
  description = "Name of the VPC created"
  value       = aws_vpc.datacenter-vpc.tags["Name"]
}

output "kke_subnet_name" {
  description = "Name of the Subnet created"
  value       = aws_subnet.datacenter-subnet.tags["Name"]
}