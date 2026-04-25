# - `kke_vpc_name`: Name of the created VPC.
output "kke_vpc_name" {
  description = "Name of the created VPC."
  value       = aws_vpc.main_vpc.tags["Name"]
}

# - `kke_subnet_name`: Name of the created Subnet.
output "kke_subnet_name" {
  description = "Name of the created Subnet."
  value       = aws_subnet.public_subnet.tags["Name"]
}

# - `kke_subnet_id`: ID of the created Subnet. Required for EC2 instance creation.
output "kke_subnet_id" {
  description = "ID of the created Subnet."
  value       = aws_subnet.public_subnet.id
}
