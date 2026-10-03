# 💻 Actividad 1 - Introducción a la programación en Bash

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Transición de Programación Estructurada (C/C++) a Bash  
**Alumno:** David Hernán Bravo  

---

## 🔄 Contexto: Transición C/C++ a Bash

El código `abm_c.cpp` se trata de un programa simple y compatible con C/C++ que muestra un menú de acciones para cargar datos a un array. El código `abm_bash.sh` es exactamente el mismo programa migrado al lenguaje Bash, tratando de mantener la mayor semejanza posible.

La idea principal es utilizar ambos códigos para realizar un primer "mapeo" y adaptar conceptos básicos de programación estructurada (tales como *variables, tipos, funciones, for, if/then/else, switch y while*) para transportarlos gradualmente hacia el lenguaje Bash.

> **Nota:** Recordar que a los scripts se les deben otorgar permisos de ejecución para que puedan correr.
> ```bash
> chmod +x ./abm_bash.sh
> ```
> *(Siempre y cuando se encuentren en el directorio correspondiente).*

---

## 📋 Consigna

1. **Análisis comparativo:** Compilar y ejecutar el código C. Probar su funcionamiento. Descargar el equivalente en Bash y estudiar las similitudes y diferencias.

2. **Desarrollo:** Una vez comprendido el código Bash, incorpore una nueva entrada al menú de opciones para realizar una nueva acción: **"Editar un producto existente"**. Deberá pedir el identificador correspondiente y actualizar los valores de dicho producto.

3. **Control de versiones:** Terminado el punto 2, subir el código al repositorio GitHub creado para la materia bajo el nombre: `ejercicio-1.sh`.

4. **Notificación:** Avisar con un mensaje en la misma actividad si pudo realizarla. En caso de cualquier adversidad y/o problema, dejarlo expresado para su tratamiento en clases.

---

## 📌 Notas a tener en cuenta

1. **Permisos de ejecución:** Los scripts requieren permisos para ejecutarse. Aplique el permiso mediante el comando:

   * Utilizando la ruta completa: `chmod +x /ruta/al/nombre_del_archivo`
   * Desde la carpeta del script: `chmod +x ./nombre_del_archivo`

2. **Instalación de Git:** Si necesita instalar Git en la VM, ejecute como administrador:
   ```bash
   apt update && apt install git
   ```