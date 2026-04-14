# variable "KKE_VPC_CIDR" {
#   description = "CIDR block of the VPC to be created"
#   type        = string
# }

# variable "KKE_SUBNET_CIDR" {
#   description = "CIDR block of the Subnet to be created"
#   type        = string
# }

# variable "app_ami_id" {
#   description = "Optional AMI ID for app instances. When null or empty, latest Amazon Linux 2023 AMI is used."
#   type        = string
#   nullable    = true
#   default     = null
# }

variable "KKE_INSTANCE_COUNT" {
  description = "Number of instances"
  type        = number
}

variable "KKE_INSTANCE_TYPE" {
  description = "Type of the instance"
  type        = string
}

variable "KKE_KEY_NAME" {
  description = "Name of key used"
  type        = string
}

variable "KKE_INSTANCE_PREFIX" {
  description = "Name of the instance"
  type        = string
}

