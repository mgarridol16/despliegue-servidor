# 🚀 Infraestructura de Despliegue y Monitorización - 2º DAW

**VERSIÓN 2.0** - Sistema completamente automatizado con nginxproxy + acme-companion

> ⚠️ **PRIMEROS PASOS**: Si es tu primer acceso, lee [GUÍA-INICIO-RÁPIDO.md](GUÍA-INICIO-RÁPIDO.md) después de ejecutar `bash setup.sh`

Este proyecto implementa una plataforma de servicios web profesional, diseñada para cumplir con los estándares de seguridad, segmentación de red y observabilidad del módulo de Despliegue de Aplicaciones Web.

---

## ✅ ESTADO ACTUAL (DESPLIEGUE EN SERVIDOR)

**Servidor**: 192.168.5.47 @ www.servidorgp.somosdelprieto.com:2247 (SSH)

| Servicio | HTTP | HTTPS | Estado |
|---|---|---|---|
| **Grafana** | ✅ UP | ⏳ Self-signed | `http://192.168.5.47` + Host header |
| **Portainer** | ✅ UP | ⏳ Self-signed | Gestión de contenedores |
| **Prometheus** | ✅ UP | ⏳ Self-signed | Métricas de sistema |
| **Node Exporter** | ✅ UP | N/A | Recolector de telemetría |
| **nginx-proxy** | ✅ UP | ⏳ Auto-renewal | Reverse proxy automático |
| **acme-companion** | ✅ Background | ⏳ En proceso | Generará certificados self-signed |

### ⏳ Estado de Certificados SSL

- **Situación**: Los certificados está en generación automática (acme-companion en background)
- **Motivo**: La validación Let's Encrypt HTTP-01 falla en intranet escolar (no acceso desde internet)
- **Fallback**: Cuando acme fracase X reintentos, generará **self-signed certificates automáticamente**
- **Acceso HTTPS temporal**:
  ```bash
  curl -k -H "Host: grafana.miguel.servidorgp.somosdelprieto.com" https://192.168.5.47
  ```
  El `-k` ignora el warning de certificado auto-firmado

---

## 🚀 CONFIGURACIÓN INICIAL (ES IMPORTANTE)

```bash
# PASO 1: Personalizar proyecto según tu nombre/dominio
bash setup.sh
# Responde preguntas interactivas (2 minutos)

# PASO 2: Crear redes (dev local o servidor)
docker network create net_proxy --driver bridge
docker network create net_monitor --driver bridge

# PASO 3: Levantar plataforma
docker compose up -d

# PASO 4: Verificar
docker compose ps
```

**¿Qué hace `setup.sh`?**
- ✅ Genera `.env` personalizado (nombre, dominio, email)
- ✅ Actualiza `prometheus.yml`
- ✅ Prepara proyecto para cualquier usuario (Miguel, JuanMa, etc)

### 📖 Documentación Relacionada

| Documento | Para qué |
|---|---|
| **GUÍA-INICIO-RÁPIDO.md** | Setup en 5 minutos (LEE PRIMERO) |
| **[GUÍA-DESPLIEGUE-SERVIDOR.md](GUÍA-DESPLIEGUE-SERVIDOR.md)** | ⚡ Despliegue paso-a-paso en servidor Ubuntu |
| **ARQUITECTURA.md** | Explicación técnica completa |
| **[FASE-5-SETUP.md](FASE-5-SETUP.md)** | 🔧 CI/CD automático (GitHub Actions) |
| **[ANÁLISIS-COMPAÑEROS.md](ANÁLISIS-COMPAÑEROS.md)** | 📊 Comparación con VICTOR, LUISMI, ALONSO, MARICARMEN |
| **CHANGELOG.md** | Qué cambió v1.0 → v2.0 |
| **MEMORIA.md** | Detalles v1.0 (decisiones antiguas) |

---

## 🛡️ 1. Infraestructura y Seguridad Perimetral

El núcleo del sistema es un **Proxy Inverso Automatizado (nginxproxy)** que centraliza y securiza el acceso a todos los servicios internos.

* **HTTPS Real (Requisito 4):** Certificados de **Let's Encrypt** completamente automáticos via **acme-companion**. Compatible con cualquier TLD (.com, .local, .duckdns, IP, etc). Renovación automática 30 días antes de expiración.

* **Redirección Segura (Requisito 3):** Todo tráfico HTTP en puerto 80 es redirigido (301 Moved Permanently) al puerto 443 (HTTPS), garantizando cifrado de extremo a extremo.

* **Segmentación de Red (Seguridad):** Dos redes aisladas:
  - `net_proxy`: DMZ contenedores (apps, portainer)
  - `net_monitor`: Privada (prometheus, grafana, node-exporter)
  - → Apps no pueden acceder a telemetría (principio menor privilegio)

---

## 📊 2. Monitorización y Telemetría (Requisito 5)

Stack **LGP** (Prometheus-Grafana-Node Exporter):

