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

    # Sanitización previa a la inyección SQL.
    user_seguro=$(sanitizar_sql "$user")

    # Verificación de usuario mediante count en SQLite3.
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
    
    # Uso de la función transversal para el encriptado.
    hash_p=$(generar_hash "$pass")

    # Inserción de usuario en base de datos.
    ejecutar_query "INSERT INTO usuarios (username, hash) VALUES ('$user_seguro', '$hash_p');"
    
    # Retornamos el código de salida del query para que la API sepa si falló.
    return $?
}

modelo_obtener_credenciales() {
    local user="$1"
    local user_seguro
    user_seguro=$(sanitizar_sql "$user")

    # Recuperación de hash e ID desde SQLite3.
    # El output por defecto de SQLite3 separa las columnas con el caracter '|'.
    ejecutar_query "SELECT id, hash FROM usuarios WHERE username='$user_seguro';"
}