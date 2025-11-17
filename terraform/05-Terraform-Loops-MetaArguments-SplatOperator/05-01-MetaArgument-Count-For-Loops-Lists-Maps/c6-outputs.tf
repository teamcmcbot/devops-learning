# Terraform Output Values
/* Concepts Covered
1. For Loop with List
2. For Loop with Map
3. For Loop with Map Advanced
4. Legacy Splat Operator (latest) - Returns List
5. Latest Generalized Splat Operator - Returns the List
*/

# Output - For Loop with List
output "for_output_list" {
  description = "For Loop with List"
  value       = [for instance in aws_instance.myec2vm : instance.public_dns]
}

# Output - For Loop with Map
output "for_output_map1" {
  description = "For Loop with Map"
  value       = { for instance in aws_instance.myec2vm : instance.id => instance.public_dns }
}

# Output - For Loop with Map Advanced
output "for_output_map2" {
  description = "For Loop with Map - Advanced"
  value       = { for c, instance in aws_instance.myec2vm : c => instance.public_dns }
}

# Output Legacy Splat Operator (Legacy) - Returns the List
/*
output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Operator"
  value = aws_instance.myec2vm.*.public_dns
}
*/

# Output Latest Generalized Splat Operator - Returns the List
output "latest_splat_instance_publicdns" {
  description = "Generalized latest Splat Operator"
  value       = aws_instance.myec2vm[*].public_dns
}


# Outputs:

# for_output_list = [
#   "ec2-44-210-78-188.compute-1.amazonaws.com",
#   "ec2-44-200-78-0.compute-1.amazonaws.com",
# ]
# for_output_map1 = {
#   "i-02e20661d0a4366ce" = "ec2-44-210-78-188.compute-1.amazonaws.com"
#   "i-048ed6ae0d6e59b37" = "ec2-44-200-78-0.compute-1.amazonaws.com"
# }
# for_output_map2 = {
#   "0" = "ec2-44-210-78-188.compute-1.amazonaws.com"
#   "1" = "ec2-44-200-78-0.compute-1.amazonaws.com"
# }
# latest_splat_instance_publicdns = [
#   "ec2-44-210-78-188.compute-1.amazonaws.com",
#   "ec2-44-200-78-0.compute-1.amazonaws.com",
# ]
