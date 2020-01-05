#!/bin/bash
echo Content-Type: text/html
echo
echo -e "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN"
        "http://www.w3.org/TR/html4/strict.dtd">
<html>
         <head>
               <title> Servidor Web d’ADS </title>
               <style>
               table {
                 font-family: arial, sans-serif;
                 border-collapse: collapse;
                 width: 100px;
                 height: 100px;
               }

               td, th {
                 border: 1px solid #dddddd;
                 text-align: left;
                 padding: 8px;
               }

               tr:nth-child(even) {
                 background-color: #dddddd;
               }
               .container {
                 display:flex;
                 flex-direction: row;
               }

               </style>
         </head>

<body>
"
echo -e "<h2>Gestion de procesos</h2>"
echo -e "<div  width=300px height=300px align="left">Lista de PIDS"


v=`ps aux | awk {'print $2 "-" $1'}`
#users=`ps aux | awk {'print $1'}`
#time=`ps aux | awk {'print $1'}`



echo -e "<div class=container>"
echo -e "<table>
  <tr>
    <th>PID - USER</th>

  </tr>
  "
  for i in $v
  do
     echo -e "<tr>"
     echo -e "<td>"
     echo "$i"
     echo -e "</td>"

     echo -e "</tr>"
  done

echo -e "</table>"
echo -e "<div> <h4>Introduzca un PID y seleccione lo que desea hacer<h4/>"
echo -e "<form action="/cgi-bin/gestionProcesos2.sh" method="post" ENCTYPE="text/plain">
  PID <input type="text" name="username" size="20">

<select name="OS" id='options' onchange='myFunc()'>
   <option value="1">Consultar Estado</option>
   <option id="val2" value="2">Interrumpir</option>
   <option value="3">Eliminar Proceso</option>
</select>
 <input id='segs' type='text' name="segs" value="segundos" hidden='true' size="7">

        <input type="submit" value="Log In">
        <input type="reset" value="reset">
        </form>"
echo -e " </div>"
echo -e "</div>"


echo -e "</div>"

echo -e "
<script>
function myFunc(){
 if(document.getElementById('options'). value == '2') {
   document.getElementById('segs').hidden = false;
 } else {
   document.getElementById('segs').hidden = true;
 }
}

function realizadoConExito(){
 alert('Proceso realizado con exito');
  </script>
        </body>

</html>
"
