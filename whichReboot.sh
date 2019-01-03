#!/bin/bash

echo "Which Gpio Pin Are You Gonna Change? "
read pinNum
if [ ! -d /sys/class/gpio/gpio$pinNum ] ; then
	echo $pinNum > /sys/class/gpio/export
fi
cd /sys/class/gpio/gpio$pinNum
echo 0 > value
sleep 1
echo 1 > value
