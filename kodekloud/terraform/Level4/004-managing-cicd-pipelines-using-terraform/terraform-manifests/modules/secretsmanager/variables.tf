variable "KKE_ENV" {
  description = "Environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "KKE_SECRET_NAME" {
  description = "Name of the Secrets Manager secret to create."
  type        = string
}

variable "KKE_SECRET_VALUE" {
  description = "Value of the Secrets Manager secret to create."
  type        = string
}