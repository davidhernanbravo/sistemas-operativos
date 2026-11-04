#!/usr/bin/env bash

# ==========================================================================
#  ARCHIVO: modelos/modelo_productos.sh
#  DESCRIPCIÓN: Lógica de negocio y persistencia para la entidad Productos.
# ==========================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

modelo_existe_producto() {
    local id="$1"
    local count

    # Verificación de existencia de producto mediante SQLite3.
    count=$(sqlite3 "$DB_FILE" "SELECT count(*) FROM productos WHERE id=$id;" 2>>"$LOG_ERR")
    [[ "$count" -gt 0 ]]
}

modelo_alta_producto() {
    local id="$1"
    local nombre="$2"
    local precio="$3"
    local nombre_seguro
    
    nombre_seguro=$(sanitizar_sql "$nombre")

    # Persistencia usando INSERT en SQLite3.
    sqlite3 "$DB_FILE" "INSERT INTO productos (id, nombre, precio) VALUES ($id, '$nombre_seguro', $precio);" 2>>"$LOG_ERR"
    return $?
}

modelo_baja_producto() {
    local id="$1"
    
    # Eliminación con DELETE en SQLite3.
    sqlite3 "$DB_FILE" "DELETE FROM productos WHERE id=$id;" 2>>"$LOG_ERR"
    return $?
}

modelo_editar_producto() {
    local id="$1"
    local nombre="$2"
    local precio="$3"
    local nombre_seguro
    
    nombre_seguro=$(sanitizar_sql "$nombre")

    # Edición directa con UPDATE en SQLite3.
    sqlite3 "$DB_FILE" "UPDATE productos SET nombre='$nombre_seguro', precio=$precio WHERE id=$id;" 2>>"$LOG_ERR"
    return $?
}

modelo_listar_productos() {
    # Consulta de registros utilizando el delimitador por defecto de SQLite ('|').
    sqlite3 "$DB_FILE" "SELECT id, nombre, precio FROM productos;" 2>>"$LOG_ERR"
}