# - `KKE_ENV`: name of the Environment used.(dev or prod)
variable "KKE_ENV" {
  description = "Name of the Environment used.(dev or prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.KKE_ENV)
    error_message = "KKE_ENV must be dev or prod."
  }
}

# - `KKE_DYNAMODB_TABLE_NAME`: name of the dynamodb table.
variable "KKE_DYNAMODB_TABLE_NAME" {
  description = "Name of the dynamodb table."
  type        = string
  default = null
}

# - `KKE_SECRET_NAME`: name of the secret.
variable "KKE_SECRET_NAME" {
  description = "Name of the secret."
  type        = string
  default = null
}

# - `KKE_SECRET_VALUE`: secret value.
variable "KKE_SECRET_VALUE" {
  description = "Secret value."
  type        = string
  default = null
}

# - `KKE_ELASTICSEARCH_DOMAIN`: domain of the elasticsearch.
variable "KKE_ELASTICSEARCH_DOMAIN" {
  description = "Domain of the elasticsearch."
  type        = string
  default = null
}