# Terraform Block - Configuration settings (TOP-LEVEL BLOCK)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# Provider Block - Provider configuration (TOP-LEVEL BLOCK)
# (This will be added in separate files)

# Variable Block - Input variable (TOP-LEVEL BLOCK)  
# variable "instance_type" {
#   description = "Type of EC2 instance"
#   type        = string
#   default     = "t2.micro"
# }

# Resource Block - Infrastructure resource (TOP-LEVEL BLOCK)
# resource "aws_instance" "example" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
# }

# Output Block - Output value (TOP-LEVEL BLOCK)
# output "instance_id" {
#   value = aws_instance.example.id
# }
