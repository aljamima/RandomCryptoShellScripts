#!/bin/bash

### more efficient diff method: diff <(sort file1) <(sort file2)
### *chit works* BUT, need to put old ips into array then verify new ip isnt one of the old ones.

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
ping -c 1 -w 0.2 $server
arp -a $server | awk '{print $4}'      # PASS THIS FUNCTION AN IP ADDRESS AND IT RETURNS MAC 
}

###### START MAIN PART OF SCRIPT ######
echo "Please Unplug All Miners."
pause
fping -a -g 10.1.1.1 10.1.1.254 2>/dev/null > out1.txt      # first scan to find ips we want to exclude from search 

# nested-loop.sh: Nested "for" loops
total=0
container=1
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
		echo -n -e "\e[32m Please Plug In The Miner At $position \e[7m"  ## white bg black text
		#echo "Please Plug In The Miner At $position, And"
		pause 
		fping -a -g 10.1.1.1 10.1.1.254 2>/dev/null > out2.txt		
		sort out1.txt > out1.sorted
		sort out2.txt > out2.sorted
		foundIp=$(diff --changed-group-format="%>" --unchanged-group-format="" "out1.sorted" "out2.sorted")
		ipStatus=$?
		if [ $ipStatus -ne 1 ]; then
			while [ -z $foundIp ]; do 
				echo "Couldn't Find The New Device, Let Me Scan Again..."
				foundIp=$(fping -a -g 10.1.1.1 10.1.1.254 2>/dev/null | sort > out2.sorted && diff --changed-group-format="%>" --unchanged-group-format="" "out1.sorted" "out2.sorted")
				ipStatus=$?
			done
		fi
		#echo -e "\033[32;41m Found A New Device At $foundIp\033[0m" ## resets color to green with red bg
		foundIp2=$(echo $foundIp | head -n1 | awk '{print $1;}')
		echo "foundIP:$foundIp FoundIp2:$foundIp2"
		mac=$(./macFromIp.sh $foundIp)
		echo "Miner was $foundIp, changing to $ipVar"
		echo "$foundIp" >> out1.txt && sort out1.txt > out1.sorted
		hostEntry $position $mac $ipVar    ## This is just making the DHCP config file just in case things dont go smoothe. 
 	    newIp=$ipVar
		oldIp=$foundIp2
		#curl 'http://$oldIp/cgi-bin/set_network_conf.cgi' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://$oldIp/network.html' -H 'Origin: http://$oldIp' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8'--data '_ant_conf_nettype=Static&_ant_conf_hostname=$position&_ant_conf_ipaddress=$newIp&_ant_conf_netmask=255.0.0.0&_ant_conf_gateway=10.0.0.1&_ant_conf_dnsservers=10.0.0.5+1.1.1.1' --compressed
 	    sshpass -e ssh -o StrictHostKeyChecking=no root@$foundIp /sbin/ifconfig eth0 $ipVar netmask $mask && reboot -f
	done
  done
done    		
	
