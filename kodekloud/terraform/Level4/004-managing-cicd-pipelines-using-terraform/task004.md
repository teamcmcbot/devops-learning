# Task 004: Managing CI/CD Pipelines Using Terraform

The xfusion team is designing a Terraform-based infrastructure to simulate real-world, production-grade deployments with strict adherence to best practices. The infrastructure must be reusable, modular, and environment-specific (dev and prod).

Requirements:

1. Create modules under `modules/` named:

- **dynamodb**:Provision a DynamoDB table named `xfusion-<env>-table` (based on the environment)`(dev & prod)`, using `id` as the HASH key.
- **secretsmanager**: to provision a Secrets Manager secret named `xfusion-<env>-secret`.
- **elasticsearch**: to provision an Elasticsearch domain named `xfusion-<env>-es`.

2. Create a secret value `xfusion-<env>-value`.(dev & prod).

3. Each environment `dev` and `prod` MUST be located under `/home/bob/terraform/env/`. Terraform commands will be executed from within each environment directory.

4. Use **absolute-path** symbolic links (`/home/bob/terraform/`) in each environment `dev/prod` for the shared Terraform files `main.tf`, `variables.tf`, and `shared modules`. Within each environment directory, the `modules/` directory MUST be a symbolic link pointing to `/home/bob/terraform/modules`.

- Keep a separate `terraform_config.tf` in each environment to define environment-specific configuration `modules`, `environment variables`, `overrides`. This file should NOT be a symlink.

5. Use `main.tf` file under `/home/bob/terraform` to define all shared resources and environment-specific modules, ensuring clarity, modularity, and maintainability.

6. Use the `variables.tf` file under `/home/bob/terraform` with the following variables:

- `KKE_ENV`: name of the Environment used.(dev or prod)
- `KKE_DYNAMODB_TABLE_NAME`: name of the dynamodb table.
- `KKE_SECRET_NAME`: name of the secret.
- `KKE_SECRET_VALUE`: secret value.
- `KKE_ELASTICSEARCH_DOMAIN`: domain of the elasticsearch.

7. Use `dev.tfvars` and `prod.tfvars` with respect to the `variables.tf` file under `/home/bob/terraform/env/<env-name>/`. Terraform plans will be executed using these files explicitly.

8. Use the following variables to output the following:

- `kke_table_name`:exposes the name of the created DynamoDB table
- `kke_secret_arn` :provides the ARN of the Secrets Manager secret
- `kke_elasticsearch_endpoint`: returns the endpoint of the Elasticsearch domain

Notes:
1. The Terraform working directory is `/home/bob/terraform`.

2. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

3. Ensure all environment directories reference shared modules via symlinks and no module code is duplicated.

4. Ensure that the variables.tf and main.tf files in each environment directory use absolute-path symbolic links.

5. Resources must be named uniquely per environment.

6. Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

## Layout

```bash
/home/bob/terraform/
  main.tf
  variables.tf
  modules/
    dynamodb/
      main.tf
      variables.tf
      outputs.tf
    secretsmanager/
      main.tf
      variables.tf
      outputs.tf
    elasticsearch/
      main.tf
      variables.tf
      outputs.tf
  env/
    dev/
      main.tf -> /home/bob/terraform/main.tf
      variables.tf -> /home/bob/terraform/variables.tf
      modules -> /home/bob/terraform/modules
      terraform_config.tf      # real file
      dev.tfvars               # real file
    prod/
      main.tf -> /home/bob/terraform/main.tf
      variables.tf -> /home/bob/terraform/variables.tf
      modules -> /home/bob/terraform/modules
      terraform_config.tf      # real file
      prod.tfvars              # real file
```

