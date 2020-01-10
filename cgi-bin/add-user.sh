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
    echo '      <form name="addUsererrorMiss" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
    echo '          <input type="hidden" name="error" value="KO_createUser_missing" />'
    echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
    echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.addUsererrorMiss.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

errors=$(sudo useraddapache $username $password)
error=$(echo "$errors" | sed -n 1p)
suberror=$(echo "$errors" | sed -n 2p)

case $error in
    -2)
        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUsererrorUser" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="KO_createUser_username" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUsererrorUser.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
    -3)
        #TODO: Implementar errors depenent de $?

        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUsererrorUser" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="KO_createUser_repeated" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUsererrorUser.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
    -4)
        #TODO: Implementar errors depenent de $?

        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUsererrorUser" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="KO_createUser_password" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUsererrorUser.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
    0)
        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUserOK" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="OK_createUser" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"$username\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"$password\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUserOK.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
esac
