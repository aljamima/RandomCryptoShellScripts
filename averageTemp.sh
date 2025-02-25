#!/bin/bash

function getAverage {
	sensors | grep -oP 'temp1.*?\+\K[0-9.]+' |bc > /tmp/sensors.txt
	total=$(cat /tmp/sensors.txt |paste -sd+ |bc)
	count=$(cat /tmp/sensors.txt |wc -l)
	#echo "total $total"
	#echo "count $count"
	average=$(echo "scale=4; $total/$count" |bc -l)
	echo "$average"
}
gpuAverage=$(getAverage)
fanSpeed=$gpuAverage

if [ '$gpuAverage' > 75 ]; then fanSpeed=100; fi

./AMDFanController.sh -a all -s $fanSpeed


