#!/usr/bin/env bash

# =================================================================================
#  ARCHIVO: utilidades/seguridad.sh
#  DESCRIPCIÓN: Funciones transversales para encriptación y sanitización de datos.
# =================================================================================

# Genera hash SHA-256 aislando el primer campo del output.
generar_hash() {
    local password="$1"
    local hash_valor
    hash_valor=$(echo -n "$password" | sha256sum | awk '{print $1}')
    echo "$hash_valor"
}

# Comprueba si una cadena contiene únicamente números mediante expresión regular.
# Extraído de las validaciones del ejercicio-3.sh para reutilizarlo en la API.
es_numero_entero() {
    local valor="$1"
    if [[ "$valor" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Sanitiza strings escapando comillas simples para mitigar inyección SQL básica.
# Se aplica el mismo reemplazo que se usaron en ejercicio-3.sh en línea (ej: ${user//\'/\'\'}).
sanitizar_sql() {
    local entrada="$1"
    echo "${entrada//\'/\'\'}"
}