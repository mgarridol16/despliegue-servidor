#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP INICIAL - Personalización de Proyecto para Despliegue
# ═══════════════════════════════════════════════════════════════════════════════
#
# Este script configura el proyecto para el usuario/institución específica.
# EJECUTAR UNA SOLA VEZ al clonar el repositorio.
#
# USO:
#   bash setup.sh
#

set -e  # Exit on error

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║           🚀 SETUP INICIAL - Personalización del Proyecto               ║"
echo "║                                                                           ║"
echo "║ Este script configura tu entorno de despliegue.                         ║"
echo "║ Se ejecuta UNA SOLA VEZ al clonar el repositorio.                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1: OBTENER DATOS DEL USUARIO
# ─────────────────────────────────────────────────────────────────────────────

echo "📝 PASO 1: Información Personal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "¿Cuál es tu nombre o alias? (ej: miguel, juanma, maria): " USERNAME

# Validar que no esté vacío
if [ -z "$USERNAME" ]; then
    echo "❌ Error: El nombre no puede estar vacío"
    exit 1
fi

# Convertir a minúsculas y reemplazar espacios por guiones
USERNAME=$(echo "$USERNAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

echo "✅ Nombre: $USERNAME"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2: DOMINIO
# ─────────────────────────────────────────────────────────────────────────────

echo "📝 PASO 2: Dominio Principal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "El dominio determina dónde será accesible tu plataforma."
echo ""
echo "OPCIONES PREDEFINIDAS:"
echo "  1) Servidor escuela (<tu-nombre>.servidorgp.somosdelprieto.com)"
echo "  2) Localhost para desarrollo local"
echo "  3) IP directa del servidor"
echo "  4) Dominio personalizado (ingresa el tuyo)"
echo ""

read -p "Elige opción (1-4): " DOMAIN_CHOICE

case $DOMAIN_CHOICE in
  1)
    MAIN_DOMAIN="${USERNAME}.servidorgp.somosdelprieto.com"
    echo "✅ Dominio: $MAIN_DOMAIN"
    ;;
  2)
    MAIN_DOMAIN="localhost"
    echo "✅ Dominio: $MAIN_DOMAIN (DESARROLLO LOCAL)"
    ;;
  3)
    read -p "Introduce la IP del servidor (ej: 192.168.1.100): " IP_ADDR
    if [ -z "$IP_ADDR" ]; then
      echo "❌ IP vacía"
      exit 1
    fi
    MAIN_DOMAIN="$IP_ADDR"
    echo "✅ Dominio (IP): $MAIN_DOMAIN"
    ;;
  4)
    read -p "Introduce tu dominio personalizado (ej: mi-app.com): " CUSTOM_DOMAIN
    if [ -z "$CUSTOM_DOMAIN" ]; then
      echo "❌ Dominio vacío"
      exit 1
    fi
    MAIN_DOMAIN="$CUSTOM_DOMAIN"
    echo "✅ Dominio personalizado: $MAIN_DOMAIN"
    ;;
  *)
    echo "❌ Opción inválida"
    exit 1
    ;;
esac

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3: EMAIL PARA LET'S ENCRYPT
# ─────────────────────────────────────────────────────────────────────────────

echo "📝 PASO 3: Email para Let's Encrypt (renovación de certificados)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Let's Encrypt te notificará cuando los certificados estén próximos a vencer."
echo ""

read -p "Email (ej: tu-email@institucion.es): " ACME_EMAIL

if [ -z "$ACME_EMAIL" ]; then
    ACME_EMAIL="admin@example.com"
    echo "⚠️  Email no especificado. Usando default: $ACME_EMAIL"
fi

echo "✅ Email: $ACME_EMAIL"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4: CREAR .env
# ─────────────────────────────────────────────────────────────────────────────

echo "🔧 PASO 4: Generando .env"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f ".env" ]; then
    echo "⚠️  .env ya existe. Haciendo backup..."
    mv .env .env.bak.$(date +%s)
fi

cat > .env << EOF
# ═══════════════════════════════════════════════════════════════════════════════
# VARIABLES DE ENTORNO - Setup Personalizado
# ═══════════════════════════════════════════════════════════════════════════════
# Generado automáticamente por setup.sh (NO editar manualmente)
# Fecha: $(date)
#

# Usuario/Proyecto
USERNAME=${USERNAME}

