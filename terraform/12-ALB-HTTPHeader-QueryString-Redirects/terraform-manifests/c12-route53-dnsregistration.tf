# DNS Registration 
resource "aws_route53_record" "default_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "myapps.${var.domain_name}"
  type    = "A"
  alias {
    #name                   = module.alb.this_lb_dns_name
    #zone_id                = module.alb.this_lb_zone_id
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

# App 1 DNS Registration
resource "aws_route53_record" "app1_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.app1_dns_name
  type    = "A"
  alias {
    #name                   = module.alb.this_lb_dns_name
    #zone_id                = module.alb.this_lb_zone_id
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

# App 2 DNS Registration
resource "aws_route53_record" "app2_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.app2_dns_name
  type    = "A"
  alias {
    #name                   = module.alb.this_lb_dns_name
    #zone_id                = module.alb.this_lb_zone_id
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

# Azure DNS Registration
resource "aws_route53_record" "azure_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.azure_dns_name
  type    = "A"
  alias {
    #name                   = module.alb.this_lb_dns_name
    #zone_id                = module.alb.this_lb_zone_id
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
