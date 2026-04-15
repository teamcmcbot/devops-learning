resource "aws_s3_bucket" "s3_bucket_with_prevent_destroy" {
  bucket = var.KKE_BUCKET_NAME

  lifecycle {
    prevent_destroy = true
  }
}