#!/usr/bin/env bash

# =========================================================================
#  ARCHIVO: api/api_usuarios.sh
#  DESCRIPCIÓN: Expone los servicios de autenticación (RPC / Texto plano).
# =========================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_usuarios.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"

# Cargamos parámetros solo si no fueron cargados previamente en el mismo proceso.
[[ -z "${RUTA_BASE:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

api_registrar_usuario() {
    local user="$1"
    local pass="$2"

    # Validamos que no lleguen campos vacíos.
    if [[ -z "$user" || -z "$pass" ]]; then
        manejar_error "Intento de registro con campos vacíos."
        echo "Usuario y contraseña son obligatorios."
        return 1
    fi

    # Verificamos si el usuario ya existe en la base de datos.
    if modelo_existe_usuario "$user"; then
        manejar_error "El usuario '$user' ya se encuentra registrado."
        echo "El usuario ya existe."
        return 1
    fi

    # Registramos el usuario y dejamos constancia en la bitácora.
    if modelo_registrar_usuario "$user" "$pass"; then
        log_accion "Registro de nuevo usuario: $user" "-" "$user"
        echo "Usuario registrado exitosamente."
        return 0
    else
        manejar_error "Fallo de BD al registrar usuario '$user'."
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

    if [[ -z "$user" || -z "$pass" ]]; then
        echo "Debe ingresar usuario y contraseña."
        return 1
    fi

    if ! modelo_existe_usuario "$user"; then
        log_accion "Intento de inicio de sesión fallido (usuario inexistente): $user" "-" "-"
        echo "Credenciales incorrectas."
        return 1
    fi

    # Recuperamos las credenciales guardadas y separamos ID y hash (id|hash).
    db_result=$(modelo_obtener_credenciales "$user")
    db_id=$(echo "$db_result" | cut -d'|' -f1)
    db_hash=$(echo "$db_result" | cut -d'|' -f2)

    hash_p=$(generar_hash "$pass")

    if [[ "$hash_p" == "$db_hash" ]]; then
        log_accion "Inicio de sesión exitoso" "$db_id" "$user"
        
        # Guardamos en variables de contexto y devolvemos ID, Usuario y Mensaje en formato TSV
        # para que el cliente web conserve la sesión y la envíe en las siguientes llamadas RPC.
        CURRENT_USER_ID="$db_id"
        CURRENT_USER_NAME="$user"
        
        printf "%s\t%s\t%s\n" "$db_id" "$user" "Acceso concedido."
        return 0
    else
        log_accion "Intento de inicio de sesión fallido (mala contraseña) para usuario: $user" "-" "$user"
        echo "Credenciales incorrectas."
        return 1
    fi
}