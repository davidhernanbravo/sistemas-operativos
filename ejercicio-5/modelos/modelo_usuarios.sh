#!/usr/bin/env bash

# =========================================================================
#  ARCHIVO: modelos/modelo_usuarios.sh
#  DESCRIPCIÓN: Lógica de negocio y persistencia para la entidad Usuarios.
# =========================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../base_de_datos/conexion.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

modelo_existe_usuario() {
    local user="$1"
    local user_seguro
    local count

    # Sanitización previa para prevenir inyección SQL.
    user_seguro=$(sanitizar_sql "$user")

    # Verificación de existencia del usuario mediante conteo en SQLite3.
    count=$(ejecutar_query "SELECT count(*) FROM usuarios WHERE username='$user_seguro';")
    
    # Retorna éxito (0) si existe, error (1) si no existe.
    [[ "$count" -gt 0 ]]
}

modelo_registrar_usuario() {
    local user="$1"
    local pass="$2"
    local user_seguro
    local hash_p
    
    user_seguro=$(sanitizar_sql "$user")
    
    # Generación del hash criptográfico (SHA-256) de la contraseña.
    hash_p=$(generar_hash "$pass")

    # Inserción del nuevo usuario en la base de datos.
    ejecutar_query "INSERT INTO usuarios (username, hash) VALUES ('$user_seguro', '$hash_p');"
    
    # Retorna el código de salida de la consulta hacia la capa de API.
    return $?
}

modelo_obtener_credenciales() {
    local user="$1"
    local user_seguro
    user_seguro=$(sanitizar_sql "$user")

    # Recuperación de ID y hash desde SQLite3 (columnas separadas por '|').
    ejecutar_query "SELECT id, hash FROM usuarios WHERE username='$user_seguro';"
}