# Resource: EC2 Instance
resource "aws_instance" "myec2vm" {
  ami           = "ami-0cae6d6fe6048ca2c"
  instance_type = "t3.micro"
  user_data     = file("${path.module}/app1-install.sh")
  tags = {
    Name = "EC2 Demo"
  }
}


