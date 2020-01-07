#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '      <head>'
echo '          <title>Logout</title>'
echo '      </head>'
echo '      <body>'
echo '          <form name="Logout" id="myForm" target="_myFrame" action="/index.html" method="GET" ENCTYPE="text/plain">'
echo '              <div align=center><input type="hidden" value="Exit"></div>'
echo '          </form>'
echo '          <script type="text/javascript">'
echo '              document.cookie = "credentials=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/cgi-bin;";'
echo '              document.Logout.submit();'
echo '          </script>'
echo '      </body>'
echo '</html>'