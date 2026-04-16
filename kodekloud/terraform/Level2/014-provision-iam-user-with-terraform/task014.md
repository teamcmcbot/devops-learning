# Task 014: Provision IAM User with Terraform

The Nautilus DevOps team is experimenting with Terraform provisioners. Your task is to create an IAM user and use a local-exec provisioner to log a confirmation message.

1. Create an IAM user named `iamuser_ravi`.

2. Use a `local-exec` provisioner with the IAM user resource to log the message `KKE iamuser_ravi has been created successfully!` to a file called `KKE_user_created.log` under `home/bob/terraform`.

3. Create the `main.tf` file (do not create a separate .tf file) to provision an IAM user.

4. Use `variables.tf` file with the following:

- `KKE_USER_NAME`: name of the IAM user.

5. Use `terraform.tfvars` to input the name of the IAM user.

6. Use `outputs.tf` file with the following:

- `kke_iam_user_name`: name of the IAM user.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.iamuser_ravi will be created
  + resource "aws_iam_user" "iamuser_ravi" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "iamuser_ravi"
      + path          = "/"
      + tags_all      = (known after apply)
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_iam_user_name = "iamuser_ravi"
aws_iam_user.iamuser_ravi: Creating...
aws_iam_user.iamuser_ravi: Provisioning with 'local-exec'...
aws_iam_user.iamuser_ravi (local-exec): Executing: ["/bin/sh" "-c" "echo 'KKE iamuser_ravi has been created successfully!' >> /home/bob/terraform/KKE_user_created.log"]
aws_iam_user.iamuser_ravi: Creation complete after 0s [id=iamuser_ravi]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

kke_iam_user_name = "iamuser_ravi"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_iam_user.iamuser_ravi:
resource "aws_iam_user" "iamuser_ravi" {
    arn                  = "arn:aws:iam::000000000000:user/iamuser_ravi"
    force_destroy        = false
    id                   = "iamuser_ravi"
    name                 = "iamuser_ravi"
    path                 = "/"
    permissions_boundary = null
    tags_all             = {}
    unique_id            = "wx96pggxofu8wvtoa14y"
}


Outputs:

kke_iam_user_name = "iamuser_ravi"

bob@iac-server ~/terraform via 💠 default ➜  cat /home/bob/terraform/KKE_user_created.log
KKE iamuser_ravi has been created successfully!
```