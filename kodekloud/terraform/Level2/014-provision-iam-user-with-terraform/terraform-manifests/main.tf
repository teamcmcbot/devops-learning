# 1. Create an IAM user named `iamuser_ravi`.
resource "aws_iam_user" "iamuser_ravi" {
  name = var.KKE_USER_NAME

  provisioner "local-exec" {
    command = "echo 'KKE ${var.KKE_USER_NAME} has been created successfully!' >> /home/bob/terraform/KKE_user_created.log"
  }
}