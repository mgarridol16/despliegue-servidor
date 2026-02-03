#!/bin/bash

# Comprobar si se ha pasado el nombre de usuario por argumento
if [ -z "$1" ]; then
    echo "Error: Debes indicar un nombre de usuario."
    echo "Uso: $0 <nombre_usuario>"
    exit 1
fi

USUARIO=$1

echo "🚀 Iniciando proceso para el usuario: $USUARIO"

sudo useradd -m -s /bin/bash "$USUARIO"

sudo usermod -aG docker "$USUARIO"

sudo mkdir -p /home/"$USUARIO"/apps
sudo chown -R "$USUARIO":"$USUARIO" /home/"$USUARIO"/apps

# 4. Establecer contraseña
echo "Introduce la contraseña para el nuevo usuario:"
sudo passwd "$USUARIO"

echo "Usuario $USUARIO configurado. Carpeta lista en /home/$USUARIO/apps"
