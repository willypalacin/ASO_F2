#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '      <head>'
echo '      <title> Monitoritzacio </title>'
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

logger -s "/$username/ ha entrado a ver la monitorizacion" 2>> /usr/lib/httpd/cgi-bin/userLogs.log

echo '      <form name="menu" id="myForm" target="_myFrame" action="/cgi-bin/menu.sh" method="GET" ENCTYPE="text/plain">'
echo '          <div align=center><input type="submit" value="Tornar Menu"></div>'
echo '      </form>'

#trobem la informació de la CPU i els cores de la CPU
data=$(top -bn1)
data_CPU=$(echo "$data" | grep "Cpu" | awk {'print $3'})
cpus=$(echo "$data_CPU" | wc -l)

#suma del cpu workload de tots els proccessos d'usuari entre cores
while read -r line
do
total_cpu_usr=$(awk "BEGIN {print $total_cpu_usr+$line; exit}")
done < <(echo "$data_CPU" | awk -F "/" {'print $1'} | sed 's/,/./g')

#suma del cpu workload de tots els proccessos del sistema entre cores
while read -r line
do
total_cpu_sys=$(awk "BEGIN {print $total_cpu_sys+$line; exit}")
done < <(echo "$data_CPU" | awk -F "/" {'print $2'} | sed 's/,/./g')

#suma del cpu workload total
total_cpu_workload=$(awk "BEGIN {print ($total_cpu_usr+$total_cpu_sys)/$cpus; exit}")

#taula CPU
echo '      <table style="float: left; border-collapse:collapse;width:49.5%;height:20%;margin:1% 1% 0 0">'
echo '          <tr>'
echo '              <td colspan="3" bgcolor="#FFFF00"> <div align=center><b>CPU Workload</b></div> </td>'
echo '          </tr>'
echo '          <tr>'
echo "              <td colspan=3> <div align=center>Total CPU Workload: $total_cpu_workload %</div> </td>"
echo '          </tr>'
echo '          <tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Core</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center> CPU User %</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>CPU System %</div> </td>'
echo '          </tr>'

for (( i=1; i<=$cpus; i++ ))
do  
    echo '      <tr>'
    echo "      <td> Core$i </td>"
    aux=$(echo "$data_CPU" | awk -F "/" {'print $1'} | sed 's/,/./g' | sed -n "$i"p)
    echo "      <td> $aux % </td>"
    aux=$(echo "$data_CPU" | awk -F "/" {'print $2'} | sed 's/,/./g' | sed -n "$i"p)
    echo "      <td> $aux % </td>"
    echo '      </tr>'
done
echo '      </table>'

#trobem la info de la memòria
data_MEM=$(echo "$data" | grep "GiB" | awk {'print $4'} | head -n 1)
data_SWAP=$(echo "$data" | grep "GiB" | awk {'print $3'} | sed -n 2p)
#taula MEM+SWAP
echo '      <table style="border-collapse:collapse;width:49.5%;height:20%;margin:1.85% 1% 0 0">'
echo '          <tr>'
echo '              <td colspan="3" bgcolor="#FFFF00"> <div align=center><b>MEM Workload</b></div> </td>'
echo '          </tr>'
echo '          <tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Memory Type</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Memory Workload %</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Memory Total (GB)</div> </td>'
echo '          </tr>'
echo '          <tr>'
echo '              <td> RAM </td>'
aux=$(echo "$data_MEM" | awk -F "/" {'print $1'} | sed 's/,/./g')
echo "              <td> $aux % </td>"
aux=$(echo "$data_MEM" | awk -F "/" {'print $2'} | sed 's/,/./g')
echo "              <td> $aux GB </td>"
echo '          </tr>'
echo '          <tr>'
echo '              <td> SWAP </td>'
aux=$(echo "$data_SWAP" | awk -F "/" {'print $1'} | sed 's/,/./g')
echo "              <td> $aux % </td>"
aux=$(echo "$data_SWAP" | awk -F "/" {'print $2'} | sed 's/,/./g')
echo "              <td> $aux GB </td>"
echo '          </tr>'
echo '      </table>'

