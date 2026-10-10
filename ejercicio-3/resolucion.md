# 📝 Desarrollo y Resolución de la Actividad 3

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Variabilidad, Bases de Datos Relacionales (SQLite3) y Trazabilidad (Logging)  
**Alumno:** David Hernán Bravo  

---

## 🖥️ Entorno de Trabajo

Para la realización de esta práctica, el código fue desarrollado, probado y documentado ejecutando un sistema operativo **Debian LXQt Live con persistencia** de manera nativa. Por este motivo, el ciclo de desarrollo se llevó a cabo íntegramente de forma local, prescindiendo de la necesidad de establecer conexiones o transferencias mediante SSH hacia máquinas virtuales.

## 🛠️ Pasos de Implementación (Refactorización del código)

A continuación se detallan, de manera estructurada, las modificaciones implementadas para evolucionar desde la versión anterior (`ejercicio-2.sh`) hacia la versión final orientada a variabilidad y persistencia relacional (`ejercicio-3.sh`):

### 1. 🗄️ Migración a Base de Datos (Transición de TSV a SQLite3)

* **Reemplazo del almacenamiento estático:** Se eliminó el uso de los archivos planos de texto tabulado para la persistencia de entidades.

* **Inicialización automatizada:** Se diseñó la función `inicializar_db()` que verifica la existencia del archivo de base de datos `data.sq3` durante el arranque. Si no se encuentra, ejecuta sentencias SQL para construir la estructura relacional inicial con dos tablas: `usuarios` (con clave autoincremental, nombre único y hash) y `productos` (con identificador, nombre y precio definido como `REAL`).

### 2. 📝 Sistema de Auditoría y Control de Errores (Logging)

* **Registro de actividad (Auditoría):** Se programó la rutina `log_accion()` para registrar toda la actividad generada. Esta guarda cada acción en el archivo `system.log` respetando un formato de columnas TSV: Fecha y Hora, ID de Usuario, Nombre de Usuario y Acción efectuada (por ejemplo, "Inicio de sesión exitoso" o "Alta de producto").

* **Gestión de fallos:** Se integró el seguimiento de problemas mediante `error.log`. Todo fallo de ejecución, como el intento de registro de un usuario duplicado, se reporta de forma inmediata en la terminal y se documenta en este archivo anexándole su correspondiente marca de tiempo.

### 3. 🔐 Refactorización del Sistema de Usuarios y Autenticación

* **Validación SQL:** La inspección de usuarios, previamente delegada a filtros como `awk`, se sustituyó por una consulta estructural `SELECT count(*)` ejecutada directamente contra la base de datos.

* **Manejo de sesión:** El cifrado por defecto (`sha256sum`) se mantuvo inalterado. Sin embargo, al validar exitosamente una credencial, el script ahora captura el ID y el nombre del operador almacenándolos en variables de sesión. Estos valores luego alimentan automáticamente el registro de trazabilidad en cada movimiento.

### 4. 📦 Gestión de Inventario (Operaciones CRUD)

* **Transacciones de datos:** Las lógicas de alta, baja y edición dejaron de basarse en la creación de archivos temporales. En la nueva versión aplican de forma explícita comandos SQL puros (`INSERT INTO`, `DELETE FROM` y `UPDATE`) sobre los registros seleccionados, garantizando mayor integridad en las transacciones.

* **Resolución de conflictos de tipo (Locale):** Durante la consulta del inventario, los precios se extraen de la base de datos manteniendo su notación original de punto flotante. Para eludir los errores de incompatibilidad con la coma decimal del sistema operativo configurado en español, se antepuso la directiva `LC_NUMERIC=C` de manera focalizada al imprimir los datos, ordenando así un renderizado correcto.

### 5. 📊 Generación de Reportes Web (HTML)

* **Extracción dinámica:** El módulo encargado de construir el reporte `productos.html` fue readaptado. En lugar de procesar línea por línea un archivo TSV, se encarga de interceptar y dar formato web estándar (<tr>, <td>) al listado devuelto por la salida de la consulta `SELECT` sobre SQLite3.

### 6. ⚙️ Otorgamiento de Permisos

* Finalmente, para lograr que el sistema de archivos aplique los privilegios de ejecución sobre el nuevo desarrollo, es preciso lanzar desde la terminal el comando: `chmod +x ejercicio-3.sh`.

## 📄 Archivos Resultantes del Proyecto

Consolidada la refactorización y luego de operarlo con normalidad, el sistema administra los siguientes archivos:

* `ejercicio-3.sh`: Archivo principal contenedor de toda la lógica ejecutable y refactorizada en bash.

* `data.sq3`: Archivo binario central gestionado por SQLite3 donde reposan las tablas del modelo de negocio.

* `system.log`: Archivo plano tabulado destinado a fungir como trazador de auditoría para cada operador.

* `error.log`: Archivo para el registro exclusivo de las excepciones o errores no contemplados en el flujo normal.

* `productos.html`: Archivo que consolida la visualización del inventario renderizado en formato de tabla web.