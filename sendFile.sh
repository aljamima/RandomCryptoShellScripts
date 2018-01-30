#!/bin/bash
clear
if [ -f ipList.txt ] ; then
    rm ipList.txt
fi
export SSHPASS='rigx'
command -v sshpass >/dev/null 2>&1 || { echo >&2 "This needs sshpass, but it's not installed.  Aborting.  use \"sudo apt-get install sshpass\""; exit 1; }
read -e -p "Enter filename you wish to transfer, use tab for completion: " file
echo "Please Enter Container Number, Or Enter 'All' For All Containers And Hit Enter"
echo ""
read -p "Which Container Do You Want To Transfer This File To?" container

if [ "$container" == "all" ]; then
		echo "Making A List Of Miners In All Containers"
        fping -a -g 10.11.1.1 10.88.8.24 2>/dev/null >> ipList.txt
		
      elif [ "$container" == "1" ]; then
		echo "Making A List Of Miners In Container 1"
        fping -a -g 10.11.1.1 10.11.8.24 2>/dev/null >> ipList.txt

      elif [ "$container" == "2" ]; then
		echo "Making A List Of Miners In Container 2"
        fping -a -g 10.22.1.1 10.22.8.24 2>/dev/null >> ipList.txt

	  elif [ "$container" == "3" ]; then
		echo "Making A List Of Miners In Container 3"
        fping -a -g 10.33.1.1 10.33.8.24 2>/dev/null >> ipList.txt
	
	  elif [ "$container" == "4" ]; then
		echo "Making A List Of Miners In Container 4"
        fping -a -g 10.44.1.1 10.44.8.24 2>/dev/null >> ipList.txt
	
	  elif [ "$container" == "5" ]; then
		echo "Making A List Of Miners In Container 5"
        fping -a -g 10.55.1.1 10.55.8.24 2>/dev/null >> ipList.txt
    
	  elif [ "$container" == "6" ]; then
		echo "Making A List Of Miners In Container 6"
        fping -a -g 10.66.1.1 10.66.8.24 2>/dev/null >> ipList.txt
    
	  elif [ "$container" == "7" ]; then
		echo "Making A List Of Miners In Container 7"
        fping -a -g 10.77.1.1 10.77.8.24 2>/dev/null >> ipList.txt
    
	  elif [ "$container" == "8" ]; then
		echo "Making A List Of Miners In Container 8"
        fping -a -g 10.88.1.1 10.88.8.24 2>/dev/null >> ipList.txt
fi

while true; do
    echo "Do you wish to transfer this file to " $container 
	read -p "Y or N?" yn
    case $yn in
        [Yy]* ) 
        while read ip; do
        sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $file rigx@$ip:/home/rigx/ 
        done < ipList.txt;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no."; exit;;
    esac
done

