#!/usr/bin/env bash

# --- CAMBIOS GLOBALES: Remoción de arreglos en memoria y límite MAX. ---
# --- Se definen constantes para los archivos TSV y HTML ---
declare -r ARCHIVO_PROD="productos.tsv"
declare -r ARCHIVO_USRS="usuarios.tsv"
declare -r ARCHIVO_HTML="productos.html"

# Inicialización de archivos si no existen para evitar errores de lectura
touch "$ARCHIVO_PROD" "$ARCHIVO_USRS"

# ==========================================
# FUNCIONES DE SEGURIDAD Y AUTENTICACIÓN
# ==========================================

# Función para generar hash SHA256 extrayendo solo el hash del output
generar_hash() {
    local password="$1"
    # Redirección a buffer/variable (aplicando dato útil de la consigna)
    local hash_valor=$(echo -n "$password" | sha256sum | awk '{print $1}')
    echo "$hash_valor"
}

# Verificación de existencia de usuario parseando solo la columna 1
existe_usuario() {
    local user="$1"
    awk -F'\t' -v u="$user" '$1==u {f=1; exit} END {if(f) exit 0; else exit 1}' "$ARCHIVO_USRS"
}

registrar_usuario() {
    local user pass hash_p

    read -rp "Ingrese nuevo nombre de usuario: " user
    
    # --- CAMBIO REQ 3: Validar que el usuario no exista previamente ---
    if existe_usuario "$user"; then
        printf "Error: El usuario '%s' ya se encuentra registrado.\n" "$user"
        return 1
    fi

    read -rs -p "Ingrese contraseña: " pass
    echo
    
    # --- CAMBIO REQ 3: Cifrado con sha256sum ---
    hash_p=$(generar_hash "$pass")

    # Escritura en TSV
    printf "%s\t%s\n" "$user" "$hash_p" >> "$ARCHIVO_USRS"
    printf "Usuario registrado exitosamente.\n"
}

iniciar_sesion() {
    local user pass hash_p hash_guardado
    local -i intentos=0

    while (( intentos < 3 )); do
        read -rp "Usuario: " user
        read -rs -p "Contraseña: " pass
        echo

        if existe_usuario "$user"; then
            # Se extrae la columna 2 correspondiente al hash del usuario ingresado
            hash_guardado=$(awk -F'\t' -v u="$user" '$1==u {print $2}' "$ARCHIVO_USRS")
            hash_p=$(generar_hash "$pass")

            if [[ "$hash_p" == "$hash_guardado" ]]; then
                printf "Acceso concedido. Bienvenido %s.\n" "$user"
                return 0
            fi
        fi

        intentos=$((intentos + 1))
        printf "Credenciales incorrectas (%d/3 intentos).\n" "$intentos"
    done

    return 1
}

# ==========================================
# FUNCIONES DE GESTIÓN DE PRODUCTOS (TSV)
# ==========================================

# Verifica si el ID existe analizando estrictamente la columna 1
existe_producto() {
    local id="$1"
    awk -F'\t' -v id="$id" '$1==id {f=1; exit} END {if(f) exit 0; else exit 1}' "$ARCHIVO_PROD"
}

alta() {
    local id nombre precio

    read -rp "Ingrese ID del producto: " id
    
    # --- CAMBIO REQ 2: Validación de no agregar producto existente ---
    if existe_producto "$id"; then
        printf "Error: El producto con ID %s ya existe.\n" "$id"
        return 1
    fi

    # Se agrega campo de nombre al input
    read -rp "Ingrese Nombre del producto: " nombre
    read -rp "Ingrese Precio del producto: " precio

    # --- CAMBIO REQ 2: Persistencia en TSV ---
    printf "%s\t%s\t%s\n" "$id" "$nombre" "$precio" >> "$ARCHIVO_PROD"
    printf "Producto %s guardado exitosamente en %s.\n" "$id" "$ARCHIVO_PROD"
}

baja() {
    local id
    
    read -rp "Ingrese ID a eliminar: " id

    if ! existe_producto "$id"; then
        printf "Error: El producto con ID %s no existe.\n" "$id"
        return 1
    fi

    # --- CAMBIO REQ 2: Eliminación filtrando mediante awk hacia un temporal y reemplazando ---
    awk -F'\t' -v id="$id" '$1!=id' "$ARCHIVO_PROD" > "${ARCHIVO_PROD}.tmp"
    mv "${ARCHIVO_PROD}.tmp" "$ARCHIVO_PROD"
    printf "Producto %s eliminado de %s.\n" "$id" "$ARCHIVO_PROD"
}

