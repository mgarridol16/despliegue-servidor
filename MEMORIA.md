# 🛠️ Dashboard de Operaciones: Infraestructura Web

****Administrador:**** Miguel Garrido | ****Nodo:**** `servidorgp.somosdelprieto.com`

## 🚀 ESTATUS DEL NODO

Punto centralizado para la orquestación de servicios en contenedor. La arquitectura prescinde de gestores de certificados locales, delegando la capa de seguridad (SSL/TLS) al Proxy perimetral del centro.

| Servicio   | Acceso Directo (HTTPS) |
| ---------- | ---------------------- |
| Portainer  | Panel de Gestión       |
| Grafana    | Monitorización         |
| Prometheus | Métricas (API)         |

## 📦 CICLO DE VIDA DE UNA APLICACIÓN

Para desplegar un nuevo servicio, solo necesitas un archivo `docker-compose.yml` en la raíz de tu proyecto. ****No requiere configuración adicional.****

### Plantilla de despliegue

YAML

services:
  app-service:
    image: <imagen>
    restart: unless-stopped
    environment:
      # Formato: <app>-<usuario>.servidorgp.somosdelprieto.com
      - VIRTUAL\_HOST=mi-app-miguel.servidorgp.somosdelprieto.com
      - VIRTUAL\_PORT=80
    networks:
      - net\_proxy

networks:
  net\_proxy:
    external: true

### Operativa de Despliegue

1.  ****Transferir:**** Sube tu carpeta de proyecto al servidor (`~/apps/`).
2.  ****Activar:**** Entra en la carpeta y ejecuta: `docker compose up -d`.
3.  ****Verificar:**** Tu servicio estará disponible al instante en su URL asignada.

## ⚙️ ADMINISTRACIÓN Y MANTENIMIENTO

### Comandos de Control

-   ****Recarga:**** `docker compose pull && docker compose up -d` (Actualiza y aplica cambios).
-   ****Limpieza:**** `docker compose down` (Detiene y elimina contenedores).
-   ****Inspección:**** `docker compose logs -f --tail 20` (Seguimiento de logs en tiempo real).
-   ****Estado:**** `docker stats` (Ver consumo de recursos).

### Reglas de Convención

-   ****Nomenclatura:**** Se utiliza estrictamente el formato `app-usuario.dominio`.
-   ****Redes:**** Todo despliegue debe estar anclado a la red `net_proxy`.
-   ****Certificados:**** Prohibido desplegar gestores SSL locales (evitar conflictos con el proxy del centro).

## 🏗️ MAPA DE TOPOLOGÍA

Fragmento de código

graph TD
    A\[Proxy Instituto / SSL Termination\] --> B(net\_proxy)
    B --> C\[Portainer\]
    B --> D\[Grafana / Prometheus\]
    B --> E\[App Usuario\]

    subgraph Interno
    D --> F\[Node Exporter\]
    end

|   |
| - |
|   |
