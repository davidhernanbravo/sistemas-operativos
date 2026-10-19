#!/usr/bin/env bash

# ==========================================================================
#  ARCHIVO: iniciar_tui.sh
#  DESCRIPCIÓN: Punto de entrada principal (Orquestador).
#               Verifica dependencias, inicializa la BD y arranca el ciclo.
# ==========================================================================

# 1. Verificación de dependencias críticas.
# Nos aseguramos de que los paquetes base estén instalados antes de arrancar.
if ! command -v whiptail &> /dev/null; then
    echo "Error crítico: 'whiptail' no está instalado. Instalalo ejecutando: sudo apt install whiptail" >&2
    exit 1
fi

if ! command -v sqlite3 &> /dev/null; then
    echo "Error crítico: 'sqlite3' no está instalado. Instalalo ejecutando: sudo apt install sqlite3" >&2
    exit 1
fi

# 2. Carga de módulos principales.
# Inyectamos el archivo de parámetros, la conexión y las dos vistas que creamos.
source "$(dirname "${BASH_SOURCE[0]}")/configuracion/parametros.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base_de_datos/conexion.sh"
source "$(dirname "${BASH_SOURCE[0]}")/interfaz_tui/vista_acceso.sh"
source "$(dirname "${BASH_SOURCE[0]}")/interfaz_tui/vista_inventario.sh"

# 3. Inicialización de la base de datos.
# Validamos si existe el archivo de la BD y su esquema. Si falla, avisamos por TUI y salimos.
if ! inicializar_db; then
    whiptail --title "Fallo Crítico del Sistema" --msgbox "No se pudo inicializar la base de datos. Revisá registros/errores.log" 10 60
    exit 1
fi

# 4. Bucle principal de la aplicación.
# Este ciclo infinito mantiene el programa vivo aislando los diferentes estados.
while true; do
    # Limpiamos la pantalla por si quedaron restos de comandos anteriores.
    clear
    
    # Invocamos la pantalla de Login/Registro. 
    # Si esta función devuelve 0, significa que el usuario se autenticó correctamente.
    if mostrar_menu_acceso; then
        
        # El usuario está logueado. Le damos el control del menú de inventario.
        # Esa función se quedará en su propio bucle hasta que el usuario decida "Cerrar Sesión".
        mostrar_menu_inventario
        
        # Cuando mostrar_menu_inventario termina (cerró sesión), el ciclo while de este archivo vuelve a iterar, 
        # mandándolo nuevamente a la pantalla de acceso.
        
    else
        # Si mostrar_menu_acceso devuelve algo distinto a 0, significa que el usuario
        # eligió la opción "Salir del Sistema" o presionó ESC.
        clear
        echo "Sistema finalizado correctamente. ¡Hasta luego!"
        exit 0
    fi
done