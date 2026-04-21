# Task 003: Enforcing IAM Naming Standards and Permissions Using Terraform

The Nautilus DevOps team is adopting strict naming conventions for all IAM resources using Terraform. They’ve asked for help enforcing lowercase, hyphenated names based on inputs like project and team.

Your task as a DevOps engineer is to complete the following using Terraform:

1. Create an `IAM User` The user name must be derived using the format `project-team-user`, all lowercase, and non-alphanumeric characters (except dashes) replaced with `-`.

2. Create an `IAM Role` Use the same naming logic for the role name, ending in `-role`, and attach an assume role policy for EC2.

3. Tagging: Both resources must be tagged with:

- `Project`: nautilus
- `Team`: dev-team
- `ManagedBy`: Terraform
- `Env`: dev

Additionally, the IAM role should have:

- `RoleType`: EC2

4. Use `locals` block within `main.tf` to:

- Derive sanitized project/team names
- Create the resource name prefix
- Define reusable common tags

5. Create the `main.tf` file (do not create a separate .tf file) to provision the IAM Role & User as per the required values.

6. Use `variables.tf` file with the following:

- `KKE_PROJECT`: name of the project(must be non-empty).
- `KKE_TEAM`: name of the team (only letters, digits, dashes or underscores)
- `KKE_ENVIRONMENT`: name of the environment

7. Use `terraform.tfvars` file to input the values.

8. Use `outputs.tf` file to output the following:

- `kke_user_name`: name of the created user.
- `kke_role_name`: name of the created role.
- `kke_tags_applied`: tags applied to the IAM User.

## Solutions

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.kke_role will be created
  + resource "aws_iam_role" "kke_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "nautilus-dev-team-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Env"       = "dev"
          + "ManagedBy" = "Terraform"
          + "Project"   = "nautilus"
          + "RoleType"  = "EC2"
          + "Team"      = "dev-team"
        }
      + tags_all              = {
          + "Env"       = "dev"
          + "ManagedBy" = "Terraform"
          + "Project"   = "nautilus"
          + "RoleType"  = "EC2"
          + "Team"      = "dev-team"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_user.kke_user will be created
  + resource "aws_iam_user" "kke_user" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "nautilus-dev-team-user"
      + path          = "/"
      + tags          = {
          + "Env"       = "dev"
          + "ManagedBy" = "Terraform"
          + "Project"   = "nautilus"
          + "Team"      = "dev-team"
        }
      + tags_all      = {
          + "Env"       = "dev"
          + "ManagedBy" = "Terraform"
          + "Project"   = "nautilus"
          + "Team"      = "dev-team"
        }
      + unique_id     = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_role_name    = "nautilus-dev-team-role"
  + kke_tags_applied = {
      + Env       = "dev"
      + ManagedBy = "Terraform"
      + Project   = "nautilus"
      + Team      = "dev-team"
    }
  + kke_user_name    = "nautilus-dev-team-user"
aws_iam_user.kke_user: Creating...
aws_iam_role.kke_role: Creating...
aws_iam_user.kke_user: Creation complete after 0s [id=nautilus-dev-team-user]
aws_iam_role.kke_role: Creation complete after 0s [id=nautilus-dev-team-role]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kke_role_name = "nautilus-dev-team-role"
kke_tags_applied = tomap({
  "Env" = "dev"
  "ManagedBy" = "Terraform"
  "Project" = "nautilus"
  "Team" = "dev-team"
})
kke_user_name = "nautilus-dev-team-user"
```

## Verifications

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_iam_role.kke_role:
resource "aws_iam_role" "kke_role" {
    arn                   = "arn:aws:iam::000000000000:role/nautilus-dev-team-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-21T08:13:57Z"
    description           = null
    force_detach_policies = false
    id                    = "nautilus-dev-team-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "nautilus-dev-team-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags                  = {
        "Env"       = "dev"
        "ManagedBy" = "Terraform"
        "Project"   = "nautilus"
        "RoleType"  = "EC2"
        "Team"      = "dev-team"
    }
    tags_all              = {
        "Env"       = "dev"
        "ManagedBy" = "Terraform"
        "Project"   = "nautilus"
        "RoleType"  = "EC2"
        "Team"      = "dev-team"
    }
    unique_id             = "AROAQAAAAAAALA5VZBSJ7"
}

# aws_iam_user.kke_user:
resource "aws_iam_user" "kke_user" {
    arn                  = "arn:aws:iam::000000000000:user/nautilus-dev-team-user"
    force_destroy        = false
    id                   = "nautilus-dev-team-user"
    name                 = "nautilus-dev-team-user"
    path                 = "/"
    permissions_boundary = null
    tags                 = {
        "Env"       = "dev"
        "ManagedBy" = "Terraform"
        "Project"   = "nautilus"
        "Team"      = "dev-team"
    }
    tags_all             = {
        "Env"       = "dev"
        "ManagedBy" = "Terraform"
        "Project"   = "nautilus"
        "Team"      = "dev-team"
    }
    unique_id            = "3k5dryt6f46om94gfplp"
}


Outputs:

kke_role_name = "nautilus-dev-team-role"
kke_tags_applied = {
    "Env"       = "dev"
    "ManagedBy" = "Terraform"
    "Project"   = "nautilus"
    "Team"      = "dev-team"
}
kke_user_name = "nautilus-dev-team-user"
```