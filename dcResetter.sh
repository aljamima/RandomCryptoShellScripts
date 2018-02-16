#!/bin/bash
#*** remember if it dont work like this we can set it as a cron job to daily reboot dc at midnight
dcNumber0="192.168.0.254" #*** ips for data collectors
dcNumber1="192.168.1.254"
server0=53                #*** whatever gpio pin number we use for this dc
server1=49                #*******************************************************************************************************************
#********************************************  SETUP STUFF  (Export All Pins And Set As Output)  **********************************************
#*********************************************************************************************************************************************
for i in {1..261..1}; do  # We are acutally exporting up to 260 pins here. Thats just for compatibility with other potential reboot server hosts
	gpioPin=${$i}_
	if [ ! -d /sys/class/gpio/gpio$gpioPin ] ; then
        echo $i > /sys/class/gpio/export
	fi
done

for j in  {1..261..1}; do
	gpioPin=${j}_
	cd /sys/class/gpio/gpio$gpioPin*
	echo out > direction
done
#**********************************************************************************************************************************************
#******************************************** END SETUP STUFF  *********************************************************************************
#**********************************************************************************************************************************************
function flipDatChitz() {
nummy=$1
gpioPin=${$nummy}_
cd /sys/class/gpio/gpio$gpioPin*
curValue=$(cat value)
if curValue == 1
then
	newValue=0
else
	newValue=1
fi
echo out > direction
echo $newValue > value
sleep 1
echo $curValue > value
sleep 5m    #  Sleep 5 Mins To give It TIme To boot Back Up
}

while true
do

if ping -c 1 $dcNumber0 &> /dev/null    #**This is gonna ping the DC#1, and if it returns a 1(exits clean), oh and pipe everything to null device
then                                       #**then it will do nothing. If theres an error, it reboots dat chitz
  echo "poop" 2>/dev/null
else                                       #** Then flip every gpio pin
	flipDatChitz $server0
fi

if ping -c 1 $dcNumber1 &> /dev/null    #**This is gonna ping the DC#2, and if it returns a 1(exits clean),
then                                       #**then it will do nothing. If theres an error, it reboots dat chitz
  echo "poop" 2>/dev/null
else
	flipDatChitz $server1
fi
sleep 5m                                   #**sleep an extra 5mins between loops just to slow it down a tad and reduce network traffic
done
