#!/usr/bin/env bash

# ============================================================================
#  ARCHIVO: configuracion/parametros.sh
#  DESCRIPCIÓN: Definición de variables globales, rutas y parámetros Web/RPC.
# ============================================================================

# Determinamos la ruta raíz del proyecto dinámicamente.
# BASH_SOURCE[0] detecta dónde está este script, dirname saca el nombre del archivo, y el ".." lleva a la raíz del ejercicio 
# de forma absoluta, sin importar desde dónde se ejecute el sistema.
declare -r RUTA_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# CAMBIO: Se eliminaron las variables de dimensionamiento de Whiptail (TUI_ALTO, TUI_ANCHO, TUI_TITULO).
# CAMBIO: Se incorporan los parámetros del servidor HTTP (socat) y las rutas de la capa de presentación Web.
declare -r PUERTO_HTTP=8080
declare -r DIR_WEB="${RUTA_BASE}/interfaz_web"
declare -r SCRIPT_SERVIDOR="${DIR_WEB}/servidor_http.sh"

# Rutas absolutas a los archivos de base de datos.
declare -r DB_FILE="${RUTA_BASE}/base_de_datos/datos.sq3"
declare -r ESQUEMA_SQL="${RUTA_BASE}/base_de_datos/esquema.sql"

# Rutas absolutas a los archivos de registro (Logs) y salidas.
declare -r LOG_SYS="${RUTA_BASE}/registros/sistema.log"
declare -r LOG_ERR="${RUTA_BASE}/registros/errores.log"
declare -r ARCHIVO_HTML="${RUTA_BASE}/salidas/reporte_productos.html"

# Variables de contexto de sesión por petición (Request Scope).
# CAMBIO: En la arquitectura Web/RPC (stateless), el estado de la sesión reside en el cliente (navegador).
# Por cada petición entrante, el subproceso instanciado por socat hidrata estas variables en memoria antes de invocar la API,
# garantizando retrocompatibilidad total con las capas inferiores y la trazabilidad en la auditoría (sistema.log).
CURRENT_USER_ID=""
CURRENT_USER_NAME=""