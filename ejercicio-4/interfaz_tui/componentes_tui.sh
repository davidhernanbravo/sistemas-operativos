#!/usr/bin/env bash

# ======================================================================
#  ARCHIVO: interfaz_tui/componentes_tui.sh
#  DESCRIPCIÓN: Funciones reutilizables (wrappers) para dibujar la TUI.
# ======================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

# Función: Muestra un mensaje en pantalla con un botón "Aceptar".
# Uso: tui_mensaje "Operación exitosa".
tui_mensaje() {
    local texto="$1"
    whiptail --title "$TUI_TITULO" --msgbox "$texto" $TUI_ALTO $TUI_ANCHO
}

# Función: Muestra un cartel de advertencia o error (mismo msgbox, distinto uso lógico).
# Uso: tui_error "Fallo en la BD".
tui_error() {
    local texto="$1"
    whiptail --title "ERROR - $TUI_TITULO" --msgbox "⚠️ $texto" $TUI_ALTO $TUI_ANCHO
}

# Función: Pide un dato por teclado. Devuelve el texto ingresado.
# Uso: nombre=$(tui_input "Ingrese su nombre:").
tui_input() {
    local texto="$1"
    # TRUCO DE DESCRIPTORES:
    # 1. '3>&1' crea un descriptor 3 temporal que apunta adonde apunta stdout (la pantalla).
    # 2. '1>&2' manda stdout a stderr.
    # 3. '2>&3' manda stderr (donde whiptail tira el texto) al stdout original.
    # Resultado: Bash puede capturar el texto escrito por el usuario en una variable.
    whiptail --title "$TUI_TITULO" --inputbox "$texto" $TUI_ALTO $TUI_ANCHO 3>&1 1>&2 2>&3
}

# Función: Pide una contraseña (oculta los caracteres con asteriscos).
# Uso: pass=$(tui_password "Ingrese su clave:").
tui_password() {
    local texto="$1"
    whiptail --title "$TUI_TITULO" --passwordbox "$texto" $TUI_ALTO $TUI_ANCHO 3>&1 1>&2 2>&3
}

# Función: Pregunta por Sí o No.
# Devuelve: Código de salida 0 (Si) o 1 (No).
# Uso: if tui_confirmar "¿Estás seguro?"; then ...
tui_confirmar() {
    local texto="$1"
    whiptail --title "$TUI_TITULO" --yesno "$texto" $TUI_ALTO $TUI_ANCHO
    return $?
}