#!/bin/sh
export SSHPASS='admin'

if [ -f ipListS9.txt ] ; then
    rm ipListS9.txt
fi
if [ -f hashratesS9s.txt ] ; then
    rm hashratesS9s.txt
    touch hashratesS9s.txt
fi
echo "Running Fping Scan To Gather Ips..."
fping -a -g 10.2.0.0/22 2>/dev/null > ipListS9.txt

for server in $(cat ipListS9.txt);
do
	apistats=`echo -n "summary+devs" | nc $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "MHS av" | cut -d "=" -f2`
#	BLADECOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
#	FREQ=`echo $apistats | sed -e 's/,/\n/g' | grep "frequency" | cut -d "=" -f2`
#	FAN1=`echo $apistats | sed -e 's/,/\n/g' | grep "fan1=" | cut -d "=" -f2`
#	FAN3=`echo $apistats | sed -e 's/,/\n/g' | grep "fan3=" | cut -d "=" -f2`
#	HWPERCENT=`echo $apistats | sed -e 's/,/\n/g' | grep "Hardware%" | cut -d "=" -f2` #HW errors
	echo "$server is at: $HASHRATE TH/s" >> hashratesS9s.txt
#	sshpass -e ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
#	sshpass -p 'root' ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
done
cat hashratesS9s.txt
