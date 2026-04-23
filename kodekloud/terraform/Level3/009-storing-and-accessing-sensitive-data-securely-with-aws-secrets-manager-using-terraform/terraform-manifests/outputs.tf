# - `kke_secret_arn`: arn of the secret created.
output "kke_secret_arn" {
  description = "ARN of the secret created in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.datacenter_db_password.arn
}
# - `kke_secret_string`: database password.
output "kke_secret_string" {
  description = "Database password stored in AWS Secrets Manager"
  value       = aws_secretsmanager_secret_version.datacenter_db_password.secret_string
  sensitive   = true
}