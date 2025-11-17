# Input Variables
# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key Pair that need to be associated with EC2 Instance"
  type        = string
  default     = "terraform-us-east-1-key"
}

# AWS EC2 Instance Type - List
variable "instance_type_list" {
  description = "List of EC2 instance types"
  type        = list(string)
  default     = ["t3.nano", "t3.micro", "t3.small"]
}

# AWS EC2 Instance Type - Map
variable "instance_type_map" {
  description = "Map of EC2 instance types"
  type        = map(string)
  default = {
    dev = "t3.nano"
    stg = "t3.small"
    prd = "t3.medium"
  }
}
