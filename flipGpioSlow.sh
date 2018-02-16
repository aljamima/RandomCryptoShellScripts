#!/bin/bash

for j in `seq 1 1 61`
do  
        cd /sys/class/gpio/gpio$j*
        curValue=$(cat value)
        if [ "$curValue" == "0" ]; then
                cd /sys/class/gpio/gpio$j*
                echo out > direction
                echo 1 > value
                cd ..
		echo "GPIO $j Was Flipped"
		sleep 1
        else
                cd /sys/class/gpio/gpio$j*
                echo out > direction
                echo 0 > value
                cd ..
		echo "GPIO $j Was Flipped"
		sleep 1
fi

done
exit

