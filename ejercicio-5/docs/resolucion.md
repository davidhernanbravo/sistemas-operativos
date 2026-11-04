# 📄 Resolución de Actividad 5

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:**  Arquitectura en Capas e Interfaces Web (RPC) con Bash y SQLite3  
**Alumno:** David Hernán Bravo  

---

## 1. Arquitectura y Decisiones de Diseño

La refactorización del sistema de gestión de inventario para esta iteración demuestra el beneficio del modelo de **Arquitectura en Capas (Layered Architecture)**. Se reemplazó la interfaz de terminal (TUI) por una interfaz completamente Web, reutilizando las capas de Servicio (API), Modelo, Persistencia y Utilidades desarrolladas en la Actividad 4.

Esta copia (`ejercicio-5-prueba/`) incorpora además las observaciones de la corrección de la Actividad 4 que sí corresponden a la versión web. En particular, se eliminó la semántica de "conexión" y la función `ejecutar_query`, dejando que cada modelo invoque `sqlite3` directamente. La observación sobre las variables de sesión no se aplicó porque la Actividad 5 no utiliza TUI; el detalle se encuentra en la sección 2.

### 1.1. Servidor Web Minimalista y Patrón RPC

Para exponer el sistema a la red sin depender de un motor pesado (como Apache o Nginx), se implementó la herramienta `socat`.

* **Despachador CGI (Gateway):** `socat` escucha peticiones HTTP en el puerto 8080 y, mediante la clonación de procesos (`fork`), deriva el flujo de entrada/salida estándar hacia el script `servidor_http.sh`. 
* **Remote Procedure Call (RPC):** A diferencia de una API REST tradicional, se optó por un único endpoint (`POST /rpc`). El cliente web (JavaScript) envía una petición en texto plano con formato TSV (Valores Separados por Tabulaciones) indicando la acción a ejecutar y sus argumentos. El servidor traduce esta petición a una llamada nativa en Bash hacia las funciones de la capa `api/` y retorna el resultado.

### 1.2. Retorno al Paradigma Stateless y Sesión en el Cliente

Al abandonar la ejecución continua del bucle `while` de la interfaz TUI, el servidor vuelve a operar sin estado (*stateless*). 

* Para no perder la trazabilidad exigida por la auditoría (`registros/sistema.log`), la sesión ahora reside en el navegador del usuario mediante `sessionStorage`. 
* En cada petición RPC, el cliente envía su `ID` y `Nombre de Usuario` junto con los datos. El `servidor_http.sh` hidrata las variables globales en memoria (`CURRENT_USER_ID` y `CURRENT_USER_NAME`) justo antes de invocar la API, garantizando que los logs registren correctamente la autoría de cada movimiento.

### 1.3. Seguridad y Aislamiento (DocumentRoot)

El enrutador del `servidor_http.sh` actúa como un estricto `DocumentRoot`. Solo permite servir archivos estáticos (`HTML`, `CSS`, `JS`) ubicados dentro del directorio `interfaz_web/` y el archivo de reporte generado en `salidas/`. Esto previene ataques de *Directory Traversal*, impidiendo que un usuario externo pueda descargar por URL los archivos de la base de datos, contraseñas o registros del sistema.


## 2. Cambios sugeridos por la Cátedra aplicados

Se aplicaron únicamente las observaciones de la corrección que corresponden a la capa de datos.

### 2.1. Renombre de "base_de_datos/conexion.sh"

* Se renombró `base_de_datos/conexion.sh` a `base_de_datos/inicializar.sh`.

* **Motivo:** en Bash no existe una conexión persistente. Cada ejecución de `sqlite3` abre y cierra la base en ese momento puntual.

 El módulo ahora solo se ocupa de inicializar el archivo y el esquema, no de mantener una conexión ni de ejecutar consultas.

* Se actualizó el `source` correspondiente en `ejercicio-5.sh`.

* La función `inicializar_db` conserva su nombre porque describe la inicialización de la base, no una conexión.

### 2.2. Eliminación de "ejecutar_query"

* Se eliminó la función `ejecutar_query` del módulo de base de datos.

