resource "aws_s3_bucket" "nautilus-s3-bucket" {
  bucket = "nautilus-s3-15798"
}

resource "aws_s3_bucket_ownership_controls" "nautilus-s3-bucket-ownership" {
  bucket = aws_s3_bucket.nautilus-s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Blocking Public Access Settings
resource "aws_s3_bucket_public_access_block" "nautilus-s3-bucket-public-access" {
  bucket = aws_s3_bucket.nautilus-s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "nautilus-s3-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.nautilus-s3-bucket-ownership, aws_s3_bucket_public_access_block.nautilus-s3-bucket-public-access]

  bucket = aws_s3_bucket.nautilus-s3-bucket.id
  acl    = "private"
}
