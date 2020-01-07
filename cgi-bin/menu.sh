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
    echo '          <div align=center><input type="hidden" value="Tornar Menu"></div>'
    echo '      </form>'
    echo '      <script type="text/javascript">'
    echo '          document.NOLogged.submit();'
    echo '      </script>'
    echo '  </body>'
    echo '</html>'
    exit 0
fi

echo '        <form action="/cgi-bin/gestioUsuaris.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Gestionar Usuaris">'
echo '        </form>'
echo '        <form action="/cgi-bin/monitoritzacio.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Monitoritzacio">'
echo '        </form>'
echo '        <form action="/cgi-bin/gestioCron.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Gestionar Tasques">'
echo '        </form>'
echo '        <form action="/cgi-bin/gestionProcesos.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Gestionar Procesos">'
echo '        </form>'
echo '        <form action="/cgi-bin/filtrajePaquetes.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Filtraje de paquetes">'
echo '        </form>'
echo '        <form action="/cgi-bin/logout.sh" method="GET" ENCTYPE="text/plain">'
echo '            <input type="submit" value="Logout">'
echo '        </form>'
echo '    </body>'
echo '</html>'
