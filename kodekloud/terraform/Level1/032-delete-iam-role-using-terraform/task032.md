# Task 032: Delete IAM Role using Terraform

The Nautilus DevOps team is currently engaged in a cleanup process, focusing on removing unnecessary data and services from their AWS account. As part of the migration process, several resources were created for one-time use only, necessitating a cleanup effort to optimize their AWS environment.

Delete the IAM role named `iamrole_kirsty` using Terraform. Make sure to keep the provisioning code, as we might need to provision this instance again later.

The Terraform working directory is /home/bob/terraform.

## Solution

1. List state to confirm the role exists.

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform state list
aws_iam_role.role
```

2. Destroy the IAM role using terraform commands.

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform destroy -target=aws_iam_role.r
ole
aws_iam_role.role: Refreshing state... [id=iamrole_kirsty]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_iam_role.role will be destroyed
  - resource "aws_iam_role" "role" {
      - arn                   = "arn:aws:iam::000000000000:role/iamrole_kirsty" -> null
      - assume_role_policy    = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "sts:AssumeRole"
                      - Effect    = "Allow"
                      - Principal = {
                          - Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              - Version   = "2012-10-17"
            }
        ) -> null
      - create_date           = "2026-01-09T07:24:09Z" -> null
      - force_detach_policies = false -> null
      - id                    = "iamrole_kirsty" -> null
      - managed_policy_arns   = [] -> null
      - max_session_duration  = 3600 -> null
      - name                  = "iamrole_kirsty" -> null
      - path                  = "/" -> null
      - tags                  = {
          - "Name" = "iamrole_kirsty"
        } -> null
      - tags_all              = {
          - "Name" = "iamrole_kirsty"
        } -> null
      - unique_id             = "AROAQAAAAAAAFUJWRHYK3" -> null
        # (3 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of
│ this plan may not represent all of the changes requested by the current
│ configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional
│ situations such as recovering from errors or mistakes, or when Terraform
│ specifically suggests to use it as part of an error message.
╵

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_iam_role.role: Destroying... [id=iamrole_kirsty]
aws_iam_role.role: Destruction complete after 0s
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested
│ in the configuration may have been ignored and the output values may not be fully
│ updated. Run the following command to verify that no other changes are pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided
│ only for exceptional situations such as recovering from errors or mistakes, or
│ when Terraform specifically suggests to use it as part of an error message.
╵

Destroy complete! Resources: 1 destroyed.
```

3. Verify the role has been deleted.

```bash

bob@iac-server ~/terraform via 💠 default ✖ terraform state list

bob@iac-server ~/terraform via 💠 default ➜
```
