#!/usr/bin/env bash

# ===========================================================================
#  ARCHIVO: base_de_datos/inicializar.sh
#  DESCRIPCIÓN: Inicializa la estructura de la base de datos SQLite.
#  NOTA: No existe una "conexión" persistente en Bash. Cada invocación de
#        sqlite3 abre y cierra la base en ese momento puntual. Por eso este
#        módulo solo se ocupa de la inicialización y no de ejecutar consultas.
# ===========================================================================

# Importamos los parámetros globales para acceder a las rutas de la BD y logs.
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