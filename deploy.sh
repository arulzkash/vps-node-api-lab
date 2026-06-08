#!/bin/bash

set -e

APP_DIR="/var/www/my-api"
SERVICE_NAME="api"
if [ -f "$APP_DIR/.env" ]; then
  set -a
  source "$APP_DIR/.env"
  set +a
fi

HOST_PORT="${HOST_PORT:-3001}"

echo "==> Moving to app directory"
cd "$APP_DIR"

echo "==> Pulling latest code"
git pull origin main

echo "==> Building and starting containers with Docker Compose"
docker compose up -d --build

echo "==> Checking Docker Compose services"
docker compose ps

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
    echo "==> Compose logs:"
    docker compose logs "$SERVICE_NAME" --tail 50
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

    echo "==> Compose logs:"
    docker compose logs "$SERVICE_NAME" --tail 50
    exit 1
  fi
done

echo ""
echo "==> Deploy finished successfully"
