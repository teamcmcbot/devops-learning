# Task 029 - Delete Backup from S3 using Terraform

The Nautilus DevOps team is currently engaged in a cleanup process, focusing on removing unnecessary data and services from their AWS account. As part of the migration process, several resources were created for one-time use only, necessitating a cleanup effort to optimize their AWS environment.

A S3 bucket named `devops-bck-296` already exists.

1. Copy the contents of `devops-bck-296` S3 bucket to `/opt/s3-backup/` directory on terraform-client host (the landing host once you load this lab).

2. Delete the S3 bucket `devops-bck-296`.

3. Use the AWS CLI through Terraform to accomplish this task—for example, by running AWS CLI commands within Terraform. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to accomplish this task.

## Solution Steps

1. check the contents of the S3 bucket

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls
2025-12-27 06:20:13 devops-bck-296

bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://devops-bck-296/
2025-12-27 06:20:14         27 devops.txt
```

2. Run terraform init, plan, apply.

```bash
bob@iac-server ~/terraform via 💠 default ✖ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.s3_backup_and_delete will be created
  + resource "null_resource" "s3_backup_and_delete" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
null_resource.s3_backup_and_delete: Creating...
null_resource.s3_backup_and_delete: Provisioning with 'local-exec'...
null_resource.s3_backup_and_delete (local-exec): Executing: ["/bin/sh" "-c" "# Copy S3 bucket contents to local directory\naws s3 cp s3://devops-bck-296 /opt/s3-backup/ --recursive\n      \n# Delete all objects in the bucket (required before deleting bucket)\naws s3 rm s3://devops-bck-296 --recursive\n      \n# Delete the S3 bucket\naws s3 rb s3://devops-bck-296\n"]
null_resource.s3_backup_and_delete (local-exec): Completed 27 Bytes/27 Bytes (3.3 KiB/s) with 1 file(s) remaining
null_resource.s3_backup_and_delete (local-exec): download: s3://devops-bck-296/devops.txt to ../../../opt/s3-backup/devops.txt
null_resource.s3_backup_and_delete (local-exec): delete: s3://devops-bck-296/devops.txt
null_resource.s3_backup_and_delete (local-exec): remove_bucket: devops-bck-296
null_resource.s3_backup_and_delete: Creation complete after 1s [id=6885505335870334984]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

3. Verify the S3 bucket is deleted and contents are copied to /opt/s3-backup/

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls

bob@iac-server ~/terraform via 💠 default ➜  ls -la /opt/s3-backup/
total 16
drwxr-xr-x 2 bob  bob  4096 Dec 27 06:30 .
drwxr-xr-x 1 root root 4096 Dec 27 06:20 ..
-rw-r--r-- 1 bob  bob    27 Dec 27 06:20 devops.txt
```
