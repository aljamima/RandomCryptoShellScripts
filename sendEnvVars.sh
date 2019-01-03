!#/bin/bash

for ip in $(<ipList.txt); do
	export SSHPASS=rigx
	sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null start_only_eth.bash rigx@$ip:/home/rigx/clay11.8/start_only_eth.bash
done
