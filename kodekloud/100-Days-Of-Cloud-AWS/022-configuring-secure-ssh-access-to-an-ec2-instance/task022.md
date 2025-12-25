# Task 022 - Configuring Secure SSH Access to an EC2 Instance

The Nautilus DevOps team needs to set up a new EC2 instance that can be accessed securely from their landing host (aws-client). The instance should be of type `t2.micro` and named `devops-ec2`. A new SSH key should be created on the aws-client host under the/root/.ssh/ folder, if it doesn't already exist. This key should then be added to the root user's authorised keys on the EC2 instance, allowing passwordless SSH access from the aws-client host.

## Solution

1. Generate an SSH key pair on the jump host (aws-client) if it doesn't already exist.

```bash
~ on ☁️  (us-east-1) ➜  ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""
Generating public/private rsa key pair.
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:2c14dJco9N843ftZXUAOOvHSGdCWoBPaUEWvJXEiFWo root@aws-client
The key's randomart image is:
+---[RSA 2048]----+
|      ..++@*+..  |
|       + =.X=*. .|
|      . E =oBo+..|
|       . + @...=o|
|        S + + o.=|
|           .   .+|
|               .o|
|                +|
|               ..|
+----[SHA256]-----+

~ on ☁️  (us-east-1) ➜  ls -la ~/.ssh
total 32
drwx------ 1 root root 4096 Dec 25 15:06 .
drwx------ 1 root root 4096 Dec 25 14:53 ..
-rw------- 1 root root  131 Dec 25 14:53 agent-environment
-r-------- 1 root root 1133 Dec 25 14:53 authorized_keys
-rw------- 1 root root 1823 Dec 25 15:06 id_rsa
-rw-r--r-- 1 root root  397 Dec 25 15:06 id_rsa.pub
```

2. Import public key to AWS as a key pair

```bash
~ on ☁️  (us-east-1) ✖ aws ec2 import-key-pair \
  --key-name devops-ec2-key \
  --public-key-material fileb:///root/.ssh/id_rsa.pub
{
    "KeyFingerprint": "86:61:1e:7d:bd:90:8c:88:a4:32:84:9a:cb:a6:68:17",
    "KeyName": "devops-ec2-key",
    "KeyPairId": "key-0a7a67e623c40134a"
}
```

3. Launch EC2 instance with the imported key pair from AWS Console. For security group, allow SSH access.

4. After the EC2 instance is running, get is public DNS or IP address from AWS Console.

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query 'Reservations[*].Instances[*].PublicDnsName' \
  --output text
ec2-54-83-89-21.compute-1.amazonaws.com
```

5. Test SSH access from aws-client to the EC2 instance.

```bash
~ on ☁️  (us-east-1) ➜  ssh -i /root/.ssh/id_rsa ec2-user@ec2-54-83-89-21.compute-1.amazonaws.com
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Thu Dec 25 15:19:25 2025 from 35.188.139.128
[ec2-user@ip-172-31-24-174 ~]$
```

6. Copy the authorized_keys file to the root user's .ssh directory on the EC2 instance.

```bash
# Then on the EC2 instance, add the key to root's authorized_keys
sudo mkdir -p /root/.ssh
sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/authorized_keys

# Also enable root login (if needed)
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

7. Verify password-less SSH access from aws-client to the EC2 instance as root.

```bash
~ on ☁️  (us-east-1) ➜  whoami
root

~ on ☁️  (us-east-1) ➜  ssh -i /root/.ssh/id_rsa ec2-54-83-89-21.compute-1.amazonaws.com
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[root@ip-172-31-24-174 ~]#
```
