#!/bin/bash

echo "Content-type: text/html"
echo ""

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
echo '      <form style="margin:5% 0%" action="/cgi-bin/add-user.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table style="float:left;border-collapse:collapse;width:50%;height:80%;border: 4px solid green;">'
echo '              <tr>'
echo '                  <td colspan="2" style="padding:5% 0 0 0;vertical-align:top;height:30%"><div align=center><font size="12"><b>ADD USER</b></font></div></td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td style="padding:0% 1% 0% 0%"><div align=right>Username </div></td>'
echo '                  <td style="padding:0% 0% 0% 1%"><div align=left><input type="text" name="username" size="20"></div></td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td style="padding:0% 1% 0% 0%"><div align=right>Password </div></td>'
echo '                  <td style="padding:0% 0% 0% 1%"><div align=left><input type="text" name="password" size="20"></div></td>'
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

echo '                  </table>'
echo '              </td></tr>'
echo '              </tr>'
echo '          </table>'
echo '      </form>'
echo '  </body>'
echo '</html>'