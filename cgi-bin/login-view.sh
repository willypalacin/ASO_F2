#!/bin/bash

echo "Content-type: text/html"
echo ""

read response
error=$(echo $response | awk -F "&" {'print $1'} | awk -F = {'print $2'} | sed 's/\r$//')
username=$(echo $response | awk -F "&" {'print $2'} | awk -F = {'print $2'} | sed 's/\r$//')
password=$(echo $response | awk -F "&" {'print $3'} | awk -F = {'print $2'} | sed 's/\r$//')

echo '<html>'
echo '  <head>'
echo '      <title> Login </title>'
echo '  </head>'
echo '  <body>'
echo '      <br>'
echo '      <h4 align=center>SIGN IN</h4>'
echo '      <form action="/cgi-bin/login-logic.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table nowrap align=center>'
echo '              <tr>'
echo '                  <td>Username</td>'

if [ $error = "KO_wrong" ]; then
    echo "                  <td><input type=\"text\" name=\"username\" value=\"$username\" size=\"20\"></td>"
else
    echo '                  <td><input type="text" name="username" size="20"></td>'
fi



echo '              </tr>'
echo '              <tr>'
echo '                  <td>Password</td>'

if [ $error = "KO_wrong" ]; then
    echo "                  <td><input type=\"text\" name=\"password\" value=\"$password\" size=\"20\"></td>"
else
    echo '                  <td><input type="text" name="password" size="20"></td>'
fi

echo '              </tr>'
echo '          </table>'
echo '          <br>'
echo '          <p align=center><input type="submit" value="Log In"></p>'
echo '      </form>'

case $error in
    KO_miss)
        echo '  <p align=center style="color:rgb(255,0,0);"> Missing username or password </p>'
        ;;
    KO_wrong)
        echo '  <p align=center style="color:rgb(255,0,0);"> Wrong username or password </p>'
        ;;
esac

echo '  </body>'
echo '</html>'
