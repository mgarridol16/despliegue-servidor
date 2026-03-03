#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT DE AUTOMATIZACIÓN: Creación de usuario de despliegue (v2.0)
# ═══════════════════════════════════════════════════════════════════════════════
# Funcionalidad:
#   1. Crea usuario del sistema
#   2. Añade al grupo docker (sin sudoers)
#   3. Genera directorio ~/apps/ para aplicaciones
#   4. Asegura que las redes Docker existen
#
# Uso: sudo ./crear_usuario_deploy.sh nombre-usuario
#

# ─────────────────────────────────────────────────────────────────────────────
# VALIDACIÓN
# ─────────────────────────────────────────────────────────────────────────────

if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Este script REQUIERE permisos de sudo."
    echo "Uso: sudo $0 <nombre-usuario>"
    exit 1
fi

if [ -z "$1" ]; then
    echo "❌ Error: Debes indicar un nombre de usuario."
    echo "Uso: sudo $0 <nombre-usuario>"
    exit 1
fi

USUARIO=$1

# ─────────────────────────────────────────────────────────────────────────────
# PASO 1: CREAR USUARIO DEL SISTEMA
# ─────────────────────────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Creando usuario: $USUARIO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if id "$USUARIO" &>/dev/null; then
    echo "⚠️  El usuario $USUARIO ya existe. Continuando con configuración..."
else
    echo "➕ Creando usuario: $USUARIO"
    useradd -m -s /bin/bash "$USUARIO"
    if [ $? -eq 0 ]; then
        echo "✅ Usuario creado correctamente"
    else
        echo "❌ Error al crear usuario"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 2: AÑADIR AL GRUPO DOCKER (Permite docker compose sin sudo)
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "🐳 Configurando acceso a Docker..."
usermod -aG docker "$USUARIO"
echo "✅ Usuario añadido al grupo docker"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 3: CREAR DIRECTORIO ~/apps/
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "📁 Creando estructura de directorios..."
mkdir -p /home/"$USUARIO"/apps
chown -R "$USUARIO":"$USUARIO" /home/"$USUARIO"/apps
echo "✅ Directorio /home/$USUARIO/apps/ creado y configurado"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 4: ASEGURAR QUE EXISTEN LAS REDES DOCKER NECESARIAS
# ─────────────────────────────────────────────────────────────────────────────
# Las apps van a usar estas redes cuando hacen "docker compose up"
# Deben existir previamente como redes externas

echo ""
echo "🌐 Verificando redes Docker..."

REDES=("net_proxy" "net_monitor")

for RED in "${REDES[@]}"; do
    if docker network ls --filter "name=^${RED}$" --format "{{.Name}}" | grep -q "^${RED}$"; then
        echo "✅ Red '$RED' ya existe"
    else
        echo "➕ Creando red: $RED"
        docker network create "$RED" --driver bridge
        echo "✅ Red '$RED' creada"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# PASO 5: CONFIGURAR CONTRASEÑA
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "🔐 Configurando contraseña para SSH/SCP..."
echo "Introduce una contraseña para el usuario $USUARIO:"
passwd "$USUARIO"

# ─────────────────────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 RESUMEN:"
echo "  • Usuario: $USUARIO"
echo "  • Grupo: docker (sin sudoers, apps con docker compose)"
echo "  • Carpeta: /home/$USUARIO/apps/"
echo "  • Redes: net_proxy, net_monitor"
echo ""
echo "📖 PRÓXIMOS PASOS:"
echo "  1. Conectar por SSH: ssh $USUARIO@<ip-servidor>"
echo "  2. Subir app: scp -r mi-app $USUARIO@<ip>:~/apps/"
echo "  3. Desplegar: cd ~/apps/mi-app && docker compose up -d"
echo ""
echo "⚠️  IMPORTANTE: El docker-compose.yml debe usar redes externas:"
echo "  networks:"
echo "    - net_proxy    # Para apps visibles desde nginx-proxy"
echo "    - net_monitor  # OPCIONAL: si necesita acceso a Prometheus"
echo ""
