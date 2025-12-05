resource "aws_ebs_volume" "k8s_volume" {
  availability_zone = "us-east-1a"
  size              = 5
  type              = "gp2"

  tags = {
    Name = "devops-vol"
  }
}

# Create snapshot of the existing volume
resource "aws_ebs_snapshot" "devops-vol-ss" {
  volume_id   = aws_ebs_volume.k8s_volume.id
  description = "Devops Snapshot"
  tags = {
    Name = "devops-vol-ss"
  }
}

# Output volume ID, ARN, tags_all
output "volume_id" {
  value = aws_ebs_volume.k8s_volume.id
}
output "volume_arn" {
  value = aws_ebs_volume.k8s_volume.arn
}
output "volume_tags" {
  value = aws_ebs_volume.k8s_volume.tags_all
}

# Output snapshot ID, ARN, size, tags
output "snapshot_id" {
  value = aws_ebs_snapshot.devops-vol-ss.id
}
output "snapshot_arn" {
  value = aws_ebs_snapshot.devops-vol-ss.arn
}
output "snapshot_size" {
  value = aws_ebs_snapshot.devops-vol-ss.volume_size
}
output "snapshot_tags" {
  value = aws_ebs_snapshot.devops-vol-ss.tags_all
}
