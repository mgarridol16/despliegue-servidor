# 🚀 Proyecto de Despliegue y Monitorización - 2º DAW

## 🛡️ Infraestructura y Seguridad
- **Proxy Inverso**: Configurado con **Nginx** para centralizar el tráfico de Grafana y Portainer.
- **HTTPS Real (Requisito 4)**: Implementado mediante el desafío **DNS-01** de Let's Encrypt. Se ha utilizado un contenedor de Certbot con hooks para automatizar la validación mediante la API de DuckDNS.
- **Redirección (Requisito 3)**: Todo el tráfico del puerto 80 se redirige automáticamente al 443 para garantizar conexiones seguras.

## 📊 Monitorización (Requisito 5)
- **Stack**: Prometheus + Grafana.
- **Métricas**: Node Exporter monitoriza el estado de la VM (CPU, RAM, Disco) en tiempo real.

## 👤 Gestión de Usuarios (Requisito 2 y 7)
- **Script de automatización**: Se ha creado `crear_usuario_deploy.sh` para dar de alta a usuarios con permisos específicos de Docker.
- **Flujo de despliegue**: Los usuarios suben sus apps a `~/apps/` y levantan los servicios mediante Docker Compose.

## 🛠️ Instrucciones de Despliegue (Runbook)
1. **Acceso**: Conectar vía SSH con el usuario de despliegue.
2. **Arranque**: Situarse en la carpeta del proyecto y ejecutar `docker compose up -d`.
3. **Validación**: Comprobar logs con `docker logs <servicio>` y acceder vía `https://miguel-daw-practica.duckdns.org`.
