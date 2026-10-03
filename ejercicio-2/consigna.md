# 💻 Actividad 2 - Operadores de redireccionamiento E/S

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Persistencia de datos en Bash, redireccionamiento E/S y cifrado (SHA256)  
**Alumno:** David Hernán Bravo  

---

## Formato de entrega
Archivo en repositorio GitHub: `/ejercicio-2/ejercicio-2.sh`

## Consigna

Teniendo en cuenta el código Bash resultante de la actividad 1, adecuar el código para incorporar las siguientes funcionalidades:

1. Agregar una funcionalidad que permita generar un archivo de reporte `productos.html` mostrando un título y detalle en un formato de tabla. (ID, Nombre, Precio). 

2. En nuestro código actualmente todos los "productos" residen en memoria. Es decir que sólo existen cuando el script está en ejecución. Realizar una modificación de modo tal que cuando se inicie el script se utilice un archivo `productos.tsv` para listar, editar, dar de alta y baja los productos. Deberá validar de no agregar un producto ya existente.

> **Considere el siguiente código de muestra para leer un archivo TSV en bash:**
> ```bash
> while IFS=$'\t' read -r col1 col2 col3; do
>   echo "Campo 1: $col1 | Campo 2: $col2"
> done < productos.tsv
> ```

3. Modificar el código de modo tal que ahora cuando inicie el script aparezcan dos opciones "Iniciar sesión" y "Registrar usuario". La autenticación de usuarios ya no deberá trabajar de forma "hard-codeada" de prueba. El listado de usuarios/contraseñas deberá estar en un archivo TSV llamado `usuarios.tsv` y no podrá exponer las contraseñas de manera abierta. Deberán guardarse de forma cifrada mediante cifrado sha256 empleando el comando `sha256sum`. La funcionalidad de registrar usuario permite dar de alta usuarios solicitando un nombre de usuario y contraseña impactando los cambios en el archivo correspondiente. En todos los casos deberá validar de no agregar un usuario ya existente.

### Datos útiles:
* **Subcadenas de string:** `sub=${cadena:3:8}` *(Extrae entre el caracter 3 y 8).*
* **Redirección a buffer/variable:** `valor=$(echo "1234")` *(Guarda la salida estándar en la variable valor).*