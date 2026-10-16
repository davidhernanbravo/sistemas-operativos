#!/usr/bin/env bash

# ============================================================================
#  ARCHIVO: configuracion/parametros.sh
#  DESCRIPCIÓN: Definición de variables globales, rutas y puerto del sistema.
# ============================================================================

# Determinamos la ruta raíz del proyecto dinámicamente.
# BASH_SOURCE[0] detecta dónde está este script, dirname saca el nombre del archivo, y el ".." lleva a 
# la raíz de ejercicio-3-1 de forma absoluta.
# Esto previene que se rompan las rutas cuando el entorno CGI ejecute los scripts.
declare -r RUTA_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Puerto para el servidor HTTP local.
declare -r PUERTO_HTTP=8080

# Rutas absolutas a los archivos de base de datos.
declare -r DB_FILE="${RUTA_BASE}/base_de_datos/datos.sq3"
declare -r ESQUEMA_SQL="${RUTA_BASE}/base_de_datos/esquema.sql"

# Rutas absolutas a los archivos de registro (Logs) y salidas.
declare -r LOG_SYS="${RUTA_BASE}/registros/sistema.log"
declare -r LOG_ERR="${RUTA_BASE}/registros/errores.log"
declare -r ARCHIVO_HTML="${RUTA_BASE}/salidas/reporte_productos.html"

# Variables de sesión.
# NOTA: En una arquitectura web (CGI), Bash no mantiene el estado en memoria entre las peticiones HTTP 
# (es stateless). Estas variables sedeclaran por compatibilidad, pero en los próximos scripts las APIs 
# deberán recuperar la sesión mediante tokens o parámetros enviados desde el frontend web.
CURRENT_USER_ID=""
CURRENT_USER_NAME=""