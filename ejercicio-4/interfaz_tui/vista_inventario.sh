#!/usr/bin/env bash

# ============================================================================
#  ARCHIVO: interfaz_tui/vista_inventario.sh
#  DESCRIPCIÓN: Controlador del menú principal (ABM de Productos y Reportes).
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/componentes_tui.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../api/api_productos.sh"

mostrar_menu_inventario() {
    local opcion
    local msj_api

    while true; do
        # Mostramos en el título el nombre del usuario logueado usando la variable global.
        opcion=$(whiptail --title "Panel - Usuario: $CURRENT_USER_NAME" --menu "Gestión de Inventario:" $TUI_ALTO $TUI_ANCHO 6 \
            "1" "Alta de Producto" \
            "2" "Baja de Producto" \
            "3" "Editar Producto" \
            "4" "Listar Productos" \
            "5" "Generar Reporte HTML" \
            "6" "Cerrar Sesión" \
            3>&1 1>&2 2>&3)

        if [[ $? -ne 0 ]]; then
            # Si presiona ESC o Cancelar en el menú principal, preguntamos antes de cerrar la sesión.
            if tui_confirmar "¿Desea cerrar la sesión?"; then
                break
            else
                continue
            fi
        fi

        case $opcion in
            1)
                # --- ALTA ---
                local id=$(tui_input "Ingrese ID (numérico):")
                [[ $? -ne 0 ]] && continue

                local nombre=$(tui_input "Ingrese Nombre del producto:")
                [[ $? -ne 0 ]] && continue

                local precio=$(tui_input "Ingrese Precio:")
                [[ $? -ne 0 ]] && continue

                # Llamamos a la API y evaluamos el código de error.
                msj_api=$(api_alta_producto "$id" "$nombre" "$precio")
                if [[ $? -eq 0 ]]; then
                    tui_mensaje "$msj_api"
                else
                    tui_error "$msj_api"
                fi
                ;;
            2)
                # --- BAJA ---
                local id=$(tui_input "Ingrese el ID del producto a ELIMINAR:")
                [[ $? -ne 0 ]] && continue

                # Pedimos confirmación extra por seguridad.
                if tui_confirmar "¿Está seguro de eliminar el producto $id?"; then
                    msj_api=$(api_baja_producto "$id")
                    if [[ $? -eq 0 ]]; then
                        tui_mensaje "$msj_api"
                    else
                        tui_error "$msj_api"
                    fi
                fi
                ;;
            3)
                # --- EDICIÓN ---
                local id=$(tui_input "Ingrese el ID del producto a EDITAR:")
                [[ $? -ne 0 ]] && continue

                local nombre=$(tui_input "Ingrese el nuevo Nombre:")
                [[ $? -ne 0 ]] && continue

                local precio=$(tui_input "Ingrese el nuevo Precio:")
                [[ $? -ne 0 ]] && continue

                msj_api=$(api_editar_producto "$id" "$nombre" "$precio")
                if [[ $? -eq 0 ]]; then
                    tui_mensaje "$msj_api"
                else
                    tui_error "$msj_api"
                fi
                ;;
            4)
                # --- LISTAR ---
                # mapfile (-t saca los saltos de línea) toma el texto impreso por la API y lo guarda elemento por elemento 
                # en un array (opciones_menu).
                local opciones_menu=()
                mapfile -t opciones_menu < <(api_listar_productos)

                if [[ ${#opciones_menu[@]} -eq 0 ]]; then
                    tui_mensaje "El inventario está vacío."
                else
                    # Le pasamos el array expandido a whiptail.
                    # El '--' indica a whiptail que ahí terminan los parámetros de configuración y empiezan los items.
                    whiptail --title "Listado de Productos" --menu "Seleccione para volver:" $TUI_ALTO $TUI_ANCHO 10 \
                        -- "${opciones_menu[@]}" 3>&1 1>&2 2>&3
                fi
                ;;
            5)
                # --- REPORTE ---
                msj_api=$(api_generar_reporte)
                if [[ $? -eq 0 ]]; then
                    tui_mensaje "$msj_api"
                else
                    tui_error "$msj_api"
                fi
                ;;
            6)
                # --- CERRAR SESIÓN ---
                break
                ;;
        esac
    done

    # Al salir, limpiamos las credenciales en memoria por seguridad.
    CURRENT_USER_ID=""
    CURRENT_USER_NAME=""
    return 0
}