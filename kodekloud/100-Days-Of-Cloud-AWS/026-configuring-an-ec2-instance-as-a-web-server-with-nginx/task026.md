# Task 026 - Configuring an EC2 Instance as a Web Server with NGINX

The Nautilus DevOps Team is working on setting up a new web server for a critical application. The team lead has requested you to create an EC2 instance that will serve as a web server using Nginx. This instance will be part of the initial infrastructure setup for the Nautilus project. Ensuring that the server is correctly configured and accessible from the internet is crucial for the upcoming deployment phase.

As a member of the Nautilus DevOps Team, your task is to create an EC2 instance with the following specifications:

**Instance Name**: The EC2 instance must be named `devops-ec2`.

**AMI**: Use any available Ubuntu AMI to create this instance.

**User Data Script**: Configure the instance to run a user data script during its launch. This script should:

- Install the Nginx package.
- Start the Nginx service.

**Security Group**: Ensure that the instance allows HTTP traffic on port `80` from the internet.

## Solution Steps:

1. Log in to the AWS Management Console.
2. Navigate to the EC2 Dashboard and click on "Launch Instance".
3. Choose an Ubuntu AMI from the list of available AMIs.
4. Select an instance type (e.g., t2.micro) and click "Next:
5. Configure the instance details:
   - Set the instance name to `devops-ec2`.
   - In the "Advanced Details" section, add the following user data script:
     ```bash
     #!/bin/bash
     apt-get update
     apt-get install -y nginx
     systemctl start nginx
     systemctl enable nginx
     ```
6. Security Group Configuration:
   - Create a new security group named `devops-sg`.
   - Add a rule to allow inbound HTTP traffic on port `80` from `0.0.0.0/0`.
7. Key Pair:
   - Create new key pair or select an existing one for SSH access.
8. Review and launch the instance.
9. Once the instance is running, obtain its public IP address from the EC2 Dashboard.
10. Open a web browser and navigate to the public IP address of the instance to verify that the Nginx welcome page is displayed.

```bash
~ on ☁️  (us-east-1) ➜  curl http://ec2-54-90-72-50.compute-1.amazonaws.com/
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
