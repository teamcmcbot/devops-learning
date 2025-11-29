# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "sap"
}

# Domain Name
variable "domain_name" {
  description = "Domain Name for Route53 Hosted Zone"
  type        = string
  default     = "example.com"
}

# SNS Email Endpoint
variable "sns_email_endpoint" {
  description = "Email Endpoint for SNS Subscription"
  type        = string
  default     = "admin@example.com"
} 
