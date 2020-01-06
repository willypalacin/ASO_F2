#!/bin/bash

echo "Content-type: text/html"
echo ""

read response
error=$(echo $response | awk -F "&" {'print $1'} | awk -F = {'print $2'} | sed 's/\r$//')
username=$(echo $response | awk -F "&" {'print $2'} | awk -F = {'print $2'} | sed 's/\r$//')
password=$(echo $response | awk -F "&" {'print $3'} | awk -F = {'print $2'} | sed 's/\r$//')

echo '<html>'
echo '  <head>'
echo '      <title> Gestio Usuaris </title>'
echo '      <style>'
echo '          table {'
echo '              table-layout: fixed'
echo '          }'
echo '      </style>'
echo '  </head>'
echo '  <body>'
echo '      <form name="menu" id="myForm" target="_myFrame" action="/menu.html" method="GET" ENCTYPE="text/plain">'
echo '          <div align=center><input type="submit" value="Tornar Menu"></div>'
echo '      </form>'
echo '      <form style="margin:5% 0%" action="/cgi-bin/add-user.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table style="float:left;border-collapse:collapse;width:50%;height:80%;border: 4px solid green;">'
echo '              <tr>'
echo '                  <td colspan="2" style="padding:5% 0 0 0;vertical-align:top;height:30%"><div align=center><font size="12"><b>ADD USER</b></font></div></td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td style="padding:0% 1% 0% 0%"><div align=right>Username </div></td>'

if [ ! -z "$username" ]; then
echo "                  <td style=\"padding:0% 0% 0% 1%\"><div align=left><input type=\"text\" name=\"username\" size=\"10\" value=\"$username\"></div></td>"
else
echo '                  <td style="padding:0% 0% 0% 1%"><div align=left><input type="text" name="username" size="10"></div></td>'
fi

echo '              </tr>'
echo '              <tr>'
echo '                  <td style="padding:0% 1% 0% 0%"><div align=right>Password </div></td>'

if [ ! -z "$password" ]; then
echo "                  <td style=\"padding:0% 0% 0% 1%\"><div align=left><input type=\"text\" name=\"password\" size=\"10\" value=\"$password\"></div></td>"
else
echo '                  <td style="padding:0% 0% 0% 1%"><div align=left><input type="text" name="password" size="10"></div></td>'
fi

echo '              </tr>'
echo '              <tr>'

case $error in
    KO_createUser_missing)
        echo '  <td colspan="2"><p align=center style="color:rgb(255,0,0);"> Missing username or password </p></td>'
        ;;
    KO_createUser_username)
        echo '  <td colspan="2"><p align=center style="color:rgb(255,0,0);"> Wrong username </p></td>'
        ;;
    KO_createUser_repeated)
        echo '  <td colspan="2"><p align=center style="color:rgb(255,0,0);"> Username repeated </p></td>'
        ;;
    KO_createUser_password)
        echo '  <td colspan="2"><p align=center style="color:rgb(255,0,0);"> Wrong password </p></td>'
        ;;
    OK_createUser)
        echo '  <td colspan="2"><p align=center style="color:rgb(0,255,0);"> User created! </p></td>'
        ;;
esac

echo '              </tr>'
echo '              <tr>'
echo '                  <td colspan="2"><div align=center><input type="submit" value="Create"></div></td>'
echo '              </tr>'
echo '          <tr><td style="height:30%"></td></tr>'
echo '          </table>'
echo '      </form>'
echo '      <form style="margin:5% 0%" action="/cgi-bin/del-user.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table style="border-collapse:collapse;width:50%;height:80%;border: 4px solid red;">'
echo '              <tr>'
echo '                  <td style="padding:5% 0 0 0;vertical-align:top;height:5%"><div align=center><font size="12"><b>DELETE USER</b></font></div></td>'
echo '              </tr>'
echo '              <tr><td>'
echo '                  <table align=center style="width:30%">'

users=$(cat /etc/passwd | tail -n +2 | grep "/bin/bash" | awk -F : {'print $1'})

while read -r user
do
    echo '                  <tr>'
    echo "                      <td> <div align=right>$user</div> </td>"
    echo "                      <td><input type=\"submit\" name=\"$user\" value=\"Delete\"></td>"
    echo '                  </tr>'
done < <(echo "$users")

echo '                      <tr>'
case $error in
    KO_deleteUser)
        echo '                  <td colspan="2"><p align=center style="color:rgb(255,0,0);"> Failed on deleting user </p></td>'
        ;;
    OK_deleteUser)
        echo '                  <td colspan="2"><p align=center style="color:rgb(0,255,0);"> User deleted! </p></td>'
        ;;
esac
echo '                      </tr>'
echo '                  </table>'
echo '              </td></tr>'
echo '              </tr>'
echo '          </table>'
echo '      </form>'
echo '  </body>'
echo '</html>'