#!/bin/bash
set -o functrace
clear
### echo -n "gpurestart|1" will restart gpu 1!!	## in DEVS: Msg=6 GPU(s)
function grab_Hashrates_Genesis {
	for server in $(cat genList.txt); do
	apistats=`echo -n "summary+gpucount" | nc -w 1 $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "MHS av" | cut -s -d "=" -f2`
	GPUCOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "Count" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	BLADECOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	mType="GPU_Miner"
	zeros="0"
	ninety="90"
	if [[ $(echo "$HASHRATE > $ninety" | bc -l) -eq 0 ]]; then
# min=$(echo 12.45 10.35 | awk '{if ($1 < $2) print $1; else print $2}')
		LOW="HASHRATE IS LOW"
	else
		LOW=""
	fi
	echo "$server is $mType at: $HASHRATE GH/s and $GPUCOUNT Gpus $LOW" >> hashratesGenesis.txt
	done
}
function grab_Hashrates_Mgt {
	for server in $(cat mgtList.txt); do
	apistats=`echo -n "stats" | nc -w 1 $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "GHS av" | cut -d "=" -f2`
	BLADECOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	mType="S9_Miner"
	gHASHRATE=$(bc -l <<< "$HASHRATE/1000")
	hashes=$(echo $gHASHRATE | head -c 4)
	if [[ "$BLADECOUNT" -lt "3" ]]; then
		LOW="LOW HASHRATE -- 1 OR MORE CARDS DOWN"
	else
		LOW=""
	fi
	echo "$server is $mType at: $hashes TH/s with $BLADECOUNT cards mining $LOW" >> hashratesMgt.txt
#### EVENTUALLY WE WILL MAKE THIS CONVERT GH INTO TH FOR READABILITY
	done
}
function line_Count {
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
rm -f ipList.txt 2>/dev/null
touch ipList.txt
rm -f moHashratesMgt.txt 2>/dev/null
touch moHashratesMgt.txt
rm -f moHashratesGen.txt 2>/dev/null
touch moHashratesGen.txt

echo "Running Fping Scan To Gather IPs"
#fping -a -g 192.168.0.11 192.168.0.254 2>/dev/null > ipList.txt       #Uncomment this line for a 192.* network
fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > ipList.txt           #Uncomment this line for a 10.* network 
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
		echo "$checks" >> mgtList.txt
#		grab_Hashrates_Mgt $checks
	elif [[ $DESCR = $SG* ]]; then
		echo "$checks" >> genList.txt
#		grab_Hashrates_Genesis $checks
	else
		echo "$checks is NOT a miner" >> notMiner.txt
	fi
done
grab_Hashrates_Mgt
grab_Hashrates_Genesis
echo ""
wc -l ipList.txt
wc -l mgtList.txt
wc -l genList.txt
wc -l notMiner.txt
echo "cat hashratesMgt.txt -OR- cat hashratesGenesis.txt "
