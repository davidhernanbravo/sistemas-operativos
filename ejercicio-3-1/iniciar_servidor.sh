#!/usr/bin/env bash

# =======================================================================
#  ARCHIVO: iniciar_servidor.sh
#  DESCRIPCIÓN: Punto de entrada principal. Inicializa la base de datos,
#  prepara el entorno CGI y levanta el servidor HTTP local.
# =======================================================================

# 1. Forzamos a que el script se ejecute siempre desde la raíz de ejercicio-3-1.
# Esto evita que las rutas relativas se rompan si ejecutás el script desde otro lado.
cd "$(dirname "${BASH_SOURCE[0]}")" || { echo "Error fatal: No se pudo acceder al directorio del proyecto."; exit 1; }

echo "======================================="
echo " Levantando Sistema de Inventario Web"
echo "======================================="

# 2. Cargamos las constantes globales y la función de conexión a la BD.
# Si estos archivos aún no existen, el script fallará acá (es el comportamiento esperado).
source "./configuracion/parametros.sh"
source "./base_de_datos/conexion.sh"

# 3. Inicializamos la base de datos.
# Esta función (que programaremos en conexion.sh) inyectará esquema.sql si datos.sq3 no existe.
echo "[INFO] Comprobando integridad de la base de datos..."
inicializar_db

# 4. Adaptación para el servidor CGI de Python.
# El módulo http.server --cgi de Python exige por convención técnica que los scripts
# ejecutables estén dentro de un directorio llamado 'cgi-bin'. Como nuestra
# estructura en español la nombra 'api', creamos un enlace simbólico (symlink).
if [[ ! -d "cgi-bin" && ! -L "cgi-bin" ]]; then
    echo "[INFO] Creando enlace simbólico temporal (cgi-bin -> api)..."
    ln -s api cgi-bin
fi

# 5. Puesta en marcha del servidor HTTP.
# Utilizamos el puerto definido en parametros.sh, o el 8080 como respaldo por defecto.
declare puerto="${PUERTO_HTTP:-8080}"

echo "[INFO] Entorno preparado. El servidor HTTP/CGI está en ejecución."
echo "===================================================================================="
echo "👉 Ingresá desde tu navegador a: http://localhost:${puerto}/interfaz_web/index.html"
echo "⏹️  Para apagar el sistema y liberar el puerto, presioná Ctrl+C."
echo "===================================================================================="

# Levantamos el servidor de Python en el puerto asignado.
python3 -m http.server "$puerto" --cgi