### Create directories and empty files:
```bash
export ROOT_DIR="/home/bob/terraform"

cd "$ROOT_DIR"
mkdir -p modules/dynamodb
mkdir -p modules/secretsmanager
mkdir -p modules/elasticsearch
mkdir -p env/dev
mkdir -p env/prod

# Root files
touch "$ROOT_DIR/main.tf" "$ROOT_DIR/variables.tf"

# Dev files
cd "$ROOT_DIR/env/dev"
touch terraform_config.tf dev.tfvars

# Prod files
cd "$ROOT_DIR/env/prod"
touch terraform_config.tf prod.tfvars

# Modules files
cd "$ROOT_DIR/modules/dynamodb"
touch main.tf variables.tf outputs.tf

cd "$ROOT_DIR/modules/secretsmanager"
touch main.tf variables.tf outputs.tf

cd "$ROOT_DIR/modules/elasticsearch"
touch main.tf variables.tf outputs.tf

# DEV symlinks
ln -s "$ROOT_DIR/main.tf" "$ROOT_DIR/env/dev/main.tf"
ln -s "$ROOT_DIR/variables.tf" "$ROOT_DIR/env/dev/variables.tf"
ln -s "$ROOT_DIR/modules" "$ROOT_DIR/env/dev/modules"

# PROD symlinks
ln -s "$ROOT_DIR/main.tf" "$ROOT_DIR/env/prod/main.tf"
ln -s "$ROOT_DIR/variables.tf" "$ROOT_DIR/env/prod/variables.tf"
ln -s "$ROOT_DIR/modules" "$ROOT_DIR/env/prod/modules"

# Verify links
cd "$ROOT_DIR"
ls -l "$ROOT_DIR/env/dev"
ls -l "$ROOT_DIR/env/prod"
```

### Verify symlinks
```bash
bob@iac-server ~/terraform via 💠 default ➜  ls -l "$ROOT_DIR/env/dev"
total 0
-rw-r--r-- 1 bob bob  0 Apr 26 14:11 dev.tfvars
lrwxrwxrwx 1 bob bob 27 Apr 26 14:11 main.tf -> /home/bob/terraform/main.tf
lrwxrwxrwx 1 bob bob 27 Apr 26 14:11 modules -> /home/bob/terraform/modules
-rw-r--r-- 1 bob bob  0 Apr 26 14:11 terraform_config.tf
lrwxrwxrwx 1 bob bob 32 Apr 26 14:11 variables.tf -> /home/bob/terraform/variables.tf

bob@iac-server ~/terraform via 💠 default ➜  ls -l "$ROOT_DIR/env/prod"
total 0
lrwxrwxrwx 1 bob bob 27 Apr 26 14:11 main.tf -> /home/bob/terraform/main.tf
lrwxrwxrwx 1 bob bob 27 Apr 26 14:11 modules -> /home/bob/terraform/modules
-rw-r--r-- 1 bob bob  0 Apr 26 14:11 prod.tfvars
-rw-r--r-- 1 bob bob  0 Apr 26 14:11 terraform_config.tf
lrwxrwxrwx 1 bob bob 32 Apr 26 14:11 variables.tf -> /home/bob/terraform/variables.tf

bob@iac-server ~/terraform via 💠 default ➜  ls
README.MD  env  main.tf  modules  provider.tf  variables.tf
```

## Solution (DEV)

