# 📖 GUÍA DE DESPLIEGUE EN SERVIDOR

****Objetivo****: Desplegar infraestructura de monitorización y despliegue de aplicaciones web en el servidor del centro.

****Nota****: La gestión de certificados SSL es externa; esta infraestructura se despliega en HTTP para ser enrutada por el proxy principal del centro.

## 📋 TABLA DE CONTENIDOS

1.  [Requisitos Previos](https://www.google.com/search?q=%23requisitos-previos)
2.  [Paso 1: Preparación del Entorno](https://www.google.com/search?q=%23paso-1-preparaci%C3%B3n-del-entorno)
3.  [Paso 2: Instalación de Dependencias](https://www.google.com/search?q=%23paso-2-instalaci%C3%B3n-de-dependencias)
4.  [Paso 3: Despliegue de la Infraestructura Base](https://www.google.com/search?q=%23paso-3-despliegue-de-la-infraestructura-base)
5.  [Paso 4: Despliegue de Aplicación Propia](https://www.google.com/search?q=%23paso-4-despliegue-de-aplicaci%C3%B3n-propia)
6.  [Troubleshooting](https://www.google.com/search?q=%23troubleshooting)

## 📋 REQUISITOS PREVIOS

-   ****Sistema****: Ubuntu 22.04 LTS o superior.
-   ****Acceso****: SSH con permisos `sudo`.
-   ****Naming Convention****: Uso obligatorio de guiones en lugar de puntos para dominios (`alumno-app.servidorgp.somosdelprieto.com`).

## PASO 1: PREPARACIÓN DEL ENTORNO

Asegura que el sistema esté actualizado antes de empezar:

Bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git nano

## PASO 2: INSTALACIÓN DE DEPENDENCIAS

### 2.1 Instalar Docker y Docker Compose

Bash

\# Instalación oficial de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

\# Configuración de permisos
sudo usermod -aG docker $USER
newgrp docker

## PASO 3: DESPLIEGUE DE LA INFRAESTRUCTURA BASE

### 3.1 Crear redes de comunicación

Es vital crear las redes externas que permiten al proxy y a la monitorización hablar entre sí:

Bash

docker network create net\_proxy
docker network create net\_monitor

### 3.2 Levantar servicios

En la carpeta del proyecto, ejecuta:

Bash

docker compose up -d

> ****Nota:**** Verifica con `docker ps` que los contenedores (`nginx-proxy`, `prometheus`, `grafana`, etc.) estén en estado `running`.

## PASO 4: DESPLIEGUE DE APLICACIÓN PROPIA

Para desplegar cualquier aplicación web, utiliza la siguiente plantilla maestra. ****No necesitas configurar certificados ni contenedores de SSL.****

### 4.1 Estructura recomendada

Crea una carpeta para cada proyecto:

Bash

mkdir -p ~/apps/mi-proyecto
cd ~/apps/mi-proyecto

### 4.2 Plantilla `docker-compose.yml` (Copiar y pegar)

Adapta el `VIRTUAL_HOST` con el formato `nombreapp-miguel.servidorgp.somosdelprieto.com`.

YAML

services:
  web:
    image: nginx:alpine
    container\_name: mi-proyecto-web
    restart: unless-stopped
    volumes:
      - ./src:/usr/share/nginx/html:ro
    environment:
      # Formato obligatorio: guion en lugar de punto
      - VIRTUAL\_HOST=mi-proyecto-miguel.servidorgp.somosdelprieto.com
      - VIRTUAL\_PORT=80
    networks:
      - net\_proxy

networks:
  net\_proxy:
    external: true

### 4.3 Puesta en marcha

Bash

docker compose up -d

## TROUBLESHOOTING

| Problema          | Solución                                                                |
| ----------------- | ----------------------------------------------------------------------- |
| 502 Bad Gateway   | El contenedor no ha terminado de arrancar o VIRTUAL_PORT es incorrecto. |
| Network not found | Asegúrate de haber ejecutado docker network create net_proxy.           |
| Permission Denied | Ejecuta newgrp docker para aplicar permisos de usuario.                 |
| Grafana vacío     | Asegúrate de que el Data Source apunte a http://prometheus:9090.        |
