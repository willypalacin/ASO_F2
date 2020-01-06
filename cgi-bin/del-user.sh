#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '  <head>'

read username
username=$(echo $username | awk -F = {'print $1'} | sed 's/\r$//')  #S'elimina el \r (trobat amb echo -n "$username" | hexdump -C)

if [ -z $username ]
then
    echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
    echo '  </head>'
    echo '  <body>'
    echo '      <form name="goGestioUsuaris" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="GET">'
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.goGestioUsuaris.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

error=$(sudo userdelapache $username)
case $error in
    -2)
        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUsererror" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="KO_deleteUser" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUsererror.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
    0)
        echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
        echo '  </head>'
        echo '  <body>'
        echo '      <form name="addUsererror" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
        echo '          <input type="hidden" name="error" value="OK_deleteUser" />'
        echo "          <input type=\"hidden\" name=\"username\" value=\"\" />"
        echo "          <input type=\"hidden\" name=\"password\" value=\"\" />"
        echo '      </form>'
        echo '      <script type="text/javascript">'
        echo '          document.addUsererror.submit();'
        echo '      </script>'
        echo '  </body>'
        echo '</html>'
        ;;
esac