#!/bin/bash

# Comprobar si se ha pasado el nombre de usuario por argumento
if [ -z "$1" ]; then
    echo "❌ Error: Debes indicar un nombre de usuario."
    echo "Uso: $0 <nombre_usuario>"
    exit 1
fi

USUARIO=$1

echo "🚀 Iniciando proceso para el usuario: $USUARIO"

# 1. Crear el usuario con su carpeta home y shell bash
sudo useradd -m -s /bin/bash "$USUARIO"

# 2. Añadir al grupo docker (VITAL: sin esto no podrá hacer docker compose up)
sudo usermod -aG docker "$USUARIO"

# 3. Crear la estructura de directorios exigida en el Requisito 2
sudo mkdir -p /home/"$USUARIO"/apps
sudo chown -R "$USUARIO":"$USUARIO" /home/"$USUARIO"/apps

# 4. Establecer contraseña
echo "🔒 Introduce la contraseña para el nuevo usuario:"
sudo passwd "$USUARIO"

echo "✅ Usuario $USUARIO configurado. Carpeta lista en /home/$USUARIO/apps"
