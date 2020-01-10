#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '      <head>'
echo '      <title> Gestio Tasques </title>'
echo '          <style>'
echo '              table, th {'
echo '                  border: 1px solid black;'
echo '              }'
echo '              td {'
echo '                  border: 1px solid black;
                        padding: 1px 1px 1px 10px'
echo '              }'
echo '          </style>'
echo '      </head>'
echo '      <body>'


hash=$(echo "$HTTP_COOKIE" | cut -c 13-)
decrypt=$(echo "$hash" |openssl base64 -d|openssl enc -d -aes-256-cbc -k "ILOVU")
username=$(echo "$decrypt" | awk {'print $1'} | sed 's/\r$//')
password=$(echo "$decrypt" | awk {'print $2'} | sed 's/\r$//')

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

if [ $shadow_pass != $password_encrypted ]; then
    echo '      <form name="NOLogged" id="myForm" target="_myFrame" action="/index.html" method="GET" ENCTYPE="text/plain">'
    echo '          <div align=center><input type="hidden" value="Tornar Menu"></div>'
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.NOLogged.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

logger -s "/$username/ ha entrado en gestion de tareas" 2>> /usr/lib/httpd/cgi-bin/userLogs.log

echo '      <form name="menu" id="myForm" target="_myFrame" action="/cgi-bin/menu.sh" method="GET" ENCTYPE="text/plain">'
echo '          <div align=center><input type="submit" value="Tornar Menu"></div>'
echo '      </form>'
echo '      <form action="/cgi-bin/del-cron.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table align=center style="border-collapse:collapse;width:100%;margin:2% 0 0 0">'
echo '              <tr>'
echo '                  <td colspan="8" bgcolor="#FFFF00"> <div align=center><b>CRON Tasks</b></div> </td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>User</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Month</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Day of month</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Day of week</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Hour</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Minute</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Command</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Delete task</div> </td>'
echo '              </tr>'

for user in $(cut -f1 -d: /etc/passwd)
do
    output=$(sudo fcrontab -u $user -l)
    i=0
    if [ ! -z "$output" ]; then
        while read -r line
        do
            ((i+=1))
            echo '      <tr>'
            echo "          <td> $user </td>"
            aux=$(echo "$line" | awk {'print $4'} | sed 's/*/EACH/g')
            echo "          <td> $aux </td>"
            aux=$(echo "$line" | awk {'print $3'} | sed 's/*/EACH/g')
            echo "          <td> $aux </td>"
            aux=$(echo "$line" | awk {'print $5'} | sed 's/*/EACH/g')
            echo "          <td> $aux </td>"
            aux=$(echo "$line" | awk {'print $2'} | sed 's/*/EACH/g')
            echo "          <td> $aux </td>"
            aux=$(echo "$line" | awk {'print $1'} | sed 's/*/EACH/g')
            echo "          <td> $aux </td>"
            aux=$(echo "$line" | awk {'$1=$2=$3=$4=$5="";print $0'})
            echo "          <td> $aux </td>"

            if [ $user = $username ]; then
                echo "      <td><div align=center><input type=\"submit\" name=\"$i\" value=\"Delete\"></div></td>"
            else
                echo "      <td>  </td>"
            fi

            echo '      </tr>'
        done < <(echo "$output")
    fi
done

echo '          </table>'
echo '      </form>'
echo '      <form action="/cgi-bin/add-cron.sh" method="POST" ENCTYPE="text/plain">'
echo '          <table align=center style="border-collapse:collapse;width:100%;margin:2% 0 0 0">'
echo '              <tr>'
echo '                  <td colspan="6" bgcolor="#FFFF00"> <div align=center><b>CRON Tasks</b></div> </td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Month</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Day of month</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Day of week</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Hour</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Minute</div> </td>'
echo '                  <td bgcolor="FFFFE0"> <div align=center>Command</div> </td>'
echo '              </tr>'
echo '              <tr>'
echo '                  <td><div align=center><input type="text" name="month" size="20"></div></td>'
echo '                  <td><div align=center><input type="text" name="day-month" size="20"></div></td>'
echo '                  <td><div align=center><input type="text" name="day-week" size="20"></div></td>'
echo '                  <td><div align=center><input type="text" name="hour" size="20"></div></td>'
echo '                  <td><div align=center><input type="text" name="minute" size="20"></div></td>'
echo '                  <td><div align=center><input type="text" name="command" size="20"></div></td>'
echo '              </tr>'
echo '          </table>'
echo '          <br>'
echo '          <div align=center><input type="submit" value="Add task"></div>'
echo '      </form>'
echo '      <br>'

read response
operation=$(echo "$response" | awk -F = {'print $1'} | sed 's/\r$//')
status=$(echo "$response" | awk -F = {'print $2'} | sed 's/\r$//')
case $operation in
    add)
        case $status in
            OK)
                echo '<p align=center style="color:rgb(0,255,0);"> Task successfully created </p>'
                ;;
            *)
                echo '<p align=center style="color:rgb(255,0,0);"> Error on creating task. Blank spaces detected! </p>'
                ;;
        esac
        ;;
    del)
        case $status in
            OK)
                echo '<p align=center style="color:rgb(0,255,0);"> Task successfully deleted </p>'
                ;;
            *)
                echo '<p align=center style="color:rgb(255,0,0);"> Error on deleting task </p>'
                ;;
        esac
        ;;
esac

echo '  </body>'
echo '</html>'