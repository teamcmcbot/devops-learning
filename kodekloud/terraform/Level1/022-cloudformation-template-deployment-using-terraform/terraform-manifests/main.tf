resource "aws_cloudformation_stack" "xfusion_stack" {
  name = "xfusion-stack"

  template_body = <<YAML
AWSTemplateFormatVersion: "2010-09-09"
Description: "Provision an S3 bucket with versioning enabled"

Resources:
  XfusionBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: "xfusion-bucket-7639"
      VersioningConfiguration:
        Status: "Enabled"
YAML
}


