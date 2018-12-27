#!/usr/bin/python3
import os
import requests
import json
import errno
from socket import error as socket_error

ip_add_file = open(r'./c2.txt','r')
output = './output.txt'
try:
    os.remove(output)
except OSError:
    pass

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
        data = r.json()
    except ValueError as ve:
        #print("bad request.json i think?")
        pass
    else:
        #print("I dont know what the problem is but there certainly IS a problem...")
        pass
    try:
        json_data = json.loads(r.text)
    except ValueError as ve:
        pass
        #print("we got an error, looks a like response WAS NOT valid json")
    my_dic = (json_data["hashrate"])
#    print("data = " + str(data))
#    print("json_data = " + str(json_data))
    print(host + "   Highest Hashrate: " + str(my_dic["highest"]), file=open("output.txt", "a"))
