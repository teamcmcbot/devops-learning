# Provision a Secrets Manager secret`. 
resource "aws_secretsmanager_secret" "secret" {
  name = "${var.KKE_SECRET_NAME}"

  tags = {
    Environment = "${var.KKE_ENV}"
  }
}   

# 2. Create a secret value `xfusion-<env>-value`.(dev & prod).
resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = "${var.KKE_SECRET_VALUE}"
}