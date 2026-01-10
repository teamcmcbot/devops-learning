resource "aws_s3_bucket" "my_bucket" {
  bucket = "nautilus-cp-25362"

  tags = {
    Name = "nautilus-cp-25362"
  }

  provisioner "local-exec" {
    command = "aws s3 cp /tmp/nautilus.txt s3://${self.bucket}/nautilus.txt"
  }
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}
