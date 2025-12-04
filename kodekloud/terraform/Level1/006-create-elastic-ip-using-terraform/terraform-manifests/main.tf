resource "aws_eip" "datacenter-eip" {
  domain = "vpc"
  tags = {
    Name = "datacenter-eip"
  }
}

output "eip_arn" {
  value = aws_eip.datacenter-eip.arn
}

output "eip_public_ip" {
  value = aws_eip.datacenter-eip.public_ip
}
