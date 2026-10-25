#!/usr/bin/env bash

# =============================================================================
#  ARCHIVO: ejercicio-5.sh
#  DESCRIPCIÓN: Punto de entrada principal (Orquestador Web/RPC).
#               Verifica dependencias, inicializa la BD y levanta el servidor.
# =============================================================================

# 1. Verificación de dependencias críticas.
# Comprobamos que socat y sqlite3 estén instalados antes de iniciar.
if ! command -v socat &> /dev/null; then
    echo "Error crítico: 'socat' no está instalado. Instalalo ejecutando: sudo apt install socat" >&2
    exit 1
fi

if ! command -v sqlite3 &> /dev/null; then
    echo "Error crítico: 'sqlite3' no está instalado. Instalalo ejecutando: sudo apt install sqlite3" >&2
    exit 1
fi

# 2. Carga de módulos principales.
# Importamos las rutas globales y el módulo de conexión a la base de datos.
source "$(dirname "${BASH_SOURCE[0]}")/configuracion/parametros.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base_de_datos/conexion.sh"

# 3. Verificación del script manejador HTTP/RPC.
# Nos aseguramos de que el script que ejecutará socat exista y tenga permisos de ejecución.
if [[ ! -f "$SCRIPT_SERVIDOR" ]]; then
    echo "Error crítico: No se encuentra el servidor en $SCRIPT_SERVIDOR" >&2
    exit 1
fi
chmod +x "$SCRIPT_SERVIDOR"

# 4. Inicialización de la base de datos.
# Validamos que el archivo SQLite y sus tablas estén listos para operar.
if ! inicializar_db; then
    echo "Fallo Crítico: No se pudo inicializar la base de datos. Revisá registros/errores.log" >&2
    exit 1
fi

# 5. Obtención de la IP de red local (Wi-Fi / LAN).
# Obtenemos la IP privada del equipo para poder acceder desde otros dispositivos.
IP_LOCAL=$(hostname -I | awk '{print $1}')
[[ -z "$IP_LOCAL" ]] && IP_LOCAL="127.0.0.1"

# Capturamos la señal de interrupción (Ctrl+C) para cerrar el servidor prolijamente.
trap 'echo -e "\nServidor detenido correctamente. ¡Hasta luego!"; exit 0' SIGINT SIGTERM

# 6. Puesta en marcha del servidor HTTP/RPC con socat.
clear
echo "=================================================================="
echo "  🌐 SERVIDOR WEB / RPC ACTIVO - GESTOR DE INVENTARIO"
echo "=================================================================="
echo "  👉 Acceso en este equipo:     http://localhost:${PUERTO_HTTP}"
echo "  📱 Acceso en tu red Wi-Fi:    http://${IP_LOCAL}:${PUERTO_HTTP}"
echo "=================================================================="
echo "  Presioná [Ctrl + C] para detener el servidor."
echo ""

# socat escucha en el puerto configurado en todas las interfaces de red.
# Por cada petición entrante, crea un subproceso (fork) y ejecuta servidor_http.sh.
socat TCP-LISTEN:"${PUERTO_HTTP}",reuseaddr,fork EXEC:"${SCRIPT_SERVIDOR}"