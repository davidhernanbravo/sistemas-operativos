#!/usr/bin/env bash

# ========================================================================
#  ARCHIVO: configuracion/parametros.sh
#  DESCRIPCIÓN: Definición de variables globales, rutas y parámetros TUI.
# ========================================================================

# Determinamos la ruta raíz del proyecto dinámicamente.
# BASH_SOURCE[0] detecta dónde está este script, dirname saca el nombre del archivo, y el ".." lleva a la raíz del ejercicio 
# de forma absoluta, sin importar desde dónde se ejecute el sistema.
declare -r RUTA_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# CAMBIO: Se eliminó PUERTO_HTTP por ser inútil en esta capa.
# CAMBIO: Se agregaron variables globales para estandarizar la interfaz Whiptail.
declare -r TUI_ALTO=20
declare -r TUI_ANCHO=70
declare -r TUI_TITULO="Gestor de Inventario TUI"

# Rutas absolutas a los archivos de base de datos.
declare -r DB_FILE="${RUTA_BASE}/base_de_datos/datos.sq3"
declare -r ESQUEMA_SQL="${RUTA_BASE}/base_de_datos/esquema.sql"

# Rutas absolutas a los archivos de registro (Logs) y salidas.
declare -r LOG_SYS="${RUTA_BASE}/registros/sistema.log"
declare -r LOG_ERR="${RUTA_BASE}/registros/errores.log"
declare -r ARCHIVO_HTML="${RUTA_BASE}/salidas/reporte_productos.html"

# Variables de sesión globales.
# CAMBIO: Actualización de la documentación arquitectónica.
# En una interfaz TUI, el proceso principal de Bash se mantiene activo durante toda la ejecución. Estas variables almacenarán 
# el estado persistente del usuario en memoria para poder pasarlo a los parámetros de auditoría (sistema.log).
CURRENT_USER_ID=""
CURRENT_USER_NAME=""