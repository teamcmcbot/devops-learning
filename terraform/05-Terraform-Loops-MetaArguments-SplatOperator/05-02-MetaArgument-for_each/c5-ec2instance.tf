# Resource: EC2 Instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "myazones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "aws_instance" "myec2vm" {
  for_each = toset(data.aws_availability_zones.myazones.names)

  ami = data.aws_ami.amzlinux2023.id
  #instance_type = var.instance_type_list[2] # For List
  instance_type          = var.instance_type_map["dev"] # For Map
  user_data              = file("${path.module}/app1-install.sh")
  key_name               = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  availability_zone      = each.key

  tags = {
    Name = "for_each-Demo-${each.key}"
    AZ   = each.key
  }
}


