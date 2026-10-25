#!/usr/bin/env bash

# ================================================================================
#  ARCHIVO: api/api_productos.sh
#  DESCRIPCIÓN: Expone los servicios de gestión de productos (RPC / Texto plano).
# ================================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_productos.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

# Cargamos parámetros solo si no fueron cargados previamente en el mismo proceso.
[[ -z "${RUTA_BASE:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

api_alta_producto() {
    # Recibimos los datos del producto. El usuario se toma de las variables de contexto.
    local id="$1"
    local nombre="$2"
    local precio="$3"

    if ! es_numero_entero "$id"; then
        manejar_error "El ID ingresado no es numérico: $id"
        echo "El ID debe ser numérico."
        return 1
    fi

    if [[ -z "$nombre" || -z "$precio" ]]; then
        echo "El nombre y el precio son obligatorios."
        return 1
    fi

    if modelo_existe_producto "$id"; then
        echo "El producto con ID $id ya existe."
        return 1
    fi
    
    if modelo_alta_producto "$id" "$nombre" "$precio"; then
        log_accion "Alta de producto ID: $id ($nombre)" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"
        echo "Producto guardado exitosamente."
        return 0
    else
        echo "Fallo al guardar en la base de datos."
        return 1
    fi
}

api_baja_producto() {
    local id="$1"

    if ! es_numero_entero "$id"; then
        echo "El ID debe ser numérico."
        return 1
    fi

    if ! modelo_existe_producto "$id"; then
        echo "El producto no existe en el sistema."
        return 1
    fi

    if modelo_baja_producto "$id"; then
        log_accion "Baja de producto ID: $id" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"
        echo "Producto eliminado de la base de datos."
        return 0
    else
        echo "Fallo al eliminar el producto."
        return 1
    fi
}

api_editar_producto() {
    local id="$1"
    local n_nombre="$2"
    local n_precio="$3"

    if ! es_numero_entero "$id"; then
        echo "El ID debe ser numérico."
        return 1
    fi

    if [[ -z "$n_nombre" || -z "$n_precio" ]]; then
        echo "El nombre y el precio son obligatorios."
        return 1
    fi

    if ! modelo_existe_producto "$id"; then
        echo "El producto no existe en el sistema."
        return 1
    fi

    if modelo_editar_producto "$id" "$n_nombre" "$n_precio"; then
        log_accion "Edición de producto ID: $id" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"
        echo "Producto actualizado correctamente."
        return 0
    else
        echo "Fallo al actualizar el producto."
        return 1
    fi
}

api_listar_productos() {
    # Registramos la consulta en la bitácora de auditoría.
    log_accion "Consulta de listado de productos" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"

    # Leemos los datos del modelo (separados por '|') y los devolvemos separados por tabulaciones (TSV)
    # para que cualquier cliente (Web/RPC) pueda separar ID, Nombre y Precio fácilmente.
    while IFS='|' read -r col1 col2 col3; do
        if [[ -n "$col1" ]]; then
            printf "%s\t%s\t%s\n" "$col1" "$col2" "$col3"
        fi
    done < <(modelo_listar_productos)
    return 0
}

api_generar_reporte() {
    # Generamos el archivo físico HTML en la carpeta salidas/.
    {
        echo "<!DOCTYPE html><html lang=\"es\"><head><meta charset=\"UTF-8\"><title>Reporte de Productos</title>"
        echo "<style>table { border-collapse: collapse; width: 50%; margin-top: 20px; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style></head>"
        echo "<body><h2>Reporte de Inventario Generado</h2><table><tr><th>ID</th><th>Nombre</th><th>Precio</th></tr>"
        
        while IFS='|' read -r col1 col2 col3; do
            if [[ -n "$col1" ]]; then
                echo "<tr><td>$col1</td><td>$col2</td><td>\$$col3</td></tr>"
            fi
        done < <(modelo_listar_productos)
        
        echo "</table></body></html>"
    } > "$ARCHIVO_HTML"

    if [[ $? -eq 0 ]]; then
        log_accion "Generación de reporte HTML" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"
        echo "Reporte HTML generado exitosamente."
        return 0
    else
        manejar_error "Fallo al escribir el archivo HTML de reporte."
        echo "Fallo de escritura en el sistema de archivos."
        return 1
    fi
}