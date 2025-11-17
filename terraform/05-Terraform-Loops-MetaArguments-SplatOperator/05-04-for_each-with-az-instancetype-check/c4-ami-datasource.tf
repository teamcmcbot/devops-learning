# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amzlinux2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
    # Matches: al2023-ami-2023.9.20251110.1-kernel-6.1-x86_64
    # Expected: ami-0cae6d6fe6048ca2c, al2023-ami-2023.9.20251110.1-kernel-6.1-x86_64
    # Actual: ami-03c870feb7c37e4ff, al2023-ami-2023.9.20251110.1-kernel-6.12-x86_64
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

