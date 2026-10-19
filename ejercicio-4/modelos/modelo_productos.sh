#!/usr/bin/env bash

# ==========================================================================
#  ARCHIVO: modelos/modelo_productos.sh
#  DESCRIPCIÓN: Lógica de negocio y persistencia para la entidad Productos.
# ==========================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../base_de_datos/conexion.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

modelo_existe_producto() {
    local id="$1"
    local count

    # Verificación de producto mediante SQLite3.
    count=$(ejecutar_query "SELECT count(*) FROM productos WHERE id=$id;")
    [[ "$count" -gt 0 ]]
}

modelo_alta_producto() {
    local id="$1"
    local nombre="$2"
    local precio="$3"
    local nombre_seguro
    
    nombre_seguro=$(sanitizar_sql "$nombre")

    # Persistencia usando INSERT en SQLite3.
    ejecutar_query "INSERT INTO productos (id, nombre, precio) VALUES ($id, '$nombre_seguro', $precio);"
    return $?
}

modelo_baja_producto() {
    local id="$1"
    
    # Eliminación con DELETE en SQLite3.
    ejecutar_query "DELETE FROM productos WHERE id=$id;"
    return $?
}

modelo_editar_producto() {
    local id="$1"
    local nombre="$2"
    local precio="$3"
    local nombre_seguro
    
    nombre_seguro=$(sanitizar_sql "$nombre")

    # Edición directa con UPDATE en SQLite3.
    ejecutar_query "UPDATE productos SET nombre='$nombre_seguro', precio=$precio WHERE id=$id;"
    return $?
}

modelo_listar_productos() {
    # CAMBIO: Se eliminó el modificador de separador por tabulador.
    # Usaremos el pipe '|' que es el delimitador por defecto de SQLite.
    # Esto facilita armar el array de argumentos que necesita whiptail para mostrar listados de opciones que contienen 
    # espacios en los nombres.
    sqlite3 "$DB_FILE" "SELECT id, nombre, precio FROM productos;" 2>>"$LOG_ERR"
}