#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SETUP INICIAL - Personalización de Proyecto para Despliegue (v2.0)
# ═══════════════════════════════════════════════════════════════════════════════
set -e

echo "📝 PASO 1: Información Personal"
read -p "¿Cuál es tu nombre o alias? (ej: miguel): " USERNAME
if [ -z "$USERNAME" ]; then echo "❌ Error"; exit 1; fi
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

MAIN_DOMAIN="servidorgp.somosdelprieto.com"

echo "🔧 PASO 2: Generando .env"
cat > .env << EOF
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
if command -v docker &> /dev/null; then
    docker network create net_proxy --driver bridge || true
    docker network create net_monitor --driver bridge || true
fi

echo "✅ SETUP COMPLETADO EXITOSAMENTE"
echo "Ejecuta: docker compose up -d"
