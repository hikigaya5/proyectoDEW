## DOCUMENTACIÓN DEL TRABAJO PROYECTO NOL

## Trabajo realizado por:
  IDENTIFICADOR DE GRUPO: Grupo 3ti12_g6   
    - Celia García Monforte  
    - Anas El Hani Marouane  
    - Manrique Marco Ases  
    - Pablo Parra Sánchez  
    - Sergio Sánchez Temporal  
    - Nabil, Youssefi  
    - Hugo Navarro Chiner  
  ALUMNO FIRMANTE DEL DOCUMENTO: Celia García Monforte


## Resumen del documento
 A continuación se detallarán los aspectos a explicar sobre todos los elementos que componen este proyecto.
  
## Puntos del documento
1. Página de entrada y enlace a la operación
2. Autenticación web 
3. Login con CentroEducativo y mantenimiento de la sesión
4. Construcción y envío de las peticiones a CentroEducativo
5. Interpretación de las respuestas de CentroEducativo  
6. Construcción y retorno de las páginas HTML de respuesta
7. Interacción del código JavaScript con los servlets por AJAX
8. Anotaciones de accesos (logs)
9. Fotos
10. Identificación del servidor usado como prototipo y detalles de las pruebas realizadas
11. Referencias y código citado

## 1. Página de entrada y enlace a la operación  
Para la realización de la página de entrada a la aplicación Notas Online (login.html) se ha utilizado "Bootstrap 5", concretamente se ha utilizado el tema "Flatly" de Bootswatch. Para poder hacer uso de este tema se importa en la cabecera del HTML como si de una hoja de estilo se tratara:  
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@4.5.2/dist/flatly/bootstrap.min.css" integrity="sha384-qF/QmIAj5ZaYFAeQcrQ6bfVMAh4zZlrGwTPY7T/M+iTTLJqJBJjwwnsE5Y0mV7QK" crossorigin="anonymous">
```

La página de entrada a la aplicación explica aquello que podrán hacer tanto alumnos como profesores cuando se autentiquen. Para poder realizar esa autenticación aparecen dos botones bajo la descripción que corresponden a cada uno, uno para profesores y otro para alumnos, ambos se encuentran dentro de un form,en el cual, en su action se hace referencia al servlet "Login" al cual ha de redirigir para realizar la autenticación:
```html
<form action="Login" method="get"><button type="button-sm-1" class="btn btn-primary">Identificarme como Profesor</button></form>
```
Como detalles para hacer la interfaz más vistosa se incluye en la página una cabecera con el nombre de la aplicación, los nombres de todos los miembros del equipo en un lateral de la página y un pequeño footer. 

## 2. Autenticación Web
Para poder realizar la autenticación web el primer paso es añadir a los usuarios en el tomcat-users.xml de forma que se distinga e identifique a los usuarios. Además se introduce la distinción entre dos roles distintos, "rolalu" que identificará a los alumnos y "rolpro" que identificará a los profesores. Esta distinción de roles nos será útil para separar entre lo que puede hacer un profesor y lo que puede hacer un alumno, a continuación se muestra el código introducido en tomcat-users.xml   

`<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">
<role rolename="rolalu"/>
<role rolename="rolpro"/>
<user username="minerva" password="123456" roles="rolalu"/>
<user username="pepe" password="123456" roles="rolalu"/>
<user username="maria" password="123456" roles="rolalu"/>
<user username="miguel" password="123456" roles="rolalu"/>
<user username="laura" password="123456" roles="rolalu"/>
<user username="ramon" password="123456" roles="rolpro"/>
<user username="pedro" password="123456" roles="rolpro"/>
<user username="manoli" password="123456" roles="rolpro"/>
<user username="joan" password="123456" roles="rolpro"/>`  `  

Además, tendremos que añadir las siguientes lineas en el web.xml de nuestrs aplicación web para acabar de definir la autenticación web:  