# Dominio Principal
MAIN_DOMAIN=${MAIN_DOMAIN}

# Email Let's Encrypt
ACME_EMAIL=${ACME_EMAIL}

# Let's Encrypt ACME Server
# - Production: https://acme-v02.api.letsencrypt.org/directory (REAL)
# - Staging: https://acme-staging-v02.api.letsencrypt.org/directory (PRUEBAS)
ACME_CA_URI=https://acme-v02.api.letsencrypt.org/directory

# Contraseña admin Grafana
GRAFANA_ADMIN_PASSWORD=admin

# Versiones de imágenes
PROXY_VERSION=1.6
ACME_COMPANION_VERSION=latest
PORTAINER_VERSION=latest
PROMETHEUS_VERSION=latest
GRAFANA_VERSION=latest
NODE_EXPORTER_VERSION=latest
EOF

echo "✅ Archivo .env creado existe"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5: ACTUALIZAR prometheus.yml
# ─────────────────────────────────────────────────────────────────────────────

echo "🔧 PASO 5: Personalizando prometheus.yml"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Crear backup
cp prometheus/prometheus.yml prometheus/prometheus.yml.bak.setup

# Reemplazar referencias a "miguel" o "lab-miguel" por el usuario
sed -i "s/cluster: 'lab-miguel'/cluster: 'lab-${USERNAME}'/g" prometheus/prometheus.yml
sed -i "s/environment: 'production'/environment: 'production-${USERNAME}'/g" prometheus/prometheus.yml

echo "✅ prometheus.yml actualizado"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6: ACTUALIZAR .env.example (para referencia)
# ─────────────────────────────────────────────────────────────────────────────

echo "🔧 PASO 6: Documentación de plantilla actualizada"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Crear backup y actualizar ejemplo para futuras referencias
cp .env.example .env.example.orig.setup

sed -i "s/MAIN_DOMAIN=.*/MAIN_DOMAIN=${MAIN_DOMAIN}/g" .env.example
sed -i "s/ACME_EMAIL=.*/ACME_EMAIL=${ACME_EMAIL}/g" .env.example

echo "✅ .env.example actualizado con tus detalles"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 7: CREAR ARCHIVO DE MARCACIÓN
# ─────────────────────────────────────────────────────────────────────────────

touch .setup-completed
cat > .setup-info << EOF
# Setup Completado
USUARIO: ${USERNAME}
DOMINIO: ${MAIN_DOMAIN}
EMAIL: ${ACME_EMAIL}
FECHA: $(date)
EOF

# ─────────────────────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                      ✅ SETUP COMPLETADO EXITOSAMENTE                   ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 RESUMEN DE CONFIGURACIÓN:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  👤 Usuario/Proyecto:     ${USERNAME}"
echo "  🌐 Dominio Principal:    ${MAIN_DOMAIN}"
echo "  📧 Email Let's Encrypt:  ${ACME_EMAIL}"
echo "  📁 Archivo .env:         $(pwd)/.env"
echo ""
echo "📖 PRÓXIMOS PASOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  DESARROLLO LOCAL:"
echo "    docker network create net_proxy --driver bridge"
echo "    docker network create net_monitor --driver bridge"
echo "    docker compose up -d"
echo ""
echo "2️⃣  DESPLIEGUE EN SERVIDOR:"
echo "    git clone <tu-repo> /home/deploy-user/apps/proyecto"
echo "    cd /home/deploy-user/apps/proyecto"
echo "    bash setup.sh"
echo "    docker compose up -d"
echo ""
echo "3️⃣  VERIFICAR INSTALACIÓN:"
echo "    docker compose ps"
echo "    curl https://${MAIN_DOMAIN}"
echo ""
echo "📚 DOCUMENTACIÓN:"
echo "    - ARQUITECTURA.md      - Explicación técnica completa"
echo "    - README.md            - Manual de operación"
echo "    - MEMORIA.md           - Detalles de implementación"
echo "    - CHANGELOG.md         - Cambios v1.0 → v2.0"
echo ""
echo "⚠️  IMPORTANTE:"
echo "    - El archivo .env contiene credenciales → NO hacer commit"
echo "    - Ya está en .gitignore, pero verifica"
echo "    - Si cambias MAIN_DOMAIN, edita solo .env (no YAML)"
echo ""
