# Task 024 - Setting up an Application Load Balancer for an EC2 Instance

The Nautilus DevOps team is currently working on setting up a simple application on the AWS cloud. They aim to establish an Application Load Balancer (ALB) in front of an EC2 instance where an Nginx server is currently running. While the Nginx server currently serves a sample page, the team plans to deploy the actual application later.

1. Set up an Application Load Balancer named `datacenter-alb`.
2. Create a target group named `datacenter-tg`.
3. Create a security group named `datacenter-sg` to open port 80 for the public.
4. Attach this security group to the ALB.
5. The ALB should route traffic on port 80 to port 80 of the `datacenter-ec2` instance.
6. Make appropriate changes in the default security group attached to the EC2 instance if necessary.

## Solution

### Step 0: Check datacenter-ec2 configuration

- vpc: vpc-037fee8828dc53ed0
- az: us-east-1c
- sg: sg-000286437453f45b6 (default sg)

### Step 1: Create Security Group for ALB

- In AWS Console, create a security group named `datacenter-sg` and allow inbound traffic on port 80.

### Step 1.1: Modify EC2 Security Group

- Modify the security group attached to the `datacenter-ec2` instance to allow inbound traffic from the `datacenter-sg` security group on port 80.

### Step 2: Create Target Group

- Create a target group named `datacenter-tg` with the following settings:
  - Target type: Instance
  - Protocol: HTTP
  - Port: 80
  - VPC: Select the VPC where `datacenter-ec2` is located.
  - Register the `datacenter-ec2` instance to this target group.

### Step 3: Create Application Load Balancer

- Create an Application Load Balancer named `datacenter-alb` with the following settings:
  - Scheme: Internet-facing
  - IP address type: IPv4
  - Listeners: HTTP on port 80
  - Availability Zones: Select at least two for high availability (Must include `us-east-1c` where `datacenter-ec2` is located).
  - Security Groups: Attach the `datacenter-sg` created earlier.
  - Under "Routing", select the `datacenter-tg` target group created earlier.

### Step 4: Verify the Setup

- Obtain the DNS name of the `datacenter-alb` from the AWS Console.
- Open a web browser and navigate to the DNS name. You should see the sample page served by the Nginx server running on the `datacenter-ec2` instance.

```bash
~ on ☁️  (us-east-1) ➜  curl http://datacenter-alb-137462595.us-east-1.elb.amazonaws.com
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
