# 5. Use `variables.tf` file from the root module with the following variable names:

# - `KKE_VPC_CIDR`: CIDR block for the VPC (`10.0.0.0/16`).
variable "KKE_VPC_CIDR" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# - `KKE_INSTANCE_TYPE`: EC2 instance type.
variable "KKE_INSTANCE_TYPE" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  # - Use validation in `variables.tf` to ensure that `KKE_INSTANCE_TYPE` only accepts `t3.micro` or `t3.large`, and display an appropriate error message if any other value is provided.
  validation {
    condition     = contains(["t3.micro", "t3.large"], var.KKE_INSTANCE_TYPE)
    error_message = "Invalid instance type. Allowed values are 't3.micro' or 't3.large'."
  }
}

