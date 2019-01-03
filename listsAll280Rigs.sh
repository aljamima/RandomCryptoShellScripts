#!/bin/bash
for each in $(<ips); do
	if sshpass -prigx ssh -w 1 -o ConnectTimeout=10 -o stricthostkeychecking=no rigx@$each 'bash -s' <<< lspci |grep 280 >> 280List.txt ; then
			echo $each >> 280List.txt
	fi
done
