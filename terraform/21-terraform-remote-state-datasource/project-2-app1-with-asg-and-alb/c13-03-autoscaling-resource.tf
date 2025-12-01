# Autoscaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name_prefix      = "myasg-"
  desired_capacity = 2
  max_size         = 10
  min_size         = 2

  #vpc_zone_identifier = module.vpc.private_subnets
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets
  #target_group_arns         = [for tg in module.alb.target_groups : tg.arn]
  target_group_arns         = [module.alb.target_groups["mytg1"].arn] # UPDATED to single TG
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_template {
    id = aws_launch_template.my_launch_template.id
    # version = "$Latest" - AWS magic string, but depends on update_default_version=true
    # version = aws_launch_template.my_launch_template.latest_version - Terraform reference, works regardless of update_default_version setting
    version = aws_launch_template.my_launch_template.latest_version
  }

  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 50
    }
    # No triggers = refresh on ANY launch template change
    triggers = ["desired_capacity"] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger   
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}
