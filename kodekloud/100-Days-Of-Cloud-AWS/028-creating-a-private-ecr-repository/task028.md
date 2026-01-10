# Task 028 : Creating a Private ECR Repository

The Nautilus DevOps team has been tasked with setting up a containerized application. They need to create a private Amazon Elastic Container Registry (ECR) repository to store their Docker images. Once the repository is created, they will build a Docker image from a Dockerfile located on the aws-client host and push this image to the ECR repository. This process is essential for maintaining and deploying containerized applications in a streamlined manner.

Create a private ECR repository named `devops-ecr`. There is a Dockerfile under `/root/pyapp` directory on `aws-client` host, build a docker image using this Dockerfile and push the same to the newly created ECR repo, the image tag must be latest.

## Additional Information

```bash
~ on ☁️  (us-east-1) ➜  cd /root/pyapp/

~/pyapp on ☁️  (us-east-1) ➜  ls -lr
total 8
-rw-r--r-- 1 root root   0 Jan 10 05:21 requirements.txt
-rw-r--r-- 1 root root 127 Jan 10 05:21 Dockerfile
-rw-r--r-- 1 root root  23 Jan 10 05:21 app.py

~/pyapp on ☁️  (us-east-1) ➜  ls -la
total 20
drwxr-xr-x 2 root root 4096 Jan 10 05:21 .
drwx------ 1 root root 4096 Jan 10 05:21 ..
-rw-r--r-- 1 root root   23 Jan 10 05:21 app.py
-rw-r--r-- 1 root root  127 Jan 10 05:21 Dockerfile
-rw-r--r-- 1 root root    0 Jan 10 05:21 requirements.txt

~/pyapp on ☁️  (us-east-1) ➜  cat Dockerfile
# Sample Dockerfile
FROM python:3.8-slim
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

## Solution

1. Create a private ECR repository named `devops-ecr`.

```bash
~/pyapp on ☁️  (us-east-1) ➜  aws ecr create-repository --repository-name devops-ecr --region us-east-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:113749894636:repository/devops-ecr",
        "registryId": "113749894636",
        "repositoryName": "devops-ecr",
        "repositoryUri": "113749894636.dkr.ecr.us-east-1.amazonaws.com/devops-ecr",
        "createdAt": 1768022819.18,
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```

2. On the `aws-client` host, build the Docker image using the Dockerfile located in `/root/pyapp`.

```bash
cd /root/pyapp
docker build -t devops-ecr:latest .
```

```bash
~/pyapp on ☁️  (us-east-1) ➜  docker build -t devops-ecr:latest .
Sending build context to Docker daemon  3.584kB
Step 1/5 : FROM python:3.8-slim
3.8-slim: Pulling from library/python
302e3ee49805: Pull complete
030d7bdc20a6: Pull complete
a3f1dfe736c5: Pull complete
3971691a3637: Pull complete
Digest: sha256:1d52838af602b4b5a831beb13a0e4d073280665ea7be7f69ce2382f29c5a613f
Status: Downloaded newer image for python:3.8-slim
 ---> b5f62925bd0f
Step 2/5 : COPY . /app
 ---> 016d1aeb2da6
Step 3/5 : WORKDIR /app
 ---> Running in 1897823a782a
Removing intermediate container 1897823a782a
 ---> 8dc25ef0ed51
Step 4/5 : RUN pip install -r requirements.txt
 ---> Running in 976d18a7003a
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

[notice] A new release of pip is available: 23.0.1 -> 25.0.1
[notice] To update, run: pip install --upgrade pip
Removing intermediate container 976d18a7003a
 ---> 3cb30424e6b5
Step 5/5 : CMD ["python", "app.py"]
 ---> Running in 5cdbde809536
Removing intermediate container 5cdbde809536
 ---> 2d72e4c44e9d
Successfully built 2d72e4c44e9d
Successfully tagged devops-ecr:latest


~/pyapp on ☁️  (us-east-1) ➜  docker images
REPOSITORY   TAG        IMAGE ID       CREATED         SIZE
devops-ecr   latest     2d72e4c44e9d   2 minutes ago   131MB
python       3.8-slim   b5f62925bd0f   16 months ago   125MB

```

3. Authenticate Docker to the ECR registry.

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 113749894636.dkr.ecr.us-east-1.amazonaws.com
```

```bash
~/pyapp on ☁️  (us-east-1) ➜  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 113749894636.dkr.ecr.us-east-1.amazonaws.com
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

4. Tag the Docker image to match the ECR repository URI.

```bash
docker tag devops-ecr:latest 113749894636.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

5. Push the Docker image to the ECR repository.

```bash
docker push 113749894636.dkr.ecr.us-east-1.amazonaws.com/devops-ecr:latest
```

6. Verify the image is pushed to the ECR repository.

```bash
aws ecr describe-images --repository-name devops-ecr --region us-east-1
```

```bash
~ on ☁️  (us-east-1) ➜  aws ecr describe-images --repository-name devops-ecr --region us-east-1
{
    "imageDetails": [
        {
            "registryId": "113749894636",
            "repositoryName": "devops-ecr",
            "imageDigest": "sha256:bcc39c356d0e1b5c78b8e6e3b5a6a67a5a7fdeb160c2aa567ee0eaf92d5308ec",
            "imageTags": [
                "latest"
            ],
            "imageSizeInBytes": 49724748,
            "imagePushedAt": 1768023606.056,
            "imageManifestMediaType": "application/vnd.docker.distribution.manifest.v2+json",
            "artifactMediaType": "application/vnd.docker.container.image.v1+json"
        }
    ]
}
```
