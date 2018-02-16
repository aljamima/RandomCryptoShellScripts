#!/bin/bash

echo "Which UNIT (gpio#)  do you want to turn on? "
read pinNum
echo "lets flip gpio:$pinNum"
gpio=${pinNum}_
cd /sys/class/gpio/gpio$gpio*

echo "Setting pin HIGH"
echo 1 > value
sleep 1

echo "Setting pig LOW (simulating button press)"
echo 0 > value
sleep 1

echo "Setting pin HIGH (simulating finger off button)"
echo 1 > value
