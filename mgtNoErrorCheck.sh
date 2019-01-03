#!/bin/sh
clear
if [ -f finList.txt ] ; then
    rm finList.txt
    touch finList.txt
fi
if [ -f ipListFinal.txt ] ; then
    rm ipListFinal.txt
    touch ipListFinal.txt
fi
if [ -f errorList.txt ] ; then
    rm errorList.txt
    touch errorList.txt
fi
echo "These Miners Didn't Take The New Config:" > errorList.txt
if [ -f ipList.txt ] ; then
    rm ipList.txt
    touch ipList.txt
fi
defaultWorker="Mgtbtc2.QuincyMiner"
defaultPool="stratum+tcp://us-east.stratum.slushpool.com:3333"
defaultPass="123"
defaultEscapedUrl="stratum%2Btcp%3A%2F%2Fus-east.stratum.slushpool.com%3A3333"
echo "Running Fping Scan To Gather Ips..."
echo "How Many Miners Do You Want To Change Worker Names For?"
read numWorkersInput
echo "What Would You Like To Change The Worker Names To?"
echo ""
echo "BE PRECISE! -- ex: Mgtbtc123.QuincyMiner "
read newWorker

#if [ -z "$newWorker" ]; then

echo ""
echo "OK, We Are Gonna Change $numWorkersInput miners To '$newWorker'"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
#echo "Running Fping Scan To Gather Ips..."
fping -a -g 192.168.0.1 192.168.0.254 2>/dev/null >ipList.txt       #Uncomment this line for a 192.* network
#fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > ipList.txt            #Uncomment this line for a 10.* network 

for checks in $(cat ipList.txt);             # maybe this stuff can help me grab the current pool info from each miner and put MGTbtc2 workers in a file
do
	apistats=`echo -n "pools" | nc $checks 4028 2>/dev/null`
	worker=`echo $apistats | sed -e 's/,/\n/g' | grep "User" | cut -d "=" -f2`
#	echo "$checks is using worker $worker"	
	if [ "$worker" = "$defaultWorker" ]; then
		echo "$checks" >> defaultWorkers.txt
	else
		echo "$checks is already assigned the default worker name" >> /tmp/remove.txt
	fi
done

echo "$(tail -n $numWorkersInput defaultWorkers.txt)" >> ipListFinal.txt
for server in $(cat ipListFinal.txt);
do
		finString="--digest --user root:root 'http://${server}/cgi-bin/set_miner_conf.cgi' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://${server}/cgi-bin/minerConfiguration.cgi' -H 'Origin: http://${server}' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data '_ant_pool1url=stratum%2Btcp%3A%2F%2Fus-east.stratum.slushpool.com%3A3333&_ant_pool1user=$newWorker&_ant_pool1pw=$defaultPass&_ant_pool2url=&_ant_pool2user=&_ant_pool2pw=&_ant_pool3url=&_ant_pool3user=&_ant_pool3pw=&_ant_nobeeper=false&_ant_notempoverctrl=false&_ant_fan_customize_switch=false&_ant_fan_customize_value=&_ant_freq=&_ant_voltage=0706' --compressed"
		echo "Changing Worker For $server ..."
		if eval $(echo curl $finString); then
			echo $server >> finList.txt
		else
			echo "$server did not accept new config" >> errorList.txt
		fi
done
#echo "$numWorkersInput Miners Were Successfully Changed To $newWorker"
# NEED TO ADD more error control and keep track of how many miners were changed
echo "cat errorList.txt or finList.txt for results"
	;;
*)
	echo "OK, We Will Abort The Procedure"
	;;
esac
