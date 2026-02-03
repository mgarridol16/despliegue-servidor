# 📑 Memoria Técnica: Infraestructura de Servicios Web y Monitorización
**Asignatura:** Despliegue de Aplicaciones Web (DAW)  
**Autor:** Miguel Garrido  
**Fecha:** Febrero 2026

---

## 1. Resumen Ejecutivo
Este documento detalla la implementación de una infraestructura de servidores basada en **Docker**, diseñada para ofrecer alta disponibilidad, seguridad criptográfica mediante **SSL/TLS** y un sistema de observabilidad en tiempo real. La arquitectura se basa en un **Proxy Inverso manual** y una segmentación de red estricta.

---

## 2. Arquitectura de Sistemas y Redes

### 2.1 Segmentación de Redes (Docker Networks)
Para cumplir con el principio de **aislamiento de servicios**, se han definido dos redes virtuales:
* **`red-proxy` (Capa de Aplicación):** Red externa que actúa como DMZ. En ella conviven el Proxy y las aplicaciones de los alumnos. Solo esta red tiene exposición al exterior.
* **`red-monit` (Capa de Gestión):** Red privada y aislada para el tráfico de métricas entre Prometheus y sus exportadores. Esto evita que un atacante desde una aplicación pueda interceptar datos de telemetría.

### 2.2 Proxy Inverso (Nginx)
Se ha optado por una configuración **nativa y manual** de Nginx. A diferencia de las soluciones automatizadas, este enfoque permite:
* Control total sobre las **cabeceras de seguridad** (X-Frame-Options, X-Content-Type, etc.).
* Gestión precisa de los **Virtual Hosts**.
* Configuración manual de la **terminación SSL**.

---

## 3. Seguridad y Criptografía

### 3.1 HTTPS Real y Desafío DNS-01 (Requisito 4)
Para la obtención de certificados de **Let's Encrypt**, se ha implementado el **desafío DNS-01** a través de la API de **DuckDNS**. 
* **Ventaja Técnica:** A diferencia del desafío HTTP-01 (que requiere el puerto 80 abierto y visibilidad pública), el DNS-01 permite validar la propiedad del dominio mediante registros TXT. Esto es ideal para entornos de laboratorio tras **CGNAT** o redes corporativas restringidas.

### 3.2 Redirección Permanente 301 (Requisito 3)
Se ha implementado una política de **HSTS (HTTP Strict Transport Security)** mediante una redirección manual en el puerto 80. Todo tráfico entrante es derivado al puerto 443 mediante un código de estado **301 (Moved Permanently)**, asegurando que nunca se transmitan datos en texto plano.

---

## 4. Stack de Observabilidad (LGP) (Requisito 5)

La infraestructura de monitorización se basa en el stack **Prometheus + Grafana**:
1.  **Recolección:** Prometheus realiza un "scraping" periódico de los endpoints de métricas.
2.  **Exportación:** Se utiliza **Node Exporter** para obtener telemetría directa del kernel de la Máquina Virtual (CPU, RAM, E/S de Disco).
3.  **Visualización:** Se ha configurado un Dashboard profesional en Grafana que permite al administrador visualizar la salud del sistema de un vistazo.

---

## 5. Gestión de Identidades y Despliegue (Requisito 2 y 7)

### 5.1 Automatización con Bash
Para la gestión de alumnos (usuarios de despliegue), se ha desarrollado el script `crear_usuario_deploy.sh`. 
* **Lógica de permisos:** El script añade al usuario al grupo `docker` y crea una estructura de directorios en `/home/$USER/apps/` con los propietarios correctos.
* **Mínimo Privilegio:** Los usuarios pueden gestionar sus contenedores pero no tienen acceso a la configuración core de la infraestructura ni a los certificados SSL del administrador.

---

## 6. Conclusiones
La plataforma implementada no solo cumple con los requisitos técnicos de la asignatura, sino que sigue las **mejores prácticas de la industria** en cuanto a seguridad perimetral y monitorización. La elección de herramientas manuales frente a automatismos demuestra un conocimiento profundo de la capa de transporte y de la orquestación de contenedores.

---
**Firma:** Miguel Garrido