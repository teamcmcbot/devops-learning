# - `KKE_NAME_PREFIX`: Name prefix to use for network resources.
variable "KKE_NAME_PREFIX" {
  description = "Name prefix to use for network resources."
  type        = string
}

# - `KKE_VPC_CIDR`: CIDR block for the VPC.
variable "KKE_VPC_CIDR" {
  description = "CIDR block for the VPC."
  type        = string
}

# - `KKE_TAGS`: Common tags map for network resources.
variable "KKE_TAGS" {
  description = "Common tags map for network resources."
  type        = map(string)
}
