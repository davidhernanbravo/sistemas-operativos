#!/usr/bin/env bash

# ==================================================================================
#  ARCHIVO: api/enrutador_cgi.sh
#  DESCRIPCIÓN: Puerta de enlace HTTP (CGI). Recibe peticiones POST del frontend,
#  parsea el JSON entrante y enruta hacia las funciones de la API correspondientes.
# ==================================================================================

# 1. Cabeceras obligatorias para el protocolo HTTP.
# Para que el navegador entienda que le estamos respondiendo con datos (y no con HTML), debemos 
# imprimir el Content-Type seguido obligatoriamente de una línea en blanco.
echo "Content-Type: application/json"
echo ""

# 2. Inclusión de las capas de servicios (APIs).
source "$(dirname "${BASH_SOURCE[0]}")/api_usuarios.sh"
source "$(dirname "${BASH_SOURCE[0]}")/api_productos.sh"

# 3. Lectura del cuerpo (payload) de la petición HTTP.
# En el estándar CGI, los datos enviados por el método POST entran por la entrada estándar (stdin) 
# en lugar de argumentos de terminal.
if [[ "$REQUEST_METHOD" == "POST" ]]; then
    # Leemos exactamente la cantidad de bytes especificada por el servidor HTTP.
    read -n "$CONTENT_LENGTH" payload_json
else
    # Si intentan entrar por la barra de direcciones del navegador (método GET), los rechazamos.
    echo '{"status": "error", "message": "Método HTTP no soportado. La API solo acepta POST."}'
    exit 1
fi

# 4. Función auxiliar para extraer valores del JSON.
# NOTA: Como Bash no parsea JSON nativamente y no queremos obligar a instalar paquetes de terceros 
# (como 'jq'), usamos un micro-script de Python 3 (que ya garantizamos que está en el sistema para 
# el servidor web).
extraer_json() {
    local clave="$1"
    echo "$payload_json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('$clave', ''))
except:
    print('')
"
}

# 5. Extracción de los parámetros de control comunes enviados por el frontend (JS).
accion=$(extraer_json "accion")
user_id=$(extraer_json "user_id")
user_name=$(extraer_json "user_name")

# 6. Enrutador central (Switch-case).
# Dependiendo de la "accion" pedida, derivamos a la función de bash correspondiente.
case "$accion" in
    "registrar_usuario")
        # Extraemos los parámetros específicos de la acción y llamamos a la función de la API.
        user=$(extraer_json "username")
        pass=$(extraer_json "password")
        api_registrar_usuario "$user" "$pass"
        ;;
    "iniciar_sesion")
        user=$(extraer_json "username")
        pass=$(extraer_json "password")
        api_iniciar_sesion "$user" "$pass"
        ;;
    "alta_producto")
        id=$(extraer_json "id")
        nombre=$(extraer_json "nombre")
        precio=$(extraer_json "precio")
        api_alta_producto "$user_id" "$user_name" "$id" "$nombre" "$precio"
        ;;
    "baja_producto")
        id=$(extraer_json "id")
        api_baja_producto "$user_id" "$user_name" "$id"
        ;;
    "editar_producto")
        id=$(extraer_json "id")
        nombre=$(extraer_json "nombre")
        precio=$(extraer_json "precio")
        api_editar_producto "$user_id" "$user_name" "$id" "$nombre" "$precio"
        ;;
    "listar_productos")
        api_listar_productos "$user_id" "$user_name"
        ;;
    "generar_reporte")
        api_generar_reporte "$user_id" "$user_name"
        ;;
    *)
        # Acción desconocida o nula para proteger al backend de requests maliciosos.
        echo '{"status": "error", "message": "Acción de API no válida o ausente."}'
        ;;
esac