# AWS Application Load Balancer (ALB) - Refresher

## What is an Application Load Balancer?

An **Application Load Balancer (ALB)** is a Layer 7 (Application Layer) load balancer that intelligently distributes incoming HTTP/HTTPS traffic across multiple targets (like EC2 instances, containers, IP addresses, or Lambda functions).

Unlike traditional load balancers that only route based on IP and port, ALBs understand the **content** of the request, allowing for sophisticated routing decisions based on:

- URL paths (`/api`, `/images`, `/admin`)
- Hostnames (`api.example.com`, `www.example.com`)
- HTTP headers
- Query strings
- Request methods

---

## How Does an ALB Work? (Flow)

```
Internet
   ↓
[Application Load Balancer]
   ↓ (Listener on Port 80/443)
   ↓
[Target Group]
   ↓ (Health Checks)
   ↓
[EC2 Instance 1] [EC2 Instance 2] [EC2 Instance 3]
```

### The Flow:

1. **Client** sends a request (e.g., `http://myapp.com/api/users`).
2. The request hits the **ALB**.
3. The **Listener** on the ALB checks which port/protocol the request came in on (e.g., port 80 for HTTP).
4. The listener evaluates **Rules** to determine where to route the request.
5. Traffic is forwarded to the appropriate **Target Group**.
6. The **Target Group** distributes the request to one of the healthy **Targets** (EC2 instances, containers, etc.).
7. The target processes the request and sends a response back through the ALB to the client.

---

## Key Components of an ALB

### 1. **Load Balancer**

The main resource that receives incoming traffic. It sits in **public subnets** (if internet-facing) and has:

- A **DNS name** (e.g., `my-alb-1234567890.us-east-1.elb.amazonaws.com`)
- **Security Groups** to control what traffic can reach it
- **Subnets** (must be in at least 2 Availability Zones for high availability)

**Terraform Configuration:**

```hcl
# Using the terraform-aws-modules/alb/aws module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  name               = "${local.name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets  # Must span at least 2 AZs
  load_balancer_type = "application"              # application, network, or gateway

  security_groups = [module.loadbalancer_sg.security_group_id]

  tags = local.common_tags
}
```

**Key Parameters:**

- `name`: Unique name for the ALB
- `vpc_id`: VPC where the ALB will be created
- `subnets`: Public subnets (at least 2 for HA)
- `load_balancer_type`: Set to `"application"` for ALB
- `security_groups`: List of security group IDs to attach

### 2. **Listener**

A **Listener** is a process that checks for connection requests on a specific **port** and **protocol**.

- **Port:** e.g., 80 (HTTP) or 443 (HTTPS)
- **Protocol:** HTTP, HTTPS
- **Default Action:** What to do with traffic (usually "forward to a target group")
- **Rules:** Optional routing rules based on path, host, headers, etc.

**Terraform Configuration:**

```hcl
# Listeners are configured within the ALB module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  # ... other ALB configuration ...

  # HTTP Listener (Port 80)
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "mytg1"  # References target group defined below
      }
    }

    # HTTPS Listener (Port 443) - Optional
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

      forward = {
        target_group_key = "mytg1"
      }
    }
  }
}
```

**Advanced Listener with Path-Based Routing:**

```hcl
listeners = {
  http = {
    port     = 80
    protocol = "HTTP"

    # Default action
    forward = {
      target_group_key = "default_tg"
    }

    # Path-based routing rules
    rules = {
      api_rule = {
        priority = 1

        conditions = [{
          path_pattern = {
            values = ["/api/*"]
          }
        }]

        actions = [{
          type             = "forward"
          target_group_key = "api_tg"
        }]
      }

      images_rule = {
        priority = 2

        conditions = [{
          path_pattern = {
            values = ["/images/*"]
          }
        }]

        actions = [{
          type             = "forward"
          target_group_key = "images_tg"
        }]
      }
    }
  }
}
```

You can have multiple listeners (e.g., one for HTTP on port 80, another for HTTPS on port 443).

### 3. **Target Group**

A **Target Group** is a logical grouping of targets (EC2 instances, IPs, containers) that will receive traffic from the ALB.

**Key Settings:**

- **Protocol & Port:** What protocol/port to forward traffic to (e.g., HTTP on port 80)
- **Target Type:**
  - `instance` (EC2 instance IDs)
  - `ip` (IP addresses)
  - `lambda` (Lambda functions)
- **Health Check:** How the ALB determines if a target is healthy
  - **Path:** e.g., `/app1/index.html`
  - **Interval:** How often to check (e.g., every 30 seconds)
  - **Healthy/Unhealthy Threshold:** How many checks before marking healthy/unhealthy
  - **Matcher:** Expected HTTP status codes (e.g., `200-399`)

**Important:** The ALB only sends traffic to **healthy** targets. If a target fails health checks, it is removed from rotation.

