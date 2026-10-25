# 🌐 Actividad 5 - Arquitectura en capas e interfaces web

**Instituto Superior de Formación Técnica Nº 151**   
**Carrera:** Tecnicatura Superior en Análisis de Sistemas  
**Materia:** Sistemas Operativos  
**Tema:** Arquitectura en capas e interfaces web  
**Alumno:** David Hernán Bravo  

---

## Formato de entrega

Repositorio GitHub: `/ejercicio-5/ejercicio-5.sh`

## Contexto

Actualmente venimos desarrollando los cimientos de cómo emplear Bash para poder construir un pequeño sistema de gestión mediante la interacción directa con el sistema operativo. Generalmente, es muy común considerar que el uso de Bash está estrechamente ligado al uso de la terminal y la introducción manual de comandos, o bien, en correr scripts que tienen interacción únicamente por esta vía. Sin embargo, Bash como cualquier otro lenguaje, no está limitado ni excluído de poder interactuar con protocolos y exponer servicios diversos. En esta actividad veremos cómo extrapolar la interfaz al contexto web.

## Utilidades

Si bien, Bash no es un lenguaje para implementar servicios servidores, dado que carece de mecanismos de eficiencia para gestionar el tráfico de solicitudes en escala industrial, sí puede manejar adecuadamente servicios servidores en escala doméstica y/o redes pequeñas de baja concurrencia con muy bajo costo de implementación. En tal sentido, está completamente habilitado para desarrollar un entorno de trabajo completamente web para gestionar su equipo de forma remota, implementar servidores de archivos sencillos y/o todo tipo de utilidades vinculadas al sistema operativo. 

## Consigna

A partir de la estructura modular en capas desarrollada en la actividad Nº4, se solicita desarrollar una variación para posibilitar que el sistema desarrollado pueda utilizarse mediante una interfaz de tipo web.

Durante la clase se abordarán algunas estrategias para implementar este enfoque de una forma simple bajo la modalidad RPC.