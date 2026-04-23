# Task 010: Managing Terraform Workspaces for Environment Isolation Using Terraform

The DevOps team is tasked with provisioning multiple `API Gateway REST APIs` and corresponding `CloudWatch Log Groups` using the following Terraform features:

1. Create two workspaces named `dev` and `prod`.

2. Create API Gateways named `dev-devops-api-1` and `prod-devops-api-2`.

3. Create matching CloudWatch Log Groups named `/aws/apigateway/dev-devops-api-1` and `/aws/apigateway/prod-devops-api-2`.

4. Use the `count` meta-argument to create multiple API Gateway REST APIs and matching log groups.

5. Leverage `terraform workspaces` to differentiate API Gateway names per environment.

6. Use `local-exec` provisioner to write a confirmation message to a log file once each resource is created.(e.g., Created API Gateway `dev-devops-api-2` in workspace dev).

7. Create two different files `apigateway.log` and `loggroups.log` in `/home/bob/terraform` to log the creation of each resource in their respective files.

8. Use a list variable `KKE_API_NAMES` to define API names (e.g., `["devops-api-1", "devops-api-2"]`).

9. Create `main.tf` file (do not create a separate .tf file) to provision the api gateway with matching log groups in different workspaces.

10. Use `variables.tf` file with the following:

- `KKE_API_NAMES` = Names of API Gateways to create.

11. Use `terraform.tfvars` file to input the names of the API Gateways.

12. Use `outputs.tf` file to output the following in the two different workspces ( devand prod).

- `kke_api_gateway_names`= name of the api gateway created.
- `kke_log_group_names`= name of the matching logroups created.

## Create Terraform Workspaces

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

bob@iac-server ~/terraform via 💠 prod ➜  terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

bob@iac-server ~/terraform via 💠 dev ➜  
```

## Solution

### DEV Workspace

```bash
bob@iac-server ~/terraform via 💠 dev ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_api_gateway_rest_api.kke_api[0] will be created
  + resource "aws_api_gateway_rest_api" "kke_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = (known after apply)
      + name                         = "dev-devops-api-1"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)

      + endpoint_configuration (known after apply)
    }

  # aws_api_gateway_rest_api.kke_api[1] will be created
  + resource "aws_api_gateway_rest_api" "kke_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = (known after apply)
      + name                         = "dev-devops-api-2"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)

      + endpoint_configuration (known after apply)
    }

  # aws_cloudwatch_log_group.kke_api_logs[0] will be created
  + resource "aws_cloudwatch_log_group" "kke_api_logs" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + log_group_class   = (known after apply)
      + name              = "/aws/apigateway/dev-devops-api-1"
      + name_prefix       = (known after apply)
      + retention_in_days = 0
      + skip_destroy      = false
      + tags_all          = (known after apply)
    }

  # aws_cloudwatch_log_group.kke_api_logs[1] will be created
  + resource "aws_cloudwatch_log_group" "kke_api_logs" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + log_group_class   = (known after apply)
      + name              = "/aws/apigateway/dev-devops-api-2"
      + name_prefix       = (known after apply)
      + retention_in_days = 0
      + skip_destroy      = false
      + tags_all          = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_api_gateway_names = [
      + "dev-devops-api-1",
      + "dev-devops-api-2",
    ]
  + kke_log_group_names   = [
      + "/aws/apigateway/dev-devops-api-1",
      + "/aws/apigateway/dev-devops-api-2",
    ]
