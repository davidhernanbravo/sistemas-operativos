# 💻 Actividad 4 - Arquitectura en capas e interfaces TUI

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Arquitectura en capas e interfaces TUI (Text User Interface) con Whiptail  
**Alumno:** David Hernán Bravo  

---

## Formato de entrega

Directorio en repositorio GitHub: `/ejercicio-4/`

## Objetivo

Actualmente venimos trabajando con un tipo de interfaz de aplicación llamada CLI (Command Line Interface). 
En esta actividad aprenderemos a trabajar con un modelo diferente de interfaces llamadas TUI (Text User Interfaces) que tratan de emular interfaces gráficas más convencionales, incorporando beneficios de las clásicas GUI (Graphical User Interface) y el poder de las CLI (Command Line Interface).

Más adelante trabajaremos con interfaces GUI en modalidad "Desktop" (Escritorio) y modalidad "Web" en una evolución de nuestros scripts según la arquitectura Cliente-Servidor.

## Consigna

Tomar el resultado de la actividad anterior (Ejercicio 3.1) y construir una interfaz de menúes alternativa aplicando el modelo de interfaz TUI mediante la herramienta `whiptail`.

1. Estructurar el proyecto dentro del directorio `/ejercicio-4/` conservando la división de capas (`configuracion`, `base_de_datos`, `utilidades`, `modelos`, `api`, `registros`, `salidas` y `docs`) de la Actividad 3.1, pero reemplazando la capa web por un directorio `interfaz_tui`.

2. Crear un nuevo script de inicialización principal (`iniciar_tui.sh`) que verifique dependencias, inicialice la base de datos y lance la interfaz principal.

3. Adaptar la **Capa de Servicio / API** (`api_usuarios.sh` y `api_productos.sh`) para eliminar el acoplamiento con HTTP/CGI y el manejo de JSON, operando ahora mediante paso de parámetros estándar en Bash y retornando códigos de salida (exit status) y texto plano.

4. Desarrollar la **Capa de Presentación TUI** dentro de `interfaz_tui/`, implementando cuadros de diálogo (`--menu`, `--inputbox`, `--passwordbox`, `--msgbox`) para el login, registro, menús principales, ABM de productos y listados.

5. El manejo de la sesión (ID y nombre de usuario) deberá persistir en variables globales en memoria durante el ciclo de ejecución del script principal, reemplazando el esquema *stateless* (sessionStorage) de la versión web.

6. La generación del reporte HTML de inventario se mantiene funcional y alojado en la carpeta `salidas/`, disparándose la acción mediante confirmación visual en la TUI.

## Condiciones

Se debe garantizar el cumplimiento estricto de la jerarquía de capas: la interfaz TUI solo puede comunicarse con la capa de API, la API solo puede comunicarse con el Modelo, y únicamente el Modelo puede interactuar con la base de datos SQLite3.

Se deben conservar todas las especificaciones técnicas y de auditoría establecidas previamente:
* Almacenamiento de contraseñas mediante hash (`SHA-256`).

* Registro obligatorio de cada operación/acción en un archivo de auditoría en formato TSV (`registros/sistema.log`) indicando fecha/hora, ID de usuario, nombre de usuario y acción solicitada.

* Registro centralizado de cualquier fallo de validación, ejecución o base de datos en el archivo de log de errores (`registros/errores.log`).