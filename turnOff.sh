#!/bin/bash

echo "Which UNIT (gpio#)  do you want to turn off? "
read pinNum
echo "lets flip gpio:$pinNum"
gpio=${pinNum}_
cd /sys/class/gpio/gpio$gpio*

echo "Setting pin LOW (simulating button press)"
echo 0 > value

