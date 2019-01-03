#!/usr/bin/python3

import os
import requests
import json
import errno
from socket import error as socket_error

##### remove old output file
ip_add_file = open(r'./c5.txt','r')
output = './output.txt'
try:
    os.remove(output)
except OSError:
    pass
    print("Error Removing Output file. Maybe doesnt exist?")
##### iterate thru ipList

for host in ip_add_file:
    host = host.strip()
    url = 'http://' + host + ':4028/api.json'
    try:
        r = requests.get(url,timeout=3)
        r.raise_for_status()
    except requests.exceptions.HTTPError as errh:
        pass
        #print (host + "Http Error:",errh)
    except requests.exceptions.ConnectionError as errc:
        pass
        #print (host + "Error Connecting:",errc)
    except requests.exceptions.Timeout as errt:
        pass
        #print (host + "Timeout Error:",errt)
    except requests.exceptions.RequestException as err:
        pass
        #print (host + "OOps: Something Else",err)

    try:
        json_data = json.loads(r.text)
    except ValueError as ve:
        pass
        #print("we got an error, looks a like response WAS NOT valid json")
    else:
        print("some other uncaught exception ocurred Probably. Maybe. OK, IDK WTF is up....")
        pass
    my_dic = (json_data["hashrate"])
    print(host + "   Highest Hashrate: " + str(my_dic["highest"]), file=open("output.txt", "a"))

#response = requests.get('http://10.22.1.1:4028/api.json')
#data = response.json()
#print(data["hashrate"])
#json_data = json.loads(response.text)
#my_dic = (json_data["hashrate"])
#print(my_dic["highest"])