```bash
bob@iac-server terraform/env/dev via 💠 default ➜  terraform apply -var-file=dev.tfvars -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.dynamodb.aws_dynamodb_table.dynamodb_table will be created
  + resource "aws_dynamodb_table" "dynamodb_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "xfusion-dev-table"
      + read_capacity    = (known after apply)
      + region           = "us-east-1"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "dev"
        }
      + tags_all         = {
          + "Environment" = "dev"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "id"
          + type = "S"
        }

      + global_secondary_index (known after apply)

      + global_table_witness (known after apply)

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)

      + warm_throughput (known after apply)
    }

  # module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain will be created
  + resource "aws_elasticsearch_domain" "elasticsearch_domain" {
      + access_policies       = (known after apply)
      + advanced_options      = (known after apply)
      + arn                   = (known after apply)
      + domain_id             = (known after apply)
      + domain_name           = "xfusion-dev-es"
      + elasticsearch_version = "7.10"
      + endpoint              = (known after apply)
      + id                    = (known after apply)
      + kibana_endpoint       = (known after apply)
      + region                = "us-east-1"
      + tags                  = {
          + "Environment" = "dev"
        }
      + tags_all              = {
          + "Environment" = "dev"
        }

      + advanced_security_options (known after apply)

      + auto_tune_options (known after apply)

      + cluster_config {
          + dedicated_master_enabled = false
          + instance_count           = 1
          + instance_type            = "t3.small.elasticsearch"

          + cold_storage_options (known after apply)
        }

      + domain_endpoint_options (known after apply)

      + ebs_options {
          + ebs_enabled = true
          + iops        = (known after apply)
          + throughput  = (known after apply)
          + volume_size = 10
          + volume_type = (known after apply)
        }

      + encrypt_at_rest (known after apply)

      + node_to_node_encryption (known after apply)
    }

  # module.secretsmanager.aws_secretsmanager_secret.secret will be created
  + resource "aws_secretsmanager_secret" "secret" {
      + arn                            = (known after apply)
      + force_overwrite_replica_secret = false
      + id                             = (known after apply)
      + name                           = "xfusion-dev-secret"
      + name_prefix                    = (known after apply)
      + policy                         = (known after apply)
      + recovery_window_in_days        = 30
      + region                         = "us-east-1"
      + tags                           = {
          + "Environment" = "dev"
        }
      + tags_all                       = {
          + "Environment" = "dev"
        }

      + replica (known after apply)
    }

  # module.secretsmanager.aws_secretsmanager_secret_version.secret_version will be created
  + resource "aws_secretsmanager_secret_version" "secret_version" {
      + arn                  = (known after apply)
      + has_secret_string_wo = (known after apply)
      + id                   = (known after apply)
      + region               = "us-east-1"
      + secret_id            = (known after apply)
      + secret_string        = (sensitive value)
      + secret_string_wo     = (write-only attribute)
      + version_id           = (known after apply)
      + version_stages       = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_elasticsearch_endpoint = (known after apply)
  + kke_secret_arn             = (known after apply)
  + kke_table_name             = "xfusion-dev-table"
module.secretsmanager.aws_secretsmanager_secret.secret: Creating...
module.dynamodb.aws_dynamodb_table.dynamodb_table: Creating...
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Creating...
module.secretsmanager.aws_secretsmanager_secret.secret: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU]
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Creating...
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU|terraform-20260427145850902900000002]
module.dynamodb.aws_dynamodb_table.dynamodb_table: Creation complete after 6s [id=xfusion-dev-table]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [10s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [20s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Creation complete after 23s [id=arn:aws:es:us-east-1:000000000000:domain/xfusion-dev-es]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_elasticsearch_endpoint = "xfusion-dev-es.us-east-1.es.localhost.localstack.cloud:4566"
kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
kke_table_name = "xfusion-dev-table"

bob@iac-server terraform/env/dev via 💠 default ➜  terraform show
# module.dynamodb.aws_dynamodb_table.dynamodb_table:
resource "aws_dynamodb_table" "dynamodb_table" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/xfusion-dev-table"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    hash_key                    = "id"
    id                          = "xfusion-dev-table"
    name                        = "xfusion-dev-table"
    read_capacity               = 0
    region                      = "us-east-1"
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Environment" = "dev"
    }
    tags_all                    = {
        "Environment" = "dev"
    }
    write_capacity              = 0

    attribute {
        name = "id"
        type = "S"
    }

    point_in_time_recovery {
        enabled                 = false
        recovery_period_in_days = 0
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}
# module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain:
resource "aws_elasticsearch_domain" "elasticsearch_domain" {
    advanced_options      = {}
    arn                   = "arn:aws:es:us-east-1:000000000000:domain/xfusion-dev-es"
    domain_id             = "000000000000/xfusion-dev-es"
    domain_name           = "xfusion-dev-es"
    elasticsearch_version = "7.10"
    endpoint              = "xfusion-dev-es.us-east-1.es.localhost.localstack.cloud:4566"
    id                    = "arn:aws:es:us-east-1:000000000000:domain/xfusion-dev-es"
    kibana_endpoint       = "xfusion-dev-es.us-east-1.es.localhost.localstack.cloud:4566/_plugin/kibana/"
    region                = "us-east-1"
    tags                  = {
        "Environment" = "dev"
    }
    tags_all              = {
        "Environment" = "dev"
    }

    advanced_security_options {
        enabled                        = false
        internal_user_database_enabled = false
    }

    auto_tune_options {
        desired_state       = "ENABLED"
        rollback_on_disable = "NO_ROLLBACK"
    }

    cluster_config {
        dedicated_master_count   = 1
        dedicated_master_enabled = false
        dedicated_master_type    = "m3.medium.elasticsearch"
        instance_count           = 1
        instance_type            = "t3.small.elasticsearch"
        warm_count               = 0
        warm_enabled             = false
        warm_type                = null
        zone_awareness_enabled   = false

        cold_storage_options {
            enabled = false
        }
    }

    cognito_options {
        enabled          = false
        identity_pool_id = null
        role_arn         = null
        user_pool_id     = null
    }

    domain_endpoint_options {
        custom_endpoint                 = null
        custom_endpoint_certificate_arn = null
        custom_endpoint_enabled         = false
        enforce_https                   = false
        tls_security_policy             = "Policy-Min-TLS-1-0-2019-07"
    }

    ebs_options {
        ebs_enabled = true
        iops        = 0
        throughput  = 0
        volume_size = 10
        volume_type = null
    }

    encrypt_at_rest {
        enabled    = false
        kms_key_id = null
    }

    node_to_node_encryption {
        enabled = false
    }

    snapshot_options {
        automated_snapshot_start_hour = 0
    }
}
# module.secretsmanager.aws_secretsmanager_secret.secret:
resource "aws_secretsmanager_secret" "secret" {
    arn                            = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
    description                    = null
    force_overwrite_replica_secret = false
    id                             = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
    kms_key_id                     = null
    name                           = "xfusion-dev-secret"
    name_prefix                    = null
    policy                         = null
    recovery_window_in_days        = 30
    region                         = "us-east-1"
    tags                           = {
        "Environment" = "dev"
    }
    tags_all                       = {
        "Environment" = "dev"
    }
}

# module.secretsmanager.aws_secretsmanager_secret_version.secret_version:
resource "aws_secretsmanager_secret_version" "secret_version" {
    arn              = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
    id               = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU|terraform-20260427145850902900000002"
    region           = "us-east-1"
    secret_binary    = (sensitive value)
    secret_id        = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
    secret_string    = (sensitive value)
    secret_string_wo = (write-only attribute)
    version_id       = "terraform-20260427145850902900000002"
    version_stages   = [
        "AWSCURRENT",
    ]
}


Outputs:

kke_elasticsearch_endpoint = "xfusion-dev-es.us-east-1.es.localhost.localstack.cloud:4566"
kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU"
kke_table_name = "xfusion-dev-table"

bob@iac-server terraform/env/dev via 💠 default ➜  terraform plan -var-file=dev.tfvars
module.secretsmanager.aws_secretsmanager_secret.secret: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU]
module.dynamodb.aws_dynamodb_table.dynamodb_table: Refreshing state... [id=xfusion-dev-table]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Refreshing state... [id=arn:aws:es:us-east-1:000000000000:domain/xfusion-dev-es]
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-dev-secret-DUWjVU|terraform-20260427145850902900000002]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed.
```

