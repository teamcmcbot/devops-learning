# - `KKE_NAME_PREFIX`: Name prefix to use for compute resources.
variable "KKE_NAME_PREFIX" {
  description = "Name prefix to use for compute resources."
  type        = string
}

# - `KKE_SUBNET_ID`: Subnet ID where the instance will be created.
variable "KKE_SUBNET_ID" {
  description = "Subnet ID where the instance will be created."
  type        = string
}

# - `KKE_INSTANCE_TYPE`: EC2 instance type.
variable "KKE_INSTANCE_TYPE" {
  description = "EC2 instance type."
  type        = string
}

# - `KKE_TAGS`: Common tags map for compute resources.
variable "KKE_TAGS" {
  description = "Common tags map for compute resources."
  type        = map(string)
}
