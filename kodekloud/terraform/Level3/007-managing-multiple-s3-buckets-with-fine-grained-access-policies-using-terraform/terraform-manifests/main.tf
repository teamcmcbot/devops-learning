# 1. Create three S3 buckets using `for_each` for environments: `Dev`, `Staging`, and `Prod`.
resource "aws_s3_bucket" "kke_buckets" {
  for_each = var.KKE_ENV_TAGS

  # 2. Name the buckets using the following naming convention: `datacenter-<environment>-bucket-32108`.
  bucket = each.value.bucket_name

  # 3. Environment-specific tags with conditional backup tag
  tags = merge(
    {
      Name        = each.value.bucket_name
      Environment = each.key
      Owner       = each.value.owner
    },
    
    # Only add the `Backup` tag for `staging` and `prod` buckets based on the environment name:
    lower(each.key) == "staging" || lower(each.key) == "prod" ? { Backup = "true" } : {}
    
    # Alternative method, if backup flag is true in the variable:
    #each.value.backup ? { Backup = "true" } : {},
  )

  # 5. Use the `lifecycle` block with `ignore_changes` to protect the `tags`.
  lifecycle {
    ignore_changes = [tags]
  }
}

# 4. For the `staging` and `prod` buckets, set `Backup = true` and add a lifecycle rule with ID `MoveToGlacier` to transition objects to `Glacier` after `30` days.
resource "aws_s3_bucket_lifecycle_configuration" "kke_backup_lifecycle" {
  
  # Only apply lifecycle rules to staging and prod buckets based on environment name:
  for_each = {
    for env, config in var.KKE_ENV_TAGS : env => config
    if lower(env) == "staging" || lower(env) == "prod"
  }

  # Alternatively, if using the backup flag in the variable:
  # for_each = {
  #   for env, config in var.KKE_ENV_TAGS : env => config
  #   if config.backup
  # }

  bucket = aws_s3_bucket.kke_buckets[each.key].id

  rule {
    id     = "MoveToGlacier"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

# 6. Create a bucket policy that allows `public read access` to all objects in the bucket.
resource "aws_s3_bucket_policy" "kke_public_read" {
  for_each = var.KKE_ENV_TAGS

  bucket = aws_s3_bucket.kke_buckets[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.kke_buckets[each.key].arn}/*"]
      }
    ]
  })

  # 7. Use `depends_on` to ensure the policy is only applied after the bucket has been created.
  depends_on = [aws_s3_bucket.kke_buckets]
}