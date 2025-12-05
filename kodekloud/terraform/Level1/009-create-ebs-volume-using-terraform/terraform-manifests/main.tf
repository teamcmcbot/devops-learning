data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "nautilus-volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 2
  type              = "gp3"

  tags = {
    Name = "nautilus-volume"
  }
}

# Output the EBS volume ID and arn

output "ebs_volume_id" {
  value = aws_ebs_volume.nautilus-volume.id
}

output "ebs_volume_arn" {
  value = aws_ebs_volume.nautilus-volume.arn
}
