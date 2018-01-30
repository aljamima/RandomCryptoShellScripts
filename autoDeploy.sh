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
NUMWORKERS=0
DEFAULTPASS="1234567890"
#################################################################################
#################################################################################
####################  SET YOUR MINERS WORKER NAME HERE  #########################
#################################################################################
DEFAULTWORKER="Mgtbtc2.Quincy2Farm"
#################################################################################
#################################################################################
######################  SET YOUR MINERS POOL HERE   #############################
###################### SPECIAL CHARS MUST BE ESCAPED ############################
#################################################################################
DEFAULTURL="stratum%2Btcp%3A%2F%2Fus-east.stratum.slushpool.com%3A3333"
#################################################################################
#################################################################################
######################  SET YOUR NETWORK RANGE HERE  ############################
#################################################################################
STARTIP="10.2.1.100"
ENDIP="10.2.1.120"
#################################################################################
#################################################################################
######################    START WORK STUFF    ###################################
#################################################################################
echo "Making Your Ip List..."
echo "$(fping -a -g $STARTIP $ENDIP 2>/dev/null)" > ipListFinal.txt
while read -r server;
do
		finString="--digest --user root:root 'http://${server}/cgi-bin/set_miner_conf.cgi' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://${server}/cgi-bin/minerConfiguration.cgi' -H 'Origin: http://${server}' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data '_ant_pool1url=$DEFAULTURL&_ant_pool1user=$DEFAULTWORKER&_ant_pool1pw=$DEFAULTPASS&_ant_pool2url=&_ant_pool2user=&_ant_pool2pw=&_ant_pool3url=&_ant_pool3user=&_ant_pool3pw=&_ant_nobeeper=false&_ant_notempoverctrl=false&_ant_fan_customize_switch=false&_ant_fan_customize_value=&_ant_freq=&_ant_voltage=0706' --compressed"
		echo "Changing Worker For $server ..."
		if eval $(echo curl $finString); then
			echo $server >> finList.txt
			NUMWORKERS=$(expr $NUMWORKERS + 1 ) 
		else
			echo "$server did not accept new config" >> errorList.txt
			NUMWORKERS=$(expr $NUMWORKERS - 1 )
		fi
done < ipListFinal.txt
echo "$NUMWORKERS Miners Were Successfully Changed To $DEFAULTWORKER"
echo "cat errorList.txt for failed attempts, cat finList.txt for successful attempts"
