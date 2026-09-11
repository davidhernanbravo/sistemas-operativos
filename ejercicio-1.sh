#!/usr/bin/env bash

# Configuraciones iniciales.
declare -r -i MAX=3
declare -A inventario

# Constantes del menú actualizadas.
declare -r -i OPCION_ALTA=1
declare -r -i OPCION_BAJA=2
declare -r -i OPCION_MOSTRAR=3
declare -r -i OPCION_EDITAR=4
declare -r -i OPCION_SALIR=5

bienvenida() {
    printf "Bienvenido/a al sistema\n\n"
}

autenticar() {
    declare -i intentos=0
    declare clave=""

    while (( intentos < 3 )); do
        read -rp "Ingrese clave (1234): " clave

        if [[ "$clave" == "1234" ]]; then
            printf "Acceso concedido.\n"
            return 0
        fi

        intentos=$((intentos + 1))
        printf "Clave incorrecta (%d/3 intentos).\n" "$intentos"
    done

    return 1
}

alta() {
    declare -i id=$1
    declare -n prod_ref=$2

    if (( id < 0 || id >= MAX )); then
        printf "Error: ID fuera de rango.\n"
        return
    fi

    inventario[$id,precio]=${prod_ref[precio]}
    inventario[$id,activo]=${prod_ref[activo]}

    printf "Producto %d guardado con precio $%.2f.\n" "$id" "${prod_ref[precio]}"
}

baja() {
    declare -i id=$1

    if (( id < 0 || id >= MAX )); then
        printf "Error: ID fuera de rango.\n"
        return
    fi

    if [[ ${inventario[$id,activo]} -eq 1 ]]; then
        inventario[$id,activo]=0
        printf "Producto %d eliminado.\n" "$id"
    else
        printf "El producto no existe.\n"
    fi
}

# Nueva función incorporada para manejar la lógica de edición.
editar() {
    declare -i id=$1
    declare -n prod_ref=$2

    # Validación de rango
    if (( id < 0 || id >= MAX )); then
        printf "Error: ID fuera de rango.\n"
        return
    fi

    # Verificación de existencia lógica (activo).
    if [[ ${inventario[$id,activo]} -eq 1 ]]; then
        inventario[$id,precio]=${prod_ref[precio]}
        printf "Producto %d actualizado. Nuevo precio: $%.2f.\n" "$id" "${prod_ref[precio]}"
    else
        printf "Error: El producto no existe o fue dado de baja.\n"
    fi
}

mostrar() {
    declare -i i=0

    printf "\nLISTADO:\n"
    for ((i=0; i<MAX; i++)); do
        if [[ ${inventario[$i,activo]} -eq 1 ]]; then
            printf "ID %d : $%.2f\n" "$i" "${inventario[$i,precio]}"
        fi
    done
}

main() {
    declare -i i=0

    # Inicialización del inventario
    for ((i=0; i<MAX; i++)); do
        inventario[$i,activo]=0
        inventario[$i,precio]=0
    done

    bienvenida

    if ! autenticar; then
        printf "\nAcceso denegado.\n"
        return 1
    fi

    declare opcion=0
    declare -i id=0
    declare -A p_temp

    while [[ "$opcion" != "$OPCION_SALIR" ]]; do
        printf "\nACCIONES:\n"
        printf "1. Alta producto (ID 0 a %d)\n" $((MAX - 1))
        printf "2. Baja producto\n"
        printf "3. Mostrar inventario\n"
        printf "4. Editar producto\n"
        printf "5. Salir\n"
        read -rp "Opcion: " opcion

        case $opcion in
            $OPCION_ALTA)
                read -rp "Ingrese ID (0-$((MAX - 1))): " id
                read -rp "Ingrese Precio: " p_temp[precio]
                p_temp[activo]=1
                alta "$id" p_temp
                ;;
            $OPCION_BAJA)
                read -rp "Ingrese ID a eliminar (0-$((MAX - 1))): " id
                baja "$id"
                ;;
            $OPCION_MOSTRAR)
                mostrar
                ;;
            $OPCION_EDITAR)
                # Ingreso de datos para la edición.
                read -rp "Ingrese ID a editar (0-$((MAX - 1))): " id
                read -rp "Ingrese nuevo Precio: " p_temp[precio]
                editar "$id" p_temp
                ;;
            $OPCION_SALIR)
                printf "\nSaliendo del programa...\n"
                ;;
            *)
                printf "\nOpcion invalida.\n"
                ;;
        esac
    done

    return 0
}

main
