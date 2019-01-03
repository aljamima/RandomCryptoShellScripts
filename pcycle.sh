#!/bin/bash
#############################################
###################ODROID BASED##############
###################RESET SERVER##############
###################FOR DATA COLLECTORS#######
#############################################
#############################################
RED='\033[0;31m'
NC='\033[0m' # No Color

function grabValue() {
	cmdString=`cat value`
	echo "$cmdString"
}
clear
echo -e "\e[45m WELCOME TO DATA COLLECTOR REBOOT-O-MATIC"
echo ""
echo
echo "which data collector you wanna reboot?"
echo "1 -- MGT Customer - S9 Miners"
echo
echo " -or- "
echo
echo "2 -- GENESIS Customer - EtherMiner Cubes"
echo
echo
echo -n "Please Select 1 or 2:"
echo
read desires
if ! [[ "$desires" =~ ^[1-2]+$ ]] ; 
 then exec >&2; printf "${RED} ERROR: INVALID INPUT ${NC}"; exit 1
fi
if [ "$desires" = "1" ]; then
	i=87
else
	i=102
fi
gpioPin=$i
if [ ! -d /sys/class/gpio/gpio$gpioPin ] ; then
       	echo $i > /sys/class/gpio/export
       	echo -n "Pin "$gpioPin" Has  Been Exported, "
	cd ..
fi
	cd /sys/class/gpio/gpio$gpioPin
        if [ `cat direction` = "in" ]; then echo out > direction && echo "set to output"; else echo "$i already OUTPUT"; fi
	curValue=$(grabValue)
	echo "Current Value Is: $(grabValue) "
	        if [ "$curValue" == "0" ]; then
       	        	echo 1 > /sys/class/gpio/gpio$i/value
			echo "GPIO $i Was Flipped"
			newValue=$(grabValue)
			echo "pin is now: $(grabValue)"
			echo 0 > /sys/class/gpio/gpio$i/value
	        	echo " and back to $(grabValue)"
		else
                	echo 0 > /sys/class/gpio/gpio$i/value
			echo "GPIO $i Was Flipped"
			newValue=$(cat value)
			echo "pin is now: $(grabValue)"
			echo 1 > /sys/class/gpio/gpio$i/value
			echo " and back to $(grabValue)"
		fi
