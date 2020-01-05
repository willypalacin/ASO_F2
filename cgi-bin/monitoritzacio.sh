#!/bin/bash

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '  <head>'
echo '      <title> Monitoritzacio </title>'
echo '      <style>'
echo '          table, th {'
echo '              border: 1px solid black;'
echo '          }'
echo '          td {'
echo '              border: 1px solid black;
                    padding: 1px 1px 1px 10px'
echo '          }'
echo '      </style>'
echo '  </head>'
echo '  <body>'
echo '      <form name="menu" id="myForm" target="_myFrame" action="/menu.html" method="GET" ENCTYPE="text/plain">'
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
on_time_number=$(echo "$data" | awk {'print $5'} | head -n 1 | sed 's/\r$//')
on_time_timestamp=$(echo "$data" | awk {'print $7'} | head -n 1 | sed 's/,//g')

#taula TEMPS ON
echo '      <table align=center style="border-collapse:collapse;width:20%;margin:2% 40% 0 40%">'
echo '          <tr>'
echo '              <td colspan="3" bgcolor="#FFFF00"> <div align=center><b>Time Wake Up</b></div> </td>'
echo '          </tr>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Dies</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Hores</div> </td>'
echo '              <td bgcolor="FFFFE0"> <div align=center>Minuts</div> </td>'
echo '          <tr>'

echo "              <td> $on_time_number </td>"
aux=$(echo "$on_time_timestamp" | awk -F : {'print $1'})
echo "              <td> $aux </td>"
aux=$(echo "$on_time_timestamp" | awk -F : {'print $2'})
echo "              <td> $aux </td>"
echo '          </tr>'
echo '      </table>'
echo '  </body>'
echo '</html>'