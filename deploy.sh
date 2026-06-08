#!/bin/bash

set -e

APP_DIR="/var/www/my-api"
IMAGE_NAME="my-api"
IMAGE_TAG="latest"
CONTAINER_NAME="my-api-docker"
HOST_PORT="3001"
CONTAINER_PORT="3000"

echo "==> Moving to app directory"
cd "$APP_DIR"

echo "==> Pulling latest code"
git pull origin main

echo "==> Building Docker image"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

echo "==> Stopping old container if exists"
docker stop "$CONTAINER_NAME" 2>/dev/null || true

echo "==> Removing old container if exists"
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "==> Starting new container"
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p 127.0.0.1:"$HOST_PORT":"$CONTAINER_PORT" \
  "$IMAGE_NAME:$IMAGE_TAG"

echo "==> Checking Docker container"
docker ps --filter "name=$CONTAINER_NAME"

echo "==> Checking backend through Docker local port"

for i in {1..10}; do
  if curl -f "http://127.0.0.1:$HOST_PORT/api/health"; then
    echo ""
    echo "==> Local Docker health check passed"
    break
  fi

  echo "Health check failed, retrying in 1 second... ($i/10)"
  sleep 1

  if [ "$i" -eq 10 ]; then
    echo "Docker local health check failed after 10 attempts"
    echo "==> Container logs:"
    docker logs "$CONTAINER_NAME" --tail 50
    exit 1
  fi
done

echo ""
echo "==> Checking public HTTPS endpoint"

for i in {1..10}; do
  if curl -f "https://api.levellife.my.id/api/health"; then
    echo ""
    echo "==> Public HTTPS health check passed"
    break
  fi

  echo "Public health check failed, retrying in 1 second... ($i/10)"
  sleep 1

  if [ "$i" -eq 10 ]; then
    echo "Public HTTPS health check failed after 10 attempts"
    echo "==> Nginx status:"
    sudo systemctl status nginx --no-pager

    echo "==> Container logs:"
    docker logs "$CONTAINER_NAME" --tail 50
    exit 1
  fi
done

echo ""
echo "==> Deploy finished successfully"
