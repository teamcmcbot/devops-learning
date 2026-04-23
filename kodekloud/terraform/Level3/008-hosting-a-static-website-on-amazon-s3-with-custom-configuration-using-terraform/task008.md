# Task 008: Hosting a Static Website on Amazon S3 with Custom Configuration Using Terraform

The Nautilus DevOps team has been tasked with creating an internal information portal for public access. As part of this project, they need to host a static website on AWS using an S3 bucket. The S3 bucket must be configured for public access to allow external users to access the static website directly via the S3 website URL.

Your task is to create a Terraform module named `s3-static-site` to handle the `creation and configuration` of the S3 bucket. For uploading the `index.html` file, you may use either Terraform or the AWS CLI.

Task Requirements:

The module directory `/home/bob/terraform/modules/s3-static-site/` is already created, configure the module to perform the following tasks:

1. Create an S3 bucket named `devops-web-4945`.

2. Configure the S3 bucket for static website hosting with `index.html` as the index document.

3. Allow `public` access to the bucket by attaching the appropriate bucket policy.

4. Within the module, use a `variables.tf` file that must define the following variables: `bucket_name` and `index_document`. These values should not be hardcoded directly into resource definitions. You may add other variables if needed to avoid hardcoding. Use these variables in `main.tf` for configuring the bucket.

5. Within the module use `outputs.tf` file to output the following:

- `website_url`: S3 static website url

6. Your S3 website url should look something like the following, `aws:4566` refers to the mock AWS endpoint configured in your environment (e.g., using LocalStack):

- `http://aws:4566/<bucketname>/index.html`

7. The S3 bucket must be tagged with the key `Project` and the value `StaticWeb`.

8. In the root `main.tf`, call the `s3-static-site` module using the required input variables (`bucket_name`, `index_document`).

9. Upload the `index.html` file from `/home/bob/terraform` directory to the S3 bucket. This can be done using either the `AWS CLI` or `Terraform` (aws_s3_object).

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
module.s3_static_site.aws_s3_bucket.static_site: Refreshing state... [id=devops-web-4945]
module.s3_static_site.aws_s3_bucket_public_access_block.static_site: Refreshing state... [id=devops-web-4945]
module.s3_static_site.aws_s3_bucket_website_configuration.static_site: Refreshing state... [id=devops-web-4945]
module.s3_static_site.aws_s3_bucket_policy.static_site_policy: Refreshing state... [id=devops-web-4945]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.s3_static_site.aws_s3_object.index_html will be created
  + resource "aws_s3_object" "index_html" {
      + acl                    = (known after apply)
      + arn                    = (known after apply)
      + bucket                 = "devops-web-4945"
      + bucket_key_enabled     = (known after apply)
      + checksum_crc32         = (known after apply)
      + checksum_crc32c        = (known after apply)
      + checksum_crc64nvme     = (known after apply)
      + checksum_sha1          = (known after apply)
      + checksum_sha256        = (known after apply)
      + content_type           = "text/html"
      + etag                   = (known after apply)
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "./index.html"
      + storage_class          = (known after apply)
      + tags_all               = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
module.s3_static_site.aws_s3_object.index_html: Creating...
module.s3_static_site.aws_s3_object.index_html: Creation complete after 0s [id=index.html]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "devops-web-4945"
s3_website_url = "http://aws:4566/devops-web-4945/index.html"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# module.s3_static_site.aws_s3_bucket.static_site:
resource "aws_s3_bucket" "static_site" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::devops-web-4945"
    bucket                      = "devops-web-4945"
    bucket_domain_name          = "devops-web-4945.s3.amazonaws.com"
    bucket_prefix               = null
    bucket_regional_domain_name = "devops-web-4945.s3.us-east-1.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "devops-web-4945"
    object_lock_enabled         = false
    policy                      = jsonencode(
        {
            Statement = [
                {
                    Action    = "s3:GetObject"
                    Effect    = "Allow"
                    Principal = "*"
                    Resource  = "arn:aws:s3:::devops-web-4945/*"
                    Sid       = "PublicReadGetObject"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Project" = "StaticWeb"
    }
    tags_all                    = {
        "Project" = "StaticWeb"
    }
    website_domain              = "s3-website-us-east-1.amazonaws.com"
    website_endpoint            = "devops-web-4945.s3-website-us-east-1.amazonaws.com"

    grant {
        id          = "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
        uri         = null
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                kms_master_key_id = null
                sse_algorithm     = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }

    website {
        error_document           = null
        index_document           = "index.html"
        redirect_all_requests_to = null
        routing_rules            = null
    }
}

# module.s3_static_site.aws_s3_bucket_policy.static_site_policy:
resource "aws_s3_bucket_policy" "static_site_policy" {
    bucket = "devops-web-4945"
    id     = "devops-web-4945"
    policy = jsonencode(
        {
            Statement = [
                {
                    Action    = "s3:GetObject"
                    Effect    = "Allow"
                    Principal = "*"
                    Resource  = "arn:aws:s3:::devops-web-4945/*"
                    Sid       = "PublicReadGetObject"
                },
            ]
            Version   = "2012-10-17"
        }
    )
}

# module.s3_static_site.aws_s3_bucket_public_access_block.static_site:
resource "aws_s3_bucket_public_access_block" "static_site" {
    block_public_acls       = false
    block_public_policy     = false
    bucket                  = "devops-web-4945"
    id                      = "devops-web-4945"
    ignore_public_acls      = false
    restrict_public_buckets = false
}

# module.s3_static_site.aws_s3_bucket_website_configuration.static_site:
resource "aws_s3_bucket_website_configuration" "static_site" {
    bucket                = "devops-web-4945"
    expected_bucket_owner = null
    id                    = "devops-web-4945"
    routing_rules         = null
    website_domain        = "s3-website-us-east-1.amazonaws.com"
    website_endpoint      = "devops-web-4945.s3-website-us-east-1.amazonaws.com"

    index_document {
        suffix = "index.html"
    }
}

# module.s3_static_site.aws_s3_object.index_html:
resource "aws_s3_object" "index_html" {
    arn                           = "arn:aws:s3:::devops-web-4945/index.html"
    bucket                        = "devops-web-4945"
    bucket_key_enabled            = false
    cache_control                 = null
    checksum_crc32                = null
    checksum_crc32c               = null
    checksum_crc64nvme            = null
    checksum_sha1                 = null
    checksum_sha256               = null
    content_disposition           = null
    content_encoding              = null
    content_language              = null
    content_type                  = "text/html"
    etag                          = "804425397b80258e93779ffdcbad0ee4"
    force_destroy                 = false
    id                            = "index.html"
    key                           = "index.html"
    object_lock_legal_hold_status = null
    object_lock_mode              = null
    object_lock_retain_until_date = null
    server_side_encryption        = "AES256"
    source                        = "./index.html"
    storage_class                 = "STANDARD"
    tags_all                      = {}
    version_id                    = null
    website_redirect              = null
}


Outputs:

bucket_name = "devops-web-4945"
s3_website_url = "http://aws:4566/devops-web-4945/index.html"
```

```bash
bob@iac-server ~/terraform via 💠 default ➜  aws s3 ls s3://devops-web-4945 --recursive
2026-04-23 08:20:44         21 index.html

bob@iac-server ~/terraform via 💠 default ➜  curl http://aws:4566/devops-web-4945/index.html
Welcome to KKE labs!

bob@iac-server ~/terraform via 💠 default ➜  terraform output
bucket_name = "devops-web-4945"
s3_website_url = "http://aws:4566/devops-web-4945/index.html"
```

