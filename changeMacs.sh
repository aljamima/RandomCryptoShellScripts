#!/bin/bash
#  Take IP adderss as input and remove that miner from the current mac table. Input new hostname and mac and then add that to current mac table then scp it and restart the dhcp server
#   CONF file takes following format:
#     host wrt45gl-etika  { hardware ethernet 00:21:29:a1:c3:a1; fixed-address 10.219.43.135; } # MSIE routeris WRT54GL
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
if [ -f /tmp/dhcpd.conf ] ; then
    rm /tmp/dhcpd.conf
fi
TODAY=`date +%Y-%m-%d.%H:%M:%S`
cp /etc/dhcp/dhcpd.conf /tmp/dhcpd.conf
function hostEntry () {
	echo -e "host $1 {\\tfixed-address $3 ; \\thardware ethernet $2 ; } ## $TODAY"
}
function removeOldIp {
	sed -i "/{.*$1.*}/d" /tmp/dhcpd.conf
}
echo "Which Ip you wanna change?"
read OLDIP

if [[ $OLDIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Valid Ip"
else
  echo "Invalid Ip"
  exit
fi
echo -e "Please Enter A Hostname For Your New Static Map:"
read NEWHOST
echo ""
echo -e "Enter The New Mac Address Exactly As It Is:  "
echo "ex. AA:BB:CC:DD:EE:00"
read NEWMAC
## validate MAC:
# capitalize it for faster regexp match
NEWMACLC=${NEWMAC^^}
if [ `echo $NEWMACLC | egrep "^([0-9A-F]{2}:){5}[0-9A-F]{2}$"` ]
then
    echo "Valid Mac"
else
    echo "Invalid Mac"
    exit
fi
echo "OK, We Are Going To Create An Entry For The Following Miner(s)"
echo
echo $NEWHOST $NEWMACLC $OLDIP
sleep 2
echo
echo "Is This Correct? Your About To Edit The Running DHCP Server, PLEASE DOUBLE-CHECK!" 
read -p "Y or N?" yn
case $yn in
	[Yy]* )
	#remove old entry
	removeOldIp $OLDIP
	## generate dhcp list:
	hostEntry $NEWHOST $NEWMACLC $OLDIP >> /tmp/dhcpd.conf
	cp /tmp/dhcpd.conf /etc/dhcp/dhcpd.conf
	sudo systemctl restart isc-dhcp-server
	systemctl status isc-dhcp-server
	;;
	[Nn]* ) 
	exit;;
	* ) echo "Please answer yes or no."; exit;;
esac



