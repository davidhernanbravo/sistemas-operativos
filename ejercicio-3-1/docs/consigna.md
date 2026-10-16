# 💻 Actividad 3.1 - Modularización y Arquitectura en Capas (API)

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Modularización, Arquitectura en Capas (API) e Interfaz Web con Bash y SQLite3  
**Alumno:** David Hernán Bravo  

---

## Formato de entrega

Directorio en repositorio GitHub: `/ejercicio-3-1/`

## Modularización y Separación de Capas

Continuando con el concepto de variabilidad y mantenibilidad trabajado en la Actividad 3, esta etapa aborda el desacoplamiento arquitectónico mediante la separación del software en capas independientes. En un script monolítico, la interfaz de usuario, las reglas de negocio y el acceso a los datos conviven en un único archivo, lo que obliga a modificar todo el código si se desea cambiar la forma en que el usuario interactúa con el sistema. 

Aplicando una **Arquitectura en Capas (Layered Architecture)** mediante la modularización de scripts en Bash (utilizando el comando `source` y una estructura organizada de directorios), es posible aislar la **Capa de Presentación (Frontend)**, la **Capa de Servicio (API)**, la **Capa de Modelo (Lógica de Negocio)** y la **Capa de Persistencia y Configuración (SQLite3)**. De esta manera, el sistema logra que el reemplazo de una interfaz de consola por una interfaz gráfica web (`.html`) sea completamente transparente para el motor lógico y la base de datos.

## Consigna

Reutilizando la lógica funcional desarrollada en la ejercitación 3 (`ejercicio-3.sh`) y tomando como referencia arquitectónica el patrón expuesto en `TemplateSolutionAPI`, se deberá refactorizar el sistema monolítico hacia una estructura modular organizada en carpetas, reemplazando la interacción por consola por una interfaz web (`.html`).

1. Estructurar el proyecto dentro del directorio `/ejercicio-3-1/` dividiendo cada capa y responsabilidad en directorios específicos con nomenclatura en español (`configuracion`, `base_de_datos`, `utilidades`, `modelos`, `api`, `interfaz_web`, `registros`, `salidas` y `docs`).

2. Separar la definición estructural de la base de datos en un archivo SQL puro (`esquema.sql`) y centralizar las rutas y variables globales del sistema en un módulo de configuración (`parametros.sh` y `conexion.sh`).

3. Construir la **Capa de Modelo** (`modelo_usuarios.sh` y `modelo_productos.sh`), la cual será la única autorizada a ejecutar consultas contra la base de datos SQLite3 (`datos.sq3`) y aplicar las validaciones de negocio correspondientes, recibiendo los datos exclusivamente por parámetros.

4. Construir la **Capa de Servicio / API** (`api_usuarios.sh`, `api_productos.sh` y `enrutador_cgi.sh`), encargada de recibir las solicitudes provenientes del frontend, invocar a las funciones correspondientes de la capa de modelo y devolver las respuestas procesadas.

5. Desarrollar la **Capa de Presentación Web** (`index.html`, `panel_inventario.html`, `estilos.css` y `cliente_api.js`) junto con su script de puesta en marcha (`iniciar_servidor.sh`), permitiendo gestionar desde el navegador el registro e inicio de sesión de usuarios, así como el alta, baja, modificación, listado de productos y exportación del reporte HTML.

6. Modularizar las funciones transversales del sistema en la carpeta `utilidades`, manteniendo la encriptación de contraseñas y el registro de auditoría y errores.

## Condiciones

Se debe garantizar el cumplimiento estricto de la jerarquía de capas: la interfaz `.html` solo puede comunicarse con la capa de API, la API solo puede comunicarse con el Modelo, y únicamente el Modelo puede interactuar con la base de datos SQLite3.

Se deben conservar todas las especificaciones técnicas y de auditoría establecidas en la Actividad 3:
* Almacenamiento de contraseñas mediante hash (`SHA-256`).

* Registro obligatorio de cada operación/acción en un archivo de auditoría en formato TSV (`registros/sistema.log`) indicando fecha/hora, ID de usuario, nombre de usuario y acción solicitada.

* Registro centralizado de cualquier fallo de validación, ejecución o base de datos en el archivo de log de errores (`registros/errores.log`).