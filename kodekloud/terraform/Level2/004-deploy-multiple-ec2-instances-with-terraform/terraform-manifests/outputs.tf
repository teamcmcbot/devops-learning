# kke_instance_names: names of the instances created.
output "kke_instance_names" {
  description = "Names of the instances created."
  value       = [for i in aws_instance.example : i.tags["Name"]]
}