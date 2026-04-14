# `KKE_instance_name` and the Elastic IP using variable `KKE_eip`.
output "KKE_instance_name" {
  description = "Name of the instance"
  value       = aws_instance.ec2-instance.tags["Name"]
}

output "KKE_eip" {
  description = "Elastic IP of the instance"
  value       = aws_eip.datacenter-eip.public_ip
}