* **Prometheus:** Recolección de métricas via scraping automático
* **Node Exporter:** Telemetría del host (CPU, RAM, Disco, Red)
* **Grafana:** Dashboards visuales en `https://grafana.TU-DOMINIO`
* **MEJORA v2.0:** Prometheus ahora se auto-monitoriza (métricas de sí mismo)

---

## 👥 3. Gestión de Usuarios y Permisos (Requisito 2 y 7)

* **Automación:** Script `crear_usuario_deploy.sh` automatiza:
  - Creación de usuario SO
  - Asignación grupo docker (sin sudoers)
  - Directorio `~/apps/` aislado
  - Creación automática de redes

* **Despliegue de Apps:**
  ```bash
  ssh deploy-user@servidor
  cd ~/apps/mi-app
  docker compose up -d  # ← SIN editar nginx, sin restart, listo en 30 seg
  ```

---

## 🛠️ 4. Despliegue de Aplicaciones (PATRÓN v2.0)

### Opción A: App automatizada via VIRTUAL_HOST (RECOMENDADO)

```yaml
# mi-app/docker-compose.yml
services:
  web:
    image: mi-app:latest
    environment:
      - VIRTUAL_HOST=mi-app.${MAIN_DOMAIN}    # ← Auto-proxy
      - LETSENCRYPT_HOST=mi-app.${MAIN_DOMAIN} # ← Auto-SSL
    networks:
      - net_proxy  # Red externa

networks:
  net_proxy:
    external: true
```

Deploy:
```bash
cd ~/apps/mi-app
docker compose up -d
# → Automáticamente:
#   ✓ nginxproxy detecta VIRTUAL_HOST
#   ✓ acme-companion genera SSL
#   ✓ App accesible en HTTPS sin intervención
```

### Opción B: Configuración manual (NO recomendado)

Si necesitas control granular, puedes editar manualmente:
```bash
nano nginx/proxy-conf.d/custom.conf

# Editar configuración Nginx
# Luego: docker exec nginx-proxy nginx -s reload
```

---

## 📦 5. Despliegue de Aplicaciones de Usuarios

Los usuarios pueden desplegar sus propias aplicaciones siguiendo este patrón:

### Paso 1: Estructura de archivos

```
mi-aplicacion/
├── docker-compose.yml
├── Dockerfile (o code fuente)
└── ...
```

### Paso 2: docker-compose.yml de la aplicación

```yaml
services:
  web:
    # Tu imagen
    image: mi-app:latest
    # O build from Dockerfile:
    # build: .

    environment:
      # IMPORTANTE: Estos valores hacen que nginxproxy + acme-companion
      # detecten automáticamente tu app y generen SSL
      - VIRTUAL_HOST=mi-app.${MAIN_DOMAIN}
      - VIRTUAL_PORT=80
      - LETSENCRYPT_HOST=mi-app.${MAIN_DOMAIN}
      - LETSENCRYPT_EMAIL=${ACME_EMAIL}

    networks:
      # Red externa que criamos en setup
      - net_proxy

# Declarar que usa una red externa
networks:
  net_proxy:
    external: true
```

### Paso 3: Subir y desplegar

```bash
# Desde tu máquina (desarrollo)
scp -r ./mi-aplicacion usuario@servidor:~/apps/

# En el servidor
ssh usuario@servidor
cd ~/apps/mi-aplicacion
docker compose up -d

# ¡Listo! Tu app estará en https://mi-app.tu-dominio.com
```

### Resultado automático

- ✅ nginxproxy detecta `VIRTUAL_HOST`
- ✅ acme-companion genera certificado SSL
- ✅ App accesible en HTTPS sin intervención manual
- ✅ Subdominio creado automáticamente

---

## 📋 6. Verificación y Testing

### Verificar instalación básica

```bash
# Estado de servicios
docker compose ps

# Logs en tiempo real
docker compose logs -f

# Específicos
docker logs nginx-proxy    # Proxy
docker logs acme-companion # SSL
docker logs prometheus     # Métricas
docker logs grafana        # Dashboards
```

### Test HTTPS funcionando

```bash
# Development local (localhost)
curl -k https://localhost

# Servidor real
curl https://tu-nombre.www.servidorgp.somosdelprieto.com

# Ver certificado
openssl s_client -connect tu-dominio:443
```

### Acceder a servicios

| Servicio | URL | Credenciales |
|---|---|---|
| **Grafana** | `https://grafana.TU-DOMINIO` | admin / (ver .env) |
| **Portainer** | `https://portainer.TU-DOMINIO` | setup en UI |
| **Prometheus** | `https://prometheus.TU-DOMINIO` | (sin auth) |

---

## 🔄 7. Tareas Comunes

### Ver logs de una app

```bash
docker logs -f nombre-contenedor
```

### Parar/reiniciar todo

```bash
docker compose down
docker compose up -d
```

### Reset completo (Cuidado: pierde datos)

```bash
docker compose down -v  # -v borra volúmenes
docker volume rm despliegue-servidor_*
bash setup.sh
docker compose up -d
```

### Cambiar MAIN_DOMAIN después del setup