**Terraform Configuration:**

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  # ... other ALB configuration ...

  target_groups = {
    mytg1 = {
      # Target group basic settings
      name_prefix                       = "mytg1-"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"  # instance, ip, or lambda

      # Deregistration delay (how long to wait before removing targets)
      deregistration_delay              = 10  # seconds (default: 300)

      # Load balancing settings
      load_balancing_algorithm_type     = "weighted_random"  # round_robin, least_outstanding_requests
      load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
      protocol_version                  = "HTTP1"  # HTTP1 or HTTP2

      # Target group health settings
      target_group_health = {
        dns_failover = {
          minimum_healthy_targets_count = 2
        }
        unhealthy_state_routing = {
          minimum_healthy_targets_percentage = 50
        }
      }

      # Health check configuration
      health_check = {
        enabled             = true
        interval            = 30                    # seconds between checks
        path                = "/app1/index.html"    # health check endpoint
        port                = "traffic-port"        # or specific port like "80"
        healthy_threshold   = 3                     # consecutive successes before healthy
        unhealthy_threshold = 3                     # consecutive failures before unhealthy
        timeout             = 6                     # seconds to wait for response
        protocol            = "HTTP"                # HTTP or HTTPS
        matcher             = "200-399"             # expected HTTP status codes
      }

      # IMPORTANT: Set to false if you want to manually attach targets
      # See GitHub issue: https://github.com/terraform-aws-modules/terraform-aws-alb/issues/316
      create_attachment = false

      tags = local.common_tags
    }
  }
}
```

**Multiple Target Groups Example:**

```hcl
target_groups = {
  # API Target Group
  api_tg = {
    name_prefix  = "api-"
    protocol     = "HTTP"
    port         = 8080
    target_type  = "instance"

    health_check = {
      path    = "/api/health"
      matcher = "200"
    }
  }

  # Web Target Group
  web_tg = {
    name_prefix  = "web-"
    protocol     = "HTTP"
    port         = 80
    target_type  = "instance"

    health_check = {
      path    = "/health"
      matcher = "200"
    }
  }
}
```

### 4. **Targets**

The actual resources that handle the traffic:

- **EC2 Instances**
- **IP Addresses** (useful for on-premises servers or containers)
- **Lambda Functions**

Targets are registered with a Target Group, either:

- **Automatically** (if using Auto Scaling Groups)
- **Manually** (using `aws_lb_target_group_attachment` in Terraform)

**Terraform Configuration:**

```hcl
# Method 1: Attach a single target
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = module.alb.target_groups["mytg1"].arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# Method 2: Attach multiple targets using for_each (recommended)
resource "aws_lb_target_group_attachment" "mytg1" {
  for_each = { for k, v in module.ec2_private : k => v }

  target_group_arn = module.alb.target_groups["mytg1"].arn
  target_id        = each.value.id  # EC2 instance ID
  port             = 80
}

# Method 3: Attach by IP address (for containers or external servers)
resource "aws_lb_target_group_attachment" "by_ip" {
  target_group_arn = module.alb.target_groups["mytg1"].arn
  target_id        = "10.0.1.100"  # Private IP address
  port             = 8080
}
```

**Key Parameters:**

- `target_group_arn`: ARN of the target group to attach to
- `target_id`:
  - EC2 instance ID (if `target_type = "instance"`)
  - IP address (if `target_type = "ip"`)
  - Lambda function ARN (if `target_type = "lambda"`)
- `port`: The port on which the target receives traffic

### 5. **Security Groups**

ALBs require **Security Groups** to control inbound/outbound traffic:

- **ALB Security Group:** Allow HTTP (80) and HTTPS (443) from the internet
- **Target Security Group:** Allow traffic from the ALB's security group on the target port (e.g., port 80)

**Terraform Configuration:**

```hcl
# ALB Security Group - Allows internet traffic
module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name        = "loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR)"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rules - Allow HTTP from internet
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Egress Rules - Allow all outbound traffic
  egress_rules = ["all-all"]

  tags = local.common_tags
}

# Private EC2 Security Group - Allows traffic only from ALB
module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name        = "private-sg"
  description = "Security Group for private EC2 instances - allows traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rules - Allow HTTP from ALB security group
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.loadbalancer_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  # Egress Rules
  egress_rules = ["all-all"]

  tags = local.common_tags
}
```

**Security Flow:**

```
Internet (0.0.0.0/0)
    ↓ [Port 80/443]
[ALB Security Group]
    ↓ [Port 80]
[Private EC2 Security Group]
    ↓
[EC2 Instances]
```

---

## Basic Configuration Checklist

When setting up an ALB, you need to configure:

1. ✅ **Load Balancer Name** and type (`application`)
2. ✅ **VPC** and **Subnets** (at least 2 AZs for high availability)
3. ✅ **Security Groups** (what traffic can reach the ALB)
4. ✅ **Listener(s)** (port/protocol, e.g., port 80 HTTP)
5. ✅ **Target Group(s)**:
   - Protocol and port
   - Target type (`instance`, `ip`, `lambda`)
   - Health check settings (path, interval, thresholds)
6. ✅ **Targets** (register EC2 instances or IPs to the target group)
7. ✅ **Routing Rules** (optional, for advanced path/host-based routing)

---

## Complete Terraform Example

Here's a complete working example that ties all components together:

```hcl
# 1. ALB Security Group
module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name                = "loadbalancer-sg"
  description         = "Security Group for ALB"
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  tags                = local.common_tags
}

