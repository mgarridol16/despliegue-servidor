#!/bin/bash
# =========================================================
# Deploy User Setup (Hybrid Version - Clean & Secure)
# =========================================================

set -e

USERNAME="$1"

if [ -z "$USERNAME" ]; then
  echo "Uso: sudo bash create-deploy-user.sh <nombre_usuario>"
  exit 1
fi

echo "📦 Creando usuario: $USERNAME"

# 1. Crear usuario si no existe
if id "$USERNAME" &>/dev/null; then
  echo "⚠️ El usuario ya existe"
else
  useradd -m -s /bin/bash "$USERNAME"
  echo "✅ Usuario creado"
fi

# 2. Contraseña manual (seguro)
passwd "$USERNAME"

# 3. Carpeta apps
mkdir -p "/home/$USERNAME/apps"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/apps"
chmod 750 "/home/$USERNAME/apps"

# 4. SSH seguro
mkdir -p "/home/$USERNAME/.ssh"
touch "/home/$USERNAME/.ssh/authorized_keys"
chmod 700 "/home/$USERNAME/.ssh"
chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"

# 5. Acceso Docker
usermod -aG docker "$USERNAME"

echo "🐳 Usuario añadido a Docker"

# 6. Redes Docker (si no existen)
for net in net_proxy net_monitor; do
  if docker network ls | grep -q "$net"; then
    echo "✅ Red $net ya existe"
  else
    docker network create "$net" --driver bridge
    echo "✅ Red $net creada"
  fi
done

echo ""
echo "🎉 Usuario configurado correctamente"
echo "📁 Home: /home/$USERNAME"
echo "📁 Apps: /home/$USERNAME/apps"
echo "🔐 SSH: añade clave en authorized_keys"
echo "🐳 Docker listo"
