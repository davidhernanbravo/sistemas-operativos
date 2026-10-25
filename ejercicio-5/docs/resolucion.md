# 📄 Resolución de Actividad 5

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:**  Arquitectura en Capas e Interfaces Web (RPC) con Bash y SQLite3  
**Alumno:** David Hernán Bravo  

---

## 1. Arquitectura y Decisiones de Diseño

La refactorización del sistema de gestión de inventario para esta iteración demuestra el máximo beneficio del modelo de **Arquitectura en Capas (Layered Architecture)**. Se reemplazó la interfaz de terminal (TUI) por una interfaz completamente Web, logrando reciclar el 100% de las capas de Servicio (API), Modelo, Persistencia y Utilidades desarrolladas en la Actividad 4, sin alterar su código fuente estructural.

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


## 2. Estructura de Carpetas

```text
📦 sistemas-operativos/
└── 📁 ejercicio-5/
    ├── 🚀 ejercicio-5.sh                # [MODIFICADO] Punto de entrada: verifica sqlite3 y socat, inicia BD y lanza el servidor
    ├── 📁 docs/
    │   ├── 📄 consigna.md               # [NUEVO] Transcripción de la consigna de la Actividad 5
    │   └── 📄 resolucion.md             # [NUEVO] Documentación de la arquitectura RPC con socat
    ├── 📁 configuracion/
    │   └── ⚙️ parametros.sh             # [MODIFICADO] Conserva rutas globales y cambia dimensiones whiptail por PUERTO_HTTP
    ├── 📁 interfaz_web/                 # [NUEVA CAPA DE PRESENTACIÓN WEB]
    │   ├── 🎯 servidor_http.sh          # [NUEVO] Script ejecutado por socat: sirve archivos estáticos y despacha llamadas RPC
    │   ├── 🌐 index.html                # [NUEVO] Interfaz gráfica única (Login, Registro y Panel de Inventario)
    │   ├── 🎨 estilos.css               # [NUEVO] Diseño visual adaptable (responsive para PC y celular por Wi-Fi)
    │   └── ⚡ cliente_rpc.js            # [NUEVO] Lógica cliente: envía peticiones RPC en TSV y actualiza la interfaz
    ├── 📁 api/                          # [IGUAL AL EJERCICIO 4]
    ├── 📁 modelos/                      # [IGUAL AL EJERCICIO 4]
    ├── 📁 base_de_datos/                # [IGUAL AL EJERCICIO 4]
    ├── 📁 utilidades/                   # [IGUAL AL EJERCICIO 4]
    ├── 📁 registros/                    # [IGUAL AL EJERCICIO 4]
    └── 📁 salidas/                      # [IGUAL AL EJERCICIO 4]
```

## 3. Instrucciones de Ejecución

Ubicado en la terminal dentro de la carpeta raíz del proyecto (`ejercicio-5`), ejecutar los siguientes comandos en orden:

```bash
# 1. Asegurar los permisos de ejecución de todos los scripts.
find . -type f -name "*.sh" -exec chmod +x {} +

# 2. Levantar el Servidor Web / RPC (verificará dependencias e inicializará la BD).
./ejercicio-5.sh
```

Una vez en ejecución, la terminal mostrará la URL de acceso local (ej. `http://localhost:8080`) y la IP correspondiente para ingresar desde cualquier otro dispositivo (PC o Celular) conectado a la misma red LAN/Wi-Fi. Para detener el servidor de forma segura, presione `[Ctrl + C]`.