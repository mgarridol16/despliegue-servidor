#!/bin/bash
set -e

echo "📝 PASO 1: Identificación"
read -p "¿Cuál es tu nombre o alias? (ej: miguel): " USERNAME
if [ -z "$USERNAME" ]; then echo "❌ Error"; exit 1; fi
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

echo "🔧 PASO 2: Personalizando prometheus.yml"
# Editamos Prometheus para que reconozca tu usuario
sed -i "s/cluster: 'lab-[a-zA-Z0-9-]*'/cluster: 'lab-${USERNAME}'/g" programasDelSistema/prometheus/prometheus.yml
sed -i "s/environment: 'production-[a-zA-Z0-9-]*'/environment: 'production-${USERNAME}'/g" programasDelSistema/prometheus/prometheus.yml

echo "🌐 PASO 3: Creando redes Docker"
docker network create net_proxy --driver bridge 2>/dev/null || true
docker network create net_monitor --driver bridge 2>/dev/null || true

echo "✅ SETUP COMPLETADO"
echo "Infraestructura lista para desplegar en 'programasDelSistema'"
