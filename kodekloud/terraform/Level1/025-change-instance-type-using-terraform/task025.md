# Task 025 - Change Instance Type Using Terraform

During the migration process, the Nautilus DevOps team created several EC2 instances in different regions. They are currently in the process of identifying the correct resources and utilization and are making continuous changes to ensure optimal resource utilization. Recently, they discovered that one of the EC2 instances was underutilized, prompting them to decide to change the instance type. Please make sure the `Status check` is completed (if it's still in Initializing state) before making any changes to the instance.

1. Change the instance type from `t2.micro` to `t2.nano` for `datacenter-ec2` instance using terraform.

2. Make sure the EC2 instance `datacenter-ec2` is in `running` state after the change.

3. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to change the instance type.

## Solution Steps:

1. Update instace type in main.tf file from t2.micro to t2.nano
2. Run terraform plan to see the changes

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform plan
aws_instance.ec2: Refreshing state... [id=i-dea42f24d4f22cf6e]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.ec2 will be updated in-place
  ~ resource "aws_instance" "ec2" {
        id                                   = "i-dea42f24d4f22cf6e"
      ~ instance_type                        = "t2.micro" -> "t2.nano"
      ~ public_dns                           = "ec2-54-214-201-0.compute-1.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "54.214.201.0" -> (known after apply)
        tags                                 = {
            "Name" = "datacenter-ec2"
        }
        # (34 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜
```

3. Run terraform apply to apply the changes

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_instance.ec2: Refreshing state... [id=i-dea42f24d4f22cf6e]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.ec2 will be updated in-place
  ~ resource "aws_instance" "ec2" {
        id                                   = "i-dea42f24d4f22cf6e"
      ~ instance_type                        = "t2.micro" -> "t2.nano"
      ~ public_dns                           = "ec2-54-214-201-0.compute-1.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "54.214.201.0" -> (known after apply)
        tags                                 = {
            "Name" = "datacenter-ec2"
        }
        # (34 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
aws_instance.ec2: Modifying... [id=i-dea42f24d4f22cf6e]
aws_instance.ec2: Still modifying... [id=i-dea42f24d4f22cf6e, 10s elapsed]
aws_instance.ec2: Still modifying... [id=i-dea42f24d4f22cf6e, 20s elapsed]
aws_instance.ec2: Modifications complete after 21s [id=i-dea42f24d4f22cf6e]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

4. Verify the instance type and status of the instance via AWS CLI

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType}" \
  --output table
-----------------------------------------------
|              DescribeInstances              |
+----------------------+----------+-----------+
|      InstanceId      |  State   |   Type    |
+----------------------+----------+-----------+
|  i-dea42f24d4f22cf6e |  running |  t2.nano  |
+----------------------+----------+-----------+
```
