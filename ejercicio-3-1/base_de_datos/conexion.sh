#!/usr/bin/env bash

# ===========================================================================
#  ARCHIVO: base_de_datos/conexion.sh
#  DESCRIPCIÓN: Inicializa la BD y centraliza la ejecución de consultas SQL.
# ===========================================================================

# Importamos los parámetros globalmente por si este módulo se invoca desde otro lado.
source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

inicializar_db() {
    # Reimplementación de la inicialización separando el esquema SQL.
    if [[ ! -f "$DB_FILE" ]]; then
        echo "[INFO] La base de datos no existe. Creando estructura..."
        
        # Validación de seguridad para evitar fallos si falta el archivo SQL.
        if [[ ! -f "$ESQUEMA_SQL" ]]; then
            echo "[ERROR CRÍTICO] No se encontró el archivo $ESQUEMA_SQL." >&2
            exit 1
        fi

        # Inyectamos el archivo .sql directamente a SQLite3.
        sqlite3 "$DB_FILE" < "$ESQUEMA_SQL" 2>>"$LOG_ERR"
        
        if [[ $? -ne 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR CRÍTICO: Fallo al crear la estructura en $DB_FILE" >> "$LOG_ERR"
            echo "Error crítico: No se pudo inicializar la base de datos. Revisar $LOG_ERR" >&2
            exit 1
        fi
        echo "[INFO] Base de datos creada exitosamente en $DB_FILE."
    fi
}

ejecutar_query() {
    local query="$1"
    # Envuelve la ejecución de consultas e intercepta los errores mandándolos al log.
    sqlite3 "$DB_FILE" "$query" 2>>"$LOG_ERR"
}