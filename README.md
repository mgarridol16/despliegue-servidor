# 🚀 Infraestructura de Despliegue y Monitorización - 2º DAW

Este proyecto implementa una plataforma de servicios web robusta, diseñada para cumplir con los estándares de seguridad, segmentación de red y observabilidad requeridos en el módulo de Despliegue de Aplicaciones Web.

---

## 🛡️ 1. Infraestructura y Seguridad Perimetral

El núcleo del sistema es un **Proxy Inverso Nginx** que centraliza y securiza el acceso a todos los servicios internos (Grafana, Portainer y aplicaciones de terceros).

* **HTTPS Real (Requisito 4):** Implementado mediante certificados de **Let's Encrypt**. A diferencia de los métodos estándar, se ha utilizado el **desafío DNS-01** mediante la API de **DuckDNS**. Esto permite obtener certificados válidos incluso en redes privadas o tras CGNAT, automatizando la validación mediante hooks en el contenedor de Certbot.
* **Redirección Obligatoria (Requisito 3):** Se ha configurado un bloque de servidor en el puerto 80 que aplica un **código de estado 301**, redirigiendo todo el tráfico de forma automática hacia el puerto 443 (HTTPS) para garantizar el cifrado de extremo a extremo.
* **Segmentación de Red:** Los servicios se dividen en redes lógicas (`red-proxy` y `red-monit`) para evitar el movimiento lateral de posibles amenazas.

---

## 📊 2. Monitorización y Telemetría (Requisito 5)

La infraestructura de observabilidad utiliza el stack **LGP** para garantizar la disponibilidad de los servicios:

* **Prometheus:** Actúa como motor de recolección de métricas mediante scraping de targets.
* **Node Exporter:** Agente encargado de extraer métricas críticas de la Máquina Virtual (Uso de CPU, carga de RAM y latencia de Disco) en tiempo real.
* **Grafana:** Interfaz visual donde se han configurado dashboards profesionales para la monitorización del hardware host.

---

## 👥 3. Gestión de Usuarios y Permisos (Requisito 2 y 7)

Se ha implementado una capa de automatización para la gestión de usuarios de despliegue, cumpliendo con las políticas de seguridad del sistema operativo:

* **Script de Automatización:** El script `crear_usuario_deploy.sh` automatiza la creación del usuario, la asignación al grupo `docker` y la preparación del entorno de trabajo.
* **Estructura de Trabajo:** Cada usuario dispone de un directorio `~/apps/` aislado, donde gestionan sus propios proyectos mediante Docker Compose, 
garantizando que el entorno del sistema permanezca limpio y organizado.

### Desplegar la App del Profesor
La aplicación se gestiona de forma aislada dentro del entorno del usuario de despliegue:

1. **Ubicación Real:** `/home/deploy-profesor/apps/`
2. **Procedimiento:** - Acceder como usuario `deploy-profesor`.
   - Clonar o copiar el proyecto dentro de la carpeta `apps/`.
   - Levantar el servicio con el comando: `docker compose up -d`.
3. **Interconexión:** Gracias a que el contenedor se conecta a la red externa `red-proxy`, el tráfico fluye desde Nginx hacia la aplicación de forma transparente.

---

## 🛠️ 4. Runbook de Operaciones (Guía de Despliegue)

Este apartado detalla el flujo de trabajo estándar para la administración de la plataforma.

### A. Procedimiento de Despliegue de Aplicaciones
1.  **Acceso:** Conectar vía SSH al servidor con las credenciales del usuario de despliegue.
2.  **Preparación:** Situar el archivo `docker-compose.yml` en la carpeta `~/apps/nombre-app/`.
3.  **Lanzamiento:** Ejecutar el comando:
    ```bash
    docker compose up -d
    ```
4.  **Vinculación:** Editar `nginx/conf.d/default.conf` para añadir el `proxy_pass` hacia el nuevo contenedor y reiniciar el proxy.

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