#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '    <head>'
echo '      <title> Login </title>'
echo '    </head>'
echo '    <body>'


hash=$(echo "$HTTP_COOKIE" | cut -c 13-)
decrypt=$(echo "$hash" |openssl base64 -d|openssl enc -d -aes-256-cbc -k "ILOVU")
username=$(echo "$decrypt" | awk {'print $1'} | sed 's/\r$//')
password=$(echo "$decrypt" | awk {'print $2'} | sed 's/\r$//')

if [ ! -z "$hash" ]; then
    for user in $(cut -f1 -d: /etc/passwd)
    do
        if [ "$user" = "$username" ]; then
            while IFS= read -r line
            do
                shadow_user=$(echo "$line" | awk -F : {'print $1'} | sed 's/\r$//')

                if [ "$shadow_user" != "$username" ]; then
                    continue
                fi

                shadow_pass=$(echo "$line" | awk -F : {'print $2'} | sed 's/\r$//')
                sha_number=$(echo $shadow_pass | awk -F $ {'print $2'} | sed 's/\r$//')
                sha_salt=$(echo $shadow_pass | awk -F $ {'print $3'} | sed 's/\r$//')

                case $sha_number in
                    1)
                        password_encrypted=$(echo $password | openssl passwd -1 -salt $sha_salt -stdin)
                        ;;
                    5)
                        password_encrypted=$(echo $password | openssl passwd -5 -salt $sha_salt -stdin)
                        ;;
                    6)
                        password_encrypted=$(echo $password | openssl passwd -6 -salt $sha_salt -stdin)
                        ;;
                esac
                break
            done < /etc/shadow
        fi
    done
    if [ "$shadow_pass" = "$password_encrypted" ]; then
        echo '      <form name="Logged" id="myForm" target="_myFrame" action="/cgi-bin/menu.sh" method="GET" ENCTYPE="text/plain">'
        echo '          <div align=center><input type="hidden" value="Tornar Menu"></div>'
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.Logged.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        exit 0
    fi
fi

read response
error=$(echo $response | awk -F "&" {'print $1'} | awk -F = {'print $2'} | sed 's/\r$//')
username=$(echo $response | awk -F "&" {'print $2'} | awk -F = {'print $2'} | sed 's/\r$//')
password=$(echo $response | awk -F "&" {'print $3'} | awk -F = {'print $2'} | sed 's/\r$//')


echo '      <br>'
echo '      <h4 align=center>SIGN IN</h4>'
echo '      <form action="/cgi-bin/login-logic.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table nowrap align=center>'
echo '              <tr>'
echo '                  <td>Username</td>'

if [ ! -z $error ] && [ $error = "KO_wrong" ]; then
    echo "                  <td><input type=\"text\" name=\"username\" value=\"$username\" size=\"20\"></td>"
else
    echo '                  <td><input type="text" name="username" size="20"></td>'
fi



echo '              </tr>'
echo '              <tr>'
echo '                  <td>Password</td>'

if [ ! -z $error ] && [ $error = "KO_wrong" ]; then
    echo "                  <td><input type=\"password\" name=\"password\" value=\"$password\" size=\"20\"></td>"
else
    echo '                  <td><input type="password" name="password" size="20"></td>'
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
