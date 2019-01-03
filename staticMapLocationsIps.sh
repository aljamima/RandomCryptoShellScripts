#!/bin/bash
#echo -e "\e[41;38;5;82m redBgGreenText \e[30;48;5;82m greenBgDarkText \e[0m" ##this line prints first in red second green
### more efficient diff method: diff <(sort file1) <(sort file2)
### *chit works* BUT, need to put old ips into array then verify new ip isnt one of the old ones.

exec   > >(tee -ia /var/log/deployment.log)        ### work on logging still...
exec  2> >(tee -ia /var/log/deployment.log >& 2)  ### I think this one is giving stderr back to stdout and i dont want that. 
exec 19> /var/log/deployment.log
export BASH_XTRACEFD="19"
set -x
DATE='date +%Y/%m/%d:%H:%M:%S'
LOG='/var/log/deployment.log'
echo_log "Script running"
function echo_log {
    echo `$DATE`" $1" >> $LOG
}
# start
echo_log "Script running"
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root -- Only For Logging Tho... So whatevs ¯\_(ツ)_/¯" 
   exit 1
fi
clear
export SSHPASS='admin'
rm -f dhcpEDITING.conf 2>/dev/null
touch dhcpEDITING.conf
rm -f out1.txt 2>/dev/null
touch out1.txt
rm -f out2.txt 2>/dev/null
touch out2.txt
rm -f out1.sorted 2>/dev/null
touch out1.sorted
rm -f out2.sorted 2>/dev/null
touch out2.sorted
function pause(){
 read -n1 -rsp $'Press Any Key To Continue -OR- Ctrl+C to exit\n'
}
function hostEntry () {
	echo -e "host $1 {\\tfixed-address $3 ; \\thardware ethernet $2}" >> dhcpEDITING.conf
}
function macFromIp () {
server=$1
ping -c 1 -w 0.2 -W 0.2 $server 1>/dev/null
arp -a $server | awk '{print $4}'      # PASS THIS FUNCTION AN IP ADDRESS AND IT RETURNS MAC 
}

###### START MAIN PART OF SCRIPT ######
echo -e "\e[41;38;5;82m PLEASE UNPLUG ALL MINERS AND MAKE SURE YOUR DEPLOYMENT SERVER IS THE ONLY OTHER DEVICE ON THE SUBNET \e[0m"
echo -e "\e[41;38;5;82m --- DO NOT PLUG IN ANY OTHER DEVICES DURING THIS PROCEDURE --- \e[0m"
pause
echo "OK, RUNNING FIRST SCAN TO ELIMINATE THIS MACHINE AND NETWORK GEAR FROM OUR FUTURE SCANS"
fping -a -g 192.168.100.1 192.168.100.254 2>/dev/null > out1.txt      # first scan to find ips we want to exclude from search 

# nested-loop.sh: Nested "for" loops
total=0
container=3
for rack in {1..9};                                      #--- num of racks to loop thru -- EXAMPLE: {start..end} ---#
do
  rackTotal=0
  for shelf in {1..5};                                   #--- num of shelves on the rack ---#
  do
    for column in {1..5}                                 #--- num of slots on the shelf ---#
	do
		let "rackTotal+=1"
		let "total+=1"     
		if [ "$shelf" -eq 5 ] && [ "$column" -gt 4 ]     # this means it wont do any miners past shelf 5 - position 4. so only 24 rigs that rack
		then 
			continue                                     # Skip rest of this particular loop iteration if its higher than number 24
	 	fi
		position="$container-$rack-$shelf-$column"       # 1-1-1-1
		ipVar="10.$container.$rack.$rackTotal"           # 10.x.x.x
		mask="255.0.0.0"
		echo -e "\e[30;48;5;82m PLUG IN NEXT MINER, SHOULD BE $position \e[0m"
		pause 
		echo "Scanning For New Devices"
		echo -e "\e[41;38;5;82m SCANNING FOR NEW DEVICES, PLEASE WAIT... \e[0m"
		fping -a -g 192.168.100.1 192.168.100.254 2>/dev/null > out2.txt		
		sort out1.txt > out1.sorted
		sort out2.txt > out2.sorted
		foundIp=$(diff --changed-group-format="%>" --unchanged-group-format="" "out1.sorted" "out2.sorted")
		ipStatus=$?
		scanCount=1
		if [ $ipStatus -ne 1 ]; then
			while [ -z $foundIp ]; do 
				echo "Couldn't Find The New Device, Let Me Scan Again... $scanCountth time"
				let "scanCount+=1"
				foundIp=$(fping -a -g 192.168.100.1 192.168.100.254 2>/dev/null | sort > out2.sorted && diff --changed-group-format="%>" --unchanged-group-format="" "out1.sorted" "out2.sorted")
				ipStatus=$?
			done
		fi
		#echo -e "\033[32;41m Found A New Device At $foundIp\033[0m" ## resets color to green with red bg
		foundIp2=$(echo $foundIp | head -n1 | awk '{print $1;}')
		ping -c 1 -w 0.2 $foundIp
		echo "foundIP:$foundIp FoundIp2:$foundIp2"
		mac=$(./macFromIp.sh $foundIp) ## it was running a seperate shell script in working version. i just changed it to makae it more portable
		echo "Miner was $foundIp, changing to $ipVar"
		echo "$foundIp" >> out1.txt && sort out1.txt > out1.sorted
		hostEntry $position $mac $ipVar    ## This is just making the DHCP config file just in case things dont go smoothe. 
 	    newIp=$ipVar
		oldIp=$foundIp2
		genMap="curl 'https://app.genesis-hive.com/scripts.php?id=createRigs' -H 'Origin: https://app.genesis-hive.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,es-419;q=0.8,es;q=0.7,ru;q=0.6' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Referer: https://app.genesis-hive.com/new.php/deployRigs' -H 'Cookie: PHPSESSID=lii3a24c81a77figr5huu0f7j4; apiKey=8a5f18ad8a4c75a19089eab75ec10d0d; rigHighchartFrom=dataMin=1519689600000; rigHighchartTo=dataMax=1520393720896' -H 'Connection: keep-alive' --data 'rowNr[]=$container&shelfNr[]=$rack&levelNr[]=$shelf&indexNr[]=$column&mac[]=$mac&minerTypeId[]=104&cardsPerMiner[]=4&area[]=GrowMine&levelsPerShelf=null&minersPerLevel=null&newFarmId=45' --compressed"
		eval $(echo $genMap)
		#curl 'http://$oldIp/cgi-bin/set_network_conf.cgi' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://$oldIp/network.html' -H 'Origin: http://$oldIp' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8'--data '_ant_conf_nettype=Static&_ant_conf_hostname=$position&_ant_conf_ipaddress=$newIp&_ant_conf_netmask=255.0.0.0&_ant_conf_gateway=10.0.0.1&_ant_conf_dnsservers=10.0.0.5+1.1.1.1' --compressed
 	    #sshpass -e ssh -o StrictHostKeyChecking=no root@$foundIp /sbin/ifconfig eth0 $ipVar netmask $mask && reboot -f
	done
  done
done    
# Close the output stream not sure if needed but why not?   ¯\_(ツ)_/¯
set +x
exec 19>&-		
exit
