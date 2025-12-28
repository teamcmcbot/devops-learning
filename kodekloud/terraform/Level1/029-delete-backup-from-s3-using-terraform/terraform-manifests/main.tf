# Add your code below

resource "null_resource" "s3_backup_and_delete" {
  provisioner "local-exec" {
    command = <<-EOT
      # Copy S3 bucket contents to local directory
      aws s3 cp s3://devops-bck-296 /opt/s3-backup/ --recursive
      
      # Delete all objects in the bucket (required before deleting bucket)
      aws s3 rm s3://devops-bck-296 --recursive
      
      # Delete the S3 bucket
      aws s3 rb s3://devops-bck-296
    EOT
  }
}
