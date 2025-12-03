# Get Default VPC ID
data "aws_vpc" "default" {
  default = true
}

# Create Security Grouprovider 
module "datacenter-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name            = "datacenter-sg"
  use_name_prefix = false
  description     = "Security group for Nautilus App Servers"
  vpc_id          = data.aws_vpc.default.id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule
  egress_rules = ["all-all"]

}
