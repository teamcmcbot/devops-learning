# RSA key of size 4096 bits
resource "tls_private_key" "devops_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the AWS Key Pair
resource "aws_key_pair" "nautilus-kp" {
  key_name   = "nautilus-kp"
  public_key = tls_private_key.devops_key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.devops_key.private_key_pem
  filename        = "/home/bob/nautilus-kp.pem"
  file_permission = "0400"
}

# Get default SG
data "aws_security_group" "default" {
  name = "default"
}


resource "aws_instance" "nautilus-ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.nautilus-kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "nautilus-ec2"
  }
}

output "instance_id" {
  value = aws_instance.nautilus-ec2.id
}

output "instance_public_ip" {
  value = aws_instance.nautilus-ec2.public_ip
}

output "instance_public_dns" {
  value = aws_instance.nautilus-ec2.public_dns
}

output "instance_tags_name" {
  value = aws_instance.nautilus-ec2.tags_all
}
