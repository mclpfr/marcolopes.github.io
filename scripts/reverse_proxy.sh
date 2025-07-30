#!/bin/bash

NGINX_CONF="/etc/nginx/sites-available/vmi2734167.contaboserver.net"

# Table associative : chemin => port
declare -A services=(
  ["/airflow/"]="8080"
  ["/grafana/"]="3000"
  ["/evidently/"]="8001"
  ["/predict/"]="8000"
  ["/auth/"]="7999"
  ["/agent/"]="8003"
  ["/drift/"]="8002"
  ["/prometheus/"]="9090"
  ["/alertmanager/"]="9093"
  ["/cadvisor/"]="8081"
)

echo "🔐 Sauvegarde de l’ancienne config..."
sudo cp "$NGINX_CONF" "$BACKUP_CONF"

for path in "${!services[@]}"; do
  port="${services[$path]}"
  
  if grep -q "location $path" "$NGINX_CONF"; then
    echo "✅ Le bloc $path existe déjà. Skipping."
  else
    echo "➕ Ajout du bloc $path → localhost:$port"
    sudo sed -i "/^}/i \ \ \ \ location $path {\n        proxy_pass http://localhost:$port/;\n        proxy_set_header Host \$host;\n        proxy_set_header X-Real-IP \$remote_addr;\n        proxy_redirect off;\n    }\n" "$NGINX_CONF"
  fi
done

echo "🔍 Vérification de la config..."
sudo nginx -t

if [ $? -eq 0 ]; then
  echo "✅ Reload de NGINX..."
  sudo systemctl reload nginx
  echo "🎉 Configuration mise à jour avec succès !"
else
  echo "❌ Erreur dans la config ! Restauration de la sauvegarde..."
  sudo cp "$BACKUP_CONF" "$NGINX_CONF"
  sudo nginx -t
fi

