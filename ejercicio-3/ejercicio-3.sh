#!/usr/bin/env bash

# ============================================================
#  CAMBIOS GLOBALES: Migración a SQLite3 y sistema de Logging
# ============================================================

declare -r DB_FILE="data.sq3"
declare -r LOG_SYS="system.log"
declare -r LOG_ERR="error.log"
declare -r ARCHIVO_HTML="productos.html"

# Variables de sesión para el log del sistema.
CURRENT_USER_ID=""
CURRENT_USER_NAME=""

# CAMBIO REQUISITOS CONSIGNAS 3 y 6: Creación e inicialización de la Base de Datos SQLite3.
inicializar_db() {
    if [[ ! -f "$DB_FILE" ]]; then

        # Se redirigen los errores al error.log.
        sqlite3 "$DB_FILE" <<EOF 2>>"$LOG_ERR"
        CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            hash TEXT NOT NULL
        );
        CREATE TABLE productos (
            id INTEGER PRIMARY KEY,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL
        );
EOF
        if [[ $? -ne 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR CRÍTICO: Fallo al crear la estructura de $DB_FILE" >> "$LOG_ERR"
            echo "Error crítico: No se pudo inicializar la base de datos. Revisar $LOG_ERR" >&2
            exit 1
        fi
    fi
}

# CAMBIO REQUISITO CONSIGNA 5: Registro de auditoría (Log del sistema en TSV).

log_accion() {
    local accion="$1"
    local fecha_hora
    fecha_hora=$(date "+%Y-%m-%d %H:%M:%S")

    # Formato TSV: Fecha/Hora | ID Usuario | Nombre Usuario | Acción.
    printf "%s\t%s\t%s\t%s\n" "$fecha_hora" "${CURRENT_USER_ID:--}" "${CURRENT_USER_NAME:--}" "$accion" >> "$LOG_SYS"
}

# CAMBIO REQUISITO CONSIGNA 6: Registro de errores (Log de errores).

manejar_error() {
    local mensaje="$1"
    local fecha_hora
    fecha_hora=$(date "+%Y-%m-%d %H:%M:%S")
    printf "[%s] ERROR: %s\n" "$fecha_hora" "$mensaje" >> "$LOG_ERR"
    printf "Error: %s (Detalles en %s)\n" "$mensaje" "$LOG_ERR" >&2
}

# Ejecuta query e intercepta errores.
ejecutar_query() {
    local query="$1"
    sqlite3 "$DB_FILE" "$query" 2>>"$LOG_ERR"
}

# ========================================
#  FUNCIONES DE SEGURIDAD Y AUTENTICACIÓN
# ========================================

generar_hash() {
    local password="$1"
    local hash_valor
    hash_valor=$(echo -n "$password" | sha256sum | awk '{print $1}')
    echo "$hash_valor"
}

existe_usuario() {
    local user="$1"
    local count

    # CAMBIO REQUISITO CONSIGNA 4: Verificación de usuario mediante count en SQLite3.
    count=$(ejecutar_query "SELECT count(*) FROM usuarios WHERE username='${user//\'/\'\'}';")
    [[ "$count" -gt 0 ]]
}

registrar_usuario() {
    local user pass hash_p

    read -rp "Ingrese nuevo nombre de usuario: " user
    
    if existe_usuario "$user"; then
        manejar_error "El usuario '$user' ya se encuentra registrado."
        return 1
    fi

    read -rs -p "Ingrese contraseña: " pass
    echo
    
    hash_p=$(generar_hash "$pass")

    # CAMBIO REQUISITO CONSIGNA 4: Inserción de usuario en base de datos.
    if ejecutar_query "INSERT INTO usuarios (username, hash) VALUES ('${user//\'/\'\'}', '$hash_p');"; then
        printf "Usuario registrado exitosamente.\n"
        log_accion "Registro de nuevo usuario: $user"
    else
        manejar_error "Fallo al registrar usuario '$user'."
    fi
}

iniciar_sesion() {
    local user pass hash_p hash_guardado
    local -i intentos=0

    while (( intentos < 3 )); do
        read -rp "Usuario: " user
        read -rs -p "Contraseña: " pass
        echo

        if existe_usuario "$user"; then

            # CAMBIO REQUISITO CONSIGNA 4: Recuperación de hash e ID desde SQLite3.
            local result
            result=$(ejecutar_query "SELECT id, hash FROM usuarios WHERE username='${user//\'/\'\'}';")
            
            local db_id
            local db_hash
            db_id=$(echo "$result" | cut -d'|' -f1)
            db_hash=$(echo "$result" | cut -d'|' -f2)
            
            hash_p=$(generar_hash "$pass")

            if [[ "$hash_p" == "$db_hash" ]]; then

                # Seteamos las variables de sesión para el log system.log.
                CURRENT_USER_ID="$db_id"
                CURRENT_USER_NAME="$user"
                printf "Acceso concedido. Bienvenido %s.\n" "$user"
                log_accion "Inicio de sesión exitoso"
                return 0
            fi
        fi

        intentos=$((intentos + 1))
        printf "Credenciales incorrectas (%d/3 intentos).\n" "$intentos"
        log_accion "Intento de inicio de sesión fallido para usuario: $user"
    done

    return 1
}

# =========================================
#  FUNCIONES DE GESTIÓN DE PRODUCTOS (SQL)
# =========================================

existe_producto() {
    local id="$1"
    local count

    # CAMBIO REQUISITO CONSIGNA 4: Verificación de producto mediante SQLite3.
    count=$(ejecutar_query "SELECT count(*) FROM productos WHERE id=$id;")
    [[ "$count" -gt 0 ]]
}

alta() {
    local id nombre precio

    read -rp "Ingrese ID del producto: " id
    
    # Expresión regular básica para validar que el ID sea numérico.
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        manejar_error "El ID ingresado no es numérico."
        return 1
    fi

    if existe_producto "$id"; then
        manejar_error "El producto con ID $id ya existe."
        return 1
    fi

    read -rp "Ingrese Nombre del producto: " nombre
    read -rp "Ingrese Precio del producto: " precio

    # CAMBIO REQUISITO CONSIGNA 4: Persistencia usando INSERT en SQLite3.
    if ejecutar_query "INSERT INTO productos (id, nombre, precio) VALUES ($id, '${nombre//\'/\'\'}', $precio);"; then
        printf "Producto %s guardado exitosamente.\n" "$id"
        log_accion "Alta de producto ID: $id ($nombre)"
    else
        manejar_error "No se pudo realizar el alta del producto ID $id."
    fi
}

baja() {
    local id
    
    read -rp "Ingrese ID a eliminar: " id

    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        manejar_error "El ID ingresado no es numérico."
        return 1
    fi

    if ! existe_producto "$id"; then
        manejar_error "El producto con ID $id no existe."
        return 1
    fi

    # CAMBIO REQUISITO CONSIGNA 4: Eliminación con DELETE en SQLite3.
    if ejecutar_query "DELETE FROM productos WHERE id=$id;"; then
        printf "Producto %s eliminado de la base de datos.\n" "$id"
        log_accion "Baja de producto ID: $id"
    else
        manejar_error "No se pudo eliminar el producto ID $id."
    fi
}

editar() {
    local id n_nombre n_precio

    read -rp "Ingrese ID a editar: " id
    
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        manejar_error "El ID ingresado no es numérico."
        return 1
    fi

    if ! existe_producto "$id"; then
        manejar_error "El producto con ID $id no existe."
        return 1
    fi

    read -rp "Ingrese nuevo Nombre: " n_nombre
    read -rp "Ingrese nuevo Precio: " n_precio

    # CAMBIO REQUISITO CONSIGNA 4: Edición directa con UPDATE en SQLite3.
    if ejecutar_query "UPDATE productos SET nombre='${n_nombre//\'/\'\'}', precio=$n_precio WHERE id=$id;"; then
        printf "Producto %s actualizado.\n" "$id"
        log_accion "Edición de producto ID: $id"
    else
        manejar_error "No se pudo actualizar el producto ID $id."
    fi
}

mostrar() {
    printf "\nLISTADO DE PRODUCTOS:\n"
    printf "%-10s | %-20s | %-10s\n" "ID" "NOMBRE" "PRECIO"
    printf -- "----------------------------------------------\n"
    
    # CAMBIO REQUISITO CONSIGNA 4: Lectura parseando la query SELECT iterando los registros.
    sqlite3 -separator $'\t' "$DB_FILE" "SELECT id, nombre, precio FROM productos;" 2>>"$LOG_ERR" | while IFS=$'\t' read -r col1 col2 col3; do
        if [[ -n "$col1" ]]; then

            # Cambio requisito consigna 6: Forzar el uso de punto como separador decimal en la salida.
            # printf "%-10s | %-20s | $%-9.2f\n" "$col1" "$col2" "$col3"
            LC_NUMERIC=C printf "%-10s | %-20s | $%-9.2f\n" "$col1" "$col2" "$col3"
            
        fi
    done
    
    log_accion "Consulta de listado de productos"
}

generar_reporte() {
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
        
        # CAMBIO REQUISITO CONSIGNA 4: Extracción desde SQLite3 en lugar del TSV.
        sqlite3 -separator $'\t' "$DB_FILE" "SELECT id, nombre, precio FROM productos;" 2>>"$LOG_ERR" | while IFS=$'\t' read -r col1 col2 col3; do
            if [[ -n "$col1" ]]; then
                echo "        <tr><td>$col1</td><td>$col2</td><td>$col3</td></tr>"
            fi
        done
        
        echo "    </table>"
        echo "</body>"
        echo "</html>"
    } > "$ARCHIVO_HTML"

    if [[ $? -eq 0 ]]; then
        printf "Reporte HTML generado correctamente en: %s\n" "$ARCHIVO_HTML"
        log_accion "Generación de reporte HTML"
    else
        manejar_error "Fallo al escribir el archivo HTML de reporte."
    fi
}

# =======================
#  CONTROLADORES DE MENÚ
# =======================

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
        printf "3. Mostrar inventario\n"
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
                log_accion "Cierre de sesión"
                CURRENT_USER_ID=""
                CURRENT_USER_NAME=""
                break 
                ;;
            *) manejar_error "Opción de menú principal inválida seleccionada." ;;
        esac
    done
}

main() {
    local op_auth
    
    # Inicializamos BD antes de comenzar flujos si no existe.
    inicializar_db

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
            *) manejar_error "Opción de menú de autenticación inválida seleccionada." ;;
        esac
    done
}

main