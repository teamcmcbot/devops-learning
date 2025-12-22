# Task 023 : OpenSearch Setup using Terraform

The Nautilus DevOps team needs to set up an Amazon OpenSearch Service domain to store and search their application logs. The domain should have the following specification:

1. The domain name should be `devops-es`.

2. Use Terraform to create the OpenSearch domain. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Notes:

1. The Terraform working directory is `/home/bob/terraform`.

2. Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

3. Before submitting the task, ensure that `terraform plan` returns No changes. Your infrastructure matches the configuration.

4. The OpenSearch domain creation process may take several minutes. Please wait until the domain is fully created before submitting.

## Resources

- [Terraform AWS OpenSearch Domain Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain)

# Verifications

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_opensearch_domain.devops-es will be created
  + resource "aws_opensearch_domain" "devops-es" {
      + access_policies                   = (known after apply)
      + advanced_options                  = (known after apply)
      + arn                               = (known after apply)
      + dashboard_endpoint                = (known after apply)
      + dashboard_endpoint_v2             = (known after apply)
      + domain_endpoint_v2_hosted_zone_id = (known after apply)
      + domain_id                         = (known after apply)
      + domain_name                       = "devops-es"
      + endpoint                          = (known after apply)
      + endpoint_v2                       = (known after apply)
      + engine_version                    = (known after apply)
      + id                                = (known after apply)
      + ip_address_type                   = (known after apply)
      + kibana_endpoint                   = (known after apply)
      + tags_all                          = (known after apply)

      + advanced_security_options (known after apply)

      + auto_tune_options (known after apply)

      + cluster_config (known after apply)

      + domain_endpoint_options (known after apply)

      + ebs_options (known after apply)

      + encrypt_at_rest (known after apply)

      + node_to_node_encryption (known after apply)

      + off_peak_window_options (known after apply)

      + software_update_options (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_opensearch_domain.devops-es: Creating...
aws_opensearch_domain.devops-es: Still creating... [10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [1m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [2m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [3m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [4m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [5m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [6m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [7m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [8m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m0s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m10s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m20s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m30s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m40s elapsed]
aws_opensearch_domain.devops-es: Still creating... [9m50s elapsed]
aws_opensearch_domain.devops-es: Still creating... [10m0s elapsed]
aws_opensearch_domain.devops-es: Creation complete after 10m0s [id=arn:aws:es:us-east-1:000000000000:domain/devops-es]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_opensearch_domain.devops-es: Refreshing state... [id=arn:aws:es:us-east-1:000000000000:domain/devops-es]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found
no differences, so no changes are needed.


bob@iac-server ~/terraform via 💠 default ➜  terraform output
opensearch_domain_arn = "arn:aws:es:us-east-1:000000000000:domain/devops-es"
opensearch_domain_name = "devops-es"
```

**NOTE:** Opensearch domain create took more than 10 minutes to be created.
