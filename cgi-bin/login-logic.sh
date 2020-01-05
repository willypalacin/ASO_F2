#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '  <head>'

read username
read password

username=$(echo $username | awk -F = {'print $2'} | sed 's/\r$//')  #S'elimina el \r (trobat amb echo -n "$username" | hexdump -C)
password=$(echo $password | awk -F = {'print $2'} | sed 's/\r$//')

if [ -z $username ] || [ -z $password ]
then
        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
    echo '  </head>'
    echo '  <body>'
    echo '      <form name="loginError" id="myForm" target="_myFrame" action="/cgi-bin/login-view.sh" method="POST">'
    echo '          <input type="hidden" name="error" value="KO_miss" />'
    echo "          <input type=\"hidden\" name=\"username\" value=\"\" />"
    echo "          <input type=\"hidden\" name=\"password\" value=\"\" />"
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.loginError.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0

exit 0
fi

#Comparar user i pass amb shadow
#echo lfs | openssl passwd -6 -salt 4mBcm/rWKkg2T -stdin
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

if [ $shadow_pass != $password_encrypted ]; then
    echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
    echo '  </head>'
    echo '  <body>'
    echo '      <form name="loginError" id="myForm" target="_myFrame" action="/cgi-bin/login-view.sh" method="POST">'
    echo '          <input type="hidden" name="error" value="KO_wrong" />'
    echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
    echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.loginError.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

echo "      <meta http-equiv='refresh' content='0; URL=http://192.168.1.49/menu.html'>"
echo '  </head>'
echo '  <body>'
echo '  </body>'
echo '</html>'

exit 0
