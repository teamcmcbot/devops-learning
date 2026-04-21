locals {
  project_sanitized = replace(lower(var.KKE_PROJECT), "/[^a-z0-9-]/", "-")
  team_sanitized    = replace(lower(var.KKE_TEAM), "/[^a-z0-9-]/", "-")

  name_prefix = "${local.project_sanitized}-${local.team_sanitized}"

  common_tags = {
    Project   = var.KKE_PROJECT
    Team      = var.KKE_TEAM
    ManagedBy = "Terraform"
    Env       = var.KKE_ENVIRONMENT
  }
}

resource "aws_iam_user" "kke_user" {
  name = "${local.name_prefix}-user"
  tags = local.common_tags
}

resource "aws_iam_role" "kke_role" {
  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    RoleType = "EC2"
  })
}