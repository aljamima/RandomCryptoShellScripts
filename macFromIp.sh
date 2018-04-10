#!/bin/bash
### call this script as 'timeout 1 ./macFromIp.sh 10.2.2.2
export SSHPASS='admin'
function hostEntry () {
	echo -e "host $1 {\\tfixed-address $3 ; \\thardware ethernet $2 }" >> dhcpEDITING.conf
}
function macFromIp () {
server=$1
ping -c 1 -w 0.2 -W 0.2 $server 1>/dev/null
arp -a $server | awk '{print $4}'      # PASS THIS FUNCTION AN IP ADDRESS AND IT RETURNS MAC 
}
ip=$1
resolved=$(macFromIp $ip)
hostEntry $ip $resolved $ip
echo $resolved
