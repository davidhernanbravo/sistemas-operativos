#!/usr/bin/env bash

# ============================================================================
#  ARCHIVO: interfaz_web/servidor_http.sh
#  DESCRIPCIÓN: Manejador HTTP y Despachador RPC ejecutado por socat.
#               Sirve los archivos web estáticos y procesa llamadas a la API.
# ============================================================================

# 1. Carga de configuración y capa de API.
source "$(dirname "${BASH_SOURCE[0]}")/../configuracion/parametros.sh"
source "${RUTA_BASE}/api/api_usuarios.sh"
source "${RUTA_BASE}/api/api_productos.sh"

# Función auxiliar para enviar respuestas en texto plano al navegador.
responder_texto() {
    local estado_http="$1"
    local tipo_mime="$2"
    local cuerpo="$3"
    local largo_bytes

    # Calculamos el tamaño exacto en bytes para la cabecera Content-Length.
    largo_bytes=$(printf "%s" "$cuerpo" | wc -c)

    printf "HTTP/1.1 %s\r\n" "$estado_http"
    printf "Content-Type: %s; charset=utf-8\r\n" "$tipo_mime"
    printf "Content-Length: %d\r\n" "$largo_bytes"
    printf "Cache-Control: no-store\r\n"
    printf "Connection: close\r\n\r\n"
    printf "%s" "$cuerpo"
}

# Función auxiliar para enviar archivos físicos (HTML, CSS, JS) al navegador.
servir_archivo() {
    local ruta_archivo="$1"
    local tipo_mime="$2"
    local largo_bytes

    if [[ ! -f "$ruta_archivo" ]]; then
        responder_texto "404 Not Found" "text/plain" "Error 404: Archivo no encontrado."
        return 1
    fi

    largo_bytes=$(wc -c < "$ruta_archivo")

    printf "HTTP/1.1 200 OK\r\n"
    printf "Content-Type: %s; charset=utf-8\r\n" "$tipo_mime"
    printf "Content-Length: %d\r\n" "$largo_bytes"
    printf "Cache-Control: no-cache\r\n"
    printf "Connection: close\r\n\r\n"
    cat "$ruta_archivo"
}

# Función principal que traduce la petición web a una llamada nativa en Bash (RPC).
procesar_rpc() {
    local linea_rpc="$1"
    local proc uid uname arg1 arg2 arg3
    local salida estado

    # Separamos los campos recibidos en formato TSV (separados por tabulador).
    IFS=$'\t' read -r proc uid uname arg1 arg2 arg3 <<< "$linea_rpc"

    # Hidratamos las variables globales de sesión para que la auditoría (sistema.log)
    # registre qué usuario está ejecutando la acción en esta petición.
    CURRENT_USER_ID="${uid:--}"
    CURRENT_USER_NAME="${uname:--}"

    # Lista blanca (whitelist) de procedimientos permitidos.
    # Invocamos la función correspondiente de la capa API según el nombre recibido.
    case "$proc" in
        iniciar_sesion)
            salida=$(api_iniciar_sesion "$arg1" "$arg2")
            estado=$?
            ;;
        registrar_usuario)
            salida=$(api_registrar_usuario "$arg1" "$arg2")
            estado=$?
            ;;
        listar_productos)
            salida=$(api_listar_productos)
            estado=$?
            ;;
        alta_producto)
            salida=$(api_alta_producto "$arg1" "$arg2" "$arg3")
            estado=$?
            ;;
        editar_producto)
            salida=$(api_editar_producto "$arg1" "$arg2" "$arg3")
            estado=$?
            ;;
        baja_producto)
            salida=$(api_baja_producto "$arg1")
            estado=$?
            ;;
        generar_reporte)
            salida=$(api_generar_reporte)
            estado=$?
            ;;
        *)
            responder_texto "400 Bad Request" "text/plain" $'ERROR\nProcedimiento RPC no válido.'
            return 1
            ;;
    esac

    # Si la API devolvió 0 (éxito), respondemos con encabezado "OK" seguido de los datos.
    # Si devolvió distinto de 0 (fallo), respondemos con "ERROR" y el mensaje de validación.
    if [[ $estado -eq 0 ]]; then
        responder_texto "200 OK" "text/plain" "$(printf "OK\n%s" "$salida")"
    else
        responder_texto "200 OK" "text/plain" "$(printf "ERROR\n%s" "$salida")"
    fi
}

# ==========================================================
#  FLUJO PRINCIPAL: LECTURA DE LA PETICIÓN HTTP DESDE SOCAT
# ==========================================================

# 2. Leemos la primera línea de la petición HTTP (Ejemplo: GET /index.html HTTP/1.1).
IFS=' ' read -r METODO RUTA VERSION
METODO="${METODO%$'\r'}"
RUTA="${RUTA%$'\r'}"

# 3. Leemos las cabeceras HTTP hasta encontrar una línea vacía.
CONTENT_LENGTH=0
while IFS= read -r linea; do
    linea="${linea%$'\r'}"
    [[ -z "$linea" ]] && break

    # Si es una petición POST, capturamos cuántos bytes trae el cuerpo del mensaje.
    if [[ "${linea,,}" =~ ^content-length:[[:space:]]*([0-9]+) ]]; then
        CONTENT_LENGTH="${BASH_REMATCH[1]}"
    fi
done

# 4. Enrutador de peticiones ( Archivos Estáticos vs Llamadas RPC ).
case "$METODO $RUTA" in
    "GET /"|"GET /index.html")
        servir_archivo "${DIR_WEB}/index.html" "text/html"
        ;;
    "GET /estilos.css")
        servir_archivo "${DIR_WEB}/estilos.css" "text/css"
        ;;
    "GET /cliente_rpc.js")
        servir_archivo "${DIR_WEB}/cliente_rpc.js" "application/javascript"
        ;;
    "GET /reporte")
        servir_archivo "${ARCHIVO_HTML}" "text/html"
        ;;
    "POST /rpc")
        # Leemos la línea de parámetros enviada en el cuerpo de la petición POST.
        CUERPO_RPC=""
        if (( CONTENT_LENGTH > 0 )); then
            IFS= read -r -t 2 CUERPO_RPC
            CUERPO_RPC="${CUERPO_RPC%$'\r'}"
        fi
        procesar_rpc "$CUERPO_RPC"
        ;;
    *)
        responder_texto "404 Not Found" "text/plain" "Error 404: Ruta no encontrada."
        ;;
esac