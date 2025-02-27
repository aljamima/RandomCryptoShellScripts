#!/bin/sh
clear
####
####     THIS IS GONNA POINT ALL S9 MINERS TO ZOOMHASH ACCOUNT WHEN THEY NO PAY BILL
#  URL: stratum+tcp://stratum.slushpool.com:3333
#   userID: zoomhash.worker1
#   password: anything
####
rm -f finList.txt 2>/dev/null
touch finList.txt
rm -f ipList.txt 2>/dev/null
touch ipList.txt
rm -f errorList.txt 2>/dev/null
touch errorList.txt

defaultWorker="zoomhash.worker1"
defaultPool="stratum+tcp://us-east.stratum.slushpool.com:3333"
defaultPass="123"
defaultEscapedUrl="stratum%2Btcp%3A%2F%2Fus-east.stratum.slushpool.com%3A3333"

echo "gonna flip all S9 miners to zoomhash worker... is this ok?"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
echo "Running Fping Scan To Gather Ips..."
#fping -a -g 192.168.0.1 192.168.0.254 2>/dev/null >ipList.txt
fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > ipList.txt           
for server in $(cat ipList.txt);       
do
	finString="--digest --user root:root 'http://${server}/cgi-bin/set_miner_conf.cgi' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://${server}/cgi-bin/minerConfiguration.cgi' -H 'Origin: http://${server}' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data '_ant_pool1url=stratum%2Btcp%3A%2F%2Fus-east.stratum.slushpool.com%3A3333&_ant_pool1user=$defaultWorker&_ant_pool1pw=$defaultPass&_ant_pool2url=&_ant_pool2user=&_ant_pool2pw=&_ant_pool3url=&_ant_pool3user=&_ant_pool3pw=&_ant_nobeeper=false&_ant_notempoverctrl=false&_ant_fan_customize_switch=false&_ant_fan_customize_value=&_ant_freq=&_ant_voltage=0706' --compressed"
	echo "Changing Worker For $server ..."
	if eval $(echo curl $finString); then
		echo $server >> finList.txt
	else
		echo "These Servers Did Not Accept New Config" > errorList.txt
		echo $server >> errorList.txt
	fi
done
echo "cat errorList.txt or finList.txt for results"
	;;
*)
	echo "OK, We Will Abort The Procedure then"
	;;
esac
