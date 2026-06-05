#!/bin/bash
set -e

echo "📝 PASO 1: Información Personal"
read -p "¿Cuál es tu nombre o alias? (ej: miguel): " USERNAME
if [ -z "$USERNAME" ]; then echo "❌ Error"; exit 1; fi
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

MAIN_DOMAIN="servidorgp.somosdelprieto.com"

echo "🔧 PASO 2: Generando .env en programasDelSistema/"
# Lo creamos directamente en la carpeta donde está el docker-compose.yml
cat > programasDelSistema/.env << EOF
USERNAME=${USERNAME}
MAIN_DOMAIN=${MAIN_DOMAIN}
GRAFANA_ADMIN_PASSWORD=admin
PROXY_VERSION=latest
PORTAINER_VERSION=latest
PROMETHEUS_VERSION=latest
GRAFANA_VERSION=latest
EOF

echo "🔧 PASO 3: Personalizando prometheus.yml"
sed -i "s/cluster: 'lab-[a-zA-Z0-9-]*'/cluster: 'lab-${USERNAME}'/g" programasDelSistema/prometheus/prometheus.yml
sed -i "s/environment: 'production-[a-zA-Z0-9-]*'/environment: 'production-${USERNAME}'/g" programasDelSistema/prometheus/prometheus.yml

echo "🌐 PASO 4: Creando redes Docker"
docker network create net_proxy --driver bridge 2>/dev/null || true
docker network create net_monitor --driver bridge 2>/dev/null || true

echo "✅ SETUP COMPLETADO"
echo "Ahora solo tienes que entrar a programasDelSistema y ejecutar: docker compose up -d"
