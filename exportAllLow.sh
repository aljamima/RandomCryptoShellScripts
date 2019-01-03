#!/bin/bash

for i in `seq 1 1 61`
do
	gpioPin=${i}_
       	if [ ! -d /sys/class/gpio/gpio$gpioPin* ] ; then
        	echo $i > /sys/class/gpio/export
        	echo "Pin "$gpioPin" Has  Been Exported"
		cd ..
	fi
	cd /sys/class/gpio/gpio$gpioPin*
        echo out > direction
	curValue=$(cat value)
	echo "All Pins Are Set To Output"
        echo "Current Value Is: "$curValue
	echo 0 > value
	newVal=$(cat value)
	echo "New Value is: "$newVal
	cd ..
done


