#!/bin/bash

###   NEED TO REFERENCE THESE VARS FROM AN ARRAY AND ALSO HAVE CURL REQUEST POKE AT MY ARRAY TO GRAB VALUES

declare -a f=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
echo "Which outlet you tryin to reboot?"
read input
let input--
re='^[0-9]+$'
if [[ $input =~ ^[0-9]+$ ]] && [[ $input -lt 25 ]]; then
	f[$input]=3
	fin="-u admn:admn 'http://10.11.1.1/Forms/outctrl_1' -H 'Host: 10.11.1.1' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: http://10.11.1.1/outctrl.html' -H 'Cookie: C5=0; C0=FF00FF00FF0000000000000000000000' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Authorization: Basic YWRtbjphZG1u' --data 'ControlAction%3F1=${f[0]}&ControlAction%3F2=${f[1]}&ControlAction%3F3=${f[2]}&ControlAction%3F4=${f[3]}&ControlAction%3F5=${f[4]}&ControlAction%3F6=${f[5]}&ControlAction%3F7=${f[6]}&ControlAction%3F8=${f[7]}&ControlAction%3F9=${f[8]}&ControlAction%3F10=${f[9]}&ControlAction%3F11=${f[10]}&ControlAction%3F12=${f[11]}&ControlAction%3F13=${f[12]}&ControlAction%3F14=${f[13]}&ControlAction%3F15=${f[14]}&ControlAction%3F16=${f[15]}&ControlAction%3F17=${f[16]}&ControlAction%3F18=${f[17]}&ControlAction%3F19=${f[18]}&ControlAction%3F20=${f[19]}&ControlAction%3F21=${f[20]}&ControlAction%3F22=${f[21]}&ControlAction%3F23=${f[22]}&ControlAction%3F24=${f[23]}' --compressed"
	eval $(echo curl $fin)
else
	echo "please input a number between 1 and 24"
fi

