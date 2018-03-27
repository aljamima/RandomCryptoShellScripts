#!/bin/bash
clear
function grab_Hashrates_Genesis {
	### echo -n "gpurestart|1" will restart gpu 1!!	## in DEVS: Msg=6 GPU(s)
	for server in $(cat genList.txt); do
	lessStats=`echo -n "summary" | nc -w 1 $server 4028 2>/dev/null`
	apiStats=`echo -n "summary+devs+pools+gpucount" | nc -w 1 $server 4028 2>/dev/null`
	gpuCounts=`echo -n "gpucount" | nc -w 1 $server 4028 2>/dev/null`
	poolStats=`echo -n "pools" | nc $server 4028 2>/dev/null`
	MHASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "MHS av" | cut -d "=" -f2`     
	GHASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "GHS av" | cut -d "=" -f2`
	THASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "THS av" | cut -d "=" -f2`
	GPUCOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "Count" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	BLADECOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	FREQ=`echo $apiStats | sed -e 's/,/\n/g' | grep "frequency" | cut -d "=" -f2`
	FAN1=`echo $apiStats | sed -e 's/,/\n/g' | grep "fan1=" | cut -d "=" -f2`
	FAN3=`echo $apiStats | sed -e 's/,/\n/g' | grep "fan3=" | cut -d "=" -f2`
	HWPERCENT=`echo $apiStats | sed -e 's/,/\n/g' | grep "Hardware%" | cut -d "=" -f2` #HW errors
	echo "$server is a $TYPE miner with, $MHASHRATE $GHASHRATE $THASHRATE and using pool: with $GPUCOUNT cards mining /n" >> hashratesGenesis.txt

#	sshpass -e ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null >> moHashrates.txt
#	sshpass -p 'root' ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
	done
}
function grab_Hashrates_Mgt {
	### echo -n "gpurestart|1" will restart gpu 1!!	## in DEVS: Msg=6 GPU(s)
	for server in $(cat mgtList.txt); do
	lessStats=`echo -n "summary" | nc -w 1 $server 4028 2>/dev/null`
	apiStats=`echo -n "summary+devs" | nc -w 1 $server 4028 2>/dev/null`
#	gpuCounts=`echo -n "gpucount" | nc -w 1 $server 4028 2>/dev/null`
	poolStats=`echo -n "pools" | nc $server 4028 2>/dev/null`
	MHASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "MHS av" | cut -d "=" -f2`     
	GHASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "GHS av" | cut -d "=" -f2`
	THASHRATE=`echo $apiStats | sed -e 's/,/\n/g' | grep "THS av" | cut -d "=" -f2`
	GPUCOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "Count" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	BLADECOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	FREQ=`echo $apiStats | sed -e 's/,/\n/g' | grep "frequency" | cut -d "=" -f2`
	FAN1=`echo $apiStats | sed -e 's/,/\n/g' | grep "fan1=" | cut -d "=" -f2`
	FAN3=`echo $apiStats | sed -e 's/,/\n/g' | grep "fan3=" | cut -d "=" -f2`
	HWPERCENT=`echo $apiStats | sed -e 's/,/\n/g' | grep "Hardware%" | cut -d "=" -f2` #HW errors
	echo -e "$server is a $TYPE miner with, $MHASHRATE $GHASHRATE $THASHRATE and using pool: with $GPUCOUNT cards mining /n" >> hashratesMGT.txt

#	sshpass -e ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null >> moHashrates.txt
#	sshpass -p 'root' ssh -o StrictHostKeyChecking=no root@$server "hostname; echo "$server is at: $HASHRATE TH/s" " 2>/dev/null
	done
}
DEFAULTWORKER="Mgtbtc2.QuincyMiner"
line_Count() {
	wc -l $1
}

rm -f mgtList.txt 2>/dev/null
touch mgtList.txt
rm -f hashratesMgt.txt 2>/dev/null
touch hashratesMgt.txt
rm -f hashratesGenesis.txt 2>/dev/null
touch hashratesGenesis.txt
rm -f notMiner.txt 2>/dev/null
touch notMiner.txt
rm -f genList.txt 2>/dev/null
touch genList.txt
rm -f defaultWorkers.txt 2>/dev/null
touch defaultWorkers.txt
rm -f errorList.txt 2>/dev/null
touch errorList.txt

echo "These Miners Didn't Take The New Config:" > errorList.txt
if [ -f ipList.txt ] ; then
 #   rm ipList.txt
    touch ipList.txt
fi
echo "Running Fping Scan To Gather IPs"
#fping -a -g 192.168.0.11 192.168.0.254 2>/dev/null > ipList.txt       #Uncomment this line for a 192.* network
#fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > ipList.txt           #Uncomment this line for a 10.* network 
echo "Done With Fping, Starting To Gather Worker Names"
for checks in $(cat ipList.txt);
do
	APISTATS=`echo -n "pools" | nc -w 1 $checks 4028`
	BM="bm"
	SG="sg"
	POOLS=`echo $APISTATS | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	DESCR=`echo $APISTATS | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	WORKER=`echo $APISTATS | sed -e 's/,/\n/g' | grep "User" | cut -d "=" -f2`
	if [[ $DESCR = $BM* ]]; then
		echo "$checks is using worker $WORKER" | tee -a mgtList.txt	
	elif [[ $DESCR = $SG* ]]; then
		
		echo "$checks" | tee -a genList.txt		
	else
		echo "$checks" | tee -a notMiner.txt
	fi
done
numIPS=`wc -l ipList.txt`
echo "found $numIPS in ipList.txt"
line_Count mgtList.txt
numMGT=`wc -l mgtList.txt`
echo -n "has $numMGT lines in the file" 
echo ""
line_Count genList.txt
echo -n "has lines in the file" 
echo ""
line_Count notMiner.txt
echo -n "has lines in the file" 

grab_Hashrates_Mgt
grab_Hashrates_Genesis
echo ""
echo "cat hashratesMGT.txt or cat hashratesGenesis.txt to see results"
