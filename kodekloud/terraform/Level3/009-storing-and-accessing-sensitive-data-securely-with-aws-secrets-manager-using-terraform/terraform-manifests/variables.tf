# - `KKE_DB_PASSWORD`: database password stored in secrets manager.
variable "KKE_DB_PASSWORD" {
  description = "Database password stored in AWS Secrets Manager"
  type        = string
  sensitive   = true
}