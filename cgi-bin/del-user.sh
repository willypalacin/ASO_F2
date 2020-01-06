#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '  <head>'

read username

if [ -z $username ]
then
    echo "      <meta http-equiv='refresh' content='0; URL=http://192.168.1.49/cgi-bin/gestioUsuaris.sh'>"
    echo '  </head>'
    echo '  <body>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

echo '  </head>'
echo '  <body>'
error=$(sudo -S userdelapache $username)

if [ ! -z $error ]; then
    echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
    echo '  </head>'
    echo '  <body>'
    echo '      <form name="addUsererror" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
    echo '          <input type="hidden" name="error" value="KO_deleteUser" />'
    echo "          <input type=\"hidden\" name=\"username\" value=\"\" />"
    echo "          <input type=\"hidden\" name=\"password\" value=\"\" />"
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.loginError.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

echo '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '  </head>'
echo '  <body>'
echo '      <form name="addUsererror" id="myForm" target="_myFrame" action="/cgi-bin/gestioUsuaris.sh" method="POST">'
echo '          <input type="hidden" name="error" value="OK_deleteUser" />'
echo "          <input type=\"hidden\" name=\"username\" value=\"\" />"
echo "          <input type=\"hidden\" name=\"password\" value=\"\" />"
echo '      </form>'
echo '      <script type="text/javascript">'
echo '          document.loginError.submit();'
echo '      </script>'
echo '  </body>'
echo '</html>'
