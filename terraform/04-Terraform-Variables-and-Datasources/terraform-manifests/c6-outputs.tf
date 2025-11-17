# Show ec2 instance pubic dns

output "ec2_instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.myec2vm.public_dns
}

output "ec2_instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.myec2vm.public_ip
}
