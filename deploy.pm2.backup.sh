#!/bin/bash

set -e

echo "==> Moving to app directory"
cd /var/www/my-api

echo "==> Pulling latest code"
git pull origin main

echo "==> Installing dependencies"
npm install

echo "==> Restarting PM2 app"
pm2 restart my-api

echo "==> Saving PM2 process list"
pm2 save

echo "==> Checking backend directly"
curl -f http://127.0.0.1:3000/api/health

echo ""
echo "==> Checking public HTTPS endpoint"
curl -f https://api.levellife.my.id/api/health


echo ""
echo "==> Deploy finished successfully"
