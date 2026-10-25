#!/usr/bin/env bash

# =============================================================================
#  ARCHIVO: api/api_productos.sh
#  DESCRIPCIÓN: Expone los servicios de gestión devolviendo texto plano (TUI).
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../modelos/modelo_productos.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/bitacora.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utilidades/seguridad.sh"

# Importamos parámetros para tener acceso a las variables globales de sesión.
source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"

api_alta_producto() {
    # Usamos CURRENT_USER_ID y CURRENT_USER_NAME.
    local id="$1"
    local nombre="$2"
    local precio="$3"

    if ! es_numero_entero "$id"; then
        manejar_error "El ID ingresado no es numérico: $id"
        # Salida en texto plano.
        echo "El ID debe ser numérico."
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
    # Construimos una lista de argumentos compatible con la estructura requerida por el 
    # componente --menu de whiptail.
    log_accion "Consulta de listado de productos" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"

    # Leemos con IFS='|' porque cambiamos el delimitador en modelo_productos.sh.
    while IFS='|' read -r col1 col2 col3; do
        if [[ -n "$col1" ]]; then
            # Imprimimos ID y Descripción separados por un espacio para que whiptail los tome como TAG y ITEM_DESC respectivamente.
            echo "$col1"
            echo "$col2 - \$$col3"
        fi
    done < <(modelo_listar_productos)
}

api_generar_reporte() {
    # Generación estática de archivo físico HTML.
    {
        echo "<!DOCTYPE html><html lang=\"es\"><head><meta charset=\"UTF-8\"><title>Reporte de Productos</title>"
        echo "<style>table { border-collapse: collapse; width: 50%; margin-top: 20px; } th, td { border: 1px solid black; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style></head>"
        echo "<body><h2>Reporte de Inventario Generado</h2><table><tr><th>ID</th><th>Nombre</th><th>Precio</th></tr>"
        
        # Leemos con IFS='|' para compatibilidad con SQLite por defecto.
        while IFS='|' read -r col1 col2 col3; do
            if [[ -n "$col1" ]]; then
                echo "<tr><td>$col1</td><td>$col2</td><td>$col3</td></tr>"
            fi
        done < <(modelo_listar_productos)
        
        echo "</table></body></html>"
    } > "$ARCHIVO_HTML"

    if [[ $? -eq 0 ]]; then
        log_accion "Generación de reporte HTML" "$CURRENT_USER_ID" "$CURRENT_USER_NAME"
        # Retornamos texto plano con la ruta final.
        echo "Reporte HTML generado exitosamente en: $ARCHIVO_HTML"
        return 0
    else
        manejar_error "Fallo al escribir el archivo HTML de reporte."
        echo "Fallo de escritura en el sistema de archivos."
        return 1
    fi
}