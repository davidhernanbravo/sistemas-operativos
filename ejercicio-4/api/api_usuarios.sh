#!/usr/bin/env bash

# ===================================================================================
#  ARCHIVO: api/api_usuarios.sh
#  DESCRIPCIÓN: Expone los servicios de autenticación devolviendo texto plano (TUI).
# ===================================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_usuarios.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"
# Importamos parámetros para tener acceso a las variables globales de sesión.
source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

api_registrar_usuario() {
    local user="$1"
    local pass="$2"

    if [[ -z "$user" || -z "$pass" ]]; then
        manejar_error "Intento de registro con campos vacíos."
        # CAMBIO: Eliminamos el JSON. Devolvemos texto plano para whiptail.
        echo "Usuario y contraseña son obligatorios."
        return 1
    fi

    if modelo_existe_usuario "$user"; then
        manejar_error "El usuario '$user' ya se encuentra registrado."
        # CAMBIO: Eliminamos el JSON.
        echo "El usuario ya existe."
        return 1
    fi

    if modelo_registrar_usuario "$user" "$pass"; then
        log_accion "Registro de nuevo usuario: $user" "-" "$user"
        # CAMBIO: Eliminamos el JSON.
        echo "Usuario registrado exitosamente."
        return 0
    else
        manejar_error "Fallo de BD al registrar usuario '$user'."
        # CAMBIO: Eliminamos el JSON.
        echo "Error interno del sistema."
        return 1
    fi
}

api_iniciar_sesion() {
    local user="$1"
    local pass="$2"
    local hash_p
    local db_result
    local db_id
    local db_hash

    if ! modelo_existe_usuario "$user"; then
        log_accion "Intento de inicio de sesión fallido (usuario inexistente): $user" "-" "-"
        echo "Credenciales incorrectas."
        return 1
    fi

    # Recupera credenciales y separa los campos (id|hash).
    db_result=$(modelo_obtener_credenciales "$user")
    db_id=$(echo "$db_result" | cut -d'|' -f1)
    db_hash=$(echo "$db_result" | cut -d'|' -f2)

    hash_p=$(generar_hash "$pass")

    if [[ "$hash_p" == "$db_hash" ]]; then
        log_accion "Inicio de sesión exitoso" "$db_id" "$user"
        
        # CAMBIO CRÍTICO: Pasamos a un modelo stateful. Seteamos las variables globales de memoria.
        CURRENT_USER_ID="$db_id"
        CURRENT_USER_NAME="$user"
        
        echo "Acceso concedido."
        return 0
    else
        log_accion "Intento de inicio de sesión fallido (mala contraseña) para usuario: $user" "-" "$user"
        # CAMBIO: Eliminamos el JSON.
        echo "Credenciales incorrectas."
        return 1
    fi
}