`<security-constraint>
    <web-resource-collection>
      <web-resource-name>Login</web-resource-name>
      <url-pattern>/Login</url-pattern>
    </web-resource-collection>
    <auth-constraint>
      <role-name>rolpro</role-name>
      <role-name>rolalu</role-name>
    </auth-constraint>
  </security-constraint>
  <login-config>
    <auth-method>BASIC</auth-method>
    <realm-name>Protegido</realm-name>
  </login-config>`  

## 3. Login con CentroEducativo y mantenimiento de la sesión  
Una vez se ha realizado la autenticación web debemos establecer una relación entre las credenciales con las cuales el usuario se identifica en la aplicación web y aquellas que se encuentran en el nivel de datos "CentroEducativo". Para ello tenemos el servlet "Login" al cual se redirige desde la página principal.  
Lo primero con lo que nos encontramos en el servlet es con una función completeHash() que ha sido creada para llenar un HashMap, en el que la clave será el usuario con el que se realiza la autenticación web y el valor será el dni que corresponde a este usuario.  
```java
Map<String, String> hash_usuarios = new HashMap<>();
	public void completeHash() {
		hash_usuarios.put("pepe", "12345678W");
		hash_usuarios.put("maria", "23456387R");
		hash_usuarios.put("miguel", "34567891F");
		hash_usuarios.put("laura", "93847525G");
		hash_usuarios.put("minerva", "37264096W");
		hash_usuarios.put("ramon", "23456733H");
		hash_usuarios.put("pedro", "10293756L");
		hash_usuarios.put("manoli", "06374291A");
		hash_usuarios.put("joan", "65748923M");
	}
```
A continuación ya tenemos el métódo doGet(request, response) en el que tratamos todos los aspectos del login y el mantenimiento de sesión. Desgranando poco a poco el código nos encontramos con diferentes elementos.    

Primero obtenemos la sesión y el usuario y, si no se cuenta ya con la KEY, asignamos a la sesión el dni del usuario (gracias a la asignación realizada anteriomente en el HashMap) y la contraseña (se indica que para todos los usuarios la contraseá será 123456) 

