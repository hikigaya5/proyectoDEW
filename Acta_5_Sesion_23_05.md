## ACTA REUNIÓN 

## Preámbulo
  FECHA: 23/05/2024  
  IDENTIFICADOR DE GRUPO: Grupo 3ti12_g6  
  TIPO DE REUNIÓN: Videoconferencia por DISCORD  
  ASISTENCIA:  
    - Celia García Monforte  
    - Anas El Hani Marouane  
    - Manrique Marco Ases  
    - Pablo Parra Sánchez  
    - Sergio Sánchez Temporal  
    - Nabil, Youssefi  
    - Hugo Navarro   
  ALUMNO FIRMANTE DEL DOCUMENTO: Celia García Monforte


## Resumen de la reunión  
En esta reunión se han puesto en común y se han revisado todas las tareas a entregar en el Hito 2. A continuación se detallarán los aspectos a explicar sobre los entregables del Hito 2.
  
## Puntos del acta
1. Página de entrada y enlace a la operación
2. Autenticación web
3. Login con CentroEducativo y mantenimiento de la sesión (no es necesariamente un paso separado)
4. Construcción y envío de las peticiones a CentroEducativo
5. Interpretación de las respuestas de CentroEducativo
6. Construcción y retorno de las páginas HTML de respuesta
7. Identificación del servidor usado como prototipo
8. Descripción del estado actual del grupo

## 1. Página de entrada y enlace a la operación  
La página de entrada a la aplicación Notas Online se ha utilizado "Bootstrap 5", concretamente se ha utilizado el tema "Flatly" de Bootswatch.   
Para poder hacer uso de este tema se importa en la cabecera del HTML como si de una hoja de estilo se tratara:  

`<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@4.5.2/dist/flatly/bootstrap.min.css" integrity="sha384-qF/QmIAj5ZaYFAeQcrQ6bfVMAh4zZlrGwTPY7T/M+iTTLJqJBJjwwnsE5Y0mV7QK" crossorigin="anonymous">`  

La página de entrada a la aplicación explica aquello que podrán hacer tanto alumnos como profesores cuando se autentiquen. Para poder realizar esa autenticación aparecen dos botones bajo la descripción que corresponden a cada uno, uno para profesores y otro para alumnos, ambos se encuentran dentro de un form,en el cual, en su action se hace referencia al servlet "Login" al cual ha de redirigir para realizar la autenticación:

`<form action="Login" method="get"><button type="button-sm-1" class="btn btn-primary">Identificarme como Profesor</button></form>`  

Como detalles para hacer la interfaz más vistosa se incluye en la página una cabecera con el nombre de la aplicación, los nombres de todos los miembros del equipo en un lateral de la página y un pequeño footer. 

## 2. Autenticación Web  

## 3. Login con CentroEducativo y mantenimiento de la sesión (no es necesariamente un paso separado)  

## 4. Construcción y envío de las peticiones a CentroEducativo

## 5. Interpretación de las respuestas de CentroEducativo  

## 6. Construcción y retorno de las páginas HTML de respuesta  

## 7. Identificación del servidor usado como prototipo  
Servidor usado como prototipo: dew.login.2324.dsicv.upv.es

## 8. Descripción del estado actual del grupo  
Actualmente el equipo está funcionando perfectamente, todos los miembros del grupo están implicados en el trabajo, se concetan a las reuniones que hace el grupo y cumplen con todo aquello que se pone como objetivos individuales. Respecto a las expectativas del equipo, todos los miembros coinciden en que se busca obtener la máxima calificación posible.




