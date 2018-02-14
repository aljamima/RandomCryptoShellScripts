#!/bin/sh
export SSHPASS='live'

if [ -f ipList.txt ] ; then
    rm ipList.txt
fi
if [ -f hashratesGenesis.txt ] ; then
    rm hashratesGenesis.txt
    touch hashratesGenesis.txt
fi
if [ -f moHashrates.txt ] ; then
    rm moHashrates.txt
    touch moHashrates.txt
fi
echo "Running Fping Scan To Gather Ips..."
fping -a -g 10.2.1.0 10.2.3.254 2>/dev/null > ipList.txt
for server in $(cat ipList.txt);
do
	lessStats=`echo -n "summary" | nc -w 1 $server 4028 2>/dev/null`
	apistats=`echo -n "summary+devs+pools+stats" | nc -w 1 $server 4028 2>/dev/null`
#	poolStats=`echo -n "pools" | nc $server 4028 2>/dev/null`
	MHASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "MHS av" | cut -d "=" -f2`     
	GHASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "GHS av" | cut -d "=" -f2`
#	THASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "THS av" | cut -d "=" -f2`
	POOLS=`echo $apistats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $lessStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
#	BLADECOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
#	FREQ=`echo $apistats | sed -e 's/,/\n/g' | grep "frequency" | cut -d "=" -f2`
#	FAN1=`echo $apistats | sed -e 's/,/\n/g' | grep "fan1=" | cut -d "=" -f2`
#	FAN3=`echo $apistats | sed -e 's/,/\n/g' | grep "fan3=" | cut -d "=" -f2`
#	HWPERCENT=`echo $apistats | sed -e 's/,/\n/g' | grep "Hardware%" | cut -d "=" -f2` #HW errors
	echo "$TYPE is at $server with, $MHASHRATE MH/s, $GHASHRATE GH/s and using pool: $POOLS mining at: $URL" >> hashratesGenesis.txt
#	sshpass -e ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null >> moHashrates.txt
#	sshpass -p 'root' ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
done
cat hashratesGenesis.txt
