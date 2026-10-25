# 📄 Resolución de Actividad 4

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:**  Arquitectura en Capas e Interfaces TUI con Bash y SQLite3  
**Alumno:** David Hernán Bravo  

---

## 1. Arquitectura y Decisiones de Diseño

La refactorización del sistema de gestión de inventario evoluciona el modelo de **Arquitectura en Capas (Layered Architecture)**, reemplazando la interfaz web de la iteración anterior por una Interfaz de Usuario de Texto (TUI) basada en `whiptail`. Este cambio demuestra el correcto desacoplamiento del sistema, ya que las capas de Modelo, Persistencia y Utilidades se mantuvieron intactas.

### 1.1. Interfaz TUI y Cambio de Paradigma de Estado

Se descartó la arquitectura Cliente-Servidor (CGI/HTTP) en favor de un proceso interactivo local en consola. 

* **De Stateless a Stateful:** A diferencia del modelo web donde la sesión se delegaba al navegador, el entorno TUI mantiene el script en ejecución continua mediante bucles `while` infinitos. Las credenciales de sesión se preservan en variables globales en memoria (`CURRENT_USER_ID` y `CURRENT_USER_NAME`) garantizando la trazabilidad ininterrumpida en la bitácora de auditoría (`sistema.log`).

* **Wrappers Visuales:** Para evitar la repetición de código y abstraer la complejidad de la herramienta `whiptail` (como la redirección inversa de descriptores de archivos `3>&1 1>&2 2>&3`), se implementó un módulo de componentes reutilizables (`componentes_tui.sh`).

### 1.2. Separación de Responsabilidades (SoC)

La estructura modularizada refleja la siguiente distribución de responsabilidades:  

* **Presentación (TUI):** Las vistas (`vista_acceso.sh` y `vista_inventario.sh`) actúan como controladores de interfaz pura. Capturan eventos del usuario y muestran alertas, delegando toda validación lógica a la API.

* **Servicio (API):** Los scripts en `api/` fueron desacoplados de la web (eliminación de JSON y cabeceras HTTP). Ahora operan mediante comunicación nativa en Bash, retornando códigos de salida estándar (`return 0` o `1`) y texto plano.

* **Modelo y Persistencia:** Se conservaron las capas `modelos/` y `base_de_datos/` sin modificaciones lógicas estructurales, reafirmando que las reglas de negocio y transacciones SQL son agnósticas a la vista.


## 2. Estructura de Carpetas

```
📦 sistemas-operativos/
└── 📁 ejercicio-4/
    ├── 🚀 ejercicio-4.sh                # Nuevo punto de entrada: verifica dependencias, inicializa BD y lanza la TUI
    ├── 📁 docs/
    │   ├── 📄 consigna.md
    │   └── 📄 resolucion.md
    ├── 📁 configuracion/
    │   └── ⚙️ parametros.sh             # Rutas globales y dimensiones estándar de ventanas whiptail
    ├── 📁 interfaz_tui/                 # NUEVA CAPA DE PRESENTACIÓN
    │   ├── 🖥️ componentes_tui.sh        # Wrappers reutilizables de whiptail (mensajes, inputs, menús)
    │   ├── 🔐 vista_acceso.sh           # Pantallas TUI de Login y Registro de usuarios
    │   └── 📦 vista_inventario.sh       # Menú principal TUI, formularios ABM, listado y disparo de reporte HTML
    ├── 📁 api/
    │   ├── 🔌 api_usuarios.sh           # Controlador adaptado para llamadas nativas en Bash (sin cabeceras HTTP/JSON)
    │   └── 🔌 api_productos.sh          # Controlador adaptado para llamadas nativas y exportación de reporte_productos.html
    ├── 📁 modelos/                      # Intacto
    ├── 📁 base_de_datos/                # Intacto
    ├── 📁 utilidades/                   # Intacto
    ├── 📁 registros/                    # Intacto
    └── 📁 salidas/                      # Intacto (sigue alojando reporte_productos.html)
```

## 3. Instrucciones de Ejecución

Ubicado en la terminal dentro de la carpeta raíz del proyecto (`ejercicio-4`), ejecutar los siguientes comandos en orden:

```bash
# 1. Asegurar los permisos de ejecución de todos los scripts.
find . -type f -name "*.sh" -exec chmod +x {} +

# 2. Levantar la aplicación TUI (verificará dependencias e inicializará la BD).
./ejercicio-4.sh
```