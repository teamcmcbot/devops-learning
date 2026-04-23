# - `KKE_API_NAMES` = Names of API Gateways to create.
variable "KKE_API_NAMES" {
  description = "Names of API Gateways to create"
  type        = list(string)
}