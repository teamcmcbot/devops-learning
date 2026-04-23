# 1. Create an AWS Secrets Manager secret.
resource "aws_secretsmanager_secret" "datacenter_db_password" {
  name = "datacenter-db-password"
}

# 2. Store the database password in the secret using Terraform.
resource "aws_secretsmanager_secret_version" "datacenter_db_password" {
  secret_id     = aws_secretsmanager_secret.datacenter_db_password.id
  secret_string = var.KKE_DB_PASSWORD
}