# 2. Application Load Balancer with Target Groups and Listeners
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  name               = "${local.name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  load_balancer_type = "application"
  security_groups    = [module.loadbalancer_sg.security_group_id]

  # Listeners
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "mytg1"
      }
    }
  }

  # Target Groups
  target_groups = {
    mytg1 = {
      name_prefix                   = "mytg1-"
      protocol                      = "HTTP"
      port                          = 80
      target_type                   = "instance"
      deregistration_delay          = 10
      load_balancing_algorithm_type = "weighted_random"
      create_attachment             = false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      tags = local.common_tags
    }
  }

  tags = local.common_tags
}

# 3. Attach EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "mytg1" {
  for_each = { for k, v in module.ec2_private : k => v }

  target_group_arn = module.alb.target_groups["mytg1"].arn
  target_id        = each.value.id
  port             = 80
}

# 4. Outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "target_group_arns" {
  description = "ARNs of target groups"
  value       = module.alb.target_groups
}
```

---

## Common Use Cases

### 1. **Simple Web Application**

- **1 Listener** (HTTP on port 80)
- **1 Target Group** (forwards to multiple EC2 instances)
- **Health Check** ensures only healthy instances receive traffic

### 2. **Microservices Architecture**

- **1 Listener** (HTTP on port 80)
- **Multiple Target Groups** (one per microservice)
- **Routing Rules:**
  - `/api/*` → API Target Group
  - `/images/*` → Image Service Target Group
  - `/admin/*` → Admin Service Target Group

### 3. **Multi-Tenant Application**

- **1 Listener** (HTTPS on port 443)
- **Host-based Routing:**
  - `tenant1.example.com` → Tenant 1 Target Group
  - `tenant2.example.com` → Tenant 2 Target Group

---

## Important Concepts

### **Deregistration Delay**

When you remove a target from a Target Group, the ALB waits a certain amount of time (default: 300 seconds) before stopping traffic to that target. This gives in-flight requests time to complete.

**Best Practice:** Set this lower (e.g., 10-30 seconds) for faster deployments.

### **Cross-Zone Load Balancing**

By default, ALBs distribute traffic evenly across all registered targets in all enabled Availability Zones. This ensures balanced load distribution even if you have unequal numbers of targets in each AZ.

### **Stickiness (Session Affinity)**

You can enable "sticky sessions" to ensure a user always goes to the same target. This is useful if your app stores session data locally (though using external session storage like Redis is better).

---

## Load Balancing Algorithms

ALBs support different algorithms for distributing traffic:

1. **Round Robin** (default for HTTP/HTTPS): Distributes requests evenly across targets
2. **Least Outstanding Requests**: Sends traffic to the target with the fewest active requests
3. **Weighted Random**: Randomly distributes traffic, but can weight certain targets more heavily

---

---

## Terraform Variables and Outputs

### Common Variables

```hcl
# variables.tf
variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "enable_http2" {
  description = "Enable HTTP/2 support"
  type        = bool
  default     = true
}
```

### Useful Outputs

```hcl
# outputs.tf
output "alb_id" {
  description = "The ID of the load balancer"
  value       = module.alb.id
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the load balancer (for Route53)"
  value       = module.alb.zone_id
}

output "target_group_arns" {
  description = "ARNs of all target groups"
  value       = { for k, v in module.alb.target_groups : k => v.arn }
}

output "listener_arns" {
  description = "ARNs of all listeners"
  value       = { for k, v in module.alb.listeners : k => v.arn }
}
```

---

## Summary

An ALB is like a **smart traffic cop** that:

- Receives incoming HTTP/HTTPS traffic
- Uses **Listeners** to know what port/protocol to expect
- Uses **Rules** to decide where to route traffic
- Forwards traffic to **Target Groups**
- Only sends traffic to **healthy targets** (via health checks)
- Can route intelligently based on URL paths, hostnames, headers, etc.

This makes ALBs perfect for modern web applications, microservices, and container-based architectures.

---

## Quick Reference: Terraform Module Structure

```
terraform-manifests/
├── alb.tf                    # ALB module configuration
├── security-groups.tf        # ALB and target security groups
├── target-attachments.tf     # Target group attachments
├── variables.tf              # Input variables
├── outputs.tf                # Output values
└── locals.tf                 # Local values (naming, tags)
```

**Deployment Steps:**

1. `terraform init` - Initialize and download modules
2. `terraform plan` - Preview changes
3. `terraform apply` - Create ALB infrastructure
4. Access your app via the ALB DNS name (from outputs)
