# AWS Region Management for Terraform Learning

## Your Situation

- Current setup: AWS CLI configured for `ap-southeast-1` (personal projects)
- Goal: Use a different region like `us-east-1` for Terraform learning
- Question: Do you need new user/access keys or just specify region?

## Recommended Approach: **Option 2 - Use Same Credentials, Different Region**

### ✅ **Best Practice: Keep Same User/Credentials**

**You do NOT need to create a new user or new access keys.** Here's why this is the better approach:

1. **Simpler management**: One set of credentials to manage
2. **Same permissions**: Your existing IAM user already has the necessary permissions
3. **Cost isolation**: You can still separate costs using tags or separate projects
4. **Security**: No need to proliferate access keys

## How to Handle Different Regions

### Method 1: Configure Region in Terraform Provider (Recommended)

Create your Terraform configuration with explicit region specification:

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Specify region directly in provider
provider "aws" {
  region = "us-east-1"  # Different from your default ap-southeast-1
}

# Your resources will be created in us-east-1
resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for us-east-1
  instance_type = "t2.micro"
}
```

### Method 2: Use Environment Variables

Set environment variables for your Terraform session:

```bash
# For your Terraform learning session
export AWS_DEFAULT_REGION=us-east-1
export AWS_REGION=us-east-1

# Then run terraform commands
terraform init
terraform plan
terraform apply
```

### Method 3: AWS CLI Profiles (Most Flexible)

Create a separate AWS CLI profile for your Terraform learning:

```bash
# Create a new profile for terraform learning
aws configure --profile terraform-learning
# Use same access key ID and secret as your default profile
# Set region to us-east-1

# Use the profile with Terraform
export AWS_PROFILE=terraform-learning

# Or specify it directly in terraform commands
AWS_PROFILE=terraform-learning terraform plan
```

## Current AWS CLI Configuration Check

Let's check your current configuration:

```bash
# Check your current default region
aws configure get region

# Check your current credentials (without exposing secrets)
aws configure list

# Test access to different regions
aws ec2 describe-regions --query 'Regions[].{Name:RegionName}' --output table
```

## Directory Structure for Learning

Organize your Terraform learning projects:

```
terraform/
├── aws-region-management.md    # This file
├── terraform-commands.md       # Your existing commands guide
├── learning-projects/
│   ├── 01-basic-ec2/
│   │   ├── main.tf             # us-east-1 region specified
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── 02-vpc-setup/
│   │   └── main.tf             # us-east-1 region specified
│   └── 03-multi-region/        # Advanced: Multiple regions
│       ├── main.tf
│       └── providers.tf
```

## Sample Learning Project Setup

Create your first learning project:

**File: `terraform/learning-projects/01-basic-ec2/main.tf`**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Explicitly set for learning
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "learning_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"  # Free tier eligible

  tags = {
    Name        = "terraform-learning"
    Project     = "udemy-course"
    Environment = "learning"
  }
}

output "instance_public_ip" {
  value = aws_instance.learning_instance.public_ip
}
```

## Region-Specific Considerations

### AMI IDs are Region-Specific

- AMI IDs differ between regions
- Use data sources to find AMIs dynamically (as shown above)
- Or check [AWS AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/)

### Availability Zones

- us-east-1 has: us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f
- ap-southeast-1 has: ap-southeast-1a, ap-southeast-1b, ap-southeast-1c

### Cost Considerations

- Some services have different pricing in different regions
- us-east-1 is often the cheapest region
- Good choice for learning/testing

## Quick Start Commands

```bash
# 1. Navigate to terraform directory
cd /Users/zhenwei.seo/github/devops-learning/terraform

# 2. Create your first learning project
mkdir -p learning-projects/01-basic-ec2
cd learning-projects/01-basic-ec2

# 3. Create the main.tf file (use the example above)
# 4. Initialize and run
terraform init
terraform validate
terraform plan
terraform apply

# 5. When done learning, clean up
terraform destroy
```

## Answers to Your Questions

### Q: Should I create a new user?

**A: No.** Use your existing IAM user - it's simpler and more practical.

### Q: Do I need new access keys?

**A: No.** Your existing access keys work in all AWS regions.

### Q: Do I need to specify region every time?

**A: No.** Once you specify the region in your Terraform provider configuration, all resources will be created in that region. You don't need to specify it for individual AWS CLI commands unless you want to override it.

## Best Practices for Learning

1. **Explicit region in provider**: Always specify region in your Terraform configuration
2. **Use tags**: Tag resources with "Project: udemy-course" for easy identification
3. **Clean up**: Always run `terraform destroy` after learning sessions
4. **Cost monitoring**: Set up billing alerts for peace of mind
5. **Start simple**: Begin with single resources before complex architectures

This approach keeps your personal projects separate while using the same credentials efficiently!