````java
HttpSession session = request.getSession();
String usuario = request.getRemoteUser(); 
if(session.getAttribute("key")==null) {
	if(usuario != null) {
		session.setAttribute("dni", hash_usuarios.get(usuario));
		session.setAttribute("password", "123456");
````
A continuación realizamos, mediante una petición POST a CentroEducativo, el login pasando en el cuerpo de la petición el dni y contraseña del usuario.

```java
URL direccionURL = new URL("http://localhost:9090/CentroEducativo/login");		
HttpURLConnection c = (HttpURLConnection) direccionURL.openConnection(); 
c.setRequestMethod("POST");
c.setRequestProperty("Content-Type", "application/json");
c.setDoOutput(true);
DataOutputStream d = new DataOutputStream(c.getOutputStream());
d.writeBytes("{\"dni\":\""+ session.getAttribute("dni")+ "\",\"password\":\""+session.getAttribute("password")+"\"}");
d.close();
```
En el mensaje de respuesta obtenemos la KEY y las cookies, con esto podremos mantener la sesión del usuario y poder realizar las futuras peticiones a CentroEducativo para obtener información refente al usuario. 

```java
List<String> cookies = c.getHeaderFields().get("Set-Cookie");
BufferedReader br = new BufferedReader(new InputStreamReader(c.getInputStream())); 
String inputLine;
StringBuffer r = new StringBuffer();
while ((inputLine = br.readLine()) != null) {
      r.append(inputLine);
}
br.close();
String KEY = r.toString();     
session.setAttribute("key", KEY);
session.setAttribute("cookies", cookies.get(0));
c.disconnect();
```
Finalmente se realiza la redirección a el servlet que corresponda en función del usuario que haya iniciado sesión:   
```java
if(request.isUserInRole("rolalu")) {
        	request.getRequestDispatcher("AsignaturasAlu").forward(request, response);
        }
if(request.isUserInRole("rolpro")) {
        	request.getRequestDispatcher("AsignaturasProf").forward(request, response);
        }
```

## 4. Construcción y envío de las peticiones a CentroEducativo  
En la aplicación encontramos diferentes funcionalidades para las cuales es necesario construir y realizar el envio de peticiones a CentroEducativo, son las siguientes:   
- Vista de las asignaturas de un Alumno (funcionalidad disponible para Alumnos)
- Vista de la nota de un Alumno (funcionaliad disponible para Alumnos)
- Vista del certificado de notas (funcionalidad disponible para Alumnos)
- Vista de las asignaturas en las que imparte docencia un Profesor (funcionalidad disponible para Profesores)
- Vista de los alumnos que estan matriculados en una asignatura (funcionalidad disponible para Profesores)
- Vista de los detalles de un Alumno (funcionalidad disponible para Profesores)

Hay algunas peticiones que se realizan por POST y otras por GET, vemos en detalle un ejemplo de cada una de ellas para ver sus similitudes y diferencias.
     
### Peticiones de tipo POST: 
```java
URL direccionURL = new URL("http://localhost:9090/CentroEducativo/login");        
HttpURLConnection c = (HttpURLConnection) direccionURL.openConnection(); 
c.setRequestMethod("POST");
c.setRequestProperty("Content-Type", "application/json");
c.setDoOutput(true);
DataOutputStream d = new DataOutputStream(c.getOutputStream());
d.writeBytes("{\"dni\":\"" + session.getAttribute("dni") + "\",\"password\":\"" + session.getAttribute("password") + "\"}");
d.close();
```
De este codigo podemos identificar la parte en la que se indica la URL a la cual se debe realizar la petición y se crea una conexión : 
```java
URL direccionURL = new URL("http://localhost:9090/CentroEducativo/login");        
HttpURLConnection c = (HttpURLConnection) direccionURL.openConnection();
```
También podemos ver como se especifican parámetros necesarios para el correcto funcionamiento de la petición como el tipo de método que es, el formato del contenido de la respuesta y habilita la conexión para enviar datos :
```java
c.setRequestMethod("POST");
c.setRequestProperty("Content-Type", "application/json");
c.setDoOutput(true);
```
Por último, se crea un DataOutPutStream para poder escribir datos en la conexión de salida y se escriben los datos JSON que forman parte del cuerpo de la petición. 
```java
DataOutputStream d = new DataOutputStream(c.getOutputStream());
d.writeBytes("{\"dni\":\"" + session.getAttribute("dni") + "\",\"password\":\"" + session.getAttribute("password") + "\"}");
d.close();
```
### Peticiones de tipo GET: 
```java
URL direccionURL = new URL("http://localhost:9090/CentroEducativo/alumnos/" + dni + "/asignaturas?key=" + key);
HttpURLConnection c = (HttpURLConnection) direccionURL.openConnection();
c.setRequestMethod("GET");
c.setRequestProperty("Accept", "application/json");
c.setRequestProperty("Cookie", cookies);
c.setDoOutput(true);
```
De este codigo podemos identificar la parte en la que se indica la URL a la cual se debe realizar la petición y se crea una conexión, de igual forma que se hacia con las peticiones POST: 
```java
URL direccionURL = new URL("http://localhost:9090/CentroEducativo/alumnos/" + dni + "/asignaturas?key=" + key);
HttpURLConnection c = (HttpURLConnection) direccionURL.openConnection();
```
Por último, vemos como se especifican parámetros necesarios para el correcto funcionamiento de la petición como el tipo de método que es, el formato del contenido de la respuesta y establece una propiedad que permie enviar cookies al servidor para realizar el mantenimiento de sesión :
```java
c.setRequestMethod("GET");
c.setRequestProperty("Accept", "application/json");
c.setRequestProperty("Cookie", cookies);
```

## 5. Interpretación de las respuestas de CentroEducativo  
Tanto en las peticiones POST como en las GET que hemos implementado recibimos como respuesta de CentroEducativo información que utilizaremos o que debe ser mostrada en la aplicación web.   
Para poder interpretar las respuestas de CentroEducativo necesitamos de un BufferedReader que lea la respuesta del servidor y posteriormente que, en un while, se lea cada linea y se añada al StringBuffer para construir la respuesta. El código utilizado se encuentra a continuación:  
```java
BufferedReader br = new BufferedReader(new InputStreamReader(c.getInputStream())); 
String inputLine;
StringBuffer r = new StringBuffer();
while ((inputLine = br.readLine()) != null) {
    r.append(inputLine);
}
```
Por útltimo, en algunos casos ha sido necesario convertir la respuestra a String para su posterior tratamiento: 
```java
 String asignaturas = r.toString();
```
## 6. Construcción y retorno de las páginas HTML de respuesta  
A partir de la información obtenida por las consultas se ha realizado la construcción de páginas HTML en los servlets para mostrar esa información obtenida, además de otros aspectos tanto decorativos como informativos. 
Para poder mostrar la información ha de indicarse que el contenido que se va a escribir tiene formato html y se hace uso de un PrintWriter que escribirá el código HTML que formará la página mediante un println:  
```java
 response.setContentType("text/html");
        PrintWriter out = response.getWriter();
	out.println("<html>");
	...

```
Ha de incluirse dentro del ```java out.println()``` el hipertexto que se incluiría en cualquier otro documento HTML. 
Por otra parte, para mostrar aquella información que proviene de las respuestas de las peticiones almacenamos en una variable de tipo String de la siguiente forma:  
```java
String alumno = re.toString();
JSONObject alumnoObject = new JSONObject(alumno);
String nombre_alumno = alumnoObject.getString("nombre");
String apellidos_alumno = alumnoObject.getString("apellidos");
```
En el código anterior se observa como se crea un objeto JSONObject y postreriormente se extraen los valores que se necesitan. Finalmente esos valores se introduciran en los prints para mostrarlos en la página: 
```java
 out.println(preTituloHTML5 + "<header class=\"header\">\n"
 + "        <div class=\"col-md-12  d-flex justify-content-center p-5\">\n"
 + "           <h1><strong>ASIGNATURAS DE: </strong>" + nombre_alumno + "&nbsp" + apellidos_alumno + "</h1>  \n"
 + "        </div>    \n"
 + "   </header>");
```
## 7. Interacción del código JavaScript con los servlets por AJAX
La integración del código JavaScript nos permite interactuar con el servidor a través de peticiones asincrónicas de la siguiente forma: 

1. Configuración del Servlet en el Servidor que maneje las peticiones AJAX 
2. Realizar una petición AJAX al servlet utilizando JavaScript
3. Una vez que la respuesta es recibida del servlet, se puede interpretar el resultado y actualizar dinámicamente la página web con la información obtenida

No se introduce codigo propio de la aplicacion puesto que no se a alcanzado esta funcionalidad

## 9. Anotaciones de accesos (logs) 
Con motivo de tener un registro de toda la información sobre el funcionamiento de la aplicación se han rescatado los logs para implementarlos a modo de filtro. Para lograrlo se ha creado un archivo `Log.java` que cuenta con un método `doFilter()`, en el cual se registra cada solicitud en un archivo log, asegurandose de que el archivo existe y abriendolo de forma en que no se sobreescriba la información anterior. Posteriormente permite que la solicitud continue su correcto procesamiento.  

A continuación se muestra el código clave: 

```
public void init(FilterConfig fConfig) throws ServletException {
		logPath = fConfig.getServletContext().getInitParameter("logFile");
	}

public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		File file1 = new File(logPath);
		HttpServletRequest req = (HttpServletRequest) request;
		if (file1.createNewFile()) {
            System.out.println("Se ha creado el archivo log correctamente.");
        } else {
            System.out.println("El archivo log ya existe.");
        }
		
		PrintWriter out2 = new PrintWriter(new FileOutputStream(new File(logPath),true));
    	
		out2.println(req.getRemoteHost() + " -- " +  req.getRemoteAddr() + " -- " + req.getRemoteUser() + " -- " + LocalDateTime.now() + " -- " + req.getMethod() + " -- " + req.getRequestURL()); 
		out2.close();
		chain.doFilter(request, response);
	}
```

## 10. Fotos 
En esta aplicación se trata con las imagenes de los alumnos para mostrarlas tanto en la vista del profesor como en el certificado de nota solicitado por el alumno. Con el fin de que ningun usuario pueda acceder a las fotos de otro usuario se ha procedido a almacenar las fotos en el directorio /user/tomcat y dentro de la carpeta "fotos" se ha creado una subcarpeta denominada users donde se encuentrar las fotos que se utilizan. 

Para poder acceder a las fotos se hace uso de un servlet llamado Fotos.java en el cual se lee un archivo que contiene una imagen codificada en base64 correspondiente al DNI del alumno y envía su contenido en formato JSON en la respuesta HTTP. En caso de que intente acceder a la foto una persona cuyo DNI no coincide lanza una excepción. 

Código:  
```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String dni = request.getParameter("dni");
		String dnir = request.getSession().getAttribute("dni").toString();
		if(dni.equals(dnir)) {
		String ruta = getServletContext().getInitParameter("directorioFotos");
		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");
		BufferedReader origen = new BufferedReader(new FileReader(ruta+"/"+dni+".pngb64"));
		PrintWriter out = response.getWriter();
		out.print("{\"dni\": \"" + dni + "\", \"img\": \"");
		String linea = origen.readLine(); out.print(linea);
		while((linea=origen.readLine()) != null) {out.print("\n" + linea);}
		out.print("\"}");
		origen.close(); out.close();
		}
		else {
			throw new ServletException("La foto que intenta obtener no corresponde a su usuario.");
		}
	}
```
## 9. Referencias y código citado  
Para la realización de este proyecto se han consultado diferentes documentos y páginas web  
- Documentación del trabajo "NOL_Especificación_Trajao2324f.docx": https://poliformat.upv.es/access/content/group/GRA_11610_2023/Trabajo%20en%20Grupo/NOL_Especificacion_Trabajo2324_v2.pdf
- Centrar texto en página principal: https://getbootstrap.esdocu.com/docs/5.1/utilities/text/
- Estilo de la página principal: https://www.bootstrapcdn.com/bootswatch
- Consultas sobre como realizar el HashMap: https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/HashMap.html
- Consultas sobre como mantener la sesión: https://stackoverflow.com/questions/36892140/how-to-handle-https-url-that-ends-up-plaintext-connection

## 10. ANEXO (actas)
### ACTA 1

ACTA REUNIÓN 1
Preámbulo
FECHA: 23/04/2024
IDENTIFICADOR DE GRUPO: Grupo 3ti12_g6
TIPO DE REUNIÓN: Videoconferencia por DISCORD
ASISTENCIA:
- Celia García Monforte
- Anas El Hani Marouane
- Manrique Marco Ases
- Pablo Parra Sánchez
- Sergio Sánchez Temporal
- Nabil, Youssefi
- Hugo Navarro ALUMNO FIRMANTE DEL DOCUMENTO: Celia García Monforte

Resumen de la reunión
En esta primera reunión se ha establecido el primer contacto entre los miembros del grupo y se han aportado los medios de contacto y otros elementos a discutir sobre la comunicación y reuniones futuras que es especificarán más adelante en este documento. Además se ha realizado una breve explicación por parte de cada miembro del equipo al resto de los componentes sobre el apartado del documento "Aspectos esenciales para el trabajo en equipo" que el alumno ha seleccionado con el objetivo de conocer la capacidad de comunicación de cada uno de los miembros del equipo.

Puntos de la reunión
Presentación y aportación de medios de comunicación
Decisión de una reserva periódica para las reuniones
Decisión sobre el depósito de materiales
Debate sobre las reglas que deben cumplir los miembros del equipo
Especificación de las exepctativas de los miembros
Exposición de los apartados sobre el documento "Aspectos esenciales para el trabajo en equipo" de cada uno de los miembros
1. Presentación y aportactión de medios de comunicación
Todos los miembros del grupo se han presentado y forman parte del grupo de WhatsApp, que es la forma elegida para la comunicación entre los miembros del grupo.

2. Decisión de una reserva reriódica para las reuniones
Se ha decidido entre los miembros del grupo que se realizarán reuniones presenciales los martes a las 17:00h. Además, en caso de que hiciera falta alguna reunion extra se ha decidido hacer reuniones por Discord.

3. Decisión sobre el depósito de materiales
Se ha decidido utilizar "GitHub" como depósito de materiales y control de versiones.

4. Debate sobre las reglas que deben cumplir los miembros del equipo
Como reglas se ha establecido que todos los miembros del equipo deben de cumplir con los plazos establecidos por el propio equipo para desarrollar los hitos. Además, se ha de asisitir a la mayor cantidad de reuniones posibles.

5. Especificación de las expectativas de los miembros
Tras debatir nuestras expectativas, todos los miembros del grupo aspiran a obtener la mejor calificación posible.

6. Exposición de los apartados sobre el documento "Aspectos esenciales para el trabajo en equipo" de cada uno de los miembros
Celia realizó la exposición sobre la Agrupación 2: Apartados "Expectativas, Brainstorming". El resto de miembros considera que se comunica con facilidad y tiene clara la idea que expresa.

Anas realizó la exposición sobre la Agrupación 3: Apartados "Conflictos, Gestión de Conflictos. El resto de miembros considera que se expresa de forma clara y precisa.

Manrique realizó la exposición sobre la Agrupación 1: Apartados "Comunicación, Objetivos, Resolución de problemas". El resto de miembros considera que su exposicion ha sido muy fácil de comprender y amena.

Pablo realizó la exposición sobre la Agrupación 2: Apartados "Expectativas, Brainstorming".El resto de miembros considera que fue muy facil comprender su exposición.

Sergio realizó la exposición sobre la Agrupación 2: Apartados "Expectativas, Brainstorming".El resto de miembros considera que se expresa con soltura y expresa sus ideas con claridad.

Nabil realizó la exposición sobre la Agrupación 3: Apartados "Conflictos, Gestión de Conflictos. El resto de miembros considera que la exposición fue fluida y fácil de entender.

Hugo realizó la exposición sobre la Agrupación 1: Apartados "Comunicación, Objetivos, Resolución de problemas". El resto de miembros considera que tenia facilidad a la hora de expresarse.

****
### ACTA 2 

ACTA REUNIÓN
Preámbulo
FECHA: 30/04/2024
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

Resumen de la reunión
En esta primera reunión se han repartido las diferentes tareas a entregar en el hito1.

Puntos de la reunión
Selección de la tarea a realizar por cada miembro del equipo
1. Selección de la tarea a realizar por cada miembro del equipo
Se ha decidido repartir las tareas de la siguiente forma:

Log0 + Formulario correspondiente: Anas y Nabil
Log1 + Formulario correspondiente: Hugo y Sergio
Log2 + Formulario correspondiente: Pablo
Shell Scrpit curls: Celia y Manrique 
****
### ACTA 3
ACTA REUNIÓN
Preámbulo
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

Resumen de la reunión
En esta reunión se han puesto en común y se han revisado todas las tareas a entregar en el Hito 1. A continuación se detallarán los aspectos a explicar sobre los entregables del Hito 1.

Puntos del acta
Información sobre como utilizar los formularios que interactuarán con los servlets log0, log1, log2
Documentación que pudiera necesitar un usuario de la aplicación resultante (consulta de logs, ubicación de ficheros generados...)
Explicación de cada una de las órdenes "curl"
1. Información sobre como utilizar los formularios que interactuarán con los servlets log0, log1, log2
Los servlets log0, log1 y log2 son componentes Java diseñados para manejar solicitudes HTTP y registrar información del cliente en un archivo de registro, están diseñados para interactuar con formularios HTML para capturar los datos del usuario y procesarlos. El formulario deberá tener un elemento "form" tal que:

 <form action="/path/LogX" method="get">
Además deberá contener los elementos necesarios para recoger la información que el usuario proporciona etiquetados como "usuario" y "pass".
Lo primero que obtiene el cliente es una página HTML en la que aparecen los enlaces a los formularios que comprueban cada Log.

Al clicar en el enlace "Log0" aparece un formulario en el que deberá rellenar usuario y contraseña. Tras enviar el formulario aparecerá un HTML con la información del cliente (nombre de usuario y contraseña), la fecha actual, la URI y el método HTTP.
Al clicar en el encade "Log1" aparece el mismo formulario que anteriormente que, además de realizar las acciones llevadas a cabo por log0, escribirá esos mismos datos en un archivo de registro.
Al clicar en el enlace "Log2", tras realizar las mismas acciones que en los formularios anteriores, el servlet obtendrá la ruta del archivo de registro de un parámetro de inicialización del contexto llamado "logFile" empleando web.xml.
2. Documentación que pudiera necesitar un usuario de la aplicación resultante (consulta de logs, ubicación de ficheros generados...)
A continuación se muestra la ubicación de los logs dentro del proyecto
image
Por último, indicar que el archivo de registro en el que se escriben los datos al completar el formulario tanto del Log1 como del Log2 se encuentran en /home/user/Documentos/resultado.txt

3. Explicación de cada una de las ordenes "curl"
Se ha realizado la siguiente secuencia de órdenes para interactuar con CentroEducativo v2.0 (leer+modificar+leer):

Login del usuario: Se ha guardado en la variable KEY la clave otorgada como resultado de esta orden, de esa forma podrá pasarse como parámetro a las órdenes siguientes que interactuen con CentroEducativo, "cucu" representa el fichero donde se guardarán las cookies. Tanto la KEY como el fichero con las cookies son necesarios para poder "mantener la sesión" e interacturar con CentroEducativo. Los parámetros necesarios se indican en formato JSON.

KEY=$(curl -s --data '{"dni":"23456733H","password":"123456"}'  -X POST -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/login  -c cucu -b cucu) 

Leer todos los alumnos de CentroEducativo: Se pasa la clave necesaria mediante la variable KEY.

curl -s -X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -H "accept: application/json" -c cucu -b cucu

Modificar un alumno de CentroEducativo: Los parámetros necesarios se indican en formato JSON. La modificación puede realizarse mediante el método POST o mediante el método PUT. Aunque le método PUT es el que mejor representa una operación de actualización hoy en dia se encuentra en desuso. A continuación se muestran ambas opciones:

curl -s  --data '{“apellidos”:”Fernándex”, "dni":"222222222H",”nombre”:”Maria”, "password":"123456"}' -X POST -H”content-type: application/json” http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY\ -c cucu -b cucu

curl -s --data '{“apellidos”:”Fernándex”, "dni":"222222222H",”nombre”:”Maria”, "password":"123456"}' -X PUT -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -c cucu -b cucu

Lectura de la información del alumno modificado: Por último, obtenemos únicamente el alumno sobre el cual hemos realizado la modificación. Los parámetros necesarios se indican en formato JSON.

curl -s --data '{"dni":"222222222H"}' -X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos/?key='$KEY -H "accept: application/json" -c cucu -b cucu  `
****
### ACTA 4

ACTA REUNIÓN
Preámbulo
FECHA: 17/05/2024
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

Resumen de la reunión
En esta reunión se han revisado todas las tareas a realizar para el Hito 2. A continuación se detallarán los aspectos debatidos en la reunión.

Puntos del acta
Reparto de las Tareas a realizar para el Hito 2.
1. Reparto de las Tareas a realizar para el Hito 2
Se ha decidido que cada miembro se enfoque en uno de los aspectos a realizar para el Hito2 de forma que investigue como desarrollar la tarea para posteriormente comunicarlo al resto del equipo y desarrollar el trabajo:

Pagina de entrada y enlace a la operación: Celia García
Autenticación web: Pablo Parra
Login con CentroEducativo y mantenimiento de la sesión (no es necesariamente un paso separado): Sergio Sánchez y Hugo Navarro
Construcción y envío de las peticiones a CentroEducativo: Nabil Youssefi
Interpretación de las respuestas de CentroEducativo: Anas El Hani
Construcción y retorno de las páginas HTML de respuesta: Manrique Marco
****
### ACTA 5

ACTA REUNIÓN
Preámbulo
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
- Hugo Navarro Chiner
ALUMNO FIRMANTE DEL DOCUMENTO: Celia García Monforte

Resumen de la reunión
En esta reunión se han puesto en común y se han revisado todas las tareas a entregar en el Hito 2.

Puntos del acta
Descripción del estado actual del proyecto
Descripción del estado actual del grupo
Indentificador del servidor usado como prototipo y detalles de las pruebas realizadas.
1. Descripción del estado actual del proyecto
Se ha realizado la revisión de todos los elementos a entregar en el Hito 2 y todas las pruebas funcionan correctamente. Se ha realizado, además, la documentación correspondiente al proyecto.

2. Descripción del estado actual del grupo
Actualmente el equipo está funcionando perfectamente, todos los miembros del grupo están implicados en el trabajo, se concetan a las reuniones que hace el grupo y cumplen con todo aquello que se pone como objetivos individuales. Respecto a las expectativas del equipo, todos los miembros coinciden en que se busca obtener la máxima calificación posible.

3. Identificación del servidor usado como prototipo y detalles de la prueba realizada
Servidor usado como prototipo: dew.cgarmon1.2324.dsicv.upv.es
En el servidor mencionado anteriormente se han realizado las siguientes pruebas:

Prueba del alumno PEPE-> usuario: pepe, contraseña: 123456
Prueba del alumno MARIA-> usuario: maria, contraseña: 123456
Prueba del alumno MIGUEL-> usuario: miguel, contraseña: 123456
Prueba del alumno LAURA-> usuario: laura, contraseña: 123456
Prueba del alumno MINERVA-> usuario: pepe, contraseña: 123456
Antes de proceder con el desarrollo completo se hicieron algunas pruebas previas para comprobar que la autenticación web y el login con CentroEducativo se hacian correctamente. Posteriormente se procedió al desarrollo completo de los aspectos de la aplicación solicitados para la entrega del Hito2

Página principal de la aplicación

![333354972-60e80c7b-3a7e-4adb-b91a-21faa28288ec](https://github.com/hikigaya5/proyectoDEW/assets/132065179/18743900-572e-429c-ac0a-194edd5b2e23)

Login de un alumn@
![333355885-a451bda6-7fd1-41df-b5a3-f8fb50f60afb](https://github.com/hikigaya5/proyectoDEW/assets/132065179/47c9532b-068e-4b76-a508-490d4e7433af)


Página que muestra la lista de asignaturas de un alumn@ concreto cuando hace el login
![333355425-c1fa6aee-009c-47f8-9ccc-15d306312a1d](https://github.com/hikigaya5/proyectoDEW/assets/132065179/f656ce5b-a313-4516-8a51-6d87623753e3)


Página que muestra la nota de un alumn@ en una asignatura concreta
![333363814-0d7759e8-531d-43d5-ac26-c68390261db1](https://github.com/hikigaya5/proyectoDEW/assets/132065179/ec113104-b2e5-479b-86d2-157703453fed)
****
### ACTA 6

ACTA REUNIÓN
Preámbulo
FECHA: 17/05/2024
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

Resumen de la reunión
En esta reunión se han revisado todas las tareas a realizar para el Hito 2. A continuación se detallarán los aspectos debatidos en la reunión.

Puntos del acta
Reparto de las Tareas a realizar para el Hito Final.
1. Reparto de las Tareas a realizar para el Hito 2
Se ha decidido que cada miembro se enfoque en uno de los aspectos a realizar para la entrega final de forma que investigue como desarrollar la tarea para posteriormente comunicarlo al resto del equipo y desarrollar el trabajo:

AJAX: Sergio y Manrique
Vistas : Celia
Certificado + Restricciones de Seguridad: Pablo
Servlet Mostrar Asignaturas de Profesor: Anas y Nabil
Servlet Detalles de un alumno + cambiar nota desde detalles: Hugo