#trobem la info del disc
data_DISK=$(df -Th | tail -n +2)
data_INODES=$(df -Thi | tail -n +2)
#taula DISK
echo '      <table align=center style="border-collapse:collapse;width:100%;margin:2% 0 0 0">'
echo '          <tr>'
echo '              <td colspan="8" bgcolor="#FFFF00"> <div align=center><b>DISK Workload</b></div> </td>'
echo '          </tr>'
echo '          <tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Mount on</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>File system</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Total</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Free</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Percentage Used</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Total Inodes</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Ocupped Inodes</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Percentage inodes Used</div> </td>'
echo '          </tr>'

fs=$(echo "$data_DISK" | wc -l)
for (( i=1; i<=$fs; i++ ))
do
    echo '       <tr>'
    aux=$(echo "$data_DISK" | awk {'print $7'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_DISK" | awk {'print $2'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_DISK" | awk {'print $3'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_DISK" | awk {'print $5'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_DISK" | awk {'print $6'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_INODES" | awk {'print $3'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_INODES" | awk {'print $4'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$data_INODES" | awk {'print $6'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    echo '       </tr>'
done

echo '      </table>'

#trobem accessos ssh
accesses=$(grep --text "Accepted password" /var/log/auth.log | tail)

#taula ACCESS
echo '      <table align=center style="border-collapse:collapse;width:100%;margin:2% 0 0 0">'
echo '          <tr>'
echo '              <td colspan="6" bgcolor="#FFFF00"> <div align=center><b>Last SSH accesses</b></div> </td>'
echo '          </tr>'
echo '          <tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Number</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Month</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Day</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Time</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Source IP</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Port</div> </td>'
echo '          </tr>'

accesses_NUMBER=$(echo "$accesses" | wc -l)
for (( i=1; i<=$accesses_NUMBER; i++ ))
do
    echo '      <tr>'
    echo "          <td> $i </td>"
    aux=$(echo "$accesses" | awk {'print $1'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$accesses" | awk {'print $2'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$accesses" | awk {'print $3'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$accesses" | awk {'print $11'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    aux=$(echo "$accesses" | awk {'print $13'} | sed -n "$i"p)
    echo "          <td> $aux </td>"
    echo '      </tr>'
done

echo '      </table>'

#trobem temps encés
on_time=$(uptime -p | cut -d " " -f2- | sed 's/,//g')
columns=$(echo "$on_time" | awk {'print NF'})

case $columns in
    2)
        setmanes=0
        dies=0
        hores=0
        minuts=$(echo "$on_time" | awk {'print $1'})
        ;;
    4)
        setmanes=0
        dies=0
        hores=$(echo "$on_time" | awk {'print $1'})
        minuts=$(echo "$on_time" | awk {'print $3'})
        ;;
    6)
        setmanes=0
        dies=$(echo "$on_time" | awk {'print $1'})
        hores=$(echo "$on_time" | awk {'print $3'})
        minuts=$(echo "$on_time" | awk {'print $5'})
        ;;
    8)
        setmanes=$(echo "$on_time" | awk {'print $1'})
        dies=$(echo "$on_time" | awk {'print $3'})
        hores=$(echo "$on_time" | awk {'print $5'})
        minuts=$(echo "$on_time" | awk {'print $7'})
        ;;
esac

#taula TEMPS ON
echo '      <table align=center style="border-collapse:collapse;width:20%;margin:2% 40% 0 40%">'
echo '          <tr>'
echo '              <td colspan="4" bgcolor="#FFFF00"> <div align=center><b>Time Wake Up</b></div> </td>'
echo '          </tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Setmanes</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Dies</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Hores</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Minuts</div> </td>'
echo '          <tr>'


echo "              <td> $setmanes </td>"
echo "              <td> $dies </td>"
echo "              <td> $hores </td>"
echo "              <td> $minuts </td>"
echo '          </tr>'
echo '      </table>'
echo '  </body>'
echo '</html>'