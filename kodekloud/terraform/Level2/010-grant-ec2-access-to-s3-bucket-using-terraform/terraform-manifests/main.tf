# Create an S3 bucket named `xfusion-logs-21964`.
resource "aws_s3_bucket" "xfusion_logs_bucket" {
  bucket = var.KKE_BUCKET_NAME
}

# Create an IAM role named `xfusion-role` 
resource "aws_iam_role" "xfusion_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# with a policy named `xfusion-access-policy` allowing `S3 PutObject` on the above bucket.
resource "aws_iam_policy" "xfusion_access_policy" {
  name   = var.KKE_POLICY_NAME
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowPutObjectToXfusionLogsBucket"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.xfusion_logs_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xfusion_role_policy_attachment" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_access_policy.arn
}

# Attach the IAM role to the EC2 instance to allow it to upload logs to the bucket.
resource "aws_iam_instance_profile" "xfusion_instance_profile" {
  name = "ec2-s3-upload-profile"
  role = aws_iam_role.xfusion_role.name
}


# Create an EC2 instance named `xfusion-ec2` that can access an S3 bucket securely.
resource "aws_instance" "xfusion-ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.xfusion_instance_profile.name
  tags = {
    Name = "xfusion-ec2"
  }
  
}