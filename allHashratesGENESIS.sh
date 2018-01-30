#!/bin/sh
export SSHPASS='live'

if [ -f ipList.txt ] ; then
    rm ipList.txt
fi
if [ -f hashratesGenesis.txt ] ; then
    rm hashratesGenesis.txt
    touch hashratesGenesis.txt
fi
echo "Running Fping Scan To Gather Ips..."
fping -a -g 10.2.0.0 10.2.3.254 2>/dev/null > ipList.txt

for server in $(cat ipList.txt);
do
	apistats=`echo -n "summary+devs" | nc $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "MHS av" | cut -d "=" -f2`
#	BLADECOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
#	FREQ=`echo $apistats | sed -e 's/,/\n/g' | grep "frequency" | cut -d "=" -f2`
#	FAN1=`echo $apistats | sed -e 's/,/\n/g' | grep "fan1=" | cut -d "=" -f2`
#	FAN3=`echo $apistats | sed -e 's/,/\n/g' | grep "fan3=" | cut -d "=" -f2`
#	HWPERCENT=`echo $apistats | sed -e 's/,/\n/g' | grep "Hardware%" | cut -d "=" -f2` #HW errors
	echo "$server is at: $HASHRATE TH/s" >> hashratesGenesis.txt
#	sshpass -e ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
#	sshpass -p 'root' ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
done
cat hashratesGenesis.txt
