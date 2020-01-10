#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '    <head>'
echo '        <title>Sunshine</title>'
echo '    </head>'
echo '    <body>'


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
    echo '          <div align=center><input type="submit" value="Tornar Menu"></div>'
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.NOLogged.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

read line       #linia a esborrar
line=$(echo "$line" | awk -F = {'print $1'} | sed 's/\r$//')
command=$(sudo fcrontab -u "$username" -l | sed -n "${line}p")
month=$(echo "$command" | awk {'print $4'})
dayMonth=$(echo "$command" | awk {'print $3'})
dayWeek=$(echo "$command" | awk {'print $5'})
hour=$(echo "$command" | awk {'print $2'})
minute=$(echo "$command" | awk {'print $1'})
command=$(echo "$command" | cut -d" " -f6-)
sudo fcrontab -u "$username" -l | sed "${line}d" | sudo fcrontab -u "$username" -

logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. MES: $month" 2>> /usr/lib/httpd/cgi-bin/userLogs.log
logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. DIA MES: $dayMonth" 2>> /usr/lib/httpd/cgi-bin/userLogs.log
logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. DIA SEMANA: $dayWeek" 2>> /usr/lib/httpd/cgi-bin/userLogs.log
logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. HORA: $hour" 2>> /usr/lib/httpd/cgi-bin/userLogs.log
logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. MINUTO: $minute" 2>> /usr/lib/httpd/cgi-bin/userLogs.log
logger -s "/$username/ ha añadido eliminado la tarea de cron siguiente. COMANDO: $command" 2>> /usr/lib/httpd/cgi-bin/userLogs.log



echo '      <form name="redirect" id="myForm" target="_myFrame" action="/cgi-bin/gestioCron.sh" method="POST" ENCTYPE="text/plain">'
echo '          <input type="hidden" name="del" value="OK">'
echo '          <div align=center><input type="submit" value="Tornar Cron"></div>'
echo '      </form>'
echo '      <script type="text/javascript">'
echo '          document.redirect.submit();'
echo '      </script>'
echo '  </body>'
echo '</html>'