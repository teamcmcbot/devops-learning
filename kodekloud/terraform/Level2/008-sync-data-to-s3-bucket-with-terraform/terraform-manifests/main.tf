resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = "devops-s3-20919"
}

resource "aws_s3_bucket_acl" "wordpress_bucket_acl" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.KKE_BUCKET
}

resource "aws_s3_bucket_acl" "kke_bucket_acl" {
  bucket = aws_s3_bucket.kke_bucket.id
  acl    = "private"
}

resource "terraform_data" "s3_sync" {
  depends_on = [aws_s3_bucket_acl.kke_bucket_acl]

  triggers_replace = [
    aws_s3_bucket.wordpress_bucket.id,
    aws_s3_bucket.kke_bucket.id
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOT
      aws s3 sync s3://${aws_s3_bucket.wordpress_bucket.bucket} s3://${aws_s3_bucket.kke_bucket.bucket} --exact-timestamps

      src_count=$(aws s3 ls s3://${aws_s3_bucket.wordpress_bucket.bucket} --recursive | wc -l)
      dst_count=$(aws s3 ls s3://${aws_s3_bucket.kke_bucket.bucket} --recursive | wc -l)

      if [ "$src_count" -ne "$dst_count" ]; then
        echo "Data consistency check failed: source=$src_count destination=$dst_count"
        exit 1
      fi

      echo "Data consistency check passed: source and destination both have $src_count objects"
    EOT
  }
}