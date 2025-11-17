# Docker Commands Reference

## Table of Contents

- [Basic Docker Commands](#basic-docker-commands)
- [Image Management](#image-management)
- [Container Management](#container-management)
- [Docker Build](#docker-build)
- [Docker Registry](#docker-registry)
- [Docker Compose](#docker-compose)
- [Networking](#networking)
- [Volumes and Storage](#volumes-and-storage)
- [System Management](#system-management)
- [Debugging and Inspection](#debugging-and-inspection)
- [Docker Security](#docker-security)

## Basic Docker Commands

### Check Docker Version and Info

```bash
# Check Docker version
docker --version
docker version

# Display system-wide information
docker info

# Get help for any command
docker --help
docker <command> --help
```

## Image Management

### Building Images

```bash
# Build image from Dockerfile
docker build -t <image-name> .
docker build -t <image-name>:<tag> .

# Build with build arguments
docker build --build-arg <key>=<value> -t <image-name> .

# Build from specific Dockerfile
docker build -f <dockerfile-path> -t <image-name> .

# Build without cache
docker build --no-cache -t <image-name> .
```

### Managing Images

```bash
# List all images
docker images
docker image ls

# Search for images on Docker Hub
docker search <image-name>

# Pull image from registry
docker pull <image-name>
docker pull <image-name>:<tag>

# Remove image
docker rmi <image-id>
docker rmi <image-name>:<tag>

# Remove all unused images
docker image prune

# Remove all images
docker rmi $(docker images -q)
```

### Image Inspection

```bash
# Inspect image details
docker inspect <image-name>

# View image history
docker history <image-name>

# Tag an image
docker tag <source-image> <target-image>:<tag>
```

## Container Management

### Running Containers

```bash
# Run container in foreground
docker run <image-name>

# Run container in background (detached)
docker run -d <image-name>

# Run with custom name
docker run --name <container-name> <image-name>

# Run with port mapping
docker run -p <host-port>:<container-port> <image-name>

# Run with volume mount
docker run -v <host-path>:<container-path> <image-name>

# Run with environment variables
docker run -e <KEY>=<value> <image-name>

# Run interactive container with TTY
docker run -it <image-name> /bin/bash

# Run container and remove after exit
docker run --rm <image-name>
```

### Container Lifecycle

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start stopped container
docker start <container-id>

# Stop running container
docker stop <container-id>

# Restart container
docker restart <container-id>

# Pause container
docker pause <container-id>

# Unpause container
docker unpause <container-id>

# Kill container (force stop)
docker kill <container-id>

# Remove container
docker rm <container-id>

# Remove all stopped containers
docker container prune
```

### Container Interaction

```bash
# Execute command in running container
docker exec <container-id> <command>

# Access container shell
docker exec -it <container-id> /bin/bash
docker exec -it <container-id> sh

# Copy files between host and container
docker cp <src-path> <container-id>:<dest-path>
docker cp <container-id>:<src-path> <dest-path>

# View container logs
docker logs <container-id>
docker logs -f <container-id>  # Follow logs
docker logs --tail 100 <container-id>  # Last 100 lines
```

## Docker Build

### Dockerfile Best Practices Commands

```bash
# Multi-stage build example
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Build Context Management

```bash
# Build with .dockerignore
echo "node_modules" > .dockerignore
echo "*.log" >> .dockerignore

# Build with specific context
docker build -t <image-name> <context-path>

# Build from URL
docker build -t <image-name> <git-url>
```

## Docker Registry

### Docker Hub Operations

```bash
# Login to Docker Hub
docker login

# Push image to registry
docker push <username>/<image-name>:<tag>

# Pull private image
docker pull <username>/<private-image>

# Logout
docker logout
```

### Private Registry

```bash
# Tag for private registry
docker tag <image-name> <registry-url>/<image-name>:<tag>

# Push to private registry
docker push <registry-url>/<image-name>:<tag>

# Login to private registry
docker login <registry-url>
```

## Docker Compose

### Basic Compose Commands

```bash
# Start services defined in docker-compose.yml
docker-compose up

# Start in background
docker-compose up -d

# Build and start
docker-compose up --build

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View running services
docker-compose ps

# View logs
docker-compose logs
docker-compose logs <service-name>

# Execute command in service
docker-compose exec <service-name> <command>

# Scale service
docker-compose up --scale <service-name>=<count>
```

### Compose File Management

```bash
# Use specific compose file
docker-compose -f <compose-file> up

# Validate compose file
docker-compose config

# Build services
docker-compose build

# Pull images
docker-compose pull
```

## Networking

### Network Management

```bash
# List networks
docker network ls

# Create network
docker network create <network-name>

# Create bridge network with subnet
docker network create --driver bridge --subnet=<subnet> <network-name>

# Connect container to network
docker network connect <network-name> <container-id>

# Disconnect container from network
docker network disconnect <network-name> <container-id>

# Remove network
docker network rm <network-name>

# Inspect network
docker network inspect <network-name>
```

### Container Networking

```bash
# Run container on specific network
docker run --network <network-name> <image-name>

# Expose all ports
docker run -P <image-name>

# Map specific ports
docker run -p 8080:80 -p 8443:443 <image-name>

# Use host networking
docker run --network host <image-name>
```

## Volumes and Storage

### Volume Management

```bash
# List volumes
docker volume ls

# Create volume
docker volume create <volume-name>

# Remove volume
docker volume rm <volume-name>

# Remove unused volumes
docker volume prune

# Inspect volume
docker volume inspect <volume-name>
```

### Mount Types

```bash
# Bind mount
docker run -v /host/path:/container/path <image-name>

# Named volume
docker run -v <volume-name>:/container/path <image-name>

# Tmpfs mount (in-memory)
docker run --tmpfs /container/path <image-name>

# Read-only mount
docker run -v /host/path:/container/path:ro <image-name>
```

## System Management

### System Information

```bash
# Display Docker system information
docker system info

# Show Docker disk usage
docker system df

# Display real-time events
docker system events

# Show system-wide information
docker stats
docker stats <container-id>  # Specific container
```

### Cleanup Commands

```bash
# Remove all unused data
docker system prune

# Remove all unused data including volumes
docker system prune -a --volumes

# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused networks
docker network prune

# Remove unused volumes
docker volume prune
```

## Debugging and Inspection

### Container Inspection

```bash
# Inspect container details
docker inspect <container-id>

# Get specific field from inspect
docker inspect --format='{{.State.Status}}' <container-id>

# View container processes
docker top <container-id>

# View container resource usage
docker stats <container-id>

# View container port mappings
docker port <container-id>
```

### Health Checks

```bash
# Run container with health check
docker run --health-cmd="curl -f http://localhost:8080/health" \
           --health-interval=30s \
           --health-timeout=10s \
           --health-retries=3 \
           <image-name>

# Check container health status
docker inspect --format='{{.State.Health.Status}}' <container-id>
```

## Docker Security

### Security Best Practices

```bash
# Run as non-root user
docker run --user 1000:1000 <image-name>

# Run with read-only filesystem
docker run --read-only <image-name>

# Drop capabilities
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE <image-name>

# Use security profiles
docker run --security-opt seccomp=<profile.json> <image-name>

# Limit resources
docker run --memory 512m --cpus 1.5 <image-name>
```

### Content Trust

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1

# Sign and push image
docker push <image-name>

# Verify signed image
docker pull <image-name>
```

## Useful Docker Commands Combinations

### Development Workflow

```bash
# Build, tag, and run in one line
docker build -t myapp . && docker run -p 8080:8080 myapp

# Remove container and run new one
docker rm -f myapp || true && docker run --name myapp -d -p 8080:8080 myimage

# View logs of last created container
docker logs $(docker ps -lq)

# Get IP address of container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-id>

# Remove all containers and images
docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q)
```

### Monitoring Commands

```bash
# Follow logs of multiple containers
docker-compose logs -f <service1> <service2>

# Monitor resource usage
watch docker stats

# List containers with custom format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## Docker Aliases (Add to ~/.bashrc or ~/.zshrc)

```bash
# Useful Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dstop='docker stop'
alias dstart='docker start'
alias drm='docker rm'
alias dprune='docker system prune -f'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcl='docker-compose logs'
```

---

## Tips and Best Practices

1. **Use .dockerignore** to exclude unnecessary files from build context
2. **Multi-stage builds** to reduce final image size
3. **Use specific tags** instead of `latest` in production
4. **Run containers as non-root** user when possible
5. **Use health checks** for better container monitoring
6. **Limit container resources** to prevent resource exhaustion
7. **Keep images small** by using alpine variants and minimal base images
8. **Use docker-compose** for multi-container applications
9. **Regular cleanup** of unused containers, images, and volumes
10. **Use secrets management** for sensitive data instead of environment variables
