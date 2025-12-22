
resource "aws_secretsmanager_secret" "datacenter_secret" {
  name = "datacenter-secret"
}

# The map here can come from other supported configurations
# like locals, resource attribute, map() built-in, etc.
variable "secret_keys_values" {
  default = {
    username = "admin"
    password = "Namin123"
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "datacenter_secret_version" {
  secret_id     = aws_secretsmanager_secret.datacenter_secret.id
  secret_string = jsonencode(var.secret_keys_values)
}
