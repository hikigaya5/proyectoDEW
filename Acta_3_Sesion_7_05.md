## ACTA REUNIÓN 

## Preámbulo
  FECHA: 6/05/2024  
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
En esta reunión se han puesto en común y se han revisado todas las tareas a entregar en el Hito 1. A continuación se detallarán los aspectos a explicar sobre los entregables del Hito 1.
  
## Puntos del acta
1. Información sobre como utilizar los formularios que interactuarán con los servlets log0, log1, log2  
2. Documentación que pudiera necesitar un usuario de la aplicación resultante (consulta de logs, ubicación de ficheros generados...)  
3. Explicación de cada una de las órdenes "curl"



## 1. Información sobre como utilizar los formularios que interactuarán con los servlets log0, log1, log2  
Los servlets log0, log1 y log2 son componentes Java diseñados para manejar solicitudes HTTP y registrar información del cliente en un archivo de registro, están diseñados para interactuar con formularios HTML para capturar los datos del usuario y procesarlos. 
El formulario deberá tener un elemento "form" tal que:
    
     <form action="/path/LogX" method="get">
    
Además deberá contener los elementos necesarios para recoger la información que el usuario proporciona etiquetados como "usuario" y "pass".  
Lo primero que obtiene el cliente es una página HTML en la que aparecen los enlaces a los formularios que comprueban cada Log. 
  - Al clicar en el enlace "Log0" aparece un formulario en el que deberá rellenar usuario y contraseña. Tras enviar el formulario aparecerá un HTML con la información del cliente (nombre de usuario y contraseña), la fecha actual, la URI y el método HTTP.
  - Al clicar en el encade "Log1" aparece el mismo formulario que anteriormente que, además de realizar las acciones llevadas a cabo por log0, escribirá esos mismos datos en un archivo de registro. 
  - Al clicar en el enlace "Log2", tras realizar las mismas acciones que en los formularios anteriores, el servlet obtendrá la ruta del archivo de registro de un parámetro de inicialización del contexto llamado "logFile" empleando web.xml.

## 2. Documentación que pudiera necesitar un usuario de la aplicación resultante (consulta de logs, ubicación de ficheros generados...)  
Todos los logs se encuentran en la carpeta ![image](https://github.com/hikigaya5/proyectoDEW/assets/132065179/abe9f3bb-8092-4c1d-8ae3-f9ffe509a155)



## 3. Explicación de cada una de las ordenes "curl"  
Se ha realizado la siguiente secuencia de órdenes para interactuar con CentroEducativo v2.0 (leer+modificar+leer): 

  - Login del usuario: Se ha guardado en la variable KEY la clave otorgada como resultado de esta orden, de esa forma podrá pasarse como parámetro a las órdenes siguientes que interactuen con CentroEducativo, "cucu" representa el fichero donde se guardarán las cookies. Tanto la KEY como el fichero con las cookies son necesarios para poder "mantener la sesión" e interacturar con CentroEducativo. Los parámetros necesarios se indican en formato JSON.
     
     `KEY=$(curl -s --data '{"dni":"23456733H","password":"123456"}' 
    -X POST -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/login 
    -c cucu -b cucu)
    `
  - Leer todos los alumnos de CentroEducativo: Se pasa la clave necesaria mediante la variable KEY.
    
    `curl -s -X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -H "accept: application/json" -c cucu -b cucu`

  - Modificar un alumno de CentroEducativo: Los parámetros necesarios se indican en formato JSON. La modificación puede realizarse mediante el método POST o mediante el método PUT. Aunque le método PUT es el que mejor representa una operación de actualización hoy en dia se encuentra en desuso. A continuación se muestran ambas opciones:
    
    `curl -s  --data '{“apellidos”:”Fernándex”, "dni":"222222222H",”nombre”:”Maria”, "password":"123456"}' -X POST -H”content-type: application/json”
http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY\ -c cucu -b cucu`

    `curl -s --data '{“apellidos”:”Fernándex”, "dni":"222222222H",”nombre”:”Maria”, "password":"123456"}' -X PUT -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -c cucu -b cucu`

  - Lectura de la información del alumno modificado: Por último, obtenemos únicamente el alumno sobre el cual hemos realizado la modificación. Los parámetros necesarios se indican en formato JSON.

     `curl -s --data '{"dni":"222222222H"}' -X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos/?key='$KEY -H "accept: application/json" -c cucu -b cucu
`
`