editar() {
    local id n_nombre n_precio

    read -rp "Ingrese ID a editar: " id
    
    if ! existe_producto "$id"; then
        printf "Error: El producto con ID %s no existe.\n" "$id"
        return 1
    fi

    read -rp "Ingrese nuevo Nombre: " n_nombre
    read -rp "Ingrese nuevo Precio: " n_precio

    # --- CAMBIO REQ 2: Edición actualizando directamente la fila en el TSV ---
    awk -F'\t' -v OFS='\t' -v id="$id" -v nom="$n_nombre" -v prec="$n_precio" '
        $1 == id { print id, nom, prec; next }
        { print $0 }
    ' "$ARCHIVO_PROD" > "${ARCHIVO_PROD}.tmp"
    mv "${ARCHIVO_PROD}.tmp" "$ARCHIVO_PROD"

    printf "Producto %s actualizado en %s.\n" "$id" "$ARCHIVO_PROD"
}

mostrar() {
    printf "\nLISTADO DE PRODUCTOS:\n"
    printf "%-10s | %-20s | %-10s\n" "ID" "NOMBRE" "PRECIO"
    printf -- "----------------------------------------------\n"
    
    # --- CAMBIO REQ 2: Listado dinámico parseando archivo TSV según muestra de cátedra ---
    while IFS=$'\t' read -r col1 col2 col3; do
        if [[ -n "$col1" ]]; then
            printf "%-10s | %-20s | $%-9.2f\n" "$col1" "$col2" "$col3"
        fi
    done < "$ARCHIVO_PROD"
}

generar_reporte() {
    # --- CAMBIO REQ 1: Generación de tabla en archivo .html ---
    # Redireccionamiento de bloque para inyectar todo el output al archivo
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"es\">"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <title>Reporte de Productos</title>"
        echo "    <style>"
        echo "        table { border-collapse: collapse; width: 50%; }"
        echo "        th, td { border: 1px solid black; padding: 8px; text-align: left; }"
        echo "        th { background-color: #f2f2f2; }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <h2>Reporte de Inventario</h2>"
        echo "    <table>"
        echo "        <tr><th>ID</th><th>Nombre</th><th>Precio</th></tr>"
        
        while IFS=$'\t' read -r col1 col2 col3; do
            if [[ -n "$col1" ]]; then
                echo "        <tr><td>$col1</td><td>$col2</td><td>$col3</td></tr>"
            fi
        done < "$ARCHIVO_PROD"
        
        echo "    </table>"
        echo "</body>"
        echo "</html>"
    } > "$ARCHIVO_HTML"

    printf "Reporte HTML generado correctamente en: %s\n" "$ARCHIVO_HTML"
}

# ==========================================
# CONTROLADORES DE MENÚ
# ==========================================

menu_principal() {
    local opcion
    declare -r -i OPC_ALTA=1
    declare -r -i OPC_BAJA=2
    declare -r -i OPC_MOSTRAR=3
    declare -r -i OPC_EDITAR=4
    declare -r -i OPC_REPORTE=5
    declare -r -i OPC_SALIR=6

    while true; do
        printf "\nGESTIÓN DE INVENTARIO:\n"
        printf "1. Alta de producto\n"
        printf "2. Baja de producto\n"
        printf "3. Mostrar inventario (TSV)\n"
        printf "4. Editar producto\n"
        printf "5. Generar reporte (HTML)\n"
        printf "6. Cerrar sesión\n"
        read -rp "Opción: " opcion

        case $opcion in
            $OPC_ALTA) alta ;;
            $OPC_BAJA) baja ;;
            $OPC_MOSTRAR) mostrar ;;
            $OPC_EDITAR) editar ;;
            $OPC_REPORTE) generar_reporte ;;
            $OPC_SALIR) 
                printf "\nCerrando sesión del sistema...\n"
                break 
                ;;
            *) printf "\nOpción inválida.\n" ;;
        esac
    done
}

main() {
    local op_auth
    
    # --- CAMBIO REQ 3: Menú de entrada para autenticación/registro ---
    while true; do
        printf "\nSISTEMA DE AUTENTICACIÓN\n"
        printf "1. Iniciar sesión\n"
        printf "2. Registrar usuario\n"
        printf "3. Salir del sistema\n"
        read -rp "Opción: " op_auth

        case $op_auth in
            1) 
                if iniciar_sesion; then
                    menu_principal
                fi
                ;;
            2) registrar_usuario ;;
            3) 
                printf "\nFinalizando ejecución. ¡Hasta luego!\n"
                exit 0 
                ;;
            *) printf "Opción inválida.\n" ;;
        esac
    done
}

main