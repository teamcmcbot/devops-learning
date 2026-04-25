# - `kke_instance_name`: Name of the created EC2 instance.
output "kke_instance_name" {
  description = "Name of the created EC2 instance."
  value       = aws_instance.compute.tags["Name"]
}
