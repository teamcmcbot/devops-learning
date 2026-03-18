resource "aws_eip" "lb" {
  
  tags = {
    Name = var.KKE_eip
  }
}