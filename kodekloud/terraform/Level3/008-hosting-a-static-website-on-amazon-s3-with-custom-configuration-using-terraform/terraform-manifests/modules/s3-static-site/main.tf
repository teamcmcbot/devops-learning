# Requirement 1: Create an S3 bucket named devops-web-4945
# Requirement 4: Using var.bucket_name variable (not hardcoded)
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  # Requirement 7: Tag with Project key and StaticWeb value
  tags = {
    Project = "StaticWeb"
  }
}

# Requirement 2: Configure the S3 bucket for static website hosting with index.html
# Requirement 4: Using var.index_document variable (not hardcoded)
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = var.index_document
  }
}

# Requirement 3: Allow public access to the bucket by attaching the appropriate bucket policy
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  # Allow public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Requirement 3: Attach bucket policy to allow public read access
resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_site]
}

# Requirement 9: Upload the index.html file to the S3 bucket
# Using aws_s3_object resource (Terraform method)
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_site.id
  key    = var.index_document
  source = var.index_html_path

  # Set content type for proper browser rendering
  content_type = "text/html"

  # Ensure file is uploaded after bucket policy is set
  depends_on = [aws_s3_bucket_policy.static_site_policy]
}
