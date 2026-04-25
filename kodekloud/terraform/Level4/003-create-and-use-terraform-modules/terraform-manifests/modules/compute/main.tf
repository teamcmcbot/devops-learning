# Use the Amazon Linux 2 AMI image with ID `ami-0c94855ba95c71c99` for the EC2 instance in the `compute` module.
resource "aws_instance" "compute" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = var.KKE_INSTANCE_TYPE
  subnet_id     = var.KKE_SUBNET_ID
  tags          = merge(var.KKE_TAGS, { Name = "${var.KKE_NAME_PREFIX}-instance" })
}
