#!/usr/bin/env bash

# ===========================================================================
#  ARCHIVO: base_de_datos/conexion.sh
#  DESCRIPCIÓN: Inicializa la BD y centraliza la ejecución de consultas SQL.
# ===========================================================================

# Importamos los parámetros globalmente por si este módulo se invoca desde otro lado.
source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

inicializar_db() {
    # Reimplementación silenciosa y con delegación de errores para entorno Web/RPC.
    if [[ ! -f "$DB_FILE" ]]; then
        
        # Validación de seguridad para evitar fallos si falta el archivo SQL.
        if [[ ! -f "$ESQUEMA_SQL" ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR CRÍTICO: No se encontró el archivo $ESQUEMA_SQL." >> "$LOG_ERR"
            # Delegamos el manejo del error al orquestador principal (ejercicio-5.sh).
            return 1 
        fi

        # Inyectamos el archivo .sql directamente a SQLite3.
        sqlite3 "$DB_FILE" < "$ESQUEMA_SQL" 2>>"$LOG_ERR"
        
        if [[ $? -ne 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR CRÍTICO: Fallo al crear la estructura en $DB_FILE" >> "$LOG_ERR"
            # Retornamos error sin forzar la salida para no interrumpir el flujo del servidor.
            return 1
        fi
        # No imprimimos texto por stdout para evitar corromper las respuestas HTTP/RPC enviadas al cliente.
    fi
    return 0
}

ejecutar_query() {
    local query="$1"
    # Envuelve la ejecución de consultas e intercepta los errores mandándolos al log.
    sqlite3 "$DB_FILE" "$query" 2>>"$LOG_ERR"
}