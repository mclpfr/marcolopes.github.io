#!/bin/bash

# 🎯 Configuration SSL + NGINX pour Streamlit (port 8501) sur srv877984.hstgr.cloud
# Pour démo, sans email

set -e

DOMAIN="srv877984.hstgr.cloud"

echo "🔧 Mise à jour du système"
sudo apt update && sudo apt upgrade -y

echo "📦 Installation de Certbot et plugin NGINX"
sudo apt install -y certbot python3-certbot-nginx

echo "📜 Génération du certificat SSL (sans email)"
sudo certbot --nginx -d "$DOMAIN" --agree-tos --redirect --register-unsafely-without-email

echo "📝 Création du fichier de configuration NGINX"
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "🔗 Activation de la config"
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

echo "🔍 Vérification NGINX"
sudo nginx -t

echo "🔄 Redémarrage de NGINX"
sudo systemctl reload nginx

echo "🔁 Ajout du renouvellement auto"
sudo crontab -l | grep -q 'certbot renew' || (
  (sudo crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet") | sudo crontab -
)

echo "✅ Terminé ! Accède à ton Streamlit sur https://$DOMAIN"

