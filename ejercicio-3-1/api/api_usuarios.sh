#!/usr/bin/env bash

# =================================================================================
#  ARCHIVO: api/api_usuarios.sh
#  DESCRIPCIÓN: Expone los servicios de autenticación devolviendo respuestas JSON.
# =================================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_usuarios.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"

# Función para registrar un nuevo usuario. Devuelve JSON con status y mensaje.
api_registrar_usuario() {
    local user="$1"
    local pass="$2"

    if [[ -z "$user" || -z "$pass" ]]; then
        manejar_error "Intento de registro con campos vacíos."
        echo '{"status": "error", "message": "Usuario y contraseña son obligatorios."}'
        return 1
    fi

    if modelo_existe_usuario "$user"; then
        manejar_error "El usuario '$user' ya se encuentra registrado."
        echo '{"status": "error", "message": "El usuario ya existe."}'
        return 1
    fi

    # Llama al modelo para insertar el usuario.
    if modelo_registrar_usuario "$user" "$pass"; then
        log_accion "Registro de nuevo usuario: $user" "-" "$user"
        echo '{"status": "success", "message": "Usuario registrado exitosamente."}'
        return 0
    else
        manejar_error "Fallo de BD al registrar usuario '$user'."
        echo '{"status": "error", "message": "Error interno del servidor."}'
        return 1
    fi
}

# Función para iniciar sesión. Devuelve JSON con status, mensaje y datos de usuario.
api_iniciar_sesion() {
    local user="$1"
    local pass="$2"
    local hash_p
    local db_result
    local db_id
    local db_hash

    if ! modelo_existe_usuario "$user"; then
        log_accion "Intento de inicio de sesión fallido (usuario inexistente): $user" "-" "-"
        echo '{"status": "error", "message": "Credenciales incorrectas."}'
        return 1
    fi

    # Recupera credenciales y separa los campos.
    db_result=$(modelo_obtener_credenciales "$user")
    db_id=$(echo "$db_result" | cut -d'|' -f1)
    db_hash=$(echo "$db_result" | cut -d'|' -f2)

    hash_p=$(generar_hash "$pass")

    # Validación de hash. Devolvemos los datos para que el frontend mantenga la sesión activa mediante 
    # Javascript (LocalStorage/SessionStorage).
    if [[ "$hash_p" == "$db_hash" ]]; then
        log_accion "Inicio de sesión exitoso" "$db_id" "$user"
        echo "{\"status\": \"success\", \"message\": \"Acceso concedido.\", \"user_id\": \"$db_id\", \"user_name\": \"$user\"}"
        return 0
    else
        log_accion "Intento de inicio de sesión fallido (mala contraseña) para usuario: $user" "-" "$user"
        echo '{"status": "error", "message": "Credenciales incorrectas."}'
        return 1
    fi
}