aws_api_gateway_rest_api.kke_api[1]: Creating...
aws_api_gateway_rest_api.kke_api[0]: Creating...
aws_api_gateway_rest_api.kke_api[0]: Provisioning with 'local-exec'...
aws_api_gateway_rest_api.kke_api[0] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created API Gateway dev-devops-api-1 in workspace dev\" >> /home/bob/terraform/apigateway.log\n"]
aws_api_gateway_rest_api.kke_api[1]: Provisioning with 'local-exec'...
aws_api_gateway_rest_api.kke_api[1] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created API Gateway dev-devops-api-2 in workspace dev\" >> /home/bob/terraform/apigateway.log\n"]
aws_api_gateway_rest_api.kke_api[0]: Creation complete after 3s [id=krehr7fqm0]
aws_api_gateway_rest_api.kke_api[1]: Creation complete after 3s [id=rk5pdtskir]
aws_cloudwatch_log_group.kke_api_logs[1]: Creating...
aws_cloudwatch_log_group.kke_api_logs[0]: Creating...
aws_cloudwatch_log_group.kke_api_logs[1]: Provisioning with 'local-exec'...
aws_cloudwatch_log_group.kke_api_logs[1] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created Log Group /aws/apigateway/dev-devops-api-2 in workspace dev\" >> /home/bob/terraform/loggroups.log\n"]
aws_cloudwatch_log_group.kke_api_logs[0]: Provisioning with 'local-exec'...
aws_cloudwatch_log_group.kke_api_logs[0] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created Log Group /aws/apigateway/dev-devops-api-1 in workspace dev\" >> /home/bob/terraform/loggroups.log\n"]
aws_cloudwatch_log_group.kke_api_logs[1]: Creation complete after 0s [id=/aws/apigateway/dev-devops-api-2]
aws_cloudwatch_log_group.kke_api_logs[0]: Creation complete after 0s [id=/aws/apigateway/dev-devops-api-1]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_api_gateway_names = [
  "dev-devops-api-1",
  "dev-devops-api-2",
]
kke_log_group_names = [
  "/aws/apigateway/dev-devops-api-1",
  "/aws/apigateway/dev-devops-api-2",
]
```

### PROD Workspace

```bash
bob@iac-server ~/terraform via 💠 prod ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_api_gateway_rest_api.kke_api[0] will be created
  + resource "aws_api_gateway_rest_api" "kke_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = (known after apply)
      + name                         = "prod-devops-api-1"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)

      + endpoint_configuration (known after apply)
    }

  # aws_api_gateway_rest_api.kke_api[1] will be created
  + resource "aws_api_gateway_rest_api" "kke_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = (known after apply)
      + name                         = "prod-devops-api-2"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)

      + endpoint_configuration (known after apply)
    }

  # aws_cloudwatch_log_group.kke_api_logs[0] will be created
  + resource "aws_cloudwatch_log_group" "kke_api_logs" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + log_group_class   = (known after apply)
      + name              = "/aws/apigateway/prod-devops-api-1"
      + name_prefix       = (known after apply)
      + retention_in_days = 0
      + skip_destroy      = false
      + tags_all          = (known after apply)
    }

  # aws_cloudwatch_log_group.kke_api_logs[1] will be created
  + resource "aws_cloudwatch_log_group" "kke_api_logs" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + log_group_class   = (known after apply)
      + name              = "/aws/apigateway/prod-devops-api-2"
      + name_prefix       = (known after apply)
      + retention_in_days = 0
      + skip_destroy      = false
      + tags_all          = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_api_gateway_names = [
      + "prod-devops-api-1",
      + "prod-devops-api-2",
    ]
  + kke_log_group_names   = [
      + "/aws/apigateway/prod-devops-api-1",
      + "/aws/apigateway/prod-devops-api-2",
    ]
aws_api_gateway_rest_api.kke_api[0]: Creating...
aws_api_gateway_rest_api.kke_api[1]: Creating...
aws_api_gateway_rest_api.kke_api[1]: Provisioning with 'local-exec'...
aws_api_gateway_rest_api.kke_api[0]: Provisioning with 'local-exec'...
aws_api_gateway_rest_api.kke_api[1] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created API Gateway prod-devops-api-2 in workspace prod\" >> /home/bob/terraform/apigateway.log\n"]
aws_api_gateway_rest_api.kke_api[0] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created API Gateway prod-devops-api-1 in workspace prod\" >> /home/bob/terraform/apigateway.log\n"]
aws_api_gateway_rest_api.kke_api[0]: Creation complete after 0s [id=5qx2oet3it]
aws_api_gateway_rest_api.kke_api[1]: Creation complete after 0s [id=xbuzpg0lsy]
aws_cloudwatch_log_group.kke_api_logs[0]: Creating...
aws_cloudwatch_log_group.kke_api_logs[1]: Creating...
aws_cloudwatch_log_group.kke_api_logs[0]: Provisioning with 'local-exec'...
aws_cloudwatch_log_group.kke_api_logs[0] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created Log Group /aws/apigateway/prod-devops-api-1 in workspace prod\" >> /home/bob/terraform/loggroups.log\n"]
aws_cloudwatch_log_group.kke_api_logs[1]: Provisioning with 'local-exec'...
aws_cloudwatch_log_group.kke_api_logs[1] (local-exec): Executing: ["/bin/sh" "-c" "mkdir -p /home/bob/terraform\necho \"Created Log Group /aws/apigateway/prod-devops-api-2 in workspace prod\" >> /home/bob/terraform/loggroups.log\n"]
aws_cloudwatch_log_group.kke_api_logs[0]: Creation complete after 0s [id=/aws/apigateway/prod-devops-api-1]
aws_cloudwatch_log_group.kke_api_logs[1]: Creation complete after 0s [id=/aws/apigateway/prod-devops-api-2]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_api_gateway_names = [
  "prod-devops-api-1",
  "prod-devops-api-2",
]
kke_log_group_names = [
  "/aws/apigateway/prod-devops-api-1",
  "/aws/apigateway/prod-devops-api-2",
]

