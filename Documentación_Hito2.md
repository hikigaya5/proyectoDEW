## DOCUMENTACIÓN DEL TRABAJO REALIZADO PARA EL HITO 2

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
 A continuación se detallarán los aspectos a explicar sobre los entregables del Hito 2.
  
## Puntos del documento
1. Página de entrada y enlace a la operación
2. Autenticación web
3. Login con CentroEducativo y mantenimiento de la sesión
4. Construcción y envío de las peticiones a CentroEducativo
5. Interpretación de las respuestas de CentroEducativo
6. Construcción y retorno de las páginas HTML de respuesta
7. Identificación del servidor usado como prototipo y detalles de las pruebas realizadas
8. Referencias y código citado

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
Para poder realizar la autenticación web el primer paso es añadir a los usuarios en el tomcat-users.xml de forma que se distinga e identifique a los usuarios. Además se introduce la distinción entre dos roles distintos, "rolalu" que identificará a los alumnos y "rolpro" que identificará a los profesores. Esta distinción de roles nos será útil en futuras fases para separar entre lo que puede hacer un profesor y lo que puede hacer un alumno, a continuación se muestra el código introducido en tomcat-users.xml   

`<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">
<role rolename="rolalu"/>
<role rolename="rolpro"/>
<user username="minerva" password="123456" roles="rolalu"/>
<user username="pepe" password="123456" roles="rolalu"/>
<user username="maria" password="123456" roles="rolalu"/>
<user username="miguel" password="123456" roles="rolalu"/>
<user username="laura" password="123456" roles="rolalu"/>`  


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
Finalmente se realiza la redirección a el servlet encargado de mostrar las asignaturas del Alumno:   
```java
if(request.isUserInRole("rolalu")) {
        	request.getRequestDispatcher("AsignaturasAlu").forward(request, response);
        }
```
Este código nos permitirá que cuando tratemos tanto con profesores como con alumnos redirigir cada uno al servlet que realiza la funcionalidad que le corresponde. 

## 4. Construcción y envío de las peticiones a CentroEducativo  
En este hito se han realizado 4 peticiones diferentes para obtener información de CentroEducativo: 
- Petición POST para realizar el Login y obtener key y cookies y poder mantener la sesión del usuario
- Petición GET del nombre y apellidos del usuario que se encuentra en este momento logueado
- Petición GET de las asignaturas de las cuales está matriculado el alumno
- Petición GET de las asignaturas de donde podemos obtener la nota que tiene el alumno

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
Para poder interpretar las respuestas de CentroEducativo neceitamos de un BufferedReader que lea la respuesta del servidor y posteriormente que, en un while, se lea cada linea y se añada al StringBuffer para construir la respuesta. El código utilizado se encuentra a continuación:  
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
 
## 7. Identificación del servidor usado como prototipo y detalles de las pruebas realizadas
Servidor usado como prototipo: dew.cgarmon1.2324.dsicv.upv.es  
En el servidor mencionado anteriormente se han realizado las siguientes pruebas: 
- Prueba del alumno PEPE-> usuario: pepe, contraseña: 123456
- Prueba del alumno MARIA-> usuario: maria, contraseña: 123456
- Prueba del alumno MIGUEL-> usuario: miguel, contraseña: 123456
- Prueba del alumno LAURA-> usuario: laura, contraseña: 123456
- Prueba del alumno MINERVA-> usuario: pepe, contraseña: 123456

Antes de proceder con el desarrollo completo se hicieron algunas pruebas previas para comprobar que la autenticación web y el login con CentroEducativo se hacían correctamente. Posteriormente se procedió al desarrollo completo de los aspectos de la aplicación solicitados para la entrega del Hito2.

### Página principal de la aplicación
![image](https://github.com/hikigaya5/proyectoDEW/assets/132065179/60e80c7b-3a7e-4adb-b91a-21faa28288ec)

### Login de un alumn@
![image](https://github.com/hikigaya5/proyectoDEW/assets/132065179/a451bda6-7fd1-41df-b5a3-f8fb50f60afb)

### Página que muestra la lista de asignaturas de un alumn@ concreto cuando hace el login  
![image](https://github.com/hikigaya5/proyectoDEW/assets/132065179/c1fa6aee-009c-47f8-9ccc-15d306312a1d)

### Página que muestra la nota de un alumn@ en una asignatura concreta
![image](https://github.com/hikigaya5/proyectoDEW/assets/132065179/0d7759e8-531d-43d5-ac26-c68390261db1)


## 8. Referencias y código citado  
Para la realización de este proyecto se han consultado diferentes documentos y páginas web  
- Documentación del trabajo "NOL_Especificación_Trajao2324f.docx": https://poliformat.upv.es/access/content/group/GRA_11610_2023/Trabajo%20en%20Grupo/NOL_Especificacion_Trabajo2324_v2.pdf
- Centrar texto en página principal: https://getbootstrap.esdocu.com/docs/5.1/utilities/text/
- Estilo de la página principal: https://www.bootstrapcdn.com/bootswatch
- Consultas sobre como realizar el HashMap: https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/HashMap.html
- Consultas sobre como mantener la sesión: https://stackoverflow.com/questions/36892140/how-to-handle-https-url-that-ends-up-plaintext-connection



