# GasGasAPP - Sistema Inteligente de Gestión de Rutas y Combustible 🚀⛽
# ENLACE VERCEL APP: https://practica-final-js-ol94.vercel.app/
![Banner](IMAGENINI.PNG)

Plataforma web integrada para optimización de viajes por carretera, combinando datos oficiales de precios de combustible con tecnología avanzada de cartografía digital.

---

## 🌟 Características Destacadas

### 📌 Búsqueda Avanzada de Gasolineras
- **Filtrado por Provincia**: Selección dinámica de ubicaciones geográficas
- **Paginación Inteligente**: Sistema de 12 tarjetas/página con carga progresiva
- **Datos en Tiempo Real**: Precios actualizados de Gasolina 95 E5 y otros combustibles
- **Tarjetas Interactivas**: Visualización detallada con:
  - Nombre comercial (Rótulo)
  - Dirección exacta
  - Coordenadas geográficas
  - Precios actualizados

### 🗺️ Sistema de Navegación Inteligente
- **Mapa LeafletJS**: Integración con OpenStreetMap
- **Geocodificación**: Conversión direcciones ↔ coordenadas (Nominatim API)
- **Cálculo de Rutas Óptimas**:
  - Distancia precisa (kilómetros)
  - Tiempo estimado (minutos)
  - Visualización gráfica de trayectorias
- **Marcadores Interactivos**: 
  - Clústeres de gasolineras
  - Popups informativos
  - Filtrado regional (Castilla-La Mancha)

### 🎨 Experiencia de Usuario Premium
- **Diseño Responsive**: Adaptable a móvil/tablet/desktop
- **Sistema de Grid CSS**: Organización visual optimizada
- **Efectos Visuales**:
  - Sombras dinámicas
  - Transiciones suaves
  - Paleta corporativa (rojo/negro/blanco)
- **Validación de Entradas**: Gestión de errores en tiempo real

---

## 🛠️ Arquitectura Técnica

### Stack Tecnológico
| Capa            | Tecnologías                                                                                                  |
|-----------------|-------------------------------------------------------------------------------------------------------------|
| **Frontend**    | ![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black) |
| **Cartografía** | ![Leaflet](https://img.shields.io/badge/Leaflet-199900?style=for-the-badge&logo=Leaflet&logoColor=white) ![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=OpenStreetMap&logoColor=white) |
| **APIs**        | [API REST Carburantes](https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/) • [OSRM](http://project-osrm.org/) • [Nominatim](https://nominatim.openstreetmap.org/) |

### 🌍 Casos de Uso Empresarial

### Sector Logístico
- ✅ Optimización de rutas para flotas de transporte  
- 💰 Cálculo de costes de combustible  
- ⛽ Planificación de puntos de repostaje  

### Usuario Final
- 🚗 Viajeros frecuentes  
- 👤 Conductores particulares  
- 🏢 Empresas de alquiler de vehículos  

### Administraciones Públicas
- 📊 Monitorización de precios regionales  
- 🗺️ Análisis de distribución geográfica  
- 📈 Control de fluctuaciones de mercado  

---

## 📜 Licencia y Contribución

### Licencia MIT
```text
Copyright 2025 Miapp

Se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia de este software...
