# 📝 Desarrollo y Resolución de la Actividad 2

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Persistencia de datos en Bash, redireccionamiento E/S y cifrado (SHA256)  
**Alumno:** David Hernán Bravo  

---

## 🖥️ Entorno de Trabajo

Para la realización de esta práctica, el código fue desarrollado, probado y documentado ejecutando un sistema operativo **Debian LXQt Live con persistencia** de manera nativa. Por este motivo, el ciclo de desarrollo se llevó a cabo íntegramente de forma local, prescindiendo de la necesidad de establecer conexiones o transferencias mediante SSH hacia máquinas virtuales.

## 🛠️ Pasos de Implementación (Refactorización del código)

A continuación se detallan, de manera estructurada, las modificaciones implementadas para evolucionar desde la versión inicial en memoria (`ejercicio-1.sh`) hacia la versión final con persistencia de datos (`ejercicio-2.sh`):

### 1. 📁 Persistencia de Datos (Transición de Memoria a Archivos)

* **Eliminación de la memoria volátil:** Se suprimió el límite máximo de productos y la estructura de arreglos que mantenía los datos en la memoria RAM del equipo.

* **Creación de estructura base:** Se configuró el script para que, al iniciarse, valide y genere de forma automática los archivos `productos.tsv` y `usuarios.tsv`. Esto asegura que toda la información sobreviva al cierre del programa y a reinicios del sistema.


### 2. 🔐 Sistema de Usuarios y Autenticación

* **Menú de bienvenida:** Se removió la clave única de prueba. Ahora el sistema recibe al operador con un menú que permite **"Iniciar sesión"** o **"Registrar usuario"**.

* **Registro y validación:** Al crear un nuevo usuario, el programa inspecciona `usuarios.tsv` para asegurar que el nombre no se encuentre duplicado en la base de datos.

* **Cifrado de seguridad (SHA256):** Las contraseñas no se almacenan como texto legible. Se empleó el algoritmo `sha256sum` para convertirlas en un código cifrado ininteligible (hash).
 
* **Control de acceso:** Durante el inicio de sesión, el sistema cifra la contraseña ingresada en el momento y la compara con el código cifrado almacenado. Si la coincidencia es exacta, se aprueba el ingreso.


### 3. 📦 Gestión de Inventario (Operaciones sobre TSV)

* **Alta de Productos:** El sistema ahora solicita ID, Nombre y Precio. Previo a guardar, verifica en `productos.tsv` que el ID introducido sea único. De cumplir las condiciones, los datos se escriben en el archivo separados por tabulaciones.

* **Listado:** La lectura se realiza procesando el archivo línea por línea y separando los campos en columnas para una lectura cómoda en la terminal.

* **Edición y Baja:** Se adaptó la lógica para que las modificaciones impacten directamente en el almacenamiento. El script localiza la fila exacta del producto, la retira (en caso de baja) o la sobreescribe con los nuevos valores (en caso de edición), manteniendo el archivo siempre actualizado.


### 4. 📊 Generación de Reportes Web (HTML)

* Se integró una nueva funcionalidad en el menú principal para la exportación de datos.

* Al ejecutarse, el programa extrae la totalidad de la información contenida en `productos.tsv`, le inyecta etiquetas de formato web estándar y construye un archivo independiente llamado `productos.html`. El resultado es una tabla estructurada y ordenada, lista para ser visualizada en cualquier navegador web.


### 5. ⚙️ Otorgamiento de Permisos

* Finalmente, para que el sistema operativo reconozca el nuevo archivo como un programa ejecutable y no como un simple texto, se procedió a habilitar sus atributos de ejecución mediante el comando de terminal: `chmod +x ejercicio-2.sh`.

## 📄 Archivos Resultantes del Proyecto

Una vez puesto en marcha, la solución gestiona de forma autónoma los siguientes archivos:

* `ejercicio-2.sh`: Archivo principal que contiene la lógica ejecutable del sistema.

* `usuarios.tsv`: Archivo de texto tabular destinado al resguardo de las credenciales de acceso cifradas.

* `productos.tsv`: Archivo de texto tabular que opera como base de datos principal del inventario.

* `productos.html`: Archivo generado dinámicamente a petición del usuario para la visualización del estado actual de los productos.