## Solution (PROD)

```bash
bob@iac-server terraform/env/prod via 💠 default ➜  terraform apply -var-file=prod.tfvars -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.dynamodb.aws_dynamodb_table.dynamodb_table will be created
  + resource "aws_dynamodb_table" "dynamodb_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "xfusion-prod-table"
      + read_capacity    = (known after apply)
      + region           = "us-east-1"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "prod"
        }
      + tags_all         = {
          + "Environment" = "prod"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "id"
          + type = "S"
        }

      + global_secondary_index (known after apply)

      + global_table_witness (known after apply)

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)

      + warm_throughput (known after apply)
    }

  # module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain will be created
  + resource "aws_elasticsearch_domain" "elasticsearch_domain" {
      + access_policies       = (known after apply)
      + advanced_options      = (known after apply)
      + arn                   = (known after apply)
      + domain_id             = (known after apply)
      + domain_name           = "xfusion-prod-es"
      + elasticsearch_version = "7.10"
      + endpoint              = (known after apply)
      + id                    = (known after apply)
      + kibana_endpoint       = (known after apply)
      + region                = "us-east-1"
      + tags                  = {
          + "Environment" = "prod"
        }
      + tags_all              = {
          + "Environment" = "prod"
        }

      + advanced_security_options (known after apply)

      + auto_tune_options (known after apply)

      + cluster_config {
          + dedicated_master_enabled = false
          + instance_count           = 1
          + instance_type            = "t3.small.elasticsearch"

          + cold_storage_options (known after apply)
        }

      + domain_endpoint_options (known after apply)

      + ebs_options {
          + ebs_enabled = true
          + iops        = (known after apply)
          + throughput  = (known after apply)
          + volume_size = 10
          + volume_type = (known after apply)
        }

      + encrypt_at_rest (known after apply)

      + node_to_node_encryption (known after apply)
    }

  # module.secretsmanager.aws_secretsmanager_secret.secret will be created
  + resource "aws_secretsmanager_secret" "secret" {
      + arn                            = (known after apply)
      + force_overwrite_replica_secret = false
      + id                             = (known after apply)
      + name                           = "xfusion-prod-secret"
      + name_prefix                    = (known after apply)
      + policy                         = (known after apply)
      + recovery_window_in_days        = 30
      + region                         = "us-east-1"
      + tags                           = {
          + "Environment" = "prod"
        }
      + tags_all                       = {
          + "Environment" = "prod"
        }

      + replica (known after apply)
    }

  # module.secretsmanager.aws_secretsmanager_secret_version.secret_version will be created
  + resource "aws_secretsmanager_secret_version" "secret_version" {
      + arn                  = (known after apply)
      + has_secret_string_wo = (known after apply)
      + id                   = (known after apply)
      + region               = "us-east-1"
      + secret_id            = (known after apply)
      + secret_string        = (sensitive value)
      + secret_string_wo     = (write-only attribute)
      + version_id           = (known after apply)
      + version_stages       = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_elasticsearch_endpoint = (known after apply)
  + kke_secret_arn             = (known after apply)
  + kke_table_name             = "xfusion-prod-table"
module.secretsmanager.aws_secretsmanager_secret.secret: Creating...
module.dynamodb.aws_dynamodb_table.dynamodb_table: Creating...
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Creating...
module.secretsmanager.aws_secretsmanager_secret.secret: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD]
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Creating...
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Creation complete after 0s [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD|terraform-20260427145319304200000002]
module.dynamodb.aws_dynamodb_table.dynamodb_table: Creation complete after 9s [id=xfusion-prod-table]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [10s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [20s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [30s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [40s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [50s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [1m0s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [1m10s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Still creating... [1m20s elapsed]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Creation complete after 1m23s [id=arn:aws:es:us-east-1:000000000000:domain/xfusion-prod-es]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_elasticsearch_endpoint = "xfusion-prod-es.us-east-1.es.localhost.localstack.cloud:4566"
kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
kke_table_name = "xfusion-prod-table"

bob@iac-server terraform/env/prod via 💠 default ➜  terraform show
# module.dynamodb.aws_dynamodb_table.dynamodb_table:
resource "aws_dynamodb_table" "dynamodb_table" {
    arn                         = "arn:aws:dynamodb:us-east-1:000000000000:table/xfusion-prod-table"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    hash_key                    = "id"
    id                          = "xfusion-prod-table"
    name                        = "xfusion-prod-table"
    read_capacity               = 0
    region                      = "us-east-1"
    stream_arn                  = null
    stream_enabled              = false
    stream_label                = null
    stream_view_type            = null
    table_class                 = "STANDARD"
    tags                        = {
        "Environment" = "prod"
    }
    tags_all                    = {
        "Environment" = "prod"
    }
    write_capacity              = 0

    attribute {
        name = "id"
        type = "S"
    }

    point_in_time_recovery {
        enabled                 = false
        recovery_period_in_days = 0
    }

    ttl {
        attribute_name = null
        enabled        = false
    }
}
# module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain:
resource "aws_elasticsearch_domain" "elasticsearch_domain" {
    advanced_options      = {}
    arn                   = "arn:aws:es:us-east-1:000000000000:domain/xfusion-prod-es"
    domain_id             = "000000000000/xfusion-prod-es"
    domain_name           = "xfusion-prod-es"
    elasticsearch_version = "7.10"
    endpoint              = "xfusion-prod-es.us-east-1.es.localhost.localstack.cloud:4566"
    id                    = "arn:aws:es:us-east-1:000000000000:domain/xfusion-prod-es"
    kibana_endpoint       = "xfusion-prod-es.us-east-1.es.localhost.localstack.cloud:4566/_plugin/kibana/"
    region                = "us-east-1"
    tags                  = {
        "Environment" = "prod"
    }
    tags_all              = {
        "Environment" = "prod"
    }

    advanced_security_options {
        enabled                        = false
        internal_user_database_enabled = false
    }

    auto_tune_options {
        desired_state       = "ENABLED"
        rollback_on_disable = "NO_ROLLBACK"
    }

    cluster_config {
        dedicated_master_count   = 1
        dedicated_master_enabled = false
        dedicated_master_type    = "m3.medium.elasticsearch"
        instance_count           = 1
        instance_type            = "t3.small.elasticsearch"
        warm_count               = 0
        warm_enabled             = false
        warm_type                = null
        zone_awareness_enabled   = false

        cold_storage_options {
            enabled = false
        }
    }

    cognito_options {
        enabled          = false
        identity_pool_id = null
        role_arn         = null
        user_pool_id     = null
    }

    domain_endpoint_options {
        custom_endpoint                 = null
        custom_endpoint_certificate_arn = null
        custom_endpoint_enabled         = false
        enforce_https                   = false
        tls_security_policy             = "Policy-Min-TLS-1-0-2019-07"
    }

    ebs_options {
        ebs_enabled = true
        iops        = 0
        throughput  = 0
        volume_size = 10
        volume_type = null
    }

    encrypt_at_rest {
        enabled    = false
        kms_key_id = null
    }

    node_to_node_encryption {
        enabled = false
    }

    snapshot_options {
        automated_snapshot_start_hour = 0
    }
}
# module.secretsmanager.aws_secretsmanager_secret.secret:
resource "aws_secretsmanager_secret" "secret" {
    arn                            = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
    description                    = null
    force_overwrite_replica_secret = false
    id                             = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
    kms_key_id                     = null
    name                           = "xfusion-prod-secret"
    name_prefix                    = null
    policy                         = null
    recovery_window_in_days        = 30
    region                         = "us-east-1"
    tags                           = {
        "Environment" = "prod"
    }
    tags_all                       = {
        "Environment" = "prod"
    }
}

# module.secretsmanager.aws_secretsmanager_secret_version.secret_version:
resource "aws_secretsmanager_secret_version" "secret_version" {
    arn              = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
    id               = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD|terraform-20260427145319304200000002"
    region           = "us-east-1"
    secret_binary    = (sensitive value)
    secret_id        = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
    secret_string    = (sensitive value)
    secret_string_wo = (write-only attribute)
    version_id       = "terraform-20260427145319304200000002"
    version_stages   = [
        "AWSCURRENT",
    ]
}


Outputs:

kke_elasticsearch_endpoint = "xfusion-prod-es.us-east-1.es.localhost.localstack.cloud:4566"
kke_secret_arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD"
kke_table_name = "xfusion-prod-table"


bob@iac-server terraform/env/prod via 💠 default ➜  terraform plan -var-file=prod.tfvars
module.secretsmanager.aws_secretsmanager_secret.secret: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD]
module.dynamodb.aws_dynamodb_table.dynamodb_table: Refreshing state... [id=xfusion-prod-table]
module.elasticsearch.aws_elasticsearch_domain.elasticsearch_domain: Refreshing state... [id=arn:aws:es:us-east-1:000000000000:domain/xfusion-prod-es]
module.secretsmanager.aws_secretsmanager_secret_version.secret_version: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:000000000000:secret:xfusion-prod-secret-ALXfoD|terraform-20260427145319304200000002]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed.
```