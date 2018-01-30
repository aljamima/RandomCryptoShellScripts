#!/bin/bash
if [ -f /tmp/cidr.txt ] ; then
    rm /tmp/cidr.txt
    touch /tmp/cidr.txt
fi

if [ -f ipList.txt ] ; then
    rm ipList.txt
    touch ipList.txt
fi

if [ -f results.csv ] ; then
    rm results.csv
    touch results.csv
fi
cidr="$(/home/chawn/ipFor.sh)"
echo "Running Fping Scan To Gather Ips..."

zmap --verbosity=4 -p 4028 -o results.csv $cidr
#zmap -B 10M -p 80 -n 10000 -o results.csv $cidr