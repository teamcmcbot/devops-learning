resource "aws_security_group" "my_sg" {
  name        = var.KKE_sg
  
  tags = {
    Name = var.KKE_sg
  }
}