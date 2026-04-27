# - `kke_secret_arn` :provides the ARN of the Secrets Manager secret
output "kke_secret_arn" {
  value = aws_secretsmanager_secret.secret.arn
}