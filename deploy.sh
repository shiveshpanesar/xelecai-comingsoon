#!/bin/bash

# === CONFIG ===
APP_DIR="$PWD"
DOMAIN="xelec.tech"
EMAIL="xelecgulshan@gmail.com"

echo "🚀 Starting deployment from $APP_DIR..."

# === Docker Install ===
if ! command -v docker &> /dev/null; then
  echo "🔧 Installing Docker..."
  apt update
  apt install -y docker.io docker-compose
  systemctl enable docker
  systemctl start docker
else
  echo "✅ Docker already installed."
fi

# === Build & Run Docker ===
cd "$APP_DIR"
echo "🐳 Building and running containers..."
docker-compose pull
docker-compose up -d --build

# === Install Nginx ===
if ! command -v nginx &> /dev/null; then
  echo "🌐 Installing Nginx..."
  apt install -y nginx
fi

# === Nginx Config ===
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
if [ ! -f "$NGINX_CONF" ]; then
  echo "🔧 Setting up Nginx config..."
  cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://localhost:8000;
    }

    location /qdrant/ {
        proxy_pass http://localhost:6333;
    }
}
EOF

  ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/
  nginx -t && systemctl restart nginx
else
  echo "✅ Nginx config already exists."
fi

# === SSL Setup ===
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
if [ ! -f "$CERT_PATH" ]; then
  echo "🔐 Setting up SSL with Certbot..."
  apt install -y certbot python3-certbot-nginx
  certbot --nginx --non-interactive --agree-tos -m "$EMAIL" -d "$DOMAIN"
else
  echo "✅ SSL certificate already exists."
fi

echo "✅ Deployment complete: https://$DOMAIN"
