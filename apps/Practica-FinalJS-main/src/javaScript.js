// URL de la API de gasolineras
const apiUrl = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/';


let paginaActual = 0;
const tarjetasPorPagina = 12; 
let datosCompletos = []; 
let provinciaSeleccionada = ''; 


let mapa;
let controlRutas;

// Función para obtener los datos de la API de gasolineras
async function obtenerDatos() {
    try {
        const respuesta = await fetch(apiUrl);
        const datos = await respuesta.json();
        datosCompletos = datos.ListaEESSPrecio; // Guarda todos los datos
        mostrarProvincias(datosCompletos); // Muestra las provincias en el select
        mostrarDatos(datosCompletos); // Muestra las tarjetas iniciales
        agregarBotonPaginacion(); // Agrega el botón de paginación
        mostrarMapa(datosCompletos); // Muestra las gasolineras en el mapa
    } catch (error) {
        console.error('Error al obtener los datos:', error);
    }
}

// Función para mostrar las provincias en el select
function mostrarProvincias(estaciones) {
    const provincias = [...new Set(estaciones.map(estacion => estacion.Provincia))]; // Provincias únicas
    const selectProvincia = document.getElementById('provincia');

    provincias.sort().forEach(provincia => {
        const option = document.createElement('option');
        option.value = provincia;
        option.textContent = provincia;
        selectProvincia.appendChild(option);
    });

    // Escuchar cambios en el select
    selectProvincia.addEventListener('change', () => {
        provinciaSeleccionada = selectProvincia.value;
        paginaActual = 0; // Reinicia la paginación
        mostrarDatos(datosCompletos); // Filtra las tarjetas
    });
}

// Función para mostrar los datos en el DOM
function mostrarDatos(estaciones) {
    const contenedor = document.getElementById('contenedor');
    contenedor.innerHTML = ''; // Limpia el contenedor antes de agregar nuevas tarjetas

    // Filtrar por provincia si hay una seleccionada
    const estacionesFiltradas = provinciaSeleccionada
        ? estaciones.filter(estacion => estacion.Provincia === provinciaSeleccionada)
        : estaciones;

    const inicio = paginaActual * tarjetasPorPagina;
    const fin = inicio + tarjetasPorPagina;

    estacionesFiltradas.slice(inicio, fin).forEach(estacion => {
        const tarjeta = document.createElement('div');
        tarjeta.className = 'tarjeta';
        tarjeta.innerHTML = `
            <h3>${estacion.Rótulo}</h3>
            <p><strong>Dirección:</strong> ${estacion.Dirección}</p>
            <p><strong>Provincia:</strong> ${estacion.Provincia}</p>
            <p><strong>Precio Gasolina 95:</strong> ${estacion['Precio Gasolina 95 E5']}</p>

        `;
        contenedor.appendChild(tarjeta);
    });
}

// Función para avanzar a la siguiente página
function siguientePagina() {
    const estacionesFiltradas = provinciaSeleccionada
        ? datosCompletos.filter(estacion => estacion.Provincia === provinciaSeleccionada)
        : datosCompletos;

    const totalPaginas = Math.ceil(estacionesFiltradas.length / tarjetasPorPagina);
    paginaActual = (paginaActual + 1) % totalPaginas; // Avanza a la siguiente página
    mostrarDatos(datosCompletos); // Muestra la nueva página
}

// Función para agregar el botón de paginación
function agregarBotonPaginacion() {
    const botonPaginacion = document.createElement('button');
    botonPaginacion.className = 'boton-paginacion';
    botonPaginacion.textContent = 'Pasar página';
    botonPaginacion.addEventListener('click', siguientePagina);
    document.querySelector('.Api').appendChild(botonPaginacion);
}

// Función para inicializar el mapa de OpenStreetMap
function inicializarMapa() {
    mapa = L.map('map').setView([39.8628, -4.0273], 8); // Centrado en Castilla-La Mancha

    // Cargar mapa de OpenStreetMap
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(mapa);

    // Inicializar el control de rutas
    controlRutas = L.Routing.control({
        waypoints: [],
        routeWhileDragging: true,
        show: false
    }).addTo(mapa);
}

// Función para mostrar las gasolineras en el mapa
function mostrarMapa(estaciones) {
    // Filtrar gasolineras en Castilla-La Mancha
    const gasolinerasCastillaLaMancha = estaciones.filter(estacion => 
        estacion.Provincia === "Albacete" || 
        estacion.Provincia === "Ciudad Real" || 
        estacion.Provincia === "Cuenca" || 
        estacion.Provincia === "Guadalajara" || 
        estacion.Provincia === "Toledo"
    );

    // Agregar marcadores al mapa
    gasolinerasCastillaLaMancha.forEach(estacion => {
        const marcador = L.marker([parseFloat(estacion["Latitud"].replace(",", ".")), parseFloat(estacion["Longitud (WGS84)"].replace(",", "."))])
            .addTo(mapa)
            .bindPopup(`<b>${estacion.Rótulo}</b><br>${estacion.Dirección}`);
    });
}

// Función para calcular una ruta
function calcularRuta() {
    const origen = document.getElementById('origen').value;
    const destino = document.getElementById('destino').value;

    if (!origen || !destino) {
        alert("Por favor, introduce un origen y un destino.");
        return;
    }

    // Usar Nominatim para geocodificar las direcciones
    Promise.all([
        fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(origen)}`).then(res => res.json()),
        fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(destino)}`).then(res => res.json())
    ]).then(([origenData, destinoData]) => {
        if (origenData.length === 0 || destinoData.length === 0) {
            alert("No se pudo encontrar la ubicación. Verifica las direcciones.");
            return;
        }

        const origenCoords = [parseFloat(origenData[0].lat), parseFloat(origenData[0].lon)];
        const destinoCoords = [parseFloat(destinoData[0].lat), parseFloat(destinoData[0].lon)];

        // Mostrar la ruta en el mapa
        controlRutas.setWaypoints([
            L.latLng(origenCoords[0], origenCoords[1]),
            L.latLng(destinoCoords[0], destinoCoords[1])
        ]);

        // Mostrar la distancia y duración
        fetch(`https://router.project-osrm.org/route/v1/driving/${origenCoords[1]},${origenCoords[0]};${destinoCoords[1]},${destinoCoords[0]}?overview=full`)
            .then(res => res.json())
            .then(data => {
                if (data.routes && data.routes.length > 0) {
                    const distancia = data.routes[0].distance / 1000; // Convertir a kilómetros
                    const duracion = data.routes[0].duration / 60; // Convertir a minutos
                    document.getElementById('rutaResultado').innerHTML = `
                        <p><strong>Distancia:</strong> ${distancia.toFixed(2)} km</p>
                        <p><strong>Duración:</strong> ${duracion.toFixed(2)} minutos</p>
                    `;
                }
            });
    });
}

// Llamar a la función para obtener y mostrar los datos
obtenerDatos();
inicializarMapa();