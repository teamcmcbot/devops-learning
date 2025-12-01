# Launch Template Resource
resource "aws_launch_template" "my_launch_template" {
  name          = "my-launch-template"
  description   = "My launch template 1"
  image_id      = data.aws_ami.amzlinux2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.private_sg.security_group_id]
  key_name               = var.instance_keypair
  user_data              = filebase64("${path.module}/app1-install.sh")
  ebs_optimized          = true
  #default_version = 1
  update_default_version = true

  block_device_mappings {
    #device_name = "/dev/sdf"      # ← Commented out (for additional disk)
    #device_name = "/dev/sda1"      # ← Traditional root device
    device_name = "/dev/xvda" # ← Modern root device
    # To verify device name: aws ec2 describe-images --image-ids ami-0f00d706c4a80fd93 --query 'Images[0].BlockDeviceMappings[0].DeviceName' --region us-east-1
    # Returns: "/dev/xvda" (Amazon Linux 2023)

    ebs {
      #volume_size           = 10
      volume_size           = 20 # Updated to test ASG Instance Refresh
      delete_on_termination = true
      volume_type           = "gp3"
    }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "myasg"
    }
  }
}
