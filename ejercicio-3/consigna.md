# 💻 Actividad 3 - Variabilidad de implementación

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Variabilidad de implementación con SQLite3 en Bash  
**Alumno:** David Hernán Bravo  

---

## Formato de entrega

Archivo en repositorio GitHub: `/ejercicio-3/ejercicio-3.sh`

## Variabilidad

La actividad tiene como objetivo trabajar el concepto de variabilidad. En todo desarrollo de software, siempre en lo posible, se trata de construir software mantenible. Mantenible es un concepto ambiguo y subjetivo al contexto de quiénes desarrollan. Pero en esencia se encuentra ligada a la idea de "reducir los costos de implementación cuando los requerimientos del mismo software cambian". Dicho de otra manera, queremos que nuestro software se rompa lo menos posible cada vez que queremos ampliar funcionalidad y/o modificar la existente. Por esta razón se suele trabajar la noción de separar la especificación de la implementación. La especificación de un software suele vislumbrarse a través de su estructura. En lenguajes como C++ muchas veces la estructura se suele trabajar bajo clases puramente abstractas, metaprogramación (templates). En bash, todos estos mecanismos no existen en el lenguaje, con lo cual, nuestra única herramienta para construir estructura subyace en el uso adecuado de funciones.

## Consigna

Reutilizando la estructura de código de la ejercitación 2 (funciones) se deberá realizar una reimplementación de las mismas de modo que las entidades (usuario) y (productos) no trabajen más con archivos estáticos TSV en disco, sino que toda la información vinculada a estos se gestione a través de una base de datos SQL mediante SQLite3.

1. Realizar la instalación de SQLite3 en la VM. (`sudo apt install sqlite3`)

2. Diseñar una estructura de base de datos SQL acorde para el almacenamiento de las entidades (usuario) y (productos).

3. Construir una función de creación e inicialización de la base de datos del punto 2, de modo tal que cuando el script se ejecute, en primer lugar chequee si existe el archivo de base de datos (`data.sq3`) en su directorio de trabajo. Si este no existe, el script deberá construirlo.

4. Reimplementar todas las funciones que trabajaban gestionando los archivos TSV en su equivalente interacción SQL contra el archivo de base de datos `data.sq3`.

5. Considerar que ahora cada operación/acción solicitada por el usuario debe quedar siempre registrada en un archivo de "log" externo en formato TSV (`system.log`). Registrando en la primera columna fecha/hora y a continuación ID de usuario, nombre de usuario, acción solicitada.

6. Considerar que cualquier error durante la ejecución del script reporta en un log de errores (`error.log`).

## Condiciones

Se debe garantizar que todo el proyecto funcione de manera transparente como si el usuario que emplea el script no encontrara ningún tipo de modificación en su forma de uso (menúes). Todo cambio interno es completamente inadvertido para el uso del script.
Se deben conservar las especificaciones establecidas para las contraseñas y todo otro criterio adoptado en la actividad 2.

Adjunto un pequeño tutorial básico adecuado para que puedan empaparse de cómo podrían vincular bash con sqlite3: [https://atareao.es/como/sqlite-desde-bash/](https://atareao.es/como/sqlite-desde-bash/)