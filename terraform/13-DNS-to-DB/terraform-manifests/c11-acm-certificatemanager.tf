# ACM Module - To create and Verify SSL Certificates
module "acm" {
  source = "terraform-aws-modules/acm/aws"
  #version = "2.14.0"
  #version = "5.0.0"
  version = "6.1.1"

  domain_name = "dns-to-db.${var.domain_name}" # Changed: specific subdomain only
  zone_id     = data.aws_route53_zone.mydomain.zone_id

  # Removed subject_alternative_names - not needed for single domain
  # subject_alternative_names = [
  #   "apps.${var.domain_name}"
  # ]
  tags = local.common_tags

  # Module Upgrade Change-1
  # Validation Method
  validation_method   = "DNS"
  wait_for_validation = true
}

# Output ACM Certificate ARN
output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  # Module Upgrade Change-2  
  #value       = module.acm.this_acm_certificate_arn
  value = module.acm.acm_certificate_arn
}

