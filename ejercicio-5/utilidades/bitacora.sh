#!/usr/bin/env bash

# ======================================================================================
#  ARCHIVO: utilidades/bitacora.sh
#  DESCRIPCIÓN: Funciones transversales para registro de auditoría y manejo de errores.
# ======================================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

# Registra eventos de auditoría en formato TSV.
log_accion() {
    local accion="$1"
    
    # Permite recibir ID y nombre de usuario por parámetro ($2 y $3) o utilizar variables globales de sesión.
    local user_id="${2:-${CURRENT_USER_ID:--}}"
    local user_name="${3:-${CURRENT_USER_NAME:--}}"
    local fecha_hora
    
    fecha_hora=$(date "+%Y-%m-%d %H:%M:%S")

    # Formato TSV: Fecha/Hora | ID Usuario | Nombre Usuario | Acción.
    printf "%s\t%s\t%s\t%s\n" "$fecha_hora" "$user_id" "$user_name" "$accion" >> "$LOG_SYS"
}

# Registra errores técnicos o de validación.
manejar_error() {
    local mensaje="$1"
    local fecha_hora
    fecha_hora=$(date "+%Y-%m-%d %H:%M:%S")
    
    printf "[%s] ERROR: %s\n" "$fecha_hora" "$mensaje" >> "$LOG_ERR"
    
    # Se emite el aviso por stderr (>&2) para no contaminar el canal stdout utilizado por la capa de servicio.
    printf "Error: %s (Detalles en %s)\n" "$mensaje" "$LOG_ERR" >&2
}