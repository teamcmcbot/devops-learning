resource "aws_s3_bucket" "devops-s3-bucket" {
  bucket = "devops-s3-27094"
}

resource "aws_s3_bucket_ownership_controls" "devops-s3-bucket-ownership" {
  bucket = aws_s3_bucket.devops-s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "devops-s3-bucket-public-access" {
  bucket = aws_s3_bucket.devops-s3-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "devops-s3-bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.devops-s3-bucket-ownership,
    aws_s3_bucket_public_access_block.devops-s3-bucket-public-access,
  ]

  bucket = aws_s3_bucket.devops-s3-bucket.id
  acl    = "public-read"
}
