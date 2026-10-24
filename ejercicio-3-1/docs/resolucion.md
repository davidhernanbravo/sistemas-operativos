# 📄 Resolución de Actividad 3.1

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:**  Modularización, Arquitectura en Capas (API) e Interfaz Web con Bash y SQLite3  
**Alumno:** David Hernán Bravo  

---

## 1. Arquitectura y Decisiones de Diseño

La refactorización del sistema de gestión de inventario abandona el paradigma monolítico para implementar un modelo de **Arquitectura en Capas (Layered Architecture)**. Este enfoque reduce drásticamente el acoplamiento y garantiza la escalabilidad del sistema, separando de forma estricta la interfaz de usuario, la lógica de negocio y la capa de persistencia.

### 1.1. Interfaz Web y Protocolo CGI

Se descartó el uso de TUI/CLI nativo en favor de una interfaz web estática (`HTML/CSS/JS`). Para comunicar el entorno web con los scripts del sistema operativo sin incurrir en dependencias de frameworks externos, se implementó el estándar **CGI (Common Gateway Interface)** apoyado en el servidor HTTP nativo de Python 3. 

* El script `enrutador_cgi.sh` actúa como único punto de entrada (Front Controller) para las peticiones HTTP mediante el método `POST`.

* El backend desarrollado en Bash opera bajo un modelo *stateless* (sin estado). El control de la sesión es delegado al `sessionStorage` del navegador mediante `cliente_api.js`, inyectando el ID y nombre de usuario en el cuerpo de cada petición (payload JSON) para mantener la trazabilidad ininterrumpida en la bitácora de auditoría (`sistema.log`).

### 1.2. Separación de Responsabilidades (SoC)

La estructura fue modularizada importando componentes mediante el comando nativo `source`:
* **Presentación:** Las vistas HTML operan sin lógica de negocio incrustada. Los eventos son capturados por funciones asíncronas en JavaScript, formateando las peticiones hacia el backend.

* **Servicio (API):** Los scripts en el directorio `api/` validan la integridad de las peticiones, coordinan la ejecución y orquestan las respuestas con cabeceras `application/json`. Carecen de permisos para interactuar directamente con SQLite.

* **Modelo:** Los scripts en `modelos/` encapsulan las reglas de negocio puras y son la única capa con autorización para preparar y solicitar transacciones SQL al módulo de conexión.

* **Utilidades Transversales:** Las funciones de encriptación (algoritmo SHA-256), sanitización de cadenas para mitigar inyección SQL y el registro de eventos fueron aisladas en `utilidades/` para evitar la duplicación de código a lo largo de las capas.

---

## 2. Estructura de Carpetas
```
📦 sistemas-operativos/
├── 📁 ... (ejercicios anteriores aislados)
└── 📁 ejercicio-3-1/
    ├── 🚀 iniciar_servidor.sh           # Punto de entrada: inicializa la BD y levanta el servidor HTTP/CGI local
    │
    ├── 📁 docs/
    │   ├── 📄 consigna.md               # Enunciado y requisitos de la cátedra
    │   └── 📄 resolucion.md             # Documentación técnica de la arquitectura y decisiones de diseño
    │
    ├── 📁 configuracion/
    │   └── ⚙️ parametros.sh             # Rutas globales (BD, logs, puerto HTTP) y variables de entorno
    │
    ├── 📁 interfaz_web/
    │   ├── 🌐 index.html                # Pantalla de inicio de sesión y registro de usuarios
    │   ├── 🌐 panel_inventario.html     # Menú principal, formularios (Alta/Baja/Edición) y tabla de productos
    │   ├── 🎨 estilos.css               # Diseño visual de las pantallas y formularios
    │   └── ⚡ cliente_api.js            # Captura eventos de los formularios HTML y los envía a la API Bash
    │
    ├── 📁 api/
    │   ├── 🔀 enrutador_cgi.sh          # Puerta de enlace HTTP: recibe peticiones del navegador y llama a las APIs
    │   ├── 🔌 api_usuarios.sh           # Controlador de servicios para login, cierre de sesión y registro
    │   └── 🔌 api_productos.sh          # Controlador de servicios para el ABM de productos y generación de reporte
    │
    ├── 📁 modelos/
    │   ├── 🧠 modelo_usuarios.sh        # Reglas de negocio y consultas SQL puras de la tabla usuarios
    │   └── 🧠 modelo_productos.sh       # Reglas de negocio y consultas SQL puras de la tabla productos
    │
    ├── 📁 base_de_datos/
    │   ├── 🗄️ esquema.sql               # Definición de tablas (CREATE TABLE usuarios y productos)
    │   ├── 🛠️ conexion.sh               # Creación de la BD y función envoltorio para ejecutar SQLite3
    │   └── 💾 datos.sq3                 # Archivo binario de la base de datos SQLite3
    │
    ├── 📁 utilidades/
    │   ├── 📝 bitacora.sh               # Funciones de escritura en sistema.log (TSV) y errores.log
    │   └── 🔒 seguridad.sh              # Generación de hashes SHA-256 y sanitización de entradas
    │
    ├── 📁 registros/
    │   ├── 📋 sistema.log               # Historial de auditoría de acciones de usuarios
    │   └── ⚠️ errores.log               # Registro de fallos técnicos, SQL y de validación
    │
    └── 📁 salidas/
        └── 📊 reporte_productos.html    # Reporte estático de inventario exportado por el sistema
```
---

## 3. Instrucciones de Ejecución

Ubicado en la terminal dentro de la carpeta raíz del proyecto (`ejercicio-3-1`), ejecutar los siguientes comandos en orden:

```bash
# 1. Asegurá los permisos de ejecución de todos los scripts (fundamental por si alguno quedó como texto plano al crearlo o pegarle el código).
find . -type f -name "*.sh" -exec chmod +x {} +

# 2. Levantá el servidor, que inicializará la BD y el entorno CGI.
./iniciar_servidor.sh
```