#!/usr/bin/env bash

# =======================================================================
#  ARCHIVO: interfaz_tui/vista_acceso.sh
#  DESCRIPCIÓN: Controlador de la pantalla de inicio (Login y Registro).
# =======================================================================

source "$(dirname "${BASH_SOURCE[0]}")/componentes_tui.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../api/api_usuarios.sh"

mostrar_menu_acceso() {
    local opcion
    local msj_api
    # Declaramos las variables locales arriba para evitar enmascarar los códigos de salida.
    local user
    local pass

    # El bucle mantiene al usuario en esta pantalla hasta que inicie sesión o elija salir.
    while true; do
        # whiptail --menu muestra una lista de opciones.
        # Estructura de cada ítem: "TAG" "Descripción".
        opcion=$(whiptail --title "$TUI_TITULO" --menu "Seleccione una opción:" $TUI_ALTO $TUI_ANCHO 4 \
            "1" "Iniciar Sesión" \
            "2" "Registrar Usuario" \
            "3" "Salir del Sistema" \
            3>&1 1>&2 2>&3)

        # Si el usuario presiona "Cancelar" o "ESC", whiptail devuelve un código distinto de cero.
        if [[ $? -ne 0 ]]; then
            break
        fi

        case $opcion in
            1)
                # --- INICIO DE SESIÓN ---
                # CAMBIO: Asignación separada de la declaración para capturar correctamente la cancelación.
                user=$(tui_input "Usuario:")
                # Si el usuario cancela el input, volvemos al menú.
                [[ $? -ne 0 ]] && continue 

                pass=$(tui_password "Contraseña:")
                [[ $? -ne 0 ]] && continue

                # Llamamos a la API. Guardamos el texto que devuelve en msj_api.
                msj_api=$(api_iniciar_sesion "$user" "$pass")
                
                # Evaluamos el código de salida ($?) de la API.
                if [[ $? -eq 0 ]]; then
                    tui_mensaje "$msj_api"
                    # Salimos del bucle con éxito (0) para que iniciar_tui.sh avance al inventario.
                    return 0 
                else
                    tui_error "$msj_api"
                fi
                ;;
            2)
                # --- REGISTRO DE USUARIO ---
                # CAMBIO: Asignación separada de la declaración.
                user=$(tui_input "Nuevo Usuario:")
                [[ $? -ne 0 ]] && continue

                pass=$(tui_password "Nueva Contraseña:")
                [[ $? -ne 0 ]] && continue

                # Llamamos a la API de registro.
                msj_api=$(api_registrar_usuario "$user" "$pass")
                
                if [[ $? -eq 0 ]]; then
                    tui_mensaje "$msj_api"
                else
                    tui_error "$msj_api"
                fi
                ;;
            3)
                # --- SALIR ---
                break
                ;;
        esac
    done

    # Si rompimos el bucle (break), significa que el usuario quiso salir del programa.
    return 1
}