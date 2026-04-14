variable "KKE_VPC_CIDR" {
  description = "CIDR block of the VPC to be created"
  type        = string
}

variable "KKE_SUBNET_CIDR" {
  description = "CIDR block of the Subnet to be created"
  type        = string
}

variable "app_ami_id" {
  description = "Optional AMI ID for app instances. When null or empty, latest Amazon Linux 2023 AMI is used."
  type        = string
  nullable    = true
  default     = null
}