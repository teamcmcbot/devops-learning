# - `kke_vpc_name`: Name of the created VPC.
output "kke_vpc_name" {
  description = "Name of the created VPC."
  value       = module.network.kke_vpc_name
}
# - `kke_subnet_name`: Name of the created Subnet.
output "kke_subnet_name" {
  description = "Name of the created Subnet."
  value       = module.network.kke_subnet_name
}
# - `kke_instance_name`: Name of the created EC2 instance.
output "kke_instance_name" {
  description = "Name of the created EC2 instance."
  value       = module.compute.kke_instance_name
}