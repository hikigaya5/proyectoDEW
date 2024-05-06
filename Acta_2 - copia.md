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

## 2. Documentación que pudiera necesitar un usuario de la aplicación resultante (consulta de logs, ubicación de ficheros generados...)  

## 3. Explicación de cada una de las ordenes "curl"  
Se ha realizado la siguiente secuencia de órdenes para interactuar con CentroEducativo v2.0 (leer+modificar+leer): 

  - Login del usuario:  
   `KEY=$(curl -s --data '{"dni":"23456733H","password":"123456"}' 
-X POST -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/login 
-c cucu -b cucu)
`




