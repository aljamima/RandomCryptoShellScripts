#!/bin/bash

for j in `seq 1 1 61`
do
        cd /sys/class/gpio/gpio$j*
        oldValue=$(cat value)
        if [ "$oldValue" == "0" ]; then
                cd /sys/class/gpio/gpio$j*
                echo "start value was "$oldValue
		echo out > direction
                echo 1 > value
                newValue=$(cat value)
		echo "GPIO $j Was Flipped"
		echo "new value was "$newValue
        else
                cd /sys/class/gpio/gpio$j*
		echo "start value was "$oldValue
                echo out > direction
                echo 0 > value
		echo "GPIO $j Was Flipped"
		echo "new value is "$newValue
fi

done
exit

