resource "aws_iam_user" "user" {
  name = var.KKE_user
  
  tags = {
    Name = var.KKE_user
  }
}