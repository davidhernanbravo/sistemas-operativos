#!/usr/bin/env bash

# ========================================================================
#  ARCHIVO: api/api_productos.sh
#  DESCRIPCIÓN: Expone los servicios de gestión de inventario y reportes.
# ========================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_productos.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

api_alta_producto() {
    # Recibimos credenciales de sesión inyectadas por el enrutador desde el frontend.
    local user_id="$1"
    local user_name="$2"
    local id="$3"
    local nombre="$4"
    local precio="$5"

    # Validación de formato delegada a utilidades.
    if ! es_numero_entero "$id"; then
        manejar_error "El ID ingresado no es numérico: $id"
        echo '{"status": "error", "message": "El ID debe ser numérico."}'
        return 1
    fi

    # Validación de existencia del producto antes de intentar insertarlo.
    if modelo_existe_producto "$id"; then
        echo '{"status": "error", "message": "El producto con ID '"$id"' ya existe."}'
        return 1
    fi
    
    # Llamada al modelo para insertar el producto. Se registra la acción en la bitácora.
    if modelo_alta_producto "$id" "$nombre" "$precio"; then
        log_accion "Alta de producto ID: $id ($nombre)" "$user_id" "$user_name"
        echo '{"status": "success", "message": "Producto guardado exitosamente."}'
        return 0
    else
        echo '{"status": "error", "message": "Fallo al guardar en la base de datos."}'
        return 1
    fi
}

# Función para dar de baja un producto. Devuelve JSON con status y mensaje.
api_baja_producto() {
    local user_id="$1"
    local user_name="$2"
    local id="$3"

    if ! es_numero_entero "$id"; then
        echo '{"status": "error", "message": "El ID debe ser numérico."}'
        return 1
    fi

    if ! modelo_existe_producto "$id"; then
        echo '{"status": "error", "message": "El producto no existe."}'
        return 1
    fi

    if modelo_baja_producto "$id"; then
        log_accion "Baja de producto ID: $id" "$user_id" "$user_name"
        echo '{"status": "success", "message": "Producto eliminado de la base de datos."}'
        return 0
    else
        echo '{"status": "error", "message": "Fallo al eliminar el producto."}'
        return 1
    fi
}

# Función para editar un producto existente. Devuelve JSON con status y mensaje.
api_editar_producto() {
    local user_id="$1"
    local user_name="$2"
    local id="$3"
    local n_nombre="$4"
    local n_precio="$5"

    if ! es_numero_entero "$id"; then
        echo '{"status": "error", "message": "El ID debe ser numérico."}'
        return 1
    fi

    if ! modelo_existe_producto "$id"; then
        echo '{"status": "error", "message": "El producto no existe."}'
        return 1
    fi

    if modelo_editar_producto "$id" "$n_nombre" "$n_precio"; then
        log_accion "Edición de producto ID: $id" "$user_id" "$user_name"
        echo '{"status": "success", "message": "Producto actualizado correctamente."}'
        return 0
    else
        echo '{"status": "error", "message": "Fallo al actualizar el producto."}'
        return 1
    fi
}

# Función para listar todos los productos. Devuelve JSON con status y arreglo de productos.
api_listar_productos() {
    local user_id="$1"
    local user_name="$2"
    local json_array="["
    local first=true

    log_accion "Consulta de listado de productos" "$user_id" "$user_name"

    # Procesamos la salida TSV del modelo y la transformamos en un arreglo JSON para que la tabla HTML 
    # pueda ser construida dinámicamente con Javascript.
    while IFS=$'\t' read -r col1 col2 col3; do
        if [[ -n "$col1" ]]; then
            if [ "$first" = true ]; then
                first=false
            else
                json_array+=","
            fi
            json_array+="{\"id\": $col1, \"nombre\": \"$col2\", \"precio\": $col3}"
        fi
    done < <(modelo_listar_productos)

    json_array+="]"
    echo "{\"status\": \"success\", \"data\": $json_array}"
}

# Función para generar un reporte HTML de productos. Devuelve JSON con status y mensaje.
api_generar_reporte() {
    local user_id="$1"
    local user_name="$2"
    
    # Generación estática de archivo físico HTML.
    {
        echo "<!DOCTYPE html><html lang=\"es\"><head><meta charset=\"UTF-8\"><title>Reporte de Productos</title>"
        echo "<style>table { border-collapse: collapse; width: 50%; margin-top: 20px; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style></head>"
        echo "<body><h2>Reporte de Inventario Generado</h2><table><tr><th>ID</th><th>Nombre</th><th>Precio</th></tr>"
        
        while IFS=$'\t' read -r col1 col2 col3; do
            if [[ -n "$col1" ]]; then
                echo "<tr><td>$col1</td><td>$col2</td><td>$col3</td></tr>"
            fi
        done < <(modelo_listar_productos)
        
        echo "</table></body></html>"
    } > "$ARCHIVO_HTML"

    if [[ $? -eq 0 ]]; then
        log_accion "Generación de reporte HTML" "$user_id" "$user_name"
        # Devolvemos la ruta relativa para que el frontend ofrezca un link de descarga/visualización.
        echo '{"status": "success", "message": "Reporte HTML generado.", "url": "../salidas/reporte_productos.html"}'
    else
        manejar_error "Fallo al escribir el archivo HTML de reporte."
        echo '{"status": "error", "message": "Fallo de escritura en el servidor."}'
    fi
}