```

## Verification

### DEV Workspace

```bash
bob@iac-server ~/terraform via 💠 dev ➜  terraform show
# aws_api_gateway_rest_api.kke_api[0]:
resource "aws_api_gateway_rest_api" "kke_api" {
    api_key_source               = "HEADER"
    arn                          = "arn:aws:apigateway:us-east-1::/restapis/krehr7fqm0"
    binary_media_types           = []
    created_date                 = "2026-04-23T12:18:00Z"
    description                  = null
    disable_execute_api_endpoint = false
    execution_arn                = "arn:aws:execute-api:us-east-1::krehr7fqm0"
    id                           = "krehr7fqm0"
    minimum_compression_size     = null
    name                         = "dev-devops-api-1"
    policy                       = null
    root_resource_id             = "bm50udzo2r"
    tags_all                     = {}

    endpoint_configuration {
        types            = [
            "EDGE",
        ]
        vpc_endpoint_ids = []
    }
}

# aws_api_gateway_rest_api.kke_api[1]:
resource "aws_api_gateway_rest_api" "kke_api" {
    api_key_source               = "HEADER"
    arn                          = "arn:aws:apigateway:us-east-1::/restapis/rk5pdtskir"
    binary_media_types           = []
    created_date                 = "2026-04-23T12:18:00Z"
    description                  = null
    disable_execute_api_endpoint = false
    execution_arn                = "arn:aws:execute-api:us-east-1::rk5pdtskir"
    id                           = "rk5pdtskir"
    minimum_compression_size     = null
    name                         = "dev-devops-api-2"
    policy                       = null
    root_resource_id             = "noem05wc7f"
    tags_all                     = {}

    endpoint_configuration {
        types            = [
            "EDGE",
        ]
        vpc_endpoint_ids = []
    }
}

# aws_cloudwatch_log_group.kke_api_logs[0]:
resource "aws_cloudwatch_log_group" "kke_api_logs" {
    arn               = "arn:aws:logs:us-east-1:000000000000:log-group:/aws/apigateway/dev-devops-api-1"
    id                = "/aws/apigateway/dev-devops-api-1"
    kms_key_id        = null
    log_group_class   = null
    name              = "/aws/apigateway/dev-devops-api-1"
    name_prefix       = null
    retention_in_days = 0
    skip_destroy      = false
    tags_all          = {}
}

# aws_cloudwatch_log_group.kke_api_logs[1]:
resource "aws_cloudwatch_log_group" "kke_api_logs" {
    arn               = "arn:aws:logs:us-east-1:000000000000:log-group:/aws/apigateway/dev-devops-api-2"
    id                = "/aws/apigateway/dev-devops-api-2"
    kms_key_id        = null
    log_group_class   = null
    name              = "/aws/apigateway/dev-devops-api-2"
    name_prefix       = null
    retention_in_days = 0
    skip_destroy      = false
    tags_all          = {}
}


Outputs:

kke_api_gateway_names = [
    "dev-devops-api-1",
    "dev-devops-api-2",
]
kke_log_group_names = [
    "/aws/apigateway/dev-devops-api-1",
    "/aws/apigateway/dev-devops-api-2",
]

```

### PROD Workspace

```bash
bob@iac-server ~/terraform via 💠 prod ➜  terraform show
# aws_api_gateway_rest_api.kke_api[0]:
resource "aws_api_gateway_rest_api" "kke_api" {
    api_key_source               = "HEADER"
    arn                          = "arn:aws:apigateway:us-east-1::/restapis/5qx2oet3it"
    binary_media_types           = []
    created_date                 = "2026-04-23T12:19:47Z"
    description                  = null
    disable_execute_api_endpoint = false
    execution_arn                = "arn:aws:execute-api:us-east-1::5qx2oet3it"
    id                           = "5qx2oet3it"
    minimum_compression_size     = null
    name                         = "prod-devops-api-1"
    policy                       = null
    root_resource_id             = "dgkljr8h0y"
    tags_all                     = {}

    endpoint_configuration {
        types            = [
            "EDGE",
        ]
        vpc_endpoint_ids = []
    }
}

# aws_api_gateway_rest_api.kke_api[1]:
resource "aws_api_gateway_rest_api" "kke_api" {
    api_key_source               = "HEADER"
    arn                          = "arn:aws:apigateway:us-east-1::/restapis/xbuzpg0lsy"
    binary_media_types           = []
    created_date                 = "2026-04-23T12:19:47Z"
    description                  = null
    disable_execute_api_endpoint = false
    execution_arn                = "arn:aws:execute-api:us-east-1::xbuzpg0lsy"
    id                           = "xbuzpg0lsy"
    minimum_compression_size     = null
    name                         = "prod-devops-api-2"
    policy                       = null
    root_resource_id             = "8cnf3m9j2p"
    tags_all                     = {}

    endpoint_configuration {
        types            = [
            "EDGE",
        ]
        vpc_endpoint_ids = []
    }
}

# aws_cloudwatch_log_group.kke_api_logs[0]:
resource "aws_cloudwatch_log_group" "kke_api_logs" {
    arn               = "arn:aws:logs:us-east-1:000000000000:log-group:/aws/apigateway/prod-devops-api-1"
    id                = "/aws/apigateway/prod-devops-api-1"
    kms_key_id        = null
    log_group_class   = null
    name              = "/aws/apigateway/prod-devops-api-1"
    name_prefix       = null
    retention_in_days = 0
    skip_destroy      = false
    tags_all          = {}
}

# aws_cloudwatch_log_group.kke_api_logs[1]:
resource "aws_cloudwatch_log_group" "kke_api_logs" {
    arn               = "arn:aws:logs:us-east-1:000000000000:log-group:/aws/apigateway/prod-devops-api-2"
    id                = "/aws/apigateway/prod-devops-api-2"
    kms_key_id        = null
    log_group_class   = null
    name              = "/aws/apigateway/prod-devops-api-2"
    name_prefix       = null
    retention_in_days = 0
    skip_destroy      = false
    tags_all          = {}
}


Outputs:

kke_api_gateway_names = [
    "prod-devops-api-1",
    "prod-devops-api-2",
]
kke_log_group_names = [
    "/aws/apigateway/prod-devops-api-1",
    "/aws/apigateway/prod-devops-api-2",
]

```

### Outputs
```bash
bob@iac-server ~/terraform via 💠 prod ➜  terraform workspace select dev
Switched to workspace "dev".

bob@iac-server ~/terraform via 💠 dev ➜  terraform output
kke_api_gateway_names = [
  "dev-devops-api-1",
  "dev-devops-api-2",
]
kke_log_group_names = [
  "/aws/apigateway/dev-devops-api-1",
  "/aws/apigateway/dev-devops-api-2",
]

bob@iac-server ~/terraform via 💠 dev ➜  terraform workspace select prod
Switched to workspace "prod".

bob@iac-server ~/terraform via 💠 prod ➜  terraform output
kke_api_gateway_names = [
  "prod-devops-api-1",
  "prod-devops-api-2",
]
kke_log_group_names = [
  "/aws/apigateway/prod-devops-api-1",
  "/aws/apigateway/prod-devops-api-2",
]
```
## apigateway.log
```log 
Created API Gateway dev-devops-api-1 in workspace dev
Created API Gateway dev-devops-api-2 in workspace dev
Created API Gateway prod-devops-api-1 in workspace prod
Created API Gateway prod-devops-api-2 in workspace prod

```

## loggroups.log
```log
Created Log Group /aws/apigateway/dev-devops-api-2 in workspace dev
Created Log Group /aws/apigateway/dev-devops-api-1 in workspace dev
Created Log Group /aws/apigateway/prod-devops-api-1 in workspace prod
Created Log Group /aws/apigateway/prod-devops-api-2 in workspace prod

```
