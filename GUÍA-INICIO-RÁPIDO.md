# ⚡ GUÍA DE INICIO RÁPIDO

**Tiempo estimado**: 5 minutos para setup local, 15 minutos para servidor real

> **⚠️ IMPORTANTE**: Este proyecto es un **TEMPLATE**. Debes personalizarlo para tu nombre/dominio.
> Sigue esta guía paso a paso.

---

## 🚀 OPCIÓN A: Desarrollo Local (5 min)

### Paso 1: Personalizar proyecto

```bash
# En la carpeta raíz del proyecto
bash setup.sh

# Responde las preguntas interactivamente:
# - ¿Cuál es tu nombre? → tu-nombre
# - ¿Dominio? → Opción 2 (localhost)
# - ¿Email? → tu-email@ejemplo.com
```

**Qué hace `setup.sh`:**
- ✅ Genera `.env` personalizado
- ✅ Actualiza `prometheus.yml` con tu nombre
- ✅ Prepara proyecto para despliegue

### Paso 2: Crear redes Docker

```bash
docker network create net_proxy --driver bridge
docker network create net_monitor --driver bridge
```

### Paso 3: Levantar infraestructura

```bash
docker compose up -d
```

### Paso 4: Verificar funcionamiento

```bash
docker compose ps
# Debería ver 7 contenedores en estado "Up"

docker logs nginx-proxy | tail -20
docker logs prometheus | tail -20
```

### Paso 5: Acceder a los servicios

```
Grafana:    http://localhost:3000/ (usuario: admin, contraseña: admin123)
Portainer:  http://localhost:9000/
Prometheus: http://localhost:9090/
```

---

## 🖥️ OPCIÓN B: Despliegue en Servidor Real (15 min)

### Paso 1: Conectarse al servidor

```bash
# Desde tu máquina local
ssh deploy-user@192.168.X.X
# O
ssh deploy-user@tu-dominio.com
```

### Paso 2: Clonar repositorio

```bash
# En el servidor
cd ~/apps/
git clone <URL-de-tu-repo> proyecto
cd proyecto
```

### Paso 3: Ejecutar setup.sh

```bash
bash setup.sh

# Responde:
# - Nombre: tu-nombre (ej: juanma)
# - Dominio: Opción 1 (servidor escuela)
#   → juanma.www.servidorgp.somosdelprieto.com
# - Email: tu-email@institucion.es
```

### Paso 4: Levantar infraestructura

```bash
docker compose up -d

# Ver logs en tiempo real
docker compose logs -f
```

### Paso 5: Esperar certificados SSL

```bash
# Comprobar logs de acme-companion (30-60 segundos)
docker logs acme-companion | tail -50

# Esperar a ver:
# "Creating SSL certificate for: juanma.www.servidorgp..."
# "Certificate installed for: juanma.www.servidorgp..."
```

### Paso 6: Verificar acceso HTTPS

```bash
# Desde tu máquina local
curl -k https://juanma.www.servidorgp.somosdelprieto.com

# Desde el navegador
https://juanma.www.servidorgp.somosdelprieto.com
```

---

## 📋 PREGUNTAS FRECUENTES

### P: ¿Qué hace `setup.sh`?

R: Personaliza el proyecto para tu usuario/dominio:
- Crea `.env` con tus valores
- Actualiza `prometheus.yml`
- Genera archivos de control (`.setup-completed`)

### P: ¿Puedo editar `.env` después manualmente?

R: **Sí**. Después de ejecutar `setup.sh`, puedes editar `.env`:
- Cambiar `MAIN_DOMAIN`
- Cambiar `ACME_EMAIL`
- Cambiar passwords Grafana

```bash
# Editar
nano .env

# Aplicar cambios
docker compose restart nginx-proxy
```

### P: ¿Qué archivos no debo commitear?

R: Estos ya están en `.gitignore`:
- `.env` (credenciales)
- `*.bak` (backups)
- Carpetas `certs/`, `vhost/`, `html/`, `acme/`
- Volúmenes persistentes

```bash
# Verificar seguridad antes de commit
git status | grep .env
# No debería aparecer
```

### P: ¿Puedo usar otro dominio (no escuela)?

R: **Sí, completamente flexible**:

```bash
# Opción 1: DuckDNS
bash setup.sh
# → Opción 4 (personalizado)
# → mi-proyecto.duckdns.org

# Opción 2: Dominio propio
# → mi-app.com

# Opción 3: IP directa (sin HTTPS)
# → 192.168.1.100
```

### P: ¿Qué pasa si ejecuto `setup.sh` dos veces?

R: No hay problema. Hace backup de archivos anteriores:
- `prometheus.yml.bak.setup`
- `.env.bak.TIMESTAMP`

Puedes revertir si es necesario.

### P: ¿Dónde veo los logs?

R:

```bash
# Todos los servicios
docker compose logs -f

# Específico
docker logs nginx-proxy-core
docker logs acme-companion-ssl
docker logs prometheus-core
docker logs grafana-ui
```

### P: ¿Cómo reset a estado inicial?

R:

```bash
# Parar contenedores
docker compose down

# OPCIONAL: Borrar volúmenes (cuidado: pierde datos)
docker volume rm vols_*

# Ejecutar setup nuevamente
bash setup.sh
docker compose up -d
```

---

## 📚 DOCUMENTACIÓN COMPLETA

Una vez que `setup.sh` termina, tienes acceso a:

| Documento | Propósito |
|---|---|
| **ARQUITECTURA.md** | Explicación técnica completa (nginxproxy, redes, flujos) |
| **README.md** | Manual de operación (comandos, troubleshooting) |
| **MEMORIA.md** | Detalles de implementación y decisiones técnicas |
| **CHANGELOG.md** | Cambios de v1.0 (manual) a v2.0 (automático) |

---

## ✅ CHECKLIST POST-SETUP

Después de ejecutar `setup.sh` y `docker compose up -d`:

```bash
# 1. ¿Todos los servicios levantados?
docker compose ps
[ ] nginx-proxy → Up
[ ] acme-companion → Up
[ ] prometheus → Up
[ ] node-exporter → Up
[ ] nginx-exporter → Up
[ ] fix-grafana-perms → Exited (esto es normal, es un init container)
[ ] grafana → Up
[ ] portainer → Up

# 2. ¿Se generaron certificados?
docker volume inspect despliegue-servidor_certs
docker logs acme-companion | grep "Certificate"

# 3. ¿Nginx detectó plataforma?
docker logs nginx-proxy | grep "portainer\|prometheus\|grafana"

# 4. ¿Prometheus tiene métricas?
curl "http://localhost:9090/api/v1/query?query=up"

# 5. ¿Puedes acceder a HTTPS?
curl -k https://localhost  # Dev local
curl https://tu-dominio.www.servidorgp...  # Servidor
```

---

## 🆘 TROUBLESHOOTING RÁPIDO

### Problema: "Network net_proxy not found"

**Solución**:
```bash
docker network create net_proxy --driver bridge
docker network create net_monitor --driver bridge
docker compose up -d
```

### Problema: "HTTPS devuelve ERR_CERT_NOT_YET_VALID"

**Significa**: ACME aún está generando certificado (normal primeras 60 seg)

**Solución**:
```bash
# Esperar 2 minutos
sleep 120

# Ver logs
docker logs acme-companion | tail -30

# Reintentar
curl -k https://tu-dominio   # Con -k para ignorar cert no válido
```

### Problema: "docker: command not found"

**Solución**: Instalar Docker Compose
```bash
sudo apt install docker.io docker-compose-plugin
docker compose version
```

### Problema: "Permission denied while trying to connect"

**Solución**:
```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```

---

## 🎓 PRÓXIMOS PASOS

Después de verificar que funciona:

1. **Desplegar app propia** → Ver [ARQUITECTURA.md](ARQUITECTURA.md#modelo-de-despliegue-de-apps)
2. **Setup en servidor real** → Seguir guía OPCIÓN B arriba
3. **Configurar CI/CD** → Ver [FASE 5](docs/CI-CD.md) (opcional)

---

## 📞 SOPORTE

Si algo no funciona:

1. **Ver logs detallados**: `docker compose logs -f`
2. **Revisar .env**: `cat .env | grep MAIN_DOMAIN`
3. **Verificar redes**: `docker network ls`
4. **Leer ARQUITECTURA.md**: Sección "Troubleshooting"

---

**¡Listo!** Tu infraestructura está lista para despliegue profesional. 🚀
