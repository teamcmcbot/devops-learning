# Task 028: Enable S3 Versioning using Terraform

Data protection and recovery are fundamental aspects of data management. It's essential to have systems in place to ensure that data can be recovered in case of accidental deletion or corruption. The DevOps team has received a requirement for implementing such measures for one of the S3 buckets they are managing.

The S3 bucket name is `nautilus-s3-11958`, enable `versioning` for this bucket using Terraform.

The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a different .tf file) to accomplish this task.

## Solution

### Step 1: Update the Terraform Configuration file to enable versioning for the S3 bucket.

```hcl

resource "aws_s3_bucket" "s3_ran_bucket" {
  bucket = "nautilus-s3-11958"
  #acl    = "private"

  tags = {
    Name = "nautilus-s3-11958"
  }
}

resource "aws_s3_bucket_acl" "s3_ran_bucket_acl" {
  bucket = aws_s3_bucket.s3_ran_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3_ran_bucket_versioning" {
  bucket = aws_s3_bucket.s3_ran_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Step 2: Apply the Terraform configuration changes.

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform apply -auto-approve
aws_s3_bucket.s3_ran_bucket: Refreshing state... [id=nautilus-s3-11958]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket_acl.s3_ran_bucket_acl will be created
  + resource "aws_s3_bucket_acl" "s3_ran_bucket_acl" {
      + acl    = "private"
      + bucket = "nautilus-s3-11958"
      + id     = (known after apply)

      + access_control_policy (known after apply)
    }

  # aws_s3_bucket_versioning.s3_ran_bucket_versioning will be created
  + resource "aws_s3_bucket_versioning" "s3_ran_bucket_versioning" {
      + bucket = "nautilus-s3-11958"
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
aws_s3_bucket_acl.s3_ran_bucket_acl: Creating...
aws_s3_bucket_versioning.s3_ran_bucket_versioning: Creating...
aws_s3_bucket_acl.s3_ran_bucket_acl: Creation complete after 0s [id=nautilus-s3-11958,private]
aws_s3_bucket_versioning.s3_ran_bucket_versioning: Creation complete after 1s [id=nautilus-s3-11958]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

```

### Step 3: Verify that versioning is enabled for the S3 bucket.

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2025-12-26 04:21:13 nautilus-s3-11958

bob@iac-server ~/terraform via 💠 default ➜  aws s3api get-bucket-versioning --bucket nautilus-s3-11958
{
    "Status": "Enabled"
}
```
