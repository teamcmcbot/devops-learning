resource "aws_s3_bucket" "xfusion_s3_bucket" {
  bucket = "xfusion-lifecycle-22645"
}

resource "aws_s3_bucket_versioning" "xfusion_s3_bucket_versioning" {
  bucket = aws_s3_bucket.xfusion_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "xfusion_lifecycle_rule" {
  bucket = aws_s3_bucket.xfusion_s3_bucket.bucket

  rule {
    id = "xfusion-lifecycle-rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }

  
}