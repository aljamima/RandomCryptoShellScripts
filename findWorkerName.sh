#!/bin/sh
clear
DEFAULTWORKER="Mgtbtc2.QuincyMiner"
if [ -f finList.txt ] ; then
    rm finList.txt
    touch finList.txt
fi
if [ -f defaultWorkers.txt ] ; then
    rm defaultWorkers.txt
    touch defaultWorkers.txt
fi
if [ -f /tmp/errorList.txt ] ; then
    rm /tmp/errorList.txt
    touch /tmp/errorList.txt
fi
echo "These Miners Didn't Take The New Config:" > errorList.txt
if [ -f /tmp/ipList.txt ] ; then
    rm /tmp/ipList.txt
    touch /tmp/ipList.txt
fi
echo "Running Fping Scan To Gather IPs"
#fping -a -g 192.168.0.11 192.168.0.254 2>/dev/null > /tmp/ipList.txt       #Uncomment this line for a 192.* network
fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > /tmp/ipList.txt           #Uncomment this line for a 10.* network 
echo "Done With Fping, Starting To Gather Worker Names"
for checks in $(cat /tmp/ipList.txt);
do
	apistats=`echo -n "pools" | nc $checks 4028 2>/dev/null`
	worker=`echo $apistats | sed -e 's/,/\n/g' | grep "User" | cut -d "=" -f2`
	echo "$checks is using worker $worker" | tee finList.txt	
done
echo "To See Results Cat /tmp/defaultWorkers.txt or /tmp/errorList.txt"
