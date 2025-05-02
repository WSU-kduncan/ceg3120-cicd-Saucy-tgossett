#!/usr/bin/env bash

IMAGE="saucydorito/gossett-ceg3120:latest"
CONTAINER="angular-site"

# 1) Pull latest image
docker pull "$IMAGE"

# 2) Stop & remove old container (ignore errors)
docker stop "$CONTAINER" || true
docker rm   "$CONTAINER" || true

# 3) Start new container
docker run -d -p 4200:4200 --name "$CONTAINER" "$IMAGE" 
