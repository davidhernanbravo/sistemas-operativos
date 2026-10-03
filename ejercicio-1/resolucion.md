# 📝 Desarrollo de la Actividad 1: Transición C/C++ a Bash

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Transición de Programación Estructurada (C/C++) a Bash  
**Alumno:** David Hernán Bravo  

---

## 🔍 1. Análisis y Comparación de Códigos

Al analizar los archivos originales proporcionados por la cátedra, se observaron las siguientes diferencias conceptuales y prácticas entre ambos lenguajes:

*   **Naturaleza del lenguaje:** El programa en C/C++ requiere ser compilado para generar un archivo ejecutable antes de poder utilizarse. Por el contrario, la versión equivalente en Bash funciona como un script que el sistema interpreta y ejecuta instrucción por instrucción.

*   **Estructura de Datos:** En el lenguaje compilado, los datos de cada producto (su precio y estado activo) se agrupan de manera ordenada utilizando una estructura `struct`. En el entorno de scripting Bash, al carecer de este tipo de estructuras nativas, se resolvió simulando este comportamiento mediante un array asociativo donde las claves combinan el identificador y el atributo específico, como por ejemplo `inventario[$id,precio]`.

*   **Tipado de variables:** El código fuente original requiere declarar explícitamente el tipo de dato de cada variable, como `int`, `float` o `char`. La contraparte interpretada maneja las variables de forma más dinámica, aunque emplea banderas como `-i` en sus declaraciones para forzar el tratamiento numérico de ciertas variables y mantener el rigor de los datos.


## ⚙️ 2. Resolución de la Consigna (Modificación del Script)

Para cumplir con el requerimiento de incorporar la acción "Editar un producto existente", se tomó el código interpretado original y se realizaron las siguientes modificaciones en el archivo final:

*   **Actualización del Menú de Opciones:** Se agregó la nueva constante `OPCION_EDITAR=4` y se desplazó el valor de `OPCION_SALIR` al número `5` para mantener la coherencia y el orden numérico de la interfaz.

*   **Creación de la Función `editar()`:** Se incorporó un bloque funcional que recibe por parámetro el ID del elemento y la referencia temporal de los datos del producto. Esta función ejecuta dos validaciones fundamentales: verifica que el ID ingresado se encuentre dentro del rango válido y corrobora que el estado lógico del producto sea activo (`1`) antes de proceder a actualizar su precio en el array del inventario.

*   **Integración en el Ciclo Principal:** Dentro de la estructura condicional `case` que maneja el menú, se añadió la captura de la opción número 4. Al seleccionarla, el sistema solicita al usuario que ingrese por teclado tanto el ID del elemento a modificar como el nuevo precio, para luego transferir esos datos como argumentos a la función de edición.


## 💻 3. Entorno de Trabajo y Ejecución Local

> 💡 **Nota sobre el entorno:** Dado que el equipo de trabajo ejecuta **Debian 13 Cinnamon** como sistema operativo anfitrión (nativo) y no bajo un entorno de Máquina Virtual, el paso de transferencia de archivos mediante el protocolo SSH (utilizando el comando `scp`) indicado en la consigna resultó innecesario. Todo el proceso de programación y despliegue se realizó de forma estrictamente local.

Los pasos lógicos ejecutados en la terminal para crear y probar el script fueron los siguientes:

1.  **Clonación del repositorio de la materia:**  

    ```bash
    git clone [https://github.com/davidhernanbravo/sistemas-operativos.git](https://github.com/davidhernanbravo/sistemas-operativos.git)
    cd sistemas-operativos
    ```

2.  **Creación y edición del archivo:**
    Utilizando el editor de texto integrado en la terminal, se volcó el código desarrollado en el archivo correspondiente a la entrega.

    ```bash
    nano ejercicio-1.sh
    ```

3.  **Otorgamiento de permisos y pruebas de validación:**
    Se asignaron los permisos de ejecución requeridos por los sistemas basados en UNIX para que el archivo sea tratado como un programa. Posteriormente, se corrió el script para auditar su funcionamiento lógico (probando altas, bajas, visualización y la nueva herramienta de edición).
    ```bash
    chmod +x ./ejercicio-1.sh
    ./ejercicio-1.sh
    ```


## 🚀 4. Subida al Repositorio de la Cátedra (GitHub)

Una vez confirmada la eficiencia y escalabilidad del código sin registrar fallos de ejecución, se procedió a asentar los cambios en el sistema de control de versiones y sincronizarlos con el repositorio remoto de la materia, ejecutando la siguiente secuencia:

1.  **Preparación del archivo para su seguimiento:**

    ```bash
    git add ejercicio-1.sh
    ```

2.  **Generación del commit con mensaje descriptivo:**
   
    ```bash
    git commit -m "Agrega ejercicio-1.sh con función de edición de productos"
    ```

3.  **Sincronización con el servidor remoto (Push):**
    ```bash
    git push origin main
    ```
    
    *(La autenticación en la terminal se resolvió implementando un Personal Access Token de GitHub, respetando los estándares de seguridad vigentes para repositorios remotos).*