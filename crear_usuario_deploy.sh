#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT DE AUTOMATIZACIÓN: Creación de usuario de despliegue (v2.1)
# ═══════════════════════════════════════════════════════════════════════════════
set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

if [ "$EUID" -ne 0 ]; then echo -e "${RED}❌ Error: Requiere sudo.${NC}"; exit 1; fi
if [ -z "$1" ]; then echo -e "${RED}❌ Error: Falta usuario.${NC}"; exit 1; fi

USUARIO=$1; DEFAULT_PASSWORD="1234"

echo -e "\n${CYAN}📋 Paso 1: Crear usuario del sistema${NC}"
if id "$USUARIO" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Usuario existe.${NC}"
else
    useradd -m -s /bin/bash "$USUARIO" && echo -e "${GREEN}✅ Usuario creado${NC}"
fi

echo -e "\n${CYAN}🔐 Paso 2: Establecer contraseña${NC}"
echo "$USUARIO:$DEFAULT_PASSWORD" | chpasswd && echo -e "${GREEN}✅ Contraseña lista${NC}"

echo -e "\n${CYAN}🐳 Paso 3: Acceso a Docker${NC}"
usermod -aG docker "$USUARIO" && echo -e "${GREEN}✅ Añadido a docker${NC}"

echo -e "\n${CYAN}📁 Paso 4: Directorio apps${NC}"
mkdir -p /home/"$USUARIO"/apps
chown -R "$USUARIO":"$USUARIO" /home/"$USUARIO"/apps
chmod 755 /home/"$USUARIO"/apps && echo -e "${GREEN}✅ Directorio creado${NC}"

echo -e "\n${CYAN}🌐 Paso 5: Redes Docker${NC}"
REDES=("net_proxy" "net_monitor")
for RED in "${REDES[@]}"; do
    if docker network ls | grep -q "^${RED}$"; then echo -e "${GREEN}✅ Red '$RED' existe${NC}"
    else docker network create "$RED" --driver bridge && echo -e "${GREEN}✅ Red '$RED' creada${NC}"; fi
done

echo -e "\n${GREEN}✅ CONFIGURACIÓN COMPLETADA${NC}"
echo -e "🔗 ${YELLOW}EJEMPLO docker-compose.yml (SIN SSL):${NC}"
cat << 'EXAMPLE'
  services:
    web:
      image: nginx:latest
      environment:
        - VIRTUAL_HOST=tuusuario-miapp.servidorgp.somosdelprieto.com
        - VIRTUAL_PORT=80
      networks:
        - net_proxy

  networks:
    net_proxy:
      external: true
EXAMPLE
echo ""