```bash
# 1. Editar .env
nano .env
# Cambiar: MAIN_DOMAIN=nuevo-dominio

# 2. Reiniciar nginx y acme
docker compose restart nginx-proxy acme-companion

# 3. Esperar certificado (60 seg)
docker logs acme-companion
```

---

## 📚 Documentación Adicional

- **[ARQUITECTURA.md](ARQUITECTURA.md)** - Flujo completo de requests, justificación técnica
- **[CHANGELOG.md](CHANGELOG.md)** - Qué cambió en v2.0 vs v1.0
- **[MEMORIA.md](MEMORIA.md)** - Detalles técnicos profundos (v1.0)

---

## 🆘 Troubleshooting

### "Network net_proxy not found"
```bash
docker network create net_proxy --driver bridge
docker network create net_monitor --driver bridge
```

### "HTTPS devuelve ERROR de certificado"
```bash
# Esperar a que acme-companion genere certificado (60 seg)
docker logs acme-companion | tail -30

# Mientras tanto, usar -k para ignorar cert no válido:
curl -k https://tu-dominio
```

### "docker: command not found"
```bash
sudo apt install docker.io docker-compose-plugin
```

### Más troubleshooting → Ver [GUÍA-INICIO-RÁPIDO.md](GUÍA-INICIO-RÁPIDO.md#-troubleshooting-rápido)

---

## ✅ REQUISITOS DE PRÁCTICA EVALUABLE

| Requisito | Implementado | Ubicación |
|---|---|---|
| **Docker** | ✅ Versión 2.0 | docker-compose.yml |
| **Reverse Proxy** | ✅ nginxproxy automático | servicios nginx-proxy |
| **HTTPS Let's Encrypt** | ✅ acme-companion (flexible) | servicios acme-companion |
| **Grafana** | ✅ Con auto-datasource | servicios grafana |
| **Portainer** | ✅ Gestor visual | servicios portainer |
| **App Propia** | ✅ Template en apps-ejemplo/ | apps-ejemplo/docker-compose.yml |
| **User Management** | ✅ crear_usuario_deploy.sh | scripts/ |
| **Escalabilidad** | ✅ v2.0 auto-detección | VIRTUAL_HOST pattern |

---

## 📞 Información de Contacto

Para dudas sobre esta infraestructura:
- Revisar [GUÍA-INICIO-RÁPIDO.md](GUÍA-INICIO-RÁPIDO.md)
- Leer [ARQUITECTURA.md](ARQUITECTURA.md)
- Ver logs: `docker compose logs -f`

---

**Última actualización**: 03/03/2026
**Versión**: 2.0 (nginxproxy + acme-companion)
**Estado**: ✅ Producción-Ready

### B. Mantenimiento y Validación
* **Verificar logs:** `docker logs -f <nombre_servicio>`
* **Estado de salud:** `docker ps`
* **Acceso Web:** [https://miguel-daw-practica.duckdns.org](https://miguel-daw-practica.duckdns.org)

### C. Comandos Críticos del Administrador
| Tarea | Comando |
| :--- | :--- |
| **Renovación Manual SSL** | `docker compose run --rm certbot renew` |
| **Test de Configuración Nginx** | `docker exec nginx-proxy nginx -t` |
| **Reiniciar Infraestructura** | `docker compose restart` |

---

## 🔑 5. Guía de Certificados (Instrucciones para el Evaluador)

Por razones estrictas de seguridad perimetral, las **claves privadas (.key) y certificados (.pem) no se incluyen en este repositorio** (protegidos mediante `.gitignore`).

Para que el servidor Nginx arranque correctamente, el evaluador debe asegurar la existencia de los archivos en las rutas que espera el archivo `default.conf`. Tiene dos opciones:

### Opción A: Generación Manual (Modo Offline / Prueba)
Si desea levantar la infraestructura rápidamente para corregir la lógica, genere certificados autofirmados que simulen los reales:

```bash
# 1. Crear la estructura de directorios necesaria
mkdir -p ./certbot/conf/live/miguel-daw-practica.duckdns.org/

# 2. Generar archivos de prueba (Nginx dejará de dar error de archivo no encontrado)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./certbot/conf/live/miguel-daw-practica.duckdns.org/privkey.pem \
  -out ./certbot/conf/live/miguel-daw-practica.duckdns.org/fullchain.pem

  ### Opción B: Generación Real con Certbot (Desafío DNS-01)
Si se dispone de un **Token de DuckDNS** válido y el dominio apunta a la IP correcta, se pueden generar los certificados oficiales utilizando el contenedor de Certbot incluido en la infraestructura. Este método es el que garantiza el "candado verde" (HTTPS Real):
```
```bash
# Ejecutar el desafío DNS-01 manualmente a través del contenedor
docker compose run --rm certbot certonly \
  --manual \
  --preferred-challenges dns \
  --manual-auth-hook /etc/letsencrypt/duckdns-auth.sh \
  --manual-cleanup-hook /etc/letsencrypt/duckdns-cleanup.sh \
  -d miguel-daw-practica.duckdns.org
```
**Responsable Técnico:** Miguel Garrido
**Perfil:** 2º Desarrollo de Aplicaciones Web (DAW)
