# 📖 FASE 4: GUÍA COMPLETA DE DESPLIEGUE EN SERVIDOR

**Objetivo**: Desplegar infraestructura en servidor Ubuntu real (escuela o VPS)
**Tiempo estimado**: 30 minutos
**Requisitos**: SSH acceso, dominio configurado, Docker instalado

---

## 📋 TABLA DE CONTENIDOS

1. [Requisitos Previos](#requisitos-previos)
2. [Paso 1: Preparación del Servidor](#paso-1-preparación-del-servidor)
3. [Paso 2: Instalación de Dependencias](#paso-2-instalación-de-dependencias)
4. [Paso 3: Descarga del Proyecto](#paso-3-descarga-del-proyecto)
5. [Paso 4: Ejecución de setup.sh](#paso-4-ejecución-de-setupsh)
6. [Paso 5: Despliegue Infraestructura](#paso-5-despliegue-infraestructura)
7. [Paso 6: Configuración DNS](#paso-6-configuración-dns)
8. [Paso 7: Verificación HTTPS](#paso-7-verificación-https)
9. [Paso 8: Despliegue App Propia](#paso-8-despliegue-app-propia)
10. [Troubleshooting](#troubleshooting)

---

## 📋 REQUISITOS PREVIOS

### Hardware Mínimo

- **CPU**: 2+ cores
- **RAM**: 4 GB (8+ recomendado)
- **Almacenamiento**: 20 GB (SSD preferible)
- **Conectividad**: Acceso SSH + puertos 80/443 abiertos

### Software Requerido

- **OS**: Ubuntu 20.04 LTS o superior
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Git** (para clonar repositorio)

### Acceso Necesario

- ✅ Servidor accesible por SSH
- ✅ Usuario con permisos sudoers (o root)
- ✅ Dominio apuntando a IP del servidor
  - Ejemplo: `mi-nombre.www.servidorgp.somosdelprieto.com` → IP servidor
  - O cualquier otro dominio personalizado

---

## PASO 1: PREPARACIÓN DEL SERVIDOR

### 1.1 Conectarse al servidor

```bash
# Desde tu máquina local
ssh usuario@192.168.X.X
# O con dominio:
ssh usuario@servidor.dominio.com

# Si es la primera conexión, aceptar fingerprint
# → yes

# Debería aparecer prompt del servidor
usuario@servidor:~$
```

### 1.2 Elevar a root o usar sudo

```bash
# Opción A: Si tienes sudoers
sudo su -
# Prompt → root@servidor:~#

# Opción B: Si eres root directamente
su -
```

### 1.3 Actualizar sistema

```bash
apt update
apt upgrade -y

# Opcional: Instalar utilidades
apt install -y curl wget git nano
```

---

## PASO 2: INSTALACIÓN DE DEPENDENCIAS

### 2.1 Instalar Docker

```bash
# Descargar script oficial
curl -fsSL https://get.docker.com -o get-docker.sh

# Ejecutar instalador
bash get-docker.sh

# Verificar instalación
docker --version
# Esperado: Docker version 20.10.X o superior

# Permitir sin sudo (opcional pero recomendado)
usermod -aG docker $USER
newgrp docker
```

### 2.2 Instalar Docker Compose v2

```bash
# Instalación via apt
apt install -y docker-compose-plugin

# Verificar
docker compose version
# Esperado: Docker Compose version 2.X.X

# De no funcionar, instalar manualmente:
sudo curl -L "https://github.com/docker/compose/releases/download/v2.XX.X/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

###2.3 Instalar Git

```bash
apt install -y git

git --version
# Esperado: git version 2.X.X
```

---

## PASO 3: DESCARGA DEL PROYECTO

### 3.1 Crear carpeta de aplicaciones

```bash
# Crear estructura estándar
mkdir -p /home/deploy-user/apps
cd /home/deploy-user/apps

# Si no existe el usuario deploy-user, crearlo:
# useradd -m -s /bin/bash deploy-user
# usermod -aG docker deploy-user
```

### 3.2 Clonar repositorio

```bash
# OPCIÓN A: Si tienes acceso a repositorio privado
git clone https://github.com/TU-USUARIO/despliegue-servidor.git proyecto
cd proyecto

# OPCIÓN B: Si es repositorio público
git clone https://github.com/alguien/despliegue-servidor.git proyecto
cd proyecto

# OPCIÓN C: Si tienes archivo ZIP
# → Subir archivo por SCP o SFTP
unzip despliegue-servidor.zip
cd despliegue-servidor
```

### 3.3 Verificar estructura

```bash
# Debería ver:
ls -la
# docker-compose.yml
# setup.sh
# .env.example
# prometheus/
# nginx/
# etc.

pwd
# /home/deploy-user/apps/proyecto
```

---

## PASO 4: EJECUCIÓN DE setup.sh

### 4.1 Ejecutar script personalización

```bash
# Asegurar permisos de ejecución
chmod +x setup.sh

# Ejecutar
bash setup.sh
```

### 4.2 Responder preguntas interactivas

```
╔═══════════════════════════════════════════════════════════════════════════╗
║           🚀 SETUP INICIAL - Personalización del Proyecto               ║
╚═══════════════════════════════════════════════════════════════════════════╝

📝 PASO 1: Información Personal
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿Cuál es tu nombre o alias? (ej: miguel, juanma, maria):
→ ESCRIBE TU NOMBRE (sin espacios)
→ Presiona ENTER
```

```
📝 PASO 2: Dominio Principal
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OPCIONES PREDEFINIDAS:
  1) Servidor escuela (www.servidorgp.somosdelprieto.com)
  2) Localhost para desarrollo local
  3) IP directa del servidor
  4) Dominio personalizado (ingresa el tuyo)

Elige opción (1-4):
→ Si estás en servidor escuela: ESCRIBE 1
→ Si es local: ESCRIBE 2
→ Si es IP privada: ESCRIBE 3
→ Si es otro dominio: ESCRIBE 4
→ Presiona ENTER
```

**Si elegiste opción 1 (servidor escuela):**
```
¿Cuál es tu nombre o alias?
→ juanma

Elige opción (1-4):
→ 1

✅ Dominio: juanma.www.servidorgp.somosdelprieto.com
```

```
📝 PASO 3: Email para Let's Encrypt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Email (ej: tu-email@institucion.es):
→ ESCRIBE TU EMAIL
→ Presiona ENTER
```

### 4.3 Verificar resultado

```bash
# setup.sh debería haber creado:
ls -la

# Buscar archivo .env
cat .env | head -20
# Debería ver MAIN_DOMAIN, ACME_EMAIL, etc.

# Buscar .setup-completed
test -f .setup-completed && echo "✅ Setup completado" || echo "❌ Setup fallido"
```

---

## PASO 5: DESPLIEGUE INFRAESTRUCTURA

### 5.1 Crear redes Docker

```bash
# Crear red de proxy (aplicaciones)
docker network create net_proxy --driver bridge

# Crear red de monitorización (privada)
docker network create net_monitor --driver bridge

# Verificar redes
docker network ls | grep net_
# Debería ver: net_proxy, net_monitor
```

### 5.2 Levantar servicios

```bash
# Desde la carpeta del proyecto
cd /home/deploy-user/apps/proyecto

# Levantar contenedores
docker compose up -d

# Ver progreso
docker compose logs -f
# Presionar CTRL+C para salir
```

### 5.3 Esperar a que arranquen

```bash
# Verificar estado
docker compose ps

# Esperado:
# NAME                     STATUS              PORTS
# nginx-proxy         Up X seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
# acme-companion      Up X seconds
# prometheus          Up X seconds
# node-exporter-telemetry  Up X seconds
# grafana-ui               Up X seconds
# portainer-mgmt           Up X seconds

# Si alguno está "Restarting" o "Exit", ver logs:
docker logs nombre-contenedor
```

### 5.4 Verificar ACME companion (certificados)

```bash
# Ver logs de generación de certificados
docker logs acme-companion-ssl | tail -50

# Buscar mensajes como:
# "Certificate created"
# "TLS certificate [...] created"
# "Reloading nginx proxy..."

# Esto puede tardar 30-60 segundos
```

---

## PASO 6: CONFIGURACIÓN DNS

### 6.1 Configurar DNS (solo servidor escuela)

Si usaste opción 1 (servidor escuela), **YA ESTÁ CONFIGURADO** en DNS de la institución.

Si usaste otro dominio, necesitas apuntar DNS:

```bash
# Obtener IP pública del servidor
curl ifconfig.me
# Ejemplo: 203.0.113.45

# En tu proveedor DNS (Namecheap, GoDaddy, etc):
# Crear registro:
# Tipo: A
# Name: TU-NOMBRE
# Value: 203.0.113.45
# TTL: 3600

# Esperar propagación (5-30 minutos)
nslookup tu-nombre.tu-dominio.com
# Debería devolver tu IP
```

### 6.2 Verificar DNS desde servidor

```bash
# Comprobar que DNS resuelve
nslookup juanma.www.servidorgp.somosdelprieto.com

# Debería devolver IP del servidor
# Address: XX.XX.XX.XX
```

---

## PASO 7: VERIFICACIÓN HTTPS

### 7.1 Test HTTP → HTTPS redirect

```bash
# Comprobar que redirecciona a HTTPS
curl -i http://juanma.www.servidorgp.somosdelprieto.com

# Esperado:
# HTTP/1.1 301 Moved Permanently
# Location: https://juanma.www.servidorgp.somosdelprieto.com
```

### 7.2 Test HTTPS con certificado

```bash
# Comprobar certificado es válido
curl -v https://juanma.www.servidorgp.somosdelprieto.com 2>&1 | grep -A 5 "certificate"

# Debería mostrar:
# * subject: CN=juanma.www.servidorgp.somosdelprieto.com
# * issuer: O=Let's Encrypt; CN=Let's Encrypt Authority X3
# * valid from: YYYY-MM-DD to YYYY-MM-DD
```

### 7.3 Test desde navegador

Abre en navegador:
```
https://juanma.www.servidorgp.somosdelprieto.com
```

**Debería ver:**
- ✅ Candado verde (HTTPS válido)
- ✅ Ningún warning de certificado
- ✅ Página "Welcome nginx-proxy" o similar

### 7.4 Acceder a servicios principales

```
Grafana:    https://juanma.www.servidorgp.somosdelprieto.com/
            → Usuario: admin
            → Password: (ver en .env GRAFANA_ADMIN_PASSWORD)

Portainer:  https://juanma.www.servidorgp.somosdelprieto.com:9000
            → (config en primera visita)

Prometheus: https://juanma.www.servidorgp.somosdelprieto.com:9090
            → Sin autenticación
```

---

## PASO 8: DESPLIEGUE APP PROPIA

### 8.1 Preparar app en servidor

```bash
# Opción A: Crear desde cero
mkdir -p /home/deploy-user/apps/mi-app
cd /home/deploy-user/apps/mi-app

# Opción B: Copiar desde apps-ejemplo
cp -r /home/deploy-user/apps/proyecto/apps-ejemplo/* \
    /home/deploy-user/apps/mi-app/
cd /home/deploy-user/apps/mi-app
```

### 8.2 Configurar docker-compose.yml

```yaml
# mi-app/docker-compose.yml

version: '3.8'

services:
  web:
    image: mi-imagen:latest  # Tu imagen Docker
    environment:
      - VIRTUAL_HOST=mi-app.juanma.www.servidorgp.somosdelprieto.com
      - VIRTUAL_PORT=80
      - LETSENCRYPT_HOST=mi-app.juanma.www.servidorgp.somosdelprieto.com
    networks:
      - net_proxy

networks:
  net_proxy:
    external: true
```

### 8.3 Desplegar

```bash
cd /home/deploy-user/apps/mi-app

docker compose up -d

# Ver logs
docker logs -f nombre-contenedor

# Esperar certificado (30-60 seg)
# Acceder: https://mi-app.juanma.www.servidorgp.somosdelprieto.com
```

---

## TROUBLESHOOTING

### Problema: "Network net_proxy not found"

```bash
# Solución: Crear redes manualmente
docker network create net_proxy --driver bridge
docker network create net_monitor --driver bridge

# Reintentar:
docker compose up -d
```

### Problema: "docker: permission denied"

```bash
# Solución: Añadir usuario a grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Reintentar
docker ps
```

### Problema: "HTTPS devuelve ERR_CERT_NOT_YET_VALID"

```bash
# Significa: Let's Encrypt aún está generando certificado (normal primeras 60 seg)

# Solución 1: Esperar
sleep 120
curl -k https://tu-dominio.com

# Solución 2: Ver logs
docker logs acme-companion-ssl | tail -30

# Solución 3: Si sigue fallando, reiniciar acme-companion
docker restart acme-companion-ssl
```

### Problema: "curl: (7) Failed to connect to ... Connection refused"

```bash
# Significa: nginx-proxy no está respondiendo

# Solución 1: Verificar que está corriendo
docker ps | grep nginx-proxy-core

# Solución 2: Ver logs
docker logs nginx-proxy-core

# Solución 3: Reiniciar
docker restart nginx-proxy-core
```

### Problema: "Por qué Grafana no carga métricas"

```bash
# Solución 1: Verificar que prometheus está corriendo
docker logs prometheus-core | tail -20

# Solución 2: Manualmente probar Prometheus
docker exec prometheus-core curl localhost:9090/api/v1/query?query=up

# Solución 3: Verificar datasource en Grafana
# → Grafana → Configuration → Data Sources
# → Prometheus URL: http://prometheus-core:9090
# → Test Connection
```

### Problema: "Certificado no se renueva"

```bash
# Verificar que ACME_CA_URI es correcto
cat .env | grep ACME_CA_URI

# Ver logs de renovación
docker logs acme-companion-ssl | grep "renew"

# Para renovación manual (no recomendado):
docker exec acme-companion-ssl acme.sh --renew -d tu-dominio.com
```

---

## ✅ CHECKLIST FINAL

Después de completar todos los pasos:

```bash
# [ ] Docker instalado y funcionando
docker ps

# [ ] Redes creadas
docker network ls | grep net_

# [ ] Contenedores levantados (6 servicios)
docker compose ps | wc -l
# Debería ser ≥ 6

# [ ] HTTPS funciona
curl -k https://tu-dominio.com | head -5

# [ ] Certificado es válido (Let's Encrypt)
openssl s_client -connect tu-dominio.com:443 -servername tu-dominio.com |\
  grep "CN="

# [ ] Grafana accesible
docker logs grafana-ui | grep "Started"

# [ ] Prometheus scrapeando métricas
curl "http://localhost:9090/api/v1/query?query=up" | grep -o '"value"'

# [ ] .env protegido (no en git)
git status | grep ".env"
# No debería aparecer
```

---

## 📞 SOPORTE Y SIGUIENTES PASOS

### Documentación completa

```bash
cat GUÍA-INICIO-RÁPIDO.md    # Setup rápido
cat ARQUITECTURA.md           # Explicación técnica
cat CHANGELOG.md             # Cambios v1.0 → v2.0
```

### Desplegar más aplicaciones

Cada nueva app:
1. Crear carpeta `~/apps/nombre-app/`
2. Crear docker-compose.yml con VIRTUAL_HOST
3. `docker compose up -d`
4. Let's Encrypt genera certificado automáticamente (30 seg)

### Creación de usuarios separados

```bash
# Crear usuario deploy-user separado (si no existe)
sudo ./crear_usuario_deploy.sh deploy-user
# Luego le das acceso SSH
# El será quien despliegue sus propias apps
```

---

**¡Infraestructura lista para producción!** 🚀

Próximo paso: [FASE 5 - CI/CD (Opcional)](docs/FASE-5-CICD.md)
