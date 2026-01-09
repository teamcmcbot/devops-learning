# Task 031 - Delete IAM Group Using Terraform

The Nautilus DevOps team is currently engaged in a cleanup process, focusing on removing unnecessary data and services from their AWS account. As part of the migration process, several resources were created for one-time use only, necessitating a cleanup effort to optimize their AWS environment.

Delete an IAM group named `iamgroup_siva` using terraform. Make sure to keep the provisioning code, as we might need to provision this instance again later.

The Terraform working directory is /home/bob/terraform.

## Instructions

1. list groups using AWS CLI to confirm the group exists.

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws iam list-groups
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "iamgroup_siva",
            "GroupId": "6xo6rip1wra1r9ru8yu5",
            "Arn": "arn:aws:iam::000000000000:group/iamgroup_siva",
            "CreateDate": "2026-01-02T02:51:38.035306Z"
        }
    ]
}
```

2. main.tf

```hcl
resource "aws_iam_group" "this" {
  name = "iamgroup_siva"
}
```

3. Destroy the IAM group using terraform commands.

```bash
terraform destroy -target=aws_iam_group.this
```

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform destroy -target=aws_iam_group.this
aws_iam_group.this: Refreshing state... [id=iamgroup_siva]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_iam_group.this will be destroyed
  - resource "aws_iam_group" "this" {
      - arn       = "arn:aws:iam::000000000000:group/iamgroup_siva" -> null
      - id        = "iamgroup_siva" -> null
      - name      = "iamgroup_siva" -> null
      - path      = "/" -> null
      - unique_id = "6xo6rip1wra1r9ru8yu5" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may
│ not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such
│ as recovering from errors or mistakes, or when Terraform specifically suggests to use it as
│ part of an error message.
╵

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_iam_group.this: Destroying... [id=iamgroup_siva]
aws_iam_group.this: Destruction complete after 0s
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested in the
│ configuration may have been ignored and the output values may not be fully updated. Run the
│ following command to verify that no other changes are pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided only for
│ exceptional situations such as recovering from errors or mistakes, or when Terraform
│ specifically suggests to use it as part of an error message.
╵

Destroy complete! Resources: 1 destroyed.
```

4. Verify the group has been deleted using AWS CLI.

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws iam list-groups
{
    "Groups": []
}
```
