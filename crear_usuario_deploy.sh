#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT DE AUTOMATIZACIÓN: Creación de usuario de despliegue (v2.1)
# ═══════════════════════════════════════════════════════════════════════════════
# Funcionalidad:
#   1. Crea usuario del sistema
#   2. Añade al grupo docker (sin sudoers)
#   3. Genera directorio ~/apps/ para aplicaciones
#   4. Asegura que las redes Docker existen
#   5. Configura contraseña
#
# Uso: sudo ./crear_usuario_deploy.sh nombre-usuario
#

set -e

# Colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# VALIDACIÓN
# ─────────────────────────────────────────────────────────────────────────────

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Error: Este script REQUIERE permisos de sudo.${NC}"
    echo "Uso: sudo $0 <nombre-usuario>"
    exit 1
fi

if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Debes indicar un nombre de usuario.${NC}"
    echo "Uso: sudo $0 <nombre-usuario>"
    exit 1
fi

USUARIO=$1
DEFAULT_PASSWORD="1234"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 1: CREAR USUARIO DEL SISTEMA
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 Paso 1: Crear usuario del sistema${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if id "$USUARIO" &>/dev/null; then
    echo -e "${YELLOW}⚠️  El usuario $USUARIO ya existe. Continuando...${NC}"
else
    echo -e "${CYAN}➕ Creando usuario: $USUARIO${NC}"
    useradd -m -s /bin/bash "$USUARIO"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Usuario creado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al crear usuario${NC}"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 2: ESTABLECER CONTRASEÑA
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔐 Paso 2: Establecer contraseña${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Contraseña por defecto: ${DEFAULT_PASSWORD}${NC}"
echo "$USUARIO:$DEFAULT_PASSWORD" | chpasswd
echo -e "${GREEN}✅ Contraseña establecida${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 3: AÑADIR AL GRUPO DOCKER
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🐳 Paso 3: Configurar acceso a Docker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! getent group docker > /dev/null; then
    echo -e "${RED}❌ Error: El grupo 'docker' no existe. ¿Está Docker instalado?${NC}"
    exit 1
fi

usermod -aG docker "$USUARIO"
echo -e "${GREEN}✅ Usuario añadido al grupo docker (sin sudoers)${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 4: CREAR DIRECTORIO ~/apps/
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📁 Paso 4: Crear estructura de directorios${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mkdir -p /home/"$USUARIO"/apps
chown -R "$USUARIO":"$USUARIO" /home/"$USUARIO"/apps
chmod 755 /home/"$USUARIO"/apps
echo -e "${GREEN}✅ Directorio /home/$USUARIO/apps/ creado y configurado${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 5: ASEGURAR QUE EXISTEN LAS REDES DOCKER
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🌐 Paso 5: Configurar redes Docker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Las apps van a usar estas redes cuando hacen "docker compose up"
# Deben existir previamente como redes externas

REDES=("net_proxy" "net_monitor")

for RED in "${REDES[@]}"; do
    if docker network ls --filter "name=^${RED}$" --format "{{.Name}}" | grep -q "^${RED}$"; then
        echo -e "${GREEN}✅ Red '$RED' ya existe${NC}"
    else
        echo -e "${CYAN}➕ Creando red: $RED${NC}"
        docker network create "$RED" --driver bridge
        echo -e "${GREEN}✅ Red '$RED' creada${NC}"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CONFIGURACIÓN COMPLETADA${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📊 ${YELLOW}RESUMEN:${NC}"
echo -e "  • ${CYAN}Usuario:${NC}      $USUARIO"
echo -e "  • ${CYAN}Contraseña:${NC}  $DEFAULT_PASSWORD"
echo -e "  • ${CYAN}Grupo:${NC}        docker (sin sudoers)"
echo -e "  • ${CYAN}Carpeta:${NC}      /home/$USUARIO/apps/"
echo -e "  • ${CYAN}Redes:${NC}        net_proxy, net_monitor"
echo ""
echo -e "📖 ${YELLOW}PRÓXIMOS PASOS:${NC}"
echo -e "  1️⃣  Conectar por SSH:"
echo -e "     ${CYAN}ssh $USUARIO@<ip-servidor>${NC}"
echo ""
echo -e "  2️⃣  Subir aplicación (desde tu máquina):"
echo -e "     ${CYAN}scp -r mi-app $USUARIO@<ip>:~/apps/${NC}"
echo ""
echo -e "  3️⃣  Desplegar en el servidor:"
echo -e "     ${CYAN}cd ~/apps/mi-app${NC}"
echo -e "     ${CYAN}docker compose up -d${NC}"
echo ""
echo -e "⚠️  ${YELLOW}IMPORTANTE:${NC}"
echo -e "   El docker-compose.yml debe usar redes externas:"
echo -e "   ${CYAN}networks:${NC}"
echo -e "     ${CYAN}- net_proxy${NC}    # Para apps visibles desde nginx"
echo -e "     ${CYAN}- net_monitor${NC}  # OPCIONAL: si necesita Prometheus"
echo ""
echo -e "🔗 ${YELLOW}EJEMPLO docker-compose.yml:${NC}"
cat << 'EXAMPLE'
  services:
    web:
      image: mi-app:latest
      environment:
        - VIRTUAL_HOST=mi-app.tu-dominio.com
        - VIRTUAL_PORT=80
        - LETSENCRYPT_HOST=mi-app.tu-dominio.com
        - LETSENCRYPT_EMAIL=tu-email@example.com
      networks:
        - net_proxy

  networks:
    net_proxy:
      external: true
EXAMPLE

echo ""
