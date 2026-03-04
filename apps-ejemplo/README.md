# 📦 Ejemplo de Aplicación para Despliegue

Esta carpeta contiene un ejemplo de cómo desplegar tu propia aplicación en la plataforma.

---

## 🚀 Estructura Mínima

```
mi-aplicacion/
├── docker-compose.yml    ← Configuración de Docker
├── Dockerfile            ← (Opcional) Si construyes tu propia imagen
├── index.html            ← (Ejemplo) Tu contenido web
└── README.md             ← Documentación
```

---

## 📋 docker-compose.yml Mínimo

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine        # O tu imagen personalizada
    container_name: mi-app-web
    restart: unless-stopped

    # IMPORTANTE: Variables para automático SSL + proxy
    environment:
      - VIRTUAL_HOST=mi-app.tu-dominio.com
      - VIRTUAL_PORT=80
      - LETSENCRYPT_HOST=mi-app.tu-dominio.com
      - LETSENCRYPT_EMAIL=tu-email@example.com

    volumes:
      - ./index.html:/usr/share/nginx/html/index.html:ro

    networks:
      - net_proxy  # Red externa = nginx-proxy

networks:
  net_proxy:
    external: true
    name: net_proxy
```

---

## 📤 Pasos de Despliegue (Desde tu máquina)

### 1️⃣ Copiar aplicación al servidor

```bash
# Desde tu máquina local
scp -r ./mi-aplicacion usuario@servidor:~/apps/

# Ejemplo:
# scp -r ./web-profesor deployer@192.168.5.47:~/apps/
```

### 2️⃣ Conectarse al servidor y desplegar

```bash
# SSH al servidor
ssh usuario@servidor

# Navegar a la carpeta
cd ~/apps/mi-aplicacion

# Levantar contenedor
docker compose up -d

# Verificar
docker compose ps
```

### 3️⃣ Comprobar que funciona

```bash
# Verificar logs
docker logs -f nombre-contenedor

# Verificar que está accesible
curl https://mi-app.tu-dominio.com

# O desde el navegador:
# https://mi-app.tu-dominio.com
```

---

## 🔑 Variables de Entorno Importantes

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `VIRTUAL_HOST` | `mi-app.tu-dominio.com` | Subdominio (detectado por nginx-proxy) |
| `VIRTUAL_PORT` | `80` | Puerto interno de tu app |
| `LETSENCRYPT_HOST` | `mi-app.tu-dominio.com` | Activa certificado SSL automático |
| `LETSENCRYPT_EMAIL` | `tu-email@example.com` | Email para renovaciones de certificado |

---

## 🏗️ Ejemplo: Aplicación PHP + Base de Datos

```yaml
version: '3.8'

services:
  # Aplicación Web
  web:
    build: ./php
    container_name: mi-app-php
    restart: unless-stopped
    environment:
      - VIRTUAL_HOST=mi-app.tu-dominio.com
      - VIRTUAL_PORT=80
      - LETSENCRYPT_HOST=mi-app.tu-dominio.com
      - LETSENCRYPT_EMAIL=tu-email@example.com
    volumes:
      - ./src:/var/www/html
    depends_on:
      - db
    networks:
      - net_proxy
      - mi-app-backend

  # Base de Datos (NO visible desde internet)
  db:
    image: mariadb:11
    container_name: mi-app-db
    restart: unless-stopped
    environment:
      MARIADB_ROOT_PASSWORD: change_me
      MARIADB_DATABASE: miapp
    volumes:
      - mi-app-db-data:/var/lib/mysql
    networks:
      - mi-app-backend

networks:
  net_proxy:
    external: true
    name: net_proxy

  mi-app-backend:
    driver: bridge

volumes:
  mi-app-db-data:
```

---

## ⚠️ Consideraciones Importantes

1. **Seguridad**: Las credenciales de BD NO deben hardcodearse. Usa `.env` externo.
2. **Persistencia**: Los volúmenes deben estar bien configurados para no perder datos.
3. **Redes**:
   - `net_proxy`: RED EXTERNA, visible desde internet via nginx
   - RED PRIVADA (ej: `mi-app-backend`): Para servicios internos (BD, Redis, etc)
4. **Dominio**: Debe ser `<algo>.tu-dominio.com` (configurado en plataforma principal)

---

## 🔄 Flujo Automático

Una vez que levantas `docker compose up -d`:

1. ✅ Docker crea el contenedor
2. ✅ nginx-proxy detecta `VIRTUAL_HOST`
3. ✅ acme-companion genera certificado SSL (30-60 seg)
4. ✅ Tu app está en `https://mi-app.tu-dominio.com`

**Sin intervención manual**, sin editar nginx, sin reiniciar nada.

---

## 🆘 Troubleshooting

### Problema: "Error: network net_proxy not found"

**Solución**: Las redes deben existir previamente. El administrador debe ejecutar:
```bash
sudo docker network create net_proxy --driver bridge
sudo docker network create net_monitor --driver bridge
```

O usar `crear_usuario_deploy.sh` que lo hace automáticamente.

### Problema: "HTTPS returns certificate error"

**Situación**: Normal. acme-companion está generando el certificado (espera 60 seg).

**Mientras tanto**:
```bash
curl -k https://mi-app.tu-dominio.com
```

El `-k` ignora errores de certificado temporal.

### Problema: "Conexión rechazada en VIRTUAL_HOST"

**Verificar**:
1. ¿El contenedor está levantado? → `docker compose ps`
2. ¿Escucha en el puerto declarado? → `docker logs nombre-contenedor`
3. ¿nginx-proxy detectó el contenedor? → `docker logs nginx-proxy | grep VIRTUAL_HOST`

---

## 📚 Documentación Completa

- **[../README.md](../README.md)** - Manual principal de la plataforma
- **[../ARQUITECTURA.md](../ARQUITECTURA.md)** - Explicación técnica del flujo
- **[../GUÍA-INICIO-RÁPIDO.md](../GUÍA-INICIO-RÁPIDO.md)** - Setup en 5 minutos
- **[../GUÍA-DESPLIEGUE-SERVIDOR.md](../GUÍA-DESPLIEGUE-SERVIDOR.md)** - Despliegue paso a paso

---

**Última actualización**: 04/03/2026
**Plataforma**: DESPLIEGUE MIGUEL v2.0
**Estado**: ✅ Listo para desplegar