* Los modelos `modelo_usuarios.sh` y `modelo_productos.sh` ahora invocan `sqlite3 "$DB_FILE" "..." 2>>"$LOG_ERR"` directamente en cada operación.

* Se conservaron la redirección de errores hacia `registros/errores.log` y los códigos de salida (`return $?`) para que la capa API siga distinguiendo éxito de fallo.

* Los modelos ahora cargan `configuracion/parametros.sh` directamente para obtener `DB_FILE` y `LOG_ERR`, sin depender del módulo de inicialización.

* No se modificó el SQL ni el comportamiento funcional del login, el ABM de productos o la generación del reporte.

### 2.3. Observación no aplicada: variables de sesión

La observación sobre `CURRENT_USER_ID` y `CURRENT_USER_NAME` en `configuracion/parametros.sh` **no se aplicó** en esta versión web:

* No existe un archivo principal de TUI que lance menús con `whiptail`.

* La sesión real se conserva en el navegador mediante `sessionStorage`.

* En el servidor, esas variables son contexto de una petición: `servidor_http.sh` las hidrata antes de invocar la API para que la auditoría registre el usuario.

* El propio profesor indicó que esa observación quedaba sin efecto para la Actividad 5 por ser una interfaz web.

Si en el futuro se quisiera eliminar el estado global, el lugar natural sería `interfaz_web/servidor_http.sh` o el pasaje explícito de `uid` y `uname` como parámetros a la API y a `log_accion`.


## 3. Estructura de Carpetas

```text
📦 sistemas-operativos/
└── 📁 ejercicio-5-prueba/
    ├── 🚀 ejercicio-5.sh                # Punto de entrada: verifica sqlite3 y socat, inicializa la BD y lanza el servidor
    ├── 📁 docs/
    │   ├── 📄 consigna.md               # Transcripción de la consigna de la Actividad 5
    │   └── 📄 resolucion.md             # Documentación de la arquitectura RPC y de los cambios aplicados
    ├── 📁 configuracion/
    │   └── ⚙️ parametros.sh             # Rutas globales y parámetros del servidor Web/RPC
    ├── 📁 interfaz_web/                 # CAPA DE PRESENTACIÓN WEB
    │   ├── 🎯 servidor_http.sh          # Script ejecutado por socat: sirve archivos estáticos y despacha llamadas RPC
    │   ├── 🌐 index.html                # Interfaz gráfica única (Login, Registro y Panel de Inventario)
    │   ├── 🎨 estilos.css               # Diseño visual adaptable (responsive para PC y celular por Wi-Fi)
    │   └── ⚡ cliente_rpc.js            # Lógica cliente: envía peticiones RPC en TSV y actualiza la interfaz
    ├── 📁 api/                          # [IGUAL AL EJERCICIO 5] Servicios de autenticación y productos
    ├── 📁 modelos/                      # [MODIFICADO] sqlite3 directo en cada modelo, sin ejecutar_query
    ├── 📁 base_de_datos/
    │   ├── 🗄️ inicializar.sh            # [RENOMBRADO] Antes conexion.sh; solo inicializa el esquema
    │   ├── 📄 esquema.sql               # Definición de tablas
    │   └── 🗃️ datos.sq3                 # Base de datos SQLite
    ├── 📁 utilidades/                   # [IGUAL AL EJERCICIO 5] Seguridad, hashing y bitácora
    ├── 📁 registros/                    # Logs de auditoría y errores
    └── 📁 salidas/                      # Reporte HTML generado
```


## 4. Instrucciones de Ejecución

Ubicado en la terminal dentro de la carpeta raíz del proyecto (`ejercicio-5-prueba`), ejecutar los siguientes comandos en orden:

```bash
# 1. Asegurar los permisos de ejecución de todos los scripts.
find . -type f -name "*.sh" -exec chmod +x {} +

# 2. Levantar el Servidor Web / RPC (verificará dependencias e inicializará la BD).
./ejercicio-5.sh
```

Una vez en ejecución, la terminal mostrará la URL de acceso local (ej. `http://localhost:8080`) y la IP correspondiente para ingresar desde cualquier otro dispositivo (PC o Celular) conectado a la misma red LAN/Wi-Fi. Para detener el servidor de forma segura, presione `[Ctrl + C]`.