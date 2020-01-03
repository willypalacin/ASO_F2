#!/bin/bash
echo Content-Type: text/html
echo
echo -e "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html>
        <head>
               <title> FASE 2 </title>
         </head>
<body>
"
echo -e "<h3>Script rebre POST</h3>"
read username #llegir`a parametrePOST=<valor>
read passwd
echo -e "les dades enviades: $username <br/>"
echo -e "fixem-nos que te tant el nom del para`metre com el contingut. <br /> Caldra` manipular la cadena per a obtenir el valor.
Emprarem awk o sed:<br />"
user=`echo $username | awk -F= '{print $2}'`
pass=`echo $passwd | awk -F= '{print $2}'`
ok=0

while IFS= read -r line
do
  userTXT=`echo $line | awk -F: '{print $1}'`
  passTXT=`echo $line | awk -F: '{print $2}'`

   if [ "${var1,,}" = "${var2,,}" ]; then
  echo ":)"
fi; then
    echo "Strings are equal."
  else
    echo "Strings are not equal."
fi
  echo $passTXT
  echo $userTXT
  echo $pass
  echo $user
  echo $ok
done < users.txt

if [ $ok = 1 ]; then
  echo -e "<h1>USER AUTENTICADO CON EXITO</h1>"
else
   echo -e "<h1>CREDS incorrectas</h1>"
fi



echo -e "
         </body>
</html>
"
