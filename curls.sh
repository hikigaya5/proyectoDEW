KEY=$(curl -s --data '{"dni":"23456733H","password":"123456"}'-X POST -H "content-type: application/json" http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/login -c cucu -b cucu)

curl -s -X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -H "accept: application/json" -c cucu -b cucu

curl -s  --data '{“apellidos”:”Fernándex”, "dni":"222222222H",”nombre”:”Maria”, "password":"123456"}' -X POST -H”content-type: application/json” http://dew cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos?key='$KEY -c cucu -b cucu)

 curl -s --data '{"dni":"222222222H"}'-X GET 'http://dew-cgarmon1-2324.dsicv.upv.es:9090/CentroEducativo/alumnos/?key='$KEY -H "accept: application/json" -c cucu -b cucu




