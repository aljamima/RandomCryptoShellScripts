#!/bin/bash

echo "Which Gpio Pin Are You Gonna Change? "
read pinNum
echo "lets flip gpio:$pinNum"
gpio=${pinNum}_
cd /sys/class/gpio/gpio$gpio*
curValue=$(cat value)
if [ "$curValue" == "0" ]; then
	cd /sys/class/gpio/gpio$gpio*
        echo out > direction
        echo 1 > value
	sleep 1
	echo 0 > value
        sleep 1
	echo 1 > value
else
        cd /sys/class/gpio/gpio$gpio*
        echo 0 > value
        sleep 1
	echo 1 > value
	sleep 1
	echo 0 > value
fi
