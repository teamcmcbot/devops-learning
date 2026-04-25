# 3. Use a `locals` block in the root module to define:

# - A common name prefix: `devops-${terraform.workspace}`.
# - Default tags with keys `Project = devops` and `Environment = terraform.workspace`.

locals {
  common_name_prefix = "devops-${terraform.workspace}"
  default_tags = {
    Project     = "devops"
    Environment = terraform.workspace
  }
}

# Create VPC via the `network` module and pass the required variables.
module "network" {
  source = "./modules/network"
    KKE_NAME_PREFIX = local.common_name_prefix
    KKE_VPC_CIDR = var.KKE_VPC_CIDR
    KKE_TAGS = local.default_tags
}

# Create EC2 instance via the `compute` module and pass the required variables.
module "compute" {
  source = "./modules/compute"
    KKE_NAME_PREFIX = local.common_name_prefix
    KKE_SUBNET_ID = module.network.kke_subnet_id
    KKE_INSTANCE_TYPE = var.KKE_INSTANCE_TYPE
    KKE_TAGS = local.default_tags
}