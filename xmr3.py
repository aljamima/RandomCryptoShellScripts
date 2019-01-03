#!/usr/bin/python3
import os
import requests
import json
import errno
from socket import error as socket_error

ip_add_file = open(r'./c22.txt','r')
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
    #print("data = " + str(data))
    #print("")
    #print("json_data = " + str(json_data))
    #print("")
    if my_dic["highest"] > 2000:
        with open("output.txt", "at") as output_file:
            output_file.write(host + "   Highest Hashrate: " + str(my_dic["highest"]) + '\n')
    else:
        with open("error.txt", "at") as error_file:
            error_file.write(host + " Has Low Hashrate( " + str(my_dic["highest"]) + ") POSSIBLY NEEDS A REBOOT!" + '\n')

with open("output.txt", "r") as output_out:
    print(output_out.read(), end="")

print("Here Are The Rigs That May Have Issues: ")
with open("errors.txt", "r") as error_out:
    print(error_out.